package com.pintu.controller{
	
	import com.pintu.common.Toast;
	import com.pintu.config.InitParams;
	import com.pintu.utils.Logger;
	
	import flash.display.Sprite;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
	public class GlobalController{
		
		//是否为调试模式
		public static const isDebug:Boolean = false;		
		//默认来宾账号
		private static const GUEST_USER_ACCOUNT:String = "a6c7897a988870d8";
		
		//持久化存储对象
		private static var cs:SharedObject;	
		
		//运行时判断，主应用负责初始化
		private static var _isLogged:Boolean = false;					
		
		//默认是guest账号，登录后更新此记录，并更新缓存
		private static var userId:String = "a6c7897a988870d8";
		//默认是来宾角色
		private static var roleName:String = "guest";
		
		//将来做提示
		private static var toastContainer:Sprite;
		
	
		public static function initClientStorage(context:Sprite):void{
			//弹出异常提示的容器
			toastContainer = context;
			
			try{
				cs = SharedObject.getLocal("ipintu");				
			}catch(e:Error){
				Logger.error("Can not create client data storage!");
				Toast.getInstance(toastContainer).show(
					"Can not create client data storage!",
					InitParams.appWidth/2,
					InitParams.appHeight/2);
				return;
			}
			
			//如果用户登录过了，则从缓存中初始化用户信息
			if(cs.data["userId"])
				userId = cs.data["userId"];
			if(cs.data["roleName"])
				roleName = cs.data["roleName"];
			
		}
		
		
		public static function rememberUser(user:String, role:String):void{			
			//当前应用要保存下来
			userId = user;
			roleName = role;
			
			//同时保存到sharedobject文件
			cs = SharedObject.getLocal("ipintu");			
			cs.data["userId"] = user;
			cs.data["roleName"] = role;
			//存文件
			var result:String = cs.flush(500);
			//判断是否保存成功
			if(result==SharedObjectFlushStatus.FLUSHED){
				Logger.debug("User log info successfully saved to disk!");
			}
					
			
		}
		
		public static function clearUser():void{
			//清空缓存
			cs.clear();
			//用户ID置为guest
			userId = GUEST_USER_ACCOUNT;
		}
		
		public static function get loggedUser():String{						
			return userId;
		}
		
		public static function get isLogged():Boolean{
			//如果是guest用户，则没有登录
			if(userId==GUEST_USER_ACCOUNT){
				return false;
			}
			return true;
		}
		
		public static function get usePaperTile():Boolean{
			return true;
		}
		
		public function GlobalController()
		{
		}
	}
}