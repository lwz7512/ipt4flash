package com.pintu.widgets{
	
	import com.greensock.TweenLite;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	import com.pintu.vos.TPicDesc;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	import org.casalib.display.CasaTextField;
	import org.casalib.events.LoadEvent;
	import org.casalib.load.CasaLoader;
	
	public class Thumbnail extends CasaSprite{
		
		private var _casaLoader:CasaLoader;
		private var _data:TPicDesc;
		private var _initialized:Boolean = false;
		//得在鼠标滑过时记下来，作为缓动起点
		private var _x:Number;
		private var _y:Number;
		
		public function Thumbnail(data:TPicDesc){
			_data = data;
			//LOAD PIC BY URL...
			_casaLoader = new CasaLoader(data.url);			
			this._casaLoader.addEventListener(LoadEvent.COMPLETE, this._onComplete);
			this._casaLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,_onError);
			this._casaLoader.start();
			
			drawLoadingText();
			drawBackground();
			
			this.addEventListener(MouseEvent.CLICK, getDetails);
			this.addEventListener(MouseEvent.MOUSE_OVER,expandThumbail);
			this.addEventListener(MouseEvent.MOUSE_OUT,thrinkThumbail);
		}
		
		private function getDetails(event:MouseEvent):void{
			dispatchEvent(new PintuEvent(PintuEvent.GETPICDETAILS,_data.tpId));
		}
		
		private function expandThumbail(event:MouseEvent):void{
			if(!_x) _x = this.x;
			if(!_y) _y = this.y;
			TweenLite.to(this, 0.1,{x:_x-2, y:_y-2, width:104, height:104});	
						
		}
		private function thrinkThumbail(event:MouseEvent):void{
			TweenLite.to(this, 0.1,{x:_x, y:_y, width:100, height:100});		
		}
		

		
		private function drawLoadingText():void{
			var tf:CasaTextField = new CasaTextField();
			tf.x = 30;
			tf.y = 40;
			tf.autoSize = "left";
			tf.defaultTextFormat = new TextFormat(null,12);
			
			tf.text = "loading...";
			this.addChild(tf);
		}
		
		private function _onComplete(e:LoadEvent):void {
			var loader:Loader = this._casaLoader.loader;			
			this.addChild(loader);
			_initialized = true;
		}
		
		private function _onError(event:IOErrorEvent):void{
			Logger.error("Load thumbnail error: "+_data.thumbnailId);
		}
		
		private function drawBackground():void{
			//葱绿：1、浅绿又略显微黄的颜色；2、草木青翠的样子。
			this.graphics.lineStyle(1,0x9ED900);
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRoundRect(0,0,100,100,13,13);
			this.graphics.endFill();
			
			//draw mask
			var clip:CasaShape = new CasaShape();
			clip.graphics.beginFill(0x000000);
			clip.graphics.drawRoundRect(-1,-1,102,102,15,15);
			clip.graphics.endFill();
			this.addChild(clip);
			this.mask = clip;
		}
		
	} //end of class
}