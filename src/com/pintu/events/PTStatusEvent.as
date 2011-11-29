package com.pintu.events{
	
	import flash.events.Event;
		
	
	public class PTStatusEvent extends Event{
		
		public var status:String;
		
		public function PTStatusEvent(type:String, status:String){
			super(type);
			this.status = status;
		}
		
		public override function  clone():Event{
			return new PTStatusEvent(type,status);
		}
		
	} //end of class
}