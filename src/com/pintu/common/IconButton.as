package com.pintu.common
{
	import com.pintu.utils.Logger;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	
	/**
	 * 带图标和文字的按钮
	 * 文字默认在图标的下方，设置textOnRight时文字在右侧
	 */ 
	public class IconButton extends TextMenu
	{
		
		private var _iconPath:String;
		private var _iconLoader:ImageLoad;
		private var icon:Bitmap;
		
		private var margin:Number = 4;
		
		private var iconTextVGap:Number = 2;
		private var iconTextHGap:Number = 4;
		
		private var _textOnRight:Boolean = false;
		
		private var _offsetX:Number = 0;
		private var _offsetY:Number = 0;
		
		
		
		public function IconButton(w:Number, h:Number)
		{
			super(w,h);			
		}
		
		public function set iconPath(path:String):void{
			_iconPath = path;
		}
		
		public function set textOnRight(value:Boolean):void{
			_textOnRight = value;
		}
				
		override protected function showIcon():void{
			if(_iconPath==null) return;
			
			_iconLoader = new ImageLoad(_iconPath);
			_iconLoader.addEventListener(LoadEvent.COMPLETE,onLoaded);
			_iconLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			_iconLoader.start();		
		}
		
		private function onLoaded(e:LoadEvent):void {
			icon = this._iconLoader.contentAsBitmap;
			this.addChild(icon);
			icon.x = this._width/2 - icon.width/2;
			
			if(_textOnRight){
				icon.y = margin/2;
				this.moveLabelX(icon.x+icon.width+iconTextHGap);
				this.moveLabelY(iconTextVGap);
				
				//FIXME, 文字与图标间距引起闪烁，这里鼠标探测增加宽度，使得间距消失
				//2011/12/19
				this.graphics.clear();
				this.graphics.beginFill(0xFFFFFF, 0.01);
				this.graphics.drawRect(0, 0, _width+iconTextHGap, _height);
				
			}else{//IN BOTTOM
				icon.y = margin;
				//repositon icon label
				this.moveLabelY(icon.height/2+2);
			}
			
			if(!this.enabled){
				icon.alpha = 0.6;
			}
			
			//FIXME, 做位置调整
			//2012/05/29
			icon.x += _offsetX;
			icon.y += _offsetY;
			
		}
		
		public function moveIcon(offsetX:Number, offsetY:Number):void{
			_offsetX = offsetX;
			_offsetY = offsetY;
		}
		
		private function onError(event:IOErrorEvent):void{
			Logger.error("load icon error: "+_iconPath);
		}
		
		//FIXME, 图标可以运行时设置禁用风格
		//2012/05/07
		override public function set enabled(enabled : Boolean) : void {
			super.enabled = enabled;
			if(!enabled && icon){
				icon.alpha = 0.6;
			}
		}
		
	}
}