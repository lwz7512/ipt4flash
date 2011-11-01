package com.pintu.events
{
	import flash.events.Event;
	
	public class ResponseEvent extends Event{
						
		public var data:String;		
		
		public function ResponseEvent(type:String, context:String){
			super(type);
			this.data = context;
		}		
		
		public override function  clone():Event{
			return new ResponseEvent(type,data);
		}
		
		
	}
}