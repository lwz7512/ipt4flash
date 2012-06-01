package com.pintu.common{
	
	import com.pintu.utils.Logger;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import org.casalib.display.CasaSprite;
	
	public class Avatar extends CasaSprite{
		
		private var _path:String;
		private var _loader:Loader;
		
		private var _loading:BusyIndicator;
		private var _maxsize:Number = 0;
		
		private var _visibleWidth:Number;
		private var _visibleHeight:Number;
		
		private var _frame:Shape;
		private var _crossDomain:Boolean;
		
		
		public function Avatar(path:String,crossDomain:Boolean=false){
			super();
			_path = path;
			_crossDomain = crossDomain;
			
			_frame = new Shape();
			this.addChild(_frame);
			
			_loader = new Loader();			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		public function set maxSize(v:Number):void{
			_maxsize = v;
			if(_maxsize){
				_frame.graphics.lineStyle(1,0xCCCCCC,0.4);
				_frame.graphics.drawRect(0,0,_maxsize,_maxsize);
			}
		}

		
		private function onComplete(evt:Event):void{
			this.removeChild(_loading);
			var bitmap:Bitmap = _loader.contentLoaderInfo.content as Bitmap;		
			Logger.debug("bitmap size: "+bitmap.width+"/"+bitmap.height);
			var smallbd:BitmapData = new BitmapData(64,64);
			smallbd.draw(bitmap);
			var small:Bitmap = new Bitmap(smallbd);
			this.addChild(small);
			
			
		}
		private function onError(evt:Event):void{
			trace("load img error...");
		}
		
		private function onAddedToStage(evt:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//显示运行指针
			_loading = new BusyIndicator();
			this.addChild(_loading);
			
			//FIXME, 居中显示，在设置图片大小情况下
			//2012/03/18
			if(_maxsize){
				_loading.x = _maxsize/2-10;
				_loading.y = _maxsize/2-10;
			}
			
			if(_path){
				if(_crossDomain){
					_loader.load(new URLRequest(_path),new LoaderContext(true));									
				}else{
					_loader.load(new URLRequest(_path));
				}
			}
		}
		
	} //end of class
}