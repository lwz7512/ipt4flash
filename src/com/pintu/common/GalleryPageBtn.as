package com.pintu.common{
	
	import com.pintu.config.StyleParams;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	
	/**
	 * 画廊左右翻页按钮，位于画廊的左右垂直中心
	 */ 
	public class GalleryPageBtn extends CasaSprite{
		
		private var _width:Number = 32;
		private var _height:Number = 32;
		
		private var _skin:CasaShape;
		private var _color:uint = 0xFFFFFF;
		
		private var _iconPath:String;
		private var _imgLoader:LazyImage;
		
		private var _direction:String = "left";
		private var _offset:Number = 0;
		
		
		public function GalleryPageBtn(w:Number=32, h:Number=32){
			super();
			
			_width = w;
			_height = h;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			
		}
		/**
		 * 按钮图标路径
		 */ 
		public function set icon(path:String):void{
			_iconPath = path;
		}
		
		/**
		 * 按钮的位置和方向调节
		 */ 
		public function offsetIcon(direction:String, offset:Number):void{
			_direction = direction;
			_offset = offset;
		}
		
		/**
		 * Handler for the ADDED_TO_STAGE event.
		 */
		private function addedToStageHandler(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);			
			init();	
		}
		
		private function mouseOverHandler(evt:MouseEvent):void{
			_skin.graphics.clear();
			_skin.graphics.beginFill(_color,0.3);
			_skin.graphics.drawRect(0,0,_width,_height);
			_skin.graphics.endFill();
			_imgLoader.alpha = 1;
		}
		private function mouseDownHandler(evt:MouseEvent):void{
			_skin.graphics.clear();
			_skin.graphics.beginFill(_color,0.1);
			_skin.graphics.drawRect(0,0,_width,_height);
			_skin.graphics.endFill();
			
			if(_direction=="left"){
				_imgLoader.x -= 1;
			}else{
				_imgLoader.x += 1;
			}
		}
		
		private function mouseUpHandler(evt:MouseEvent):void{
			if(_direction=="left"){
				_imgLoader.x += 1;
			}else{
				_imgLoader.x -= 1;
			}
		}
		
		private function mouseOutHandler(evt:MouseEvent):void{
			_skin.graphics.clear();
			_imgLoader.alpha = 0.6;
		}
		
		private function init() : void {
			
			drawBackground();
			
			_skin = new CasaShape();
			this.addChild(_skin);
						
			showIcon();			
		}
		
		//TODO, ADD ARROW ICON...
		private function showIcon():void{
			if(!_iconPath) return;
			//假定图标都是32宽高
			_imgLoader = new LazyImage(_iconPath);
			_imgLoader.x = (_width-32)/2+_offset;
			_imgLoader.y = (_height-32)/2;
			this.addChild(_imgLoader);
			//默认是浅色的，方便鼠标交互视觉反馈
			_imgLoader.alpha = 0.6;
		}
		
		private function drawBackground():void{
			this.graphics.clear();
//			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(0xFFFFFF,0.01);
			this.graphics.drawRect(0,0,_width,_height);
			this.graphics.endFill();
		}
		
		override public function get width():Number{
			return this._width;
		}
		
		override public function get height():Number{
			return this._height;
		}
		
	} //end of class
}