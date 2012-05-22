package com.pintu.common{
	
	import com.pintu.config.StyleParams;
	
	import flash.events.Event;
	
	import org.casalib.display.CasaSprite;
	
	
	public class FloatTip extends CasaSprite{
		
		private var _width:Number;
		private var _height:Number;
		
		private var _content:String = "";
		
		private var _contentTF:SimpleText;
		
		private var _backgroundColor:uint = 0xf0fcff;		
		private var _backgroundAlpha:Number = 0.8;
		
		
		
		public function FloatTip(w:Number){
			super();
			
			_width = w;
			
			this.addEventListener(Event.ADDED_TO_STAGE, createContent);
			this.addEventListener(Event.REMOVED_FROM_STAGE, clearContent);
		}
		
		public function set content(txt:String):void{
			_content = txt;
		}
		
		private function createContent(evt:Event):void{
			if(!_contentTF){
				_contentTF = new SimpleText(_content);
				_contentTF.width = _width+4;
				_contentTF.y = 10;
				this.addChild(_contentTF);
			}else{				
				_contentTF.text = _content;
			}
			
			var grayColor:uint = StyleParams.GRAY_TEXT_COLOR;
			
			this.graphics.moveTo(0,10);
			this.graphics.lineStyle(1,grayColor);
			
			var rightOffset:Number = 150;
			
			//开始填充
			this.graphics.beginFill(_backgroundColor,_backgroundAlpha);
			//短边
			this.graphics.lineTo(rightOffset,10);
			//顶点
			this.graphics.lineTo(rightOffset+5,2);
			this.graphics.lineTo(rightOffset+10,10);
			//右顶点
			this.graphics.lineTo(200,10);
			//右下顶点
			this.graphics.lineTo(200,_contentTF.textHeight+20);
			//左下顶点
			this.graphics.lineTo(0,_contentTF.textHeight+20);
			//回原点
			this.graphics.lineTo(0,10);
			//结束填充
			this.graphics.endFill();
		}
		private function clearContent(evt:Event):void{
			_contentTF.text = "";
			this.graphics.clear();
		}
		
	} //end of class
}