package com.pintu.widgets{
	
	import com.greensock.TweenLite;
	import com.pintu.common.IconButton;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PintuEvent;
	import com.pintu.widgets.BrowseMode;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 图片浏览工具栏，事件自身监听，在HomePage中处理
	 */ 
	public class SlideToolBar extends CasaSprite{
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		//工具栏高度
		private var toolbarHeight:Number = InitParams.TREEITEM_HEIGHT;	
		//宽度与画廊相同
		private var toolbarWidth:Number = InitParams.GALLERY_WIDTH;
		
		public function SlideToolBar(){
			super();
			
			//先确定绘图起始位置
			initDrawPoint();	
			
			drawBackground();
			
			drawTools();
			
			this.addEventListener(Event.ADDED_TO_STAGE, addStageMoveListener);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removeStageMoveListener);
		}
		
		private function addStageMoveListener(evt:Event):void{
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, detectMouseInSlideToolBar);
		}
		private function removeStageMoveListener(evt:Event):void{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, detectMouseInSlideToolBar);
		}
		private function detectMouseInSlideToolBar(evt:MouseEvent):void{
			var mouseX:Number = evt.stageX;
			var mouseY:Number = evt.stageY;			
			
			var slideToolDetectHeight:Number = 2*toolbarHeight;
			var slideToolDetectArea:Rectangle = new Rectangle(
				drawStartX,drawStartY-toolbarHeight,toolbarWidth,slideToolDetectHeight);
			
			var isInSlideTool:Boolean = slideToolDetectArea.contains(mouseX,mouseY);
					
			if(isInSlideTool){
				TweenLite.to(this, 0.3, {alpha : 1});
			}else{
				TweenLite.to(this, 0.3, {alpha : 0});
			}
		}
		
		private function initDrawPoint():void{
			drawStartX = InitParams.startDrawingX();	
			//如果舞台大小大于默认应用大小
			if(InitParams.isStretchHeight()){
				drawStartY = InitParams.appHeight 
					- InitParams.FOOTER_HEIGHT
					-InitParams.TOP_BOTTOM_GAP
					-toolbarHeight;
			}else{
				drawStartY = InitParams.MINAPP_HEIGHT
					- InitParams.FOOTER_HEIGHT
					-InitParams.TOP_BOTTOM_GAP
					-toolbarHeight;
			}
			
		}
		
		private function drawBackground():void{
			this.graphics.beginFill(StyleParams.DEFAULT_BLACK_COLOR, 0.8);
			this.graphics.drawRect(drawStartX, drawStartY, toolbarWidth, toolbarHeight);
			this.graphics.endFill();
		}
		
		//从右往左放
		private function drawTools():void{
			
			var toolsHGap:int = 90;			
			var toolStartX:Number = drawStartX+toolbarWidth-toolsHGap;
			
			var overColors:Array = [StyleParams.HEADER_MENU_MOUSEOVER,StyleParams.HEADER_MENU_MOUSEOVER];
			var downColors:Array = [StyleParams.DEFAULT_DARK_GREEN,StyleParams.DEFAULT_DARK_GREEN];			
			
			var newGallery:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			newGallery.iconPath = "assets/newgallery.png";
			newGallery.x = toolStartX;
			newGallery.y = drawStartY;
			newGallery.textOnRight = true;
			newGallery.label = "最新画廊";
			newGallery.setSkinStyle(null,overColors,downColors);	
			newGallery.addEventListener(MouseEvent.CLICK, getLatestGallery);
			this.addChild(newGallery);
			
			var randomGallery:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			randomGallery.iconPath = "assets/walkaround.png";
			randomGallery.x = toolStartX-toolsHGap;
			randomGallery.y = drawStartY;
			randomGallery.textOnRight = true;
			randomGallery.label = "随便看看";	
			randomGallery.setSkinStyle(null,overColors,downColors);	
			randomGallery.addEventListener(MouseEvent.CLICK, getRandomGallery);
			this.addChild(randomGallery);
			
			var bigpicGallery:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			bigpicGallery.iconPath = "assets/biggallery.png";
			bigpicGallery.x = toolStartX-2*toolsHGap;
			bigpicGallery.y = drawStartY;
			bigpicGallery.textOnRight = true;
			bigpicGallery.label = "大图列表";	
			bigpicGallery.setSkinStyle(null,overColors,downColors);	
			bigpicGallery.addEventListener(MouseEvent.CLICK, getBigPicGallery);
			this.addChild(bigpicGallery);
			
			var hotpicGallery:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			hotpicGallery.iconPath = "assets/hot.png";
			hotpicGallery.x = toolStartX-3*toolsHGap;
			hotpicGallery.y = drawStartY;
			hotpicGallery.textOnRight = true;
			hotpicGallery.label = "热点图片";
			hotpicGallery.setSkinStyle(null,overColors,downColors);	
			hotpicGallery.addEventListener(MouseEvent.CLICK, getHotGallery);
			this.addChild(hotpicGallery);
			
			var classicGallery:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			classicGallery.iconPath = "assets/classic.png";
			classicGallery.x = toolStartX-4*toolsHGap;
			classicGallery.y = drawStartY;
			classicGallery.textOnRight = true;
			classicGallery.label = "经典图片";	
			classicGallery.setSkinStyle(null,overColors,downColors);	
			classicGallery.addEventListener(MouseEvent.CLICK, getClassicGallery);
			this.addChild(classicGallery);
			
			var favoredGallery:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			favoredGallery.iconPath = "assets/recentfavor.png";
			favoredGallery.x = toolStartX-5*toolsHGap;
			favoredGallery.y = drawStartY;
			favoredGallery.textOnRight = true;
			favoredGallery.label = "最近收藏";		
			favoredGallery.setSkinStyle(null,overColors,downColors);	
			favoredGallery.addEventListener(MouseEvent.CLICK, getRecentFavored);
			this.addChild(favoredGallery);
		}
		
		private function getLatestGallery(evt:MouseEvent):void{
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, BrowseMode.CATEGORY_GALLERY_TBMODE);			
			this.dispatchEvent(typeChangeEvent);
		}
		
		private function getRandomGallery(evt:MouseEvent):void{
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, BrowseMode.CATEGORY_RANDOM_TBMODE);			
			this.dispatchEvent(typeChangeEvent);
		}
		
		private function getBigPicGallery(evt:MouseEvent):void{
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, BrowseMode.CATEGORY_GALLERY_BPMODE);			
			this.dispatchEvent(typeChangeEvent);
		}
		
		private function getHotGallery(evt:MouseEvent):void{
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, BrowseMode.CATEGORY_HOT);			
			this.dispatchEvent(typeChangeEvent);
		}
		
		private function getClassicGallery(evt:MouseEvent):void{
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, BrowseMode.CATEGORY_CLASSICAL);			
			this.dispatchEvent(typeChangeEvent);
		}
		
		private function getRecentFavored(evt:MouseEvent):void{
			var typeChangeEvent:PintuEvent = new PintuEvent(
				PintuEvent.BROWSE_CHANGED, BrowseMode.CATEGORY_FAVORED);			
			this.dispatchEvent(typeChangeEvent);
		}
		
		
	}
}