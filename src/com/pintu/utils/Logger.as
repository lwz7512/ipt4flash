package com.pintu.utils
{
	public class Logger
	{
		public function Logger()
		{
		}
		
		public static function debug(info:String):void{
			trace(">>> "+info);
		}
		
	}
}