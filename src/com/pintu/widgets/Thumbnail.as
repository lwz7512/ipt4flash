package com.pintu.widgets{
	
	import com.greensock.TweenLite;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	import com.pintu.vos.TPicDesc;
	
	import flash.display.Bitmap;
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
	import org.casalib.load.ImageLoad;
	
	public class Thumbnail extends CasaSprite{
		
		protected var _imgLoader:ImageLoad;
		private var tf:CasaTextField;
		
		private var _data:TPicDesc;
		private var _initialized:Boolean = false;
		//得在鼠标滑过时记下来，作为缓动起点
		private var _x:Number;
		private var _y:Number;
		
		private var _roundRadius:int = 6;
		
		public function Thumbnail(data:TPicDesc){
			_data = data;
			//LOAD PIC BY URL...
			_imgLoader = new ImageLoad(data.url);			
			this._imgLoader.addEventListener(LoadEvent.COMPLETE, _onComplete);
			this._imgLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,_onError);
			this._imgLoader.start();
			
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
			//这个位置必须存下来使用
			if(!_x) _x = this.x;
			if(!_y) _y = this.y;
			TweenLite.to(this, 0.1,{x:_x-2, y:_y-2, width:104, height:104});	
						
		}
		private function thrinkThumbail(event:MouseEvent):void{
			TweenLite.to(this, 0.1,{x:_x, y:_y, width:100, height:100});		
		}
		

		
		private function drawLoadingText():void{
			tf = new CasaTextField();
			tf.x = 30;
			tf.y = 40;
			tf.autoSize = "left";
			tf.defaultTextFormat = new TextFormat(null,12);
			
			tf.text = "loading...";
			this.addChild(tf);
		}
		
		private function _onComplete(e:LoadEvent):void {
			var bitmap:Bitmap = this._imgLoader.contentAsBitmap;	
			bitmap.x = 1;
			bitmap.y = 1;
			this.addChild(bitmap);
			
			//如果比缩略图默认尺寸大，就按默认尺寸设置
			//这样防止缓动效果出问题
			if(bitmap.width>100)
				bitmap.width = 100;
			if(bitmap.height>100)
				bitmap.height = 100;					
			
			_initialized = true;
			
			if(this.contains(tf)) this.removeChild(tf);
		}
		
		private function _onError(event:IOErrorEvent):void{
			Logger.error("Load thumbnail error: "+_data.thumbnailId);
		}
		
		private function drawBackground():void{
			//花白：白色和黑色混杂的。斑白的、夹杂有灰色的白
			this.graphics.lineStyle(1,0xC2CCD0,1,true);
			//黑色背景，这样暗示详情背景是黑色的
			this.graphics.beginFill(StyleParams.FOOTER_SOLID_GRAY);
			//稍微宽点容纳图片
			this.graphics.drawRoundRect(0,0,101,100,_roundRadius,_roundRadius);
			this.graphics.endFill();
			
			//draw mask
			var clip:CasaShape = new CasaShape();
			clip.graphics.beginFill(0x000000);
			//稍微宽点容纳图片
			clip.graphics.drawRoundRect(0,0,101,100,_roundRadius,_roundRadius);
			clip.graphics.endFill();
			this.addChild(clip);
			this.mask = clip;
		}
		
	} //end of class
}