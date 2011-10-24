package com.pintu.utils
{
	public class Logger
	{
		public function Logger()
		{
		}
		
		public static function debug(info:String):void{
			trace(">D>: "+info);
		}
		
		public static function warn(info:String):void{
			trace(">W>: "+info);
		}
		
		public static function error(info:String):void{
			trace(">E>: "+info);
		}
		
	}
}