package com.pintu.common{
	
	import com.pintu.config.StyleParams;
	import com.pintu.events.PintuEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaSprite;
	
	
	public class LinkRow extends CasaSprite{
		
		private var _name:String;
		private var _id:String;
		
		private var _width:Number = 100;
		private var _height:Number = 26;
		private var _bgColor:uint = 0;
		
		private var link:SimpleLinkTxt;
		private var _eventType:String;
		
		public function LinkRow(name:String, id:String){
			super();
			_name = name;
			_id = id;
			
			this.addEventListener(Event.ADDED_TO_STAGE, draw);
		}
		
		private function draw(evt:Event):void{
			var text:String = _name;
			link = new SimpleLinkTxt(text, StyleParams.DEFAULT_TEXT_COLOR, 12, false, false);
			link.x = (_width-link.textWidth)/2;
			link.y = 4;
			link.width = _width;
			link.addEventListener(MouseEvent.CLICK, linkClickHandler);
			this.addChild(link);
			
			if(_bgColor){				
				this.graphics.beginFill(_bgColor);
				this.graphics.drawRect(0,0,_width,_height);
				this.graphics.endFill();
			}
		}
		
		private function linkClickHandler(evt:MouseEvent):void{
			if(!_eventType) return;
			
			var sender:PintuEvent = new PintuEvent(_eventType, _id);
			this.dispatchEvent(sender);
		}
		
		public function set eventType(type:String):void{
			_eventType = type;
		}
		
		public function set backgroundColor(color:uint):void{
			_bgColor = color;
		}
		
		override public function set width(w:Number):void{
			_width = w;
		}
		
		override public function set height(h:Number):void{
			_height = h;
		}
		
	} //end of class
}