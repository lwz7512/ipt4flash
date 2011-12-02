package com.pintu.widgets{
	
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	import com.pintu.common.IconMenuItem;
	
	public class BrowseMode extends CasaSprite{
		
		/**
		 * 缩略图模式
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
		
		private var frameCounter:int;
		private var idleDurationFrames:int = 24;
		
		public function BrowseMode(){
			
			//加个阴影是不是好看点
			var shadowLayer:CasaShape = new CasaShape();
			shadowLayer.graphics.lineStyle(1,0xC2CCD0, 1);
			shadowLayer.graphics.drawRect(0,0,menuGroupWidth,menuItemHeight*6);
			this.addChild(shadowLayer);
			
			var shadow:DropShadowFilter = new DropShadowFilter(2,45,0x999999,0.6);
			shadowLayer.filters = [shadow];
			
			thumbnailMenu = new IconMenuItem("缩略图");
			this.addChild(thumbnailMenu);
			
			bigPicListMenu = new IconMenuItem("大图列表");
			bigPicListMenu.y = menuItemHeight;
			this.addChild(bigPicListMenu);
			
			hotPicsMenu = new IconMenuItem("热点图片");
			hotPicsMenu.y = 2*menuItemHeight;
			this.addChild(hotPicsMenu);
			
			classicalMenu = new IconMenuItem("经典图片");
			classicalMenu.y = 3*menuItemHeight;
			this.addChild(classicalMenu);
			
			favoredMenu = new IconMenuItem("最近收藏");
			favoredMenu.y = 4*menuItemHeight;
			this.addChild(favoredMenu);
			
			randomMenu = new IconMenuItem("随便看看");
			randomMenu.y = 5*menuItemHeight;
			this.addChild(randomMenu);
			
			//监听鼠标动作
			this.addEventListener(MouseEvent.MOUSE_OVER, function():void{
				isMouseOn = true;
			});
			this.addEventListener(MouseEvent.MOUSE_OUT, function():void{
				isMouseOn = false;
			});
									
		}
		
		//0.3秒内滑出
		public function goDown():void{
			this.addEventListener(Event.ENTER_FRAME, idleCheckToClose);
			//滑到工具栏以下
			TweenLite.to(this, 0.3, {y : 32});
			mouseInOwner = true;
		}
		
		override public function set x(v:Number):void{
			super.x = v;
			//只初始化一次
			if(!_initX) {
				_initX = v;
				trace("sub menu initX: "+_initX);
			}
		}
		override public function set y(v:Number):void{
			super.y = v;
			//只初始化一次
			if(!_initY) {
				_initY = v;
				trace("sub menu initY: "+_initY);
			}			
		}
		
		public function set inOwner(v:Boolean):void{
			this.mouseInOwner = v;
		}
		
		//0.3秒内滑入
		private function goBack():void{
			this.removeEventListener(Event.ENTER_FRAME, idleCheckToClose);			
			//回去初始位置
			TweenLite.to(this, 0.3, {y : _initY});
			mouseInOwner = false;
		}
		
		//如果24帧内，即0.6秒内鼠标还没落在菜单上，菜单自动收回
		//也发生在鼠标离开后0.5秒，菜单自动收回
		//如果鼠标还在父菜单上，不收回
		public function idleCheckToClose(evt:Event):void{
			frameCounter++;			
			if(frameCounter>idleDurationFrames && !isMouseOn && !mouseInOwner){				
				goBack();
				frameCounter = 0;
			}
		}
		
	} //end of class
}