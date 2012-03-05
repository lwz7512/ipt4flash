package com.pintu.common{
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	
	
	public class HandCursorLink extends CasaSprite{
		
		private var _link:SimpleText;
			
		private var _txt:String;
		private var _color:uint
		private var _fontSize:int
		private var _bold:Boolean;
		private var _wrap:Boolean;
		private var _overColor:uint;
		
		private var _mouseOverFormat:TextFormat;
		
		public function HandCursorLink(text:String, color:uint=0, fontSize:int=12, bold:Boolean=false, wrap:Boolean=false, overColor:uint=0x177cb0){
			
			_txt = text;
			_color = color;
			_fontSize = fontSize;
			_bold = bold;
			_wrap = wrap;
			_overColor = overColor;		
			
			_mouseOverFormat = new TextFormat(null,fontSize,overColor,bold,null,true);
			
			this.buttonMode = true;
			this.useHandCursor = true;
			this.mouseChildren = false;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddtoStage);
			
		}
		
		private function onAddtoStage(evt:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE,onAddtoStage);
			
			_link = new SimpleText(_txt,_color,_fontSize,_bold,_wrap,false);
			this.addChild(_link);
		}
		
		public function set text(txt:String):void{
			_txt = txt;
		}
		
		
	} //end of class
}