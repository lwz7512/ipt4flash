package com.pintu.common{
	
	import flash.text.TextFormat;
	
	import org.casalib.display.CasaTextField;
	
	
	public class SimpleText extends CasaTextField{
		
		public function SimpleText(text:String, color:uint=0, fontSize:int=12, bold:Boolean=false, wrap:Boolean=true){
			this.autoSize = "left";
			this.wordWrap = wrap;
			this.multiline = true;			
			this.selectable = false;
			
			var format:TextFormat = new TextFormat(null, fontSize,color,bold);
			this.defaultTextFormat = format;
			
			//先有样式，后设置文字内容
			this.text = text;
		}
		
		
	} //end of class
}