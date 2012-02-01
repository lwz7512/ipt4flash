package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.events.*;
	import com.pintu.utils.Logger;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import org.casalib.display.CasaSprite;

	/**
	 * 类似于微博中的“我的首页”下面的内容
	 * 就是把主工具栏中的“俺滴”菜单项拆到右边栏
	 * 
	 * 主要处理消息的获取，图片的显示和获取交由主显示区处理
	 */ 
	public class AndiBlock extends AbstractWidget{
		
		/**
		 * 我的贴图
		 */
		public static const CATEGORY_GALLERY_MINE:String = "gallery_myworks";
		/**
		 * 我的收藏
		 */
		public static const CATEGORY_GALLERY_MYFAV:String = "gallery_myfavors";
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var titleBackgroudColor:uint = StyleParams.COLUMN_TITLE_BACKGROUND;
		private var titleBackgroudHeight:int = InitParams.ANDI_TITLE_HEIGHT;
		
		//菜单使用颜色
		private var upColors:Array;
		private var overColors:Array;
		private var downColors:Array;		
		
		//在它的文字位置旁边，放消息数目提示
		private var myMsgs:TextMenu;
		private var msgNum:CircleNumText;
		
		//取回的消息存起来
		private var msgList:Array;
		
		
		//我的收藏菜单
		private var myFavorites:TextMenu;
		//有新收藏的提示+1
		private var newlyMarked:CircleNumText;
		
		
		
		public function AndiBlock(model:IPintu){
			super(model);
			
			drawLoginBackGround();
			drawTitleBar();
			drawMenus();
		}
		
		//派发事件后，Homepage里来取这个数据
		public function get msgs():Array{
			return msgList;
		}
		
		//由主模块调用，来显示有新收藏了的动画
		public function showNewMarked():void{
			var myTimeline:TimelineLite = new TimelineLite();
			//一闪
			myTimeline.append(new TweenLite(newlyMarked, 0.6, {alpha:1}));
			myTimeline.append(new TweenLite(newlyMarked, 0.6, {alpha:0}));
			//一闪
			myTimeline.append(new TweenLite(newlyMarked, 0.6, {alpha:1}));
			myTimeline.append(new TweenLite(newlyMarked, 0.6, {alpha:0}));
			//一闪
			myTimeline.append(new TweenLite(newlyMarked, 0.6, {alpha:1}));
			myTimeline.append(new TweenLite(newlyMarked, 0.6, {alpha:0}));
		}
		
		
		override protected function initModelListener(evt:Event):void{			
			this.removeEventListener(Event.ADDED_TO_STAGE,initModelListener);
			
			PintuImpl(_clonedModel).addEventListener(ApiMethods.GETUSERMSG, userMsgFetched);
			PintuImpl(_clonedModel).addEventListener(ApiMethods.CHANGEMSGSTATE, userMsgReaded);
						
			//查询个人的消息，这里是得到消息并显示消息数目
			_clonedModel.getUserMsgs();
			
		}
		
		override protected function cleanUpModelListener(evt:Event):void{
			msgList = null;
			//先移除事件
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.GETUSERMSG, userMsgFetched);
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.CHANGEMSGSTATE, userMsgReaded);
			//后清空模型
			super.cleanUpModelListener(evt);
		}
		
		private function userMsgReaded(evt:Event):void{
			if(evt is PTStatusEvent){
				this.removeChild(msgNum);
			}
			if(evt is PTErrorEvent){
				Logger.error("update msgs readed error!!!");
			}
		}		
		
		private function userMsgFetched(evt:Event):void{
			if(evt is ResponseEvent){
				var msgs:String = ResponseEvent(evt).data;
				if(!msgs) return;
				
				//先存起来，点击链接才展示
				msgList = JSON.decode(msgs);
				if(msgList.length==0) return;
				
				//显示带圈数目在消息文字后面
				Logger.debug("user msgs: \n"+msgs);
				msgNum = new CircleNumText(msgList.length.toString());
				msgNum.x = myMsgs.x+myMsgs.width - 20;
				msgNum.y = myMsgs.y+3;
				this.addChild(msgNum);
				
			}
			
			if(evt is PTErrorEvent){
				Logger.error("get user msgs error!!!");
			}
		}		
		
		private function drawTitleBar():void{
			this.graphics.lineStyle(1, titleBackgroudColor);
			this.graphics.beginFill(titleBackgroudColor, 1);
			this.graphics.drawRect(drawStartX,drawStartY,InitParams.ANDI_ASSETS_WIDTH,titleBackgroudHeight);
			this.graphics.endFill();
			
			var title:SimpleText = new SimpleText("我的首页", 0xFFFFFF, 13);
			title.x = drawStartX+(InitParams.ANDI_ASSETS_WIDTH-title.textWidth)/2;
			title.y = drawStartY+4;
			this.addChild(title);
		}
		
		private function drawMenus():void{			
			//主菜单颜色设置
			upColors = [StyleParams.PICDETAIL_BACKGROUND_THIRD,
				StyleParams.PICDETAIL_BACKGROUND_THIRD];
			overColors = [StyleParams.HEADER_MENU_MOUSEOVER,
				StyleParams.HEADER_MENU_MOUSEOVER];
			downColors = [StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN,
				StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN];
			
			var menuVGap:Number = 2;
			var menuStartX:Number = drawStartX+1;
			var menuStartY:Number = drawStartY+titleBackgroudHeight+menuVGap;
			var menuWidth:Number = InitParams.ANDI_ASSETS_WIDTH-1;
			
			//我的贴图
			var myPics:TextMenu = new TextMenu(menuWidth, titleBackgroudHeight);
			myPics.setSkinStyle(upColors,overColors,downColors);
			myPics.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				0xFFFFFF);
			myPics.upAlpha = 1;
			myPics.label = "已发作品";
			myPics.x = menuStartX;
			myPics.y = menuStartY;
			myPics.addEventListener(MouseEvent.CLICK, getMyPics);
			this.addChild(myPics);
			
			//我的收藏
			myFavorites = new TextMenu(menuWidth, titleBackgroudHeight);
			myFavorites.setSkinStyle(upColors,overColors,downColors);
			myFavorites.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				0xFFFFFF);
			myFavorites.upAlpha = 1;
			myFavorites.label = "收藏集";
			myFavorites.x = menuStartX;
			myFavorites.y = menuStartY+titleBackgroudHeight+menuVGap;
			myFavorites.addEventListener(MouseEvent.CLICK, getMyFavors);
			this.addChild(myFavorites);
			//收藏提示
			newlyMarked = new CircleNumText("+1");
			newlyMarked.x = myFavorites.x+myFavorites.width - 20;
			newlyMarked.y = myFavorites.y+3;
			//先不显示
			newlyMarked.alpha = 0;
			//加个阴影
			var shadow:DropShadowFilter = new DropShadowFilter(4,45,0x666666,0.8);
			newlyMarked.filters = [shadow];
			this.addChild(newlyMarked);
			
			//我的消息
			myMsgs = new TextMenu(menuWidth, titleBackgroudHeight);
			myMsgs.setSkinStyle(upColors,overColors,downColors);
			myMsgs.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				0xFFFFFF);
			myMsgs.upAlpha = 1;
			myMsgs.label = "最新消息";
			myMsgs.x = menuStartX;
			myMsgs.y = menuStartY+2*titleBackgroudHeight+2*menuVGap;
			myMsgs.addEventListener(MouseEvent.CLICK, showMsgList);
			this.addChild(myMsgs);
						
		}
		
		//HomePage里监听，要和主显示区交互，完成图片显示
		//关于图片的显示和获取，交由主显示区处理
		private function getMyPics(evt:MouseEvent):void{
			this.dispatchEvent(new PintuEvent(PintuEvent.GET_MYPICS,null));
		}
		//HomePage里监听，要和主显示区交互，完成图片显示
		//关于图片的显示和获取，交由主显示区处理
		private function getMyFavors(evt:MouseEvent):void{
			this.dispatchEvent(new PintuEvent(PintuEvent.GET_MYFAVS,null));
		}
		
		//HomePage里监听，要和主显示区交互，完成消息内容显示
		private function showMsgList(evt:MouseEvent):void{
			//没有消息不派发事件
			if(msgList && msgList.length>0){
				//通知主显示区绘制消息列表
				var showMsg:PintuEvent = new PintuEvent(PintuEvent.SHOW_MSGS,null);
				this.dispatchEvent(showMsg);
				
				//通知后台，消息已读
				msgReaded();
			}
		}
		
		/**
		 * 只要打开了消息，就认为是已读了，不再取了
		 */ 
		private function msgReaded():void{
			var msgIds:String = "";
			for each(var msg:Object in msgList){
				msgIds += (msg.id+",");
			}
			//通知后台，消息已读
			_clonedModel.markMsgReaded(msgIds);
		}
		
		private function drawLoginBackGround():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT
				+InitParams.TOP_BOTTOM_GAP
				+InitParams.USER_DETAIL_HEIGHT
				+InitParams.DEFAULT_GAP;
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);			
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,
				InitParams.ANDI_ASSETS_WIDTH,InitParams.ANDI_ASSETS_HEIGHT);
			this.graphics.endFill();
		}
		
		
	}//end of class
}