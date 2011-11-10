package com.pintu.widgets
{
	import com.pintu.utils.Logger;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	
	/**
	 * 只有图片没有文字的，可交互按钮
	 */ 
	public class SimpleIcon extends SimpleImage
	{
		
		private var _icon:Bitmap;
		
		private var _showUpSkin:Boolean = false;
		
		private var _iconWidth:Number = 30;
		//为了跟搜索框底部对齐，高度稍微大点
		private var _iconHeight:Number = 31;
		
		private var _mouseOn:Boolean = false;
		
		public function SimpleIcon(path:String){			
			super(path);
			
			drawBackground();
			
			this.addEventListener(MouseEvent.MOUSE_OVER,drawOverSkin);
			this.addEventListener(MouseEvent.MOUSE_OUT,drawOutSkin);
			this.addEventListener(MouseEvent.MOUSE_DOWN,drawDownSkin);
			this.addEventListener(MouseEvent.MOUSE_UP,drawUpSkin);
		}		
		
		public function set showUpSkin(v:Boolean):void{
			_showUpSkin = v;
		}
		
		private function drawBackground():void{
			if(_showUpSkin){
				this.graphics.clear();
				//墨灰：即黑灰
				this.graphics.lineStyle(1,0x758a99);
				//银白：带银光的白色
				this.graphics.beginFill(0xE9E7EF);
				this.graphics.drawRect(0,0,_iconWidth,_iconHeight);
				this.graphics.endFill();				
			}
		}
		
		private function drawOverSkin(event:MouseEvent):void{
			_mouseOn = true;
			
			this.graphics.clear();
			//花白：白色和黑色混杂的。斑白的、夹杂有灰色的白。
			this.graphics.beginFill(0xc2ccd0);
			this.graphics.drawRect(0,0,_iconWidth,_iconHeight);
			this.graphics.endFill();
		}
		private function drawOutSkin(event:MouseEvent):void{
			_mouseOn = false;
			drawBackground();
		}
		private function drawDownSkin(event:MouseEvent):void{
			this.graphics.clear();
			this.graphics.beginFill(0xc2ccd0);
			this.graphics.drawRect(0,0,_iconWidth,_iconHeight);
			this.graphics.endFill();
			
			if(_mouseOn){
				_imgLoader.contentAsBitmap.x ++;
				_imgLoader.contentAsBitmap.y ++;			
			}
		}
		private function drawUpSkin(event:MouseEvent):void{
			if(_mouseOn){
				_imgLoader.contentAsBitmap.x --;
				_imgLoader.contentAsBitmap.y --;				
			}
		}
		

		
	}
}