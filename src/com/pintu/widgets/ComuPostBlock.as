package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.common.IconButton;
	import com.pintu.common.LazyImage;
	import com.pintu.common.SimpleText;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.events.PintuEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
	import com.pintu.utils.PintuUtils;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	
	/**
	 * 社区贴条子，以及用户资料
	 * 
	 * 2012/05/14
	 */ 
	public class ComuPostBlock extends AbstractWidget{
		
		private var titleBackgroudColor:uint = StyleParams.PICDETAIL_BACKGROUND_THIRD;
		private var titleBackgroudHeight:int = InitParams.MAINMENUBAR_HEIGHT;

		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		private var userInfoContainer:CasaSprite;
		
		
		public function ComuPostBlock(model:IPintu){
			super(model);
			
			initDrawPoint();			
			
			drawBackGround();	
			drawTitleBar();
			//当前区域的遮罩
			addUserDetailsMask();
			
			userInfoContainer = new CasaSprite();
			//向下移动，给工具栏让位
			userInfoContainer.y = 4;			
			this.addChild(userInfoContainer);
		}
		
		override protected function safeAddModelListener():void{
			//获取个人信息			
			_clonedModel.getUserEstate(PintuImpl(_clonedModel).currentUser);
			
			PintuImpl(_clonedModel).addEventListener(ApiMethods.GETUSERESTATE, userDetailHandler);
		}
		
		override protected function safeClearModelListener():void{
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.GETUSERESTATE, userDetailHandler);
		}
		
		private function userDetailHandler(evt:Event):void{	
			
			if(evt is ResponseEvent){
				var jsUser:String = ResponseEvent(evt).data;
				//Logger.debug("user info: \n"+jsUser);				
				var objUser:Object = JSON.decode(jsUser);
				buildUserDetails(objUser);				
			}
			
			if(evt is PTErrorEvent){
				Logger.error("get user details error!!!");
			}
		}
		
		private function addUserDetailsMask():void{
			var mask:CasaShape = new CasaShape();
			mask.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			mask.graphics.drawRect(drawStartX,drawStartY,blockWidth+1,blockHeight+1);
			mask.graphics.endFill();
			this.addChild(mask);
			this.mask = mask;
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
			
			//贴条子
			var post:IconButton = new IconButton(InitParams.MAINMENUBAR_HEIGHT,InitParams.MAINMENUBAR_HEIGHT-buttonGap);
			post.iconPath = "assets/community/notes.png";
			post.addEventListener(MouseEvent.CLICK, postNote);
			post.x = drawStartX+buttonXoffset;
			post.y = drawStartY;			
			post.label = "贴条子";			
			post.setSkinStyle(upColors,overColors,downColors);
			post.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);	
			this.addChild(post);			
		}
		
		private function postNote(evt:MouseEvent):void{
			//HomPage监听该事件
			dispatchEvent(new PintuEvent(PintuEvent.POST_NOTE,null));
		}
		
		
		private function initDrawPoint():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			blockWidth = InitParams.USER_DETAIL_WIDTH;
			blockHeight = InitParams.USER_DETAIL_HEIGHT;
		}
		
		private function drawBackGround():void{
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);			
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);
			this.graphics.endFill();
			
		}
		
	} //end of class
}