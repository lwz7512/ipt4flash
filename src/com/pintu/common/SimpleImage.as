package com.pintu.common{
	
	import com.greensock.TweenLite;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	
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
		private var _isButtonMode:Boolean = false;
		
		public function SimpleImage(path:String){
			_iconPath = path;
			_imgLoader = new ImageLoad(path);
			_imgLoader.addEventListener(LoadEvent.COMPLETE,onLoaded);
			_imgLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			//延迟加载，好让set属性生效
			this.addEventListener(Event.ADDED_TO_STAGE,function():void{
				//不要重复加载，否则就叠上去了
				if(!_bitmap)
					_imgLoader.start();				
			});
						
		}		
		
		
		public function get bitmap():Bitmap{
			return _bitmap;
		}
		
		public function set maxSize(v:Number):void{
			_maxsize = v;
			if(_maxsize){
				this.graphics.lineStyle(1,0xCCCCCC,0.4);
				this.graphics.drawRect(0,0,_maxsize,_maxsize);
			}
		}
		
		public function get maxSize():Number{
			return _maxsize;
		}
		
		override public function set buttonMode(v:Boolean):void{
			_isButtonMode = v;
		}
		
		private function onLoaded(e:LoadEvent):void {
			_bitmap = this._imgLoader.contentAsBitmap;
			_bitmap.x = 2;
			_bitmap.y = 2;
			var ratio:Number = _bitmap.width/_bitmap.height;
			
			if(_maxsize>0 && _bitmap.height>_maxsize){
				_bitmap.height = _maxsize;
				_bitmap.width = _maxsize*ratio;
			}
			this.addChild(_bitmap);	
			//普通模式
			if(!_isButtonMode){
				//图片淡出效果
				TweenLite.from(_bitmap,0.4,{alpha: 0});				
			}else{
				_bitmap.alpha = 0.6;
				addButtonBehavior();
			}
			
			var evt:PintuEvent = new PintuEvent(PintuEvent.IMAGE_LOADED,null);
			this.dispatchEvent(evt);
		}
		
		private function addButtonBehavior():void{
			
			this.addEventListener(MouseEvent.MOUSE_OVER,function():void{
				_bitmap.alpha = 1;
			});
			this.addEventListener(MouseEvent.MOUSE_OUT,function():void{
				_bitmap.alpha = 0.6;
			});
			this.addEventListener(Event.REMOVED_FROM_STAGE,function():void{
				_bitmap.alpha = 0.6;
			});
		}
		
		private function onError(event:IOErrorEvent):void{
			Logger.error("load icon error: "+_iconPath);
		}
		
	} //end of class
}