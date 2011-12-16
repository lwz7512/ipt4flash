package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.events.*;
	import com.pintu.utils.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 显示在应用右上角的个人详情部分
	 */ 
	public class UserDetailsBlock extends AbstractWidget{		
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		private var userDetailFetched:Boolean;
			
		
		private var titleBackgroudColor:uint = StyleParams.ICONMENU_MOUSEOVER_TOP;
		private var titleBackgroudHeight:int = InitParams.ANDI_TITLE_HEIGHT;
		private var iconYOffset:int = 0;
		private var iconHGap:int = 58;
		
		public function UserDetailsBlock(model:IPintu){
			super(model);			
			
			initDrawPoint();			
			
			drawLoginBackGround();	
			drawTitleBar();
						
		}
		
		override protected function initModelListener(evt:Event):void{			
//			Logger.debug("to getUserEstate...");
			
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
			this.graphics.beginFill(titleBackgroudColor, 1);
			this.graphics.drawRect(drawStartX,drawStartY,InitParams.ANDI_ASSETS_WIDTH,titleBackgroudHeight);
			this.graphics.endFill();
			
			var overColors:Array = [StyleParams.HEADER_MENU_MOUSEOVER,StyleParams.HEADER_MENU_MOUSEOVER];
			var downColors:Array = [StyleParams.DEFAULT_DARK_GREEN,StyleParams.DEFAULT_DARK_GREEN];
			
			//上传图片
			var upload:IconButton = new IconButton(titleBackgroudHeight,titleBackgroudHeight);
			upload.iconPath = "assets/post_pic.png";
			upload.addEventListener(MouseEvent.CLICK, postImage);
			upload.x = drawStartX;
			upload.y = drawStartY+iconYOffset;
			upload.textOnRight = true;
			upload.label = "贴图";
			
			upload.setSkinStyle(null,overColors,downColors);			
			this.addChild(upload);
			
			//发消息
			var writeMsg:IconButton = new IconButton(titleBackgroudHeight,titleBackgroudHeight);
			writeMsg.iconPath = "assets/write_msg.png";
			writeMsg.addEventListener(MouseEvent.CLICK, postMsg);
			writeMsg.x = drawStartX+iconHGap;
			writeMsg.y = drawStartY+iconYOffset;
			writeMsg.textOnRight = true;
			writeMsg.label = "写信";			
			writeMsg.setSkinStyle(null,overColors,downColors);			
			this.addChild(writeMsg);
			
			//修改资料
			var updateUser:IconButton = new IconButton(titleBackgroudHeight,titleBackgroudHeight);
			updateUser.iconPath = "assets/update_user.png";
			updateUser.addEventListener(MouseEvent.CLICK, postUserInfo);
			updateUser.x = drawStartX+2*iconHGap;
			updateUser.y = drawStartY+iconYOffset;
			updateUser.textOnRight = true;
			updateUser.label = "修改资料";			
			updateUser.setSkinStyle(null,overColors,downColors);			
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
			var yOffset:Number = 4;
			
			var dark:uint = StyleParams.BROWN_GRAY_COLOR;
			var normalTXTSize:int = 12;
			var bigTXTSize:int = 16;
			var avatarToTextGap:Number = 4;
			var textHGap:Number = 10;			
					
			
			//头像
			var avatarUrl:String = _clonedModel.composeImgUrlByPath(userObj["avatar"]);
			var avatarImg:SimpleImage = new SimpleImage(avatarUrl);
			avatarImg.x = startX;
			avatarImg.y = startY;	
			avatarImg.maxSize = 64;
			this.addChild(avatarImg);
			
			//用户名
			var userNameStr:String = PintuUtils.getShowUserName(userObj["account"]);
			var userNameTF:SimpleText = new SimpleText(userNameStr,dark,bigTXTSize,true);
			userNameTF.x = startX+xOffset;
			userNameTF.y = startY+yOffset+avatarImg.maxSize;
			this.addChild(userNameTF);
			
			//级别，与用户名左对齐，在用户名的下面
			var levelStr:String = "级别 "+userObj["level"];
			var levelTF:SimpleText = new SimpleText(levelStr, dark, normalTXTSize);
			levelTF.x =startX+avatarImg.maxSize+avatarToTextGap;
			levelTF.y = startY+yOffset;
			this.addChild(levelTF);
			
			//积分，与用户名左对齐，在级别的后面
			var scoreStr:String = "积分 "+userObj["score"];
			var scoreTF:SimpleText = new SimpleText(scoreStr, dark, normalTXTSize);
			scoreTF.x = levelTF.x+levelTF.textWidth+textHGap;
			scoreTF.y = levelTF.y;
			this.addChild(scoreTF);
			
			//贴图数
			var postNumStr:String = "贴图数 "+userObj["tpicNum"];
			var postNumTF:SimpleText = new SimpleText(postNumStr, dark, normalTXTSize);
			postNumTF.x = levelTF.x;
			postNumTF.y = startY+40;
			this.addChild(postNumTF);
			
			//评论数
			var cmntNumStr:String = "评论数 "+userObj["storyNum"];
			var cmntNumTF:SimpleText = new SimpleText(cmntNumStr, dark, normalTXTSize);
			cmntNumTF.x = postNumTF.x+postNumTF.textWidth+textHGap;
			cmntNumTF.y = startY+40;
			this.addChild(cmntNumTF);
			
			
			var shellsY:Number = startY+avatarImg.maxSize+userNameTF.textHeight+4*yOffset;
			
			//海贝数目
			var seaShell:SimpleImage = new SimpleImage("assets/shell_sea_24.png");
			seaShell.x = startX+xOffset;
			seaShell.y = shellsY;
			this.addChild(seaShell);
			var seaShellNum:SimpleText = new SimpleText(userObj["seaShell"],dark,normalTXTSize);
			seaShellNum.x = seaShell.x+24+xOffset;
			seaShellNum.y = shellsY+yOffset;
			this.addChild(seaShellNum);
			
			//铜贝数目			
			var copperShell:SimpleImage = new SimpleImage("assets/shell_copper_24.png");
			copperShell.x = seaShellNum.x+2*textHGap;
			copperShell.y = shellsY;
			this.addChild(copperShell);
			var copperShellNum:SimpleText = new SimpleText(userObj["copperShell"],dark,normalTXTSize);
			copperShellNum.x = copperShell.x+24+xOffset;
			copperShellNum.y = shellsY+yOffset;
			this.addChild(copperShellNum);
			
			
			//银贝数目
			var silverShell:SimpleImage = new SimpleImage("assets/shell_silver_24.png");
			silverShell.x = copperShellNum.x+2*textHGap;
			silverShell.y = shellsY;
			this.addChild(silverShell);
			var silverShellNum:SimpleText = new SimpleText(userObj["silverShell"],dark,normalTXTSize);
			silverShellNum.x = silverShell.x+24+xOffset;
			silverShellNum.y = shellsY+yOffset;
			this.addChild(silverShellNum);			
			
			//金贝数目
			var goldShell:SimpleImage = new SimpleImage("assets/shell_gold_24.png");
			goldShell.x = silverShellNum.x+2*textHGap;
			goldShell.y = shellsY;
			this.addChild(goldShell);
			var goldShellNum:SimpleText = new SimpleText(userObj["goldShell"],dark,normalTXTSize);
			goldShellNum.x = goldShell.x+24+xOffset;
			goldShellNum.y = shellsY+yOffset;
			this.addChild(goldShellNum);
			
		}
		
		
		private function drawLoginBackGround():void{
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);			
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);
			this.graphics.endFill();
			
			
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