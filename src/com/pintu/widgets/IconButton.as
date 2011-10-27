package com.pintu.widgets
{
	import com.pintu.utils.Logger;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	
	public class IconButton extends TextMenu
	{
		
		private var _iconPath:String;
		private var _iconLoader:ImageLoad;
		
		private var margin:Number = 4;
		private var iconTextGap:Number = 0;
		
		public function IconButton(w:Number, h:Number)
		{
			super(w,h);			
		}
		
		public function set iconPath(path:String):void{
			_iconPath = path;
		}
		
		override protected function showIcon():void{
			if(_iconPath==null) return;
			
			_iconLoader = new ImageLoad(_iconPath);
			_iconLoader.addEventListener(LoadEvent.COMPLETE,onLoaded);
			_iconLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			_iconLoader.start();		
		}
		
		private function onLoaded(e:LoadEvent):void {
			var icon:Bitmap = this._iconLoader.contentAsBitmap;
			this.addChild(icon);
			
			icon.x = this._width/2 - icon.width/2;
			icon.y = margin;
			//repositon icon label
			this.moveLabel(icon.y+icon.height+iconTextGap);
		}
		
		private function onError(event:IOErrorEvent):void{
			Logger.error("load icon error: "+_iconPath);
		}
		

		
	}
}