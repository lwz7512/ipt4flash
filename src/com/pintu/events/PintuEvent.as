package com.pintu.events
{
	import flash.events.Event;
	
	public class PintuEvent extends Event
	{
		
		public static const NAVIGATE:String = "navigate";
		public static const BROWSE_CHANGED:String = "browseChanged";
		public static const GETPICDETAILS:String = "getPicDetails";
		public static const IMAGE_LOADED:String = "imageLoaded";		
		public static const SEARCH_BYTAGS:String = "searchByTags";
		
		public static const REFRESH_GALLERY:String = "refreshGallery";
		public static const RANDOM_GALLERY:String = "randomGallery";
		public static const UPLOAD_IMAGE:String = "uploadImage";
		public static const DNLOAD_IMAGE:String = "dnloadImage";
		
		//弹出提示事件
		public static const HINT_USER:String = "hintToUser";
		
		//通常带的参数
		public var data:String;
		//第二参数
		public var extra:String;
		
		public function PintuEvent(type:String, context:String){
			//都是冒泡事件，可以传播到顶级对象
			super(type,true);
			this.data = context;
		}
		
		public override function  clone():Event{
			return new PintuEvent(type,data);
		}
		
	}
}