package com.pintu.events
{
	import flash.events.Event;
	
	public class PTErrorEvent extends Event{
		
		public var data:String;		
		
		public function PTErrorEvent(type:String, context:String){
			super(type);
			this.data = context;
		}
		
		public override function  clone():Event{
			return new PTErrorEvent(type,data);
		}
		
	}
}