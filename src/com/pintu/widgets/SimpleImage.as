package com.pintu.widgets{
	
	import com.pintu.utils.Logger;
	
	import flash.display.Bitmap;
	import flash.events.IOErrorEvent;
	
	import org.casalib.display.CasaSprite;
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	
	public class SimpleImage extends CasaSprite{
		
		
		protected var _iconPath:String;
		protected var _imgLoader:ImageLoad;
		
		public function SimpleImage(path:String){
			_iconPath = path;
			_imgLoader = new ImageLoad(path);
			_imgLoader.addEventListener(LoadEvent.COMPLETE,onLoaded);
			_imgLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			_imgLoader.start();
		}
		
		private function onLoaded(e:LoadEvent):void {
			var content:Bitmap = this._imgLoader.contentAsBitmap;
			content.x = 2;
			content.y = 2;
			this.addChild(content);					
		}
		
		private function onError(event:IOErrorEvent):void{
			Logger.error("load icon error: "+_iconPath);
		}
		
	} //end of class
}