package com.pintu.controller
{
	public class GlobalController
	{
		//运行时判断，主应用负责初始化
		public static var isLogged:Boolean = false;
		
		//默认是guest账号，登录后更新此记录，并更新缓存
		private static var userId:String = "a6c7897a988870d8";
		//默认是来宾角色
		private static var roleName:String = "guest";
		
		//是否为调试模式
		public static const isDebug:Boolean = true;
		
		public static function rememberUser(user:String, role:String):void{
			userId = user;
			roleName = role;
			//TODO, 保存到sharedobject
			
		}
		
		public static function get user():String{
			return userId;
		}
		
		public function GlobalController()
		{
		}
	}
}