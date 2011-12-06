package com.pintu.widgets{
	
	import com.greensock.TweenLite;
	import com.pintu.common.IconMenuItem;
	import com.pintu.config.InitParams;
	import com.pintu.events.PintuEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	
	/**
	 * HeaderBar在主应用中监听此事件，然后调用各模块的menuHandler
	 */ 
	public class BrowseMode extends CasaSprite{
		
		/**
		 * 缩略图模式，展现最近6个小时的图片
		 */
		public static const CATEGORY_GALLERY_TBMODE:String = "gallery_tb";
		/**
		 * 随机画廊模式
		 */ 
		public static const CATEGORY_RANDOM_TBMODE:String = "gallery_rd";
		/**
		 * 大图模式
		 */ 
		public static const CATEGORY_GALLERY_BPMODE:String = "gallery_bp";
		/**
		 * 热图模式
		 */ 
		public static const CATEGORY_HOT:String = "hot";
		/**
		 * 经典图片模式
		 */ 
		public static const CATEGORY_CLASSICAL:String = "classical";
		/**
		 * 最近的收藏模式
		 */ 
		public static const CATEGORY_FAVORED:String = "favored";
		
		
		private var thumbnailMenu:IconMenuItem;
		private var bigPicListMenu:IconMenuItem;
		private var hotPicsMenu:IconMenuItem;
		private var classicalMenu:IconMenuItem;
		private var favoredMenu:IconMenuItem;
		private var randomMenu:IconMenuItem;
		
		//保留一个最初的位置，好恢复
		private var _initX:Number = 0;
		private var _initY:Number = 0;
		
		private var menuItemHeight:Number = 28;
		private var menuGroupWidth:Number = 100;
		
		//鼠标还在触发该子菜单的主菜单上吗
		private var mouseInOwner:Boolean = false;		
		//鼠标在当前子菜单上吗
		private var isMouseOn:Boolean = false;
		//点击子菜单项，强迫收回
		private var forceCloseFlag:Boolean = false;
		
		private var frameCounter:int;
		private var idleDurationFrames:int = 24;
		
		public function BrowseMode(){
			
			//阴影层放在最底下
			var shadowLayer:CasaShape = new CasaShape();
			shadowLayer.graphics.lineStyle(1,0xC2CCD0, 1);
			shadowLayer.graphics.drawRect(0,0,menuGroupWidth,menuItemHeight*6);
			this.addChild(shadowLayer);	
			//加个阴影是不是好看点
			var shadow:DropShadowFilter = new DropShadowFilter(2,45,0x999999,0.6);
			shadowLayer.filters = [shadow];
			
			thumbnailMenu = new IconMenuItem("最新画廊");
			thumbnailMenu.addEventListener(MouseEvent.CLICK, thumbnailClickHandler);
			this.addChild(thumbnailMenu);
			
			bigPicListMenu = new IconMenuItem("大图列表");
			bigPicListMenu.y = menuItemHeight;
			bigPicListMenu.addEventListener(MouseEvent.CLICK, bigPicListClickHandler);
			this.addChild(bigPicListMenu);
			
			hotPicsMenu = new IconMenuItem("热点图片");
			hotPicsMenu.y = 2*menuItemHeight;
			hotPicsMenu.addEventListener(MouseEvent.CLICK, hotPicsClickHandler);
			this.addChild(hotPicsMenu);
			
			classicalMenu = new IconMenuItem("经典图片");
			classicalMenu.y = 3*menuItemHeight;
			classicalMenu.addEventListener(MouseEvent.CLICK, classicalClickHandler);
			this.addChild(classicalMenu);
			
			favoredMenu = new IconMenuItem("最近收藏");
			favoredMenu.y = 4*menuItemHeight;
			favoredMenu.addEventListener(MouseEvent.CLICK, favoredClickHandler);
			this.addChild(favoredMenu);
			
			randomMenu = new IconMenuItem("随便看看");
			randomMenu.y = 5*menuItemHeight;
			randomMenu.addEventListener(MouseEvent.CLICK, randomClickHandler);
			this.addChild(randomMenu);
			
			//监听鼠标动作
			this.addEventListener(MouseEvent.MOUSE_OVER, function():void{
				isMouseOn = true;
			});
			this.addEventListener(MouseEvent.MOUSE_OUT, function():void{
				isMouseOn = false;
			});
									
		}
		
		private function thumbnailClickHandler(evt:MouseEvent):void{
			//通知菜单收回
			forceCloseFlag = true;
			
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, CATEGORY_GALLERY_TBMODE);			
			this.dispatchEvent(typeChangeEvent);
		}
		private function bigPicListClickHandler(evt:MouseEvent):void{
			//通知菜单收回
			forceCloseFlag = true;
			
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, CATEGORY_GALLERY_BPMODE);			
			this.dispatchEvent(typeChangeEvent);
		}
		private function hotPicsClickHandler(evt:MouseEvent):void{
			//通知菜单收回
			forceCloseFlag = true;
			
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, CATEGORY_HOT);			
			this.dispatchEvent(typeChangeEvent);
		}
		private function classicalClickHandler(evt:MouseEvent):void{
			//通知菜单收回
			forceCloseFlag = true;
			
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, CATEGORY_CLASSICAL);			
			this.dispatchEvent(typeChangeEvent);
		}
		private function favoredClickHandler(evt:MouseEvent):void{
			//通知菜单收回
			forceCloseFlag = true;
			
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, CATEGORY_FAVORED);			
			this.dispatchEvent(typeChangeEvent);
		}
		private function randomClickHandler(evt:MouseEvent):void{
			//通知菜单收回
			forceCloseFlag = true;
			
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, CATEGORY_RANDOM_TBMODE);			
			this.dispatchEvent(typeChangeEvent);
		}
		
		/**
		 * HeaderBar 点击或者滑过主菜单文字时，调用该方法展开子菜单
		 * 0.3秒内滑出
		 */ 
		public function goDown():void{
			this.addEventListener(Event.ENTER_FRAME, idleCheckToClose);
			//滑到工具栏以下
			var targetY:int = InitParams.HEADER_HEIGHT+2;
			TweenLite.to(this, 0.3, {y : targetY});
			//这时鼠标还在主菜单上
			mouseInOwner = true;
		}
		
		override public function set x(v:Number):void{
			super.x = v;
			//只初始化一次
			if(!_initX) {
				_initX = v;				
			}
		}
		override public function set y(v:Number):void{
			super.y = v;
			//只初始化一次
			if(!_initY) {
				_initY = v;				
			}			
		}
		
		public function set inOwner(v:Boolean):void{
			this.mouseInOwner = v;
		}
		
		//0.3秒内滑入
		private function goBack():void{
			this.removeEventListener(Event.ENTER_FRAME, idleCheckToClose);			
			//回去初始位置
			TweenLite.to(this, 0.1, {y : _initY});
			//这时鼠标肯定不在主菜单上了
			mouseInOwner = false;
			//恢复初始状态开关
			frameCounter = 0;
			forceCloseFlag = false;
		}
		
		//如果24帧内，即0.6秒内鼠标还没落在菜单上，菜单自动收回
		//也发生在鼠标离开后0.5秒，菜单自动收回
		//如果鼠标还在父菜单上，不收回
		private function idleCheckToClose(evt:Event):void{
			if(forceCloseFlag){
				goBack();
				return;
			}			
			//离开菜单的空闲检测
			frameCounter++;			
			if(frameCounter>idleDurationFrames && !isMouseOn && !mouseInOwner){				
				goBack();				
			}
		}
		
	} //end of class
}