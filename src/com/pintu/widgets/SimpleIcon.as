package com.pintu.widgets
{
	import com.pintu.utils.Logger;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	
	public class SimpleIcon extends Sprite
	{
		private var _iconPath:String;
		private var _iconLoader:ImageLoad;
		private var _icon:Bitmap;
		
		private var _iconWidth:Number = 30;
		private var _iconHeight:Number = 30;
		
		public function SimpleIcon(path:String)
		{
			_iconPath = path;
			_iconLoader = new ImageLoad(_iconPath);
			_iconLoader.addEventListener(LoadEvent.COMPLETE,onLoaded);
			_iconLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			_iconLoader.start();	
			
			this.addEventListener(MouseEvent.MOUSE_OVER,drawOverSkin);
			this.addEventListener(MouseEvent.MOUSE_OUT,drawOutSkin);
			this.addEventListener(MouseEvent.MOUSE_DOWN,drawDownSkin);
			this.addEventListener(MouseEvent.MOUSE_UP,drawUpSkin);
		}			
		
		private function drawOverSkin(event:MouseEvent):void{
			this.graphics.clear();
			//花白：白色和黑色混杂的。斑白的、夹杂有灰色的白。
			this.graphics.beginFill(0xc2ccd0);
			this.graphics.drawRect(0,0,_iconWidth,_iconHeight);
			this.graphics.endFill();
		}
		private function drawOutSkin(event:MouseEvent):void{
			this.graphics.clear();
		}
		private function drawDownSkin(event:MouseEvent):void{
			this.graphics.clear();
			this.graphics.beginFill(0xc2ccd0);
			this.graphics.drawRect(0,0,_iconWidth,_iconHeight);
			this.graphics.endFill();
			_icon.x = _icon.x+1;
			_icon.y = _icon.y+1;
		}
		private function drawUpSkin(event:MouseEvent):void{
			_icon.x = _icon.x-1;
			_icon.y = _icon.y-1;
		}
		
		private function onLoaded(e:LoadEvent):void {
			_icon = this._iconLoader.contentAsBitmap;
			_icon.x = 2;
			_icon.y = 2;
			this.addChild(_icon);					
		}
		
		private function onError(event:IOErrorEvent):void{
			Logger.error("load icon error: "+_iconPath);
		}
		
	}
}