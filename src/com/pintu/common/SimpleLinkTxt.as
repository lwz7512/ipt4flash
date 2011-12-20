package com.pintu.common{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	
	public class SimpleLinkTxt extends SimpleText{
		
		protected var _mouseOverColor:uint;
		
		protected var _mouseOverFormat:TextFormat;
		
		public function SimpleLinkTxt(text:String, color:uint=0, fontSize:int=12, bold:Boolean=false, wrap:Boolean=false, overColor:uint=0x177cb0)
		{
			super(text, color, fontSize, bold, wrap);
							
			_mouseOverFormat = new TextFormat(null,fontSize,overColor,bold,null,true);		
			
			this.addEventListener(MouseEvent.MOUSE_OVER, drawOverColor);
			this.addEventListener(MouseEvent.MOUSE_OUT, resetColor);
		}
		
		private function drawOverColor(evt:MouseEvent):void{
			this.defaultTextFormat = _mouseOverFormat;
			this.text = _txt;
		}
		private function resetColor(evt:MouseEvent):void{
			this.defaultTextFormat =_normalFormat;
			this.text = _txt;
		}
		
	} //end of class
}