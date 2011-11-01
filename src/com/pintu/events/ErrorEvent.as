package com.pintu.events
{
	import flash.events.Event;
	
	public class ErrorEvent extends Event{
		
		public var data:String;		
		
		public function ErrorEvent(type:String, context:String){
			super(type);
			this.data = context;
		}
		
		public override function  clone():Event{
			return new ErrorEvent(type,data);
		}
		
	}
}