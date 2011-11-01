package com.pintu.controller
{
	public class GlobalController
	{
		//运行时判断，主应用负责初始化
		public static var isLogged:Boolean;
		
		//默认是guest账号，登录后更新此记录，并更新缓存
		public static var userId:String = "a6c7897a988870d8";
		
		//是否为调试模式
		public static const isDebug:Boolean = true;
		
		
		public function GlobalController()
		{
		}
	}
}