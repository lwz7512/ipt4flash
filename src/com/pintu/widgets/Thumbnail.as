package com.pintu.widgets{
	
	import com.greensock.TweenLite;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.*;
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
		
		private var _roundRadius:int = 4;
		
		private var defaultThumbnailPath:String = "assets/defaultImage100.png";
		//如果丢失了图片，不能进行点击
		private var isLost:Boolean = true;
		
		private var timeBarHeight:int = 24;
		
		public function Thumbnail(data:TPicDesc){
			_data = data;
//			Logger.debug("thumbnail url: "+data.url);
			//LOAD PIC BY URL...
			_imgLoader = new ImageLoad(data.url);			
			this._imgLoader.addEventListener(LoadEvent.COMPLETE, _onComplete);
			this._imgLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,_onError);
			this._imgLoader.start();
			
			drawLoadingText();		
			
			//draw mask
			var clip:CasaShape = new CasaShape();
			clip.graphics.beginFill(0x000000);
			//FIXME, 稍微宽点容纳图片，稍微高点容纳文字条
			//2012/01/11, 2012/05/07
			clip.graphics.drawRoundRect(0,0,102,102,_roundRadius,_roundRadius);
			clip.graphics.endFill();
			this.addChild(clip);
			this.mask = clip;
			
			this.addEventListener(MouseEvent.CLICK, getDetails);
			this.addEventListener(MouseEvent.MOUSE_OVER,expandThumbail);
			this.addEventListener(MouseEvent.MOUSE_OUT,thrinkThumbail);
		}
		
		private function getDetails(event:MouseEvent):void{
			if(isLost) return;
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
			tf.selectable = false;
			tf.x = 30;
			tf.y = 40;
			tf.autoSize = "left";
			tf.defaultTextFormat = new TextFormat(null,12, StyleParams.DEFAULT_TEXT_COLOR);
			
			tf.text = "loading...";
			this.addChild(tf);
		}
		
		private function _onComplete(e:LoadEvent):void {
			isLost = false;
			//第一次载人的图片
			var bitmap:Bitmap = _imgLoader.contentAsBitmap;				
		
			
			//重设样式
			//FIXME, 2012/02/15
//			tf.defaultTextFormat = new TextFormat(null,12, StyleParams.WHITE_TEXT_COLOR);
//			tf.defaultTextFormat = new TextFormat(null,12, StyleParams.GREEN_TEXT_COLOR);
			//FIXME, 2012/05/07
			tf.defaultTextFormat = new TextFormat(null,12, StyleParams.HEADERBAR_TOP_LIGHTGREEN);
			
			//如果比缩略图默认尺寸大，就按默认图显示，这可能是不合法图片
			//这样防止缓动效果出问题
			if(bitmap.width>100 || bitmap.height>100){//异常图片使用默认的				
				tf.text = "it's lost...";
				tf.x = (100-tf.textWidth)/2;
				tf.y = 78;		
				isLost = true;
			}else{//正常图片显示
				bitmap.x = 1;
				bitmap.y = 1;
				this.addChild(bitmap);
							
				//图片发布时间				
				tf.text = PintuUtils.getRelativeTimeByMiliSeconds(_data.creationTime);
				tf.x = (100-tf.textWidth)/2;
				tf.y = 78;
			}						
			
			//画文字所在背景，及边框
			drawBackground();		
			
			//移除在底部的文字
			this.removeChild(tf);
			//放在顶部
			this.addChild(tf);
			
			_initialized = true;			
		}
		
		private function _onError(event:IOErrorEvent):void{
			Logger.error("Load thumbnail error: "+_data.thumbnailId);
			tf.defaultTextFormat = new TextFormat(null,12, StyleParams.WHITE_TEXT_COLOR);
			tf.text = "I'm lost!";
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0,0,100,100);
			this.graphics.endFill();
		}
		
		private function drawBackground():void{
			//再画底部背景条						
			var canvas:CasaShape = new CasaShape();
			this.addChild(canvas);
			//灰色背景，这样暗示详情背景是黑色的
			//2012/05/07
			canvas.graphics.beginFill(0xF5F5F5, 0.8);
			//稍微宽点容纳图片，高度窄点，否则盖住边框了
			canvas.graphics.drawRect(0, (100-timeBarHeight),101,timeBarHeight+1);
			canvas.graphics.endFill();					
			
			//花白：白色和黑色混杂的。斑白的、夹杂有灰色的白
			canvas.graphics.lineStyle(1,StyleParams.PICDETAIL_BACKGROUND_BROWN,1,true);
			canvas.graphics.drawRect(0, 0, 101, 101);
		}
		
	} //end of class
}