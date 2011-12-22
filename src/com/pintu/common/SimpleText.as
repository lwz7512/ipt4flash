package com.pintu.common{
	
	import flash.text.TextFormat;
	
	import org.casalib.display.CasaTextField;
	
	
	public class SimpleText extends CasaTextField{
		
		protected var _normalFormat:TextFormat;
		protected var _txt:String;
		
		public function SimpleText(text:String, color:uint=0, fontSize:int=12, bold:Boolean=false, wrap:Boolean=true, selectable:Boolean=false){
			this.autoSize = "left";
			this.wordWrap = wrap;
			this.multiline = true;			
			this.selectable = selectable;
			
			_txt = text;
			
			_normalFormat = new TextFormat(null, fontSize,color,bold,null,false);
			this.defaultTextFormat = _normalFormat;
			
			//先有样式，后设置文字内容
			this.text = _txt;
		}
		
		
	} //end of class
}