package com.pintu.common{
	
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	public class RestrictLengthText extends SimpleText{
		
		protected var _mouseOverFormat:TextFormat;
		
		protected var _restrict:Number;
		
		public function RestrictLengthText(text:String, color:uint=0, restrict:int=10, wrap:Boolean=false, isLink:Boolean=false){
			super(text, color, 12, false, wrap, false, true);
			
			this._txt = truncateStr(text,restrict);
			//先有样式，后设置文字内容
			this.text = _txt;	
			
			_restrict = restrict;
			
			if(!isLink) return;
			
			_mouseOverFormat = new TextFormat(null,12,0x177cb0,false,null,true);
			
			this.addEventListener(MouseEvent.MOUSE_OVER, drawOverColor);
			this.addEventListener(MouseEvent.MOUSE_OUT, resetColor);
		}
		
		override public function set text(value:String):void{
			this._txt = truncateStr(value,_restrict);		
			super.text = _txt;	
		}
		
		private function drawOverColor(evt:MouseEvent):void{
			this.defaultTextFormat = _mouseOverFormat;
			this.text = _txt;
		}
		private function resetColor(evt:MouseEvent):void{
			this.defaultTextFormat =_normalFormat;
			this.text = _txt;
		}
		
		//FIXME, 先简单搞搞。。。
		private function truncateStr(str:String, strictLength:Number):String{
			if(str.length<strictLength) return str;
			return str.substr(0,strictLength)+"...";
		}

		
	} //end of class
}