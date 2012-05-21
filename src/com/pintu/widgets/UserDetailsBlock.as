package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.controller.GlobalController;
	import com.pintu.events.*;
	import com.pintu.utils.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	
	/**
	 * 显示在应用右上角的个人详情部分
	 */ 
	public class UserDetailsBlock extends AbstractWidget{		
		
		private var titleBackgroudColor:uint = StyleParams.PICDETAIL_BACKGROUND_THIRD;
		private var titleBackgroudHeight:int = InitParams.MAINMENUBAR_HEIGHT;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		private var userInfoContainer:CasaSprite;
		private var wealthContainer:CasaSprite;
		private var wealthSwitcher:CasaSprite;
		
		
		private var iconYOffset:int = 0;
		private var iconHGap:int = 66;
		

		
		public function UserDetailsBlock(model:IPintu){
			super(model);			
			
			initDrawPoint();			
			
			drawLoginBackGround();	
			drawTitleBar();
			
			//当前区域的遮罩
			addUserDetailsMask();
			
			userInfoContainer = new CasaSprite();
			//向下移动，给工具栏让位
			userInfoContainer.y = 4;			
			this.addChild(userInfoContainer);
			
			//财富对象容器，运行时添加
			wealthContainer = new CasaSprite();
			drawWealthBackground();
			
			wealthSwitcher = new CasaSprite();
			this.addChild(wealthSwitcher);
			drawTriangleSwitcher();
		}
		
		/**
		 * 更新用户资料后刷新显示
		 */ 
		public function refreshUserEstate():void{
			_clonedModel.getUserEstate(PintuImpl(_clonedModel).currentUser);
		}
		
		override protected function initModelListener(evt:Event):void{			
			super.initModelListener(evt);
			
			//获取个人信息			
			_clonedModel.getUserEstate(PintuImpl(_clonedModel).currentUser);
			
			PintuImpl(_clonedModel).addEventListener(ApiMethods.GETUSERESTATE, userDetailHandler);
		}

		override protected function cleanUpModelListener(evt:Event):void{
			//先移除事件
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.GETUSERESTATE, userDetailHandler);
			//后清空模型
			super.cleanUpModelListener(evt);
		}
		
		private function drawTitleBar():void{
			this.graphics.lineStyle(1, titleBackgroudColor);
			this.graphics.beginFill(titleBackgroudColor, 1);
			this.graphics.drawRect(drawStartX+1,drawStartY+1,InitParams.ANDI_ASSETS_WIDTH-2,titleBackgroudHeight);
			this.graphics.endFill();
			
			//icon button colors
			var upColors:Array = [0xFFFFFF,0xFFFFFF];
			var overColors:Array = [StyleParams.ICONMENU_MOUSEOVER_TOP,
				StyleParams.ICONMENU_MOUSEOVER_BOTTOM];
			var downColors:Array = [StyleParams.ICONMENU_SELECTED_TOP,
				StyleParams.ICONMENU_SELECTED_BOTTOM];
			
			var buttonGap:Number = 2;
			var buttonXoffset:Number = 4;
			
			//上传图片
			var upload:IconButton = new IconButton(InitParams.MAINMENUBAR_HEIGHT,InitParams.MAINMENUBAR_HEIGHT-buttonGap);
			upload.iconPath = "assets/post_pic_l.png";
			upload.addEventListener(MouseEvent.CLICK, postImage);
			upload.x = drawStartX+buttonXoffset;
			upload.y = drawStartY+iconYOffset;			
			upload.label = "贴图";			
			upload.setSkinStyle(upColors,overColors,downColors);
			upload.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);	
			this.addChild(upload);
			
			//发消息
			var writeMsg:IconButton = new IconButton(InitParams.MAINMENUBAR_HEIGHT,InitParams.MAINMENUBAR_HEIGHT-buttonGap);
			writeMsg.iconPath = "assets/write_msg_l.png";
			writeMsg.addEventListener(MouseEvent.CLICK, postMsg);
			writeMsg.x = drawStartX+iconHGap+buttonXoffset;
			writeMsg.y = drawStartY+iconYOffset;			
			writeMsg.label = "写信";			
			writeMsg.setSkinStyle(upColors,overColors,downColors);
			writeMsg.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);			
			this.addChild(writeMsg);
			
			//修改资料
			var updateUser:IconButton = new IconButton(InitParams.MAINMENUBAR_HEIGHT,InitParams.MAINMENUBAR_HEIGHT-buttonGap);
			updateUser.iconPath = "assets/update_user_l.png";
			updateUser.addEventListener(MouseEvent.CLICK, postUserInfo);
			updateUser.x = drawStartX+2*iconHGap+buttonXoffset;
			updateUser.y = drawStartY+iconYOffset;			
			updateUser.label = "修改资料";			
			updateUser.setSkinStyle(upColors,overColors,downColors);
			updateUser.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);			
			this.addChild(updateUser);
			
		}
		
		private function postImage(evt:MouseEvent):void{
			//HomPage监听该事件
			dispatchEvent(new PintuEvent(PintuEvent.UPLOAD_IMAGE,null));
		}
		private function postMsg(evt:MouseEvent):void{
			//HomPage监听该事件
			dispatchEvent(new PintuEvent(PintuEvent.POST_MSG,null));
		}
		private function postUserInfo(evt:MouseEvent):void{
			//HomPage监听该事件
			dispatchEvent(new PintuEvent(PintuEvent.POST_USERINFO,null));
		}
		
		
		private function userDetailHandler(evt:Event):void{	
			
			if(evt is ResponseEvent){
				var jsUser:String = ResponseEvent(evt).data;
//				Logger.debug("user info: \n"+jsUser);				
				var objUser:Object = JSON.decode(jsUser);
				buildUserDetails(objUser);				
			}
			
			if(evt is PTErrorEvent){
				Logger.error("get user details error!!!");
			}
		}
			
		private function buildUserDetails(userObj:Object):void{
			var startX:Number = drawStartX;
			var startY:Number = drawStartY+titleBackgroudHeight;
			var xOffset:Number = 4;
			var yOffset:Number = 5;
			
			var dark:uint = StyleParams.BROWN_GRAY_COLOR;
			var white:uint = StyleParams.WHITE_TEXT_COLOR;
			var normalTXTSize:int = 12;
			var bigTXTSize:int = 16;
			var avatarToTextGap:Number = 4;
			var textHGap:Number = 10;			
			
			//修改用户资料后重新绘制
			if(userInfoContainer.numChildren)
				userInfoContainer.removeChildren();
						
			
			//头像
			var avatarUrl:String = _clonedModel.composeImgUrlByPath(userObj["avatar"]);
			var avatarImg:LazyImage = new LazyImage(avatarUrl);
			avatarImg.x = startX;
			avatarImg.y = startY;	
			avatarImg.maxSize = 64;
			userInfoContainer.addChild(avatarImg);
			
			//用户名
			var accountStr:String = PintuUtils.getShowUserName(userObj["account"]);
			var userNameStr:String = userObj["nickName"];
			if(userNameStr==null || userNameStr=="")
				userNameStr = accountStr;
			var userNameTF:SimpleText = new SimpleText(userNameStr,dark,bigTXTSize,true);
			userNameTF.x = startX+xOffset;
			userNameTF.y = startY+yOffset+avatarImg.maxSize;
			userInfoContainer.addChild(userNameTF);
			
			//记下用户昵称，用于修改
			GlobalController.account = userNameStr;
			
			//级别，与用户名左对齐，在用户名的下面
			var levelStr:String = "级别 "+userObj["level"];
			var levelTF:SimpleText = new SimpleText(levelStr, dark, normalTXTSize);
			levelTF.x =startX+avatarImg.maxSize+avatarToTextGap;
			levelTF.y = startY+yOffset;
			userInfoContainer.addChild(levelTF);
			
			//积分，与用户名左对齐，在级别的后面
			var scoreStr:String = "积分 "+userObj["score"];
			var scoreTF:SimpleText = new SimpleText(scoreStr, dark, normalTXTSize);
			scoreTF.x = levelTF.x+levelTF.textWidth+textHGap;
			scoreTF.y = levelTF.y;
			userInfoContainer.addChild(scoreTF);
			
			//贴图数
			var postNumStr:String = "贴图数 "+userObj["tpicNum"];
			var postNumTF:SimpleText = new SimpleText(postNumStr, dark, normalTXTSize);
			postNumTF.x = levelTF.x;
			postNumTF.y = startY+40;
			userInfoContainer.addChild(postNumTF);
			
			//评论数
			var cmntNumStr:String = "评论数 "+userObj["storyNum"];
			var cmntNumTF:SimpleText = new SimpleText(cmntNumStr, dark, normalTXTSize);
			cmntNumTF.x = postNumTF.x+postNumTF.textWidth+textHGap;
			cmntNumTF.y = startY+40;
			userInfoContainer.addChild(cmntNumTF);
			
			var shellsY:Number = startY+avatarImg.maxSize+userNameTF.textHeight+4*yOffset;
			
			
			//准备财富容器
			userInfoContainer.addChild(wealthContainer);
			
			//海贝数目
			var seaShell:LazyImage = new LazyImage("assets/shell_sea_24.png");
			seaShell.x = startX+xOffset;
			seaShell.y = shellsY;
			wealthContainer.addChild(seaShell);
			var seaShellNum:SimpleText = new SimpleText(userObj["seaShell"],white,normalTXTSize);
			seaShellNum.x = seaShell.x+24+xOffset;
			seaShellNum.y = shellsY+yOffset;
			wealthContainer.addChild(seaShellNum);
			
			//铜贝数目			
			var copperShell:LazyImage = new LazyImage("assets/shell_copper_24.png");
			copperShell.x = seaShellNum.x+2*textHGap;
			copperShell.y = shellsY;
			wealthContainer.addChild(copperShell);
			var copperShellNum:SimpleText = new SimpleText(userObj["copperShell"],white,normalTXTSize);
			copperShellNum.x = copperShell.x+24+xOffset;
			copperShellNum.y = shellsY+yOffset;
			wealthContainer.addChild(copperShellNum);
			
			
			//银贝数目
			var silverShell:LazyImage = new LazyImage("assets/shell_silver_24.png");
			silverShell.x = copperShellNum.x+2*textHGap;
			silverShell.y = shellsY;
			wealthContainer.addChild(silverShell);
			var silverShellNum:SimpleText = new SimpleText(userObj["silverShell"],white,normalTXTSize);
			silverShellNum.x = silverShell.x+24+xOffset;
			silverShellNum.y = shellsY+yOffset;
			wealthContainer.addChild(silverShellNum);			
			
			//金贝数目
			var goldShell:LazyImage = new LazyImage("assets/shell_gold_24.png");
			goldShell.x = silverShellNum.x+2*textHGap;
			goldShell.y = shellsY;
			wealthContainer.addChild(goldShell);
			var goldShellNum:SimpleText = new SimpleText(userObj["goldShell"],white,normalTXTSize);
			goldShellNum.x = goldShell.x+24+xOffset;
			goldShellNum.y = shellsY+yOffset;
			wealthContainer.addChild(goldShellNum);
			
		}
		
		
		private function drawLoginBackGround():void{
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);			
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);
			this.graphics.endFill();
						
		}
		
		private function drawTriangleSwitcher():void{
			//初始化颜色
			renderTriangleByColor(StyleParams.DEFAULT_BORDER_COLOR);
			
			wealthSwitcher.addEventListener(MouseEvent.MOUSE_OVER, function():void{
				renderTriangleByColor(StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN);
			});
			wealthSwitcher.addEventListener(MouseEvent.MOUSE_OUT, function():void{
				renderTriangleByColor(StyleParams.DEFAULT_BORDER_COLOR);
			});
			wealthSwitcher.addEventListener(MouseEvent.MOUSE_DOWN, function():void{
				renderTriangleByColor(StyleParams.HEADER_MENU_SELECTED);
			});
			wealthSwitcher.addEventListener(MouseEvent.CLICK, function():void{
				slideUserWealth();
			});			
			
		}
		
		private function drawWealthBackground():void{
			wealthContainer.graphics.clear();
			wealthContainer.graphics.beginFill(StyleParams.DEFAULT_BLACK_COLOR,0.8);
			wealthContainer.graphics.drawRect(drawStartX, drawStartY+blockHeight-3, blockWidth, 30);
			wealthContainer.graphics.endFill();
		}
		
		private function slideUserWealth():void{
			//已经弹出了，就不再动画了
			if(wealthContainer.y<0) return;
			
			var myTimeline:TimelineLite = new TimelineLite();
			//一闪
			myTimeline.append(new TweenLite(wealthContainer, 0.4, {y : -30}));
			//停留2秒回去
			myTimeline.append(new TweenLite(wealthContainer, 0.4, {y:0}), 2);
		}
		
		private function renderTriangleByColor(color:uint):void{
			var triangleLength:Number = 16;
			wealthSwitcher.graphics.clear();
			//移动到底边向左顶点
			wealthSwitcher.graphics.moveTo(drawStartX+blockWidth-triangleLength,drawStartY+blockHeight+1);
			//开始填充
			wealthSwitcher.graphics.beginFill(color);
			//绘制到右边上顶点
			wealthSwitcher.graphics.lineTo(drawStartX+blockWidth,drawStartY+blockHeight-triangleLength);
			//绘制到区域右下角
			wealthSwitcher.graphics.lineTo(drawStartX+blockWidth,drawStartY+blockHeight+1);
			//回到起点
			wealthSwitcher.graphics.lineTo(drawStartX+blockWidth-triangleLength,drawStartY+blockHeight+1);
			//结束填充
			wealthSwitcher.graphics.endFill();
		}
		
		private function addUserDetailsMask():void{
			var mask:CasaShape = new CasaShape();
			mask.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			mask.graphics.drawRect(drawStartX,drawStartY,blockWidth+1,blockHeight+1);
			mask.graphics.endFill();
			this.addChild(mask);
			this.mask = mask;
		}
		
		private function initDrawPoint():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			blockWidth = InitParams.USER_DETAIL_WIDTH;
			blockHeight = InitParams.USER_DETAIL_HEIGHT;
		}
		
		
		
	} //end of class
}