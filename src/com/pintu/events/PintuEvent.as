package com.pintu.events
{
	import flash.events.Event;
	
	public class PintuEvent extends Event
	{
		
		public static const NAVIGATE:String = "navigate";
		public static const BROWSE_CHANGED:String = "browseChanged";
		public static const GETPICDETAILS:String = "getPicDetails";
		public static const IMAGE_LOADED:String = "imageLoaded";
		public static const REFRESH_GALLERY:String = "refreshGallery";
		public static const RANDOM_GALLERY:String = "randomGallery";
		public static const SEARCH_BYTAGS:String = "searchByTags";
		
		public var data:String;		
		
		public function PintuEvent(type:String, context:String){
			//都是冒泡事件
			super(type,true);
			this.data = context;
		}
		
		public override function  clone():Event{
			return new PintuEvent(type,data);
		}
		
	}
}