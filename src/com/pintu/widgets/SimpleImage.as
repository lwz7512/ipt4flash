package com.pintu.widgets{
	
	import com.greensock.TweenLite;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import org.casalib.display.CasaSprite;
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	
	/**
	 * 就是一个图片
	 */ 
	public class SimpleImage extends CasaSprite{
		
		
		protected var _iconPath:String;
		protected var _imgLoader:ImageLoad;
		
		private var _bitmap:Bitmap;
		
		private var _maxsize:Number = 0;
		
		public function SimpleImage(path:String){
			_iconPath = path;
			_imgLoader = new ImageLoad(path);
			_imgLoader.addEventListener(LoadEvent.COMPLETE,onLoaded);
			_imgLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			
			this.addEventListener(Event.ADDED_TO_STAGE,function():void{
				_imgLoader.start();
			});
		}
		
		
		public function get bitmap():Bitmap{
			return _bitmap;
		}
		
		public function set maxSize(v:Number):void{
			_maxsize = v;
		}
		
		public function get maxSize():Number{
			return _maxsize;
		}
		
		private function onLoaded(e:LoadEvent):void {
			_bitmap = this._imgLoader.contentAsBitmap;
			_bitmap.x = 2;
			_bitmap.y = 2;
			var ratio:Number = _bitmap.width/_bitmap.height;
			//宽度不限制
//			if(_bitmap.width>_maxsize){
//				_bitmap.width = _maxsize;
//				_bitmap.height = _maxsize/ratio;
//			}
			if(_maxsize>0 && _bitmap.height>_maxsize){
				_bitmap.height = _maxsize;
				_bitmap.width = _maxsize*ratio;
			}
			this.addChild(_bitmap);	
			//图片淡出效果
			TweenLite.from(_bitmap,0.4,{alpha: 0});
			
			var evt:PintuEvent = new PintuEvent(PintuEvent.IMAGE_LOADED,null);
			this.dispatchEvent(evt);
		}
		
		private function onError(event:IOErrorEvent):void{
			Logger.error("load icon error: "+_iconPath);
		}
		
	} //end of class
}