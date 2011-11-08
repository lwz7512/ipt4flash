package com.pintu.events
{
	import flash.events.Event;
	
	public class PintuEvent extends Event
	{
		
		public static const NAVIGATE:String = "navigate";
		public static const BROWSE_CHANGED:String = "browseChanged";
		public static const GETPICDETAILS:String = "getPicDetails";
		
		public var data:String;		
		
		public function PintuEvent(type:String, context:String)
		{
			super(type);
			this.data = context;
		}
		
		public override function  clone():Event{
			return new PintuEvent(type,data);
		}
		
	}
}