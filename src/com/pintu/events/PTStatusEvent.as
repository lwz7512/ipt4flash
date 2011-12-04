package com.pintu.events{
	
	import flash.events.Event;
		
	
	public class PTStatusEvent extends Event{
		
		public var data:String;
		
		public function PTStatusEvent(type:String, status:String){
			super(type);
			this.data = status;
		}
		
		public override function  clone():Event{
			return new PTStatusEvent(type,data);
		}
		
	} //end of class
}