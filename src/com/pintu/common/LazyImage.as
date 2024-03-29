package com.pintu.common{
	
	import com.greensock.TweenLite;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.system.LoaderContext;
	
	import org.casalib.display.CasaSprite;
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	
	/**
	 * 就是一个图片
	 * 
	 * 修改为延迟载入图片
	 * 2012/03/05
	 */ 
	public class LazyImage extends CasaSprite{
		
		
		protected var _iconPath:String;
		protected var _imgLoader:ImageLoad;
		
		private var _bitmap:Bitmap;
		
		private var _maxsize:Number = 0;
		
		private var _visibleWidth:Number;
		private var _visibleHeight:Number;
		
		private var _loading:BusyIndicator;
		private var _context:LoaderContext;
		
		public function LazyImage(path:String, context:LoaderContext=null){
			_iconPath = path;
			_context = context;
			//路径有可能为空，后指定
			if(path){
				_imgLoader = new ImageLoad(path,_context);
				_imgLoader.addEventListener(LoadEvent.COMPLETE,onLoaded);
				_imgLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);				
			}
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//第二次机会来创建图片加载器
			if(!_imgLoader && _iconPath){
				_imgLoader = new ImageLoad(_iconPath,_context);
				_imgLoader.addEventListener(LoadEvent.COMPLETE,onLoaded);
				_imgLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			}
			//不要重复加载，否则就叠上去了
			if(!_bitmap && _imgLoader) {
				//发起请求
				_imgLoader.start();	
				
				//显示运行指针
				_loading = new BusyIndicator();
				this.addChild(_loading);
				
				//FIXME, 居中显示，在设置图片大小情况下
				//2012/03/18
				if(_visibleWidth && _visibleHeight){
					_loading.x = _visibleWidth/2-10;
					_loading.y = _visibleHeight/2-10;
				}
//				Logger.debug("> start to loading image: "+_iconPath);
			}
						
		}
		
		public function set imgPath(url:String):void{
			_iconPath = url;
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
		
		
		public function set visibleWidth(w:Number):void{
			_visibleWidth = w;
		}
		public function set visibleHeight(h:Number):void{
			_visibleHeight = h;
		}
		
		private function onLoaded(e:LoadEvent):void {
			
			if(this.contains(_loading)){
				this.removeChild(_loading);
			}			
			
			_bitmap = this._imgLoader.contentAsBitmap;
			_bitmap.x = 2;
			_bitmap.y = 2;
			var ratio:Number = _bitmap.width/_bitmap.height;
			//FIXME, 按比例缩放头像
			//2012/06/01
			if(_maxsize>0 && _bitmap.height>_maxsize){
				_bitmap.scaleX = _maxsize/_bitmap.height;
				_bitmap.scaleY = _maxsize/_bitmap.height;				
			}
			this.addChild(_bitmap);	
						
			//图片淡出效果
			TweenLite.from(_bitmap,0.4,{alpha: 0});				
			
			
			var evt:PintuEvent = new PintuEvent(PintuEvent.IMAGE_LOADED,null);
			this.dispatchEvent(evt);
		}
		

		
		private function onError(event:IOErrorEvent):void{
			Logger.error("load icon error: "+_iconPath);
			if(this.contains(_loading)){
				this.removeChild(_loading);
			}
		}
		
	} //end of class
}