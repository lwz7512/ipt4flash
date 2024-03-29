package com.pintu.controller{
	
	import com.pintu.common.Toast;
	import com.pintu.config.InitParams;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	
	import flash.display.Sprite;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
	/**
	 * 用于登陆用户状态缓存
	 * 以及用户设置保存
	 * 2011/12/21
	 */ 
	public class GlobalController{
		
		/**
		 * 每次登陆后记下账号，用于修改昵称时调用
		 * UserDetailsBlock在获取用户数据后记下
		 * UserEditWin在打开窗口时，要显示修改
		 */ 
		public static var account:String;
		
		//FIXME, 是否为调试模式
		public static const isDebug:Boolean = false;
		
		//爱品图账号，用于转发微博到爱品图
		//2012/05/04
		public static const IPINTU_ID:String = "833a99772360fcfb";
		
		//FIXME, 微广告系统中的ipint用户ID，用于取回管理员发布的广告
		//2012/04/24
		public static const ADMIN_ID:String = "96a28a3e859a66b1";
		
		//默认收信人，客服
		public static const KEFU_ID:String = "b8931b314c24dca4";
		public static const KEFU_NAME:String = "客服小辣椒";
		
		//用户反馈收信人
		public static const PRODUCT_MANAGER_ID:String = "b053beae20125b5b";
		public static const PRODUCT_MANAGER_NAME:String = "产品经理";
		
		//默认来宾账号
		private static const GUEST_USER_ACCOUNT:String = "a6c7897a988870d8";		
		//持久化存储对象
		private static var cs:SharedObject;			
		//运行时判断，主应用负责初始化
		private static var _isLogged:Boolean = false;							
		//默认是guest账号，登录后更新此记录，并更新缓存
		private static var userId:String = GUEST_USER_ACCOUNT;
		//默认是来宾角色
		private static var roleName:String = "guest";
		
		//派发提示事件
		private static var _context:Sprite;
		//设置的浏览模式
		private static var _browseType:String;
		
	
		public static function initClientStorage(context:Sprite):void{
			_context = context;
			
			try{
				//FIXME, ADD LOACALPATH FOR MULTI SWF ACCESS
				//2012/02/01
				cs = SharedObject.getLocal("ipintu", "/");				
			}catch(e:Error){
				Logger.error("Can not create client data storage!");
				
				hintToUser("Can not create client data storage!");
								
				return;
			}
			
			//如果缓存过用户，那么肯定是登陆过了
			if(cs.data["userId"] && cs.data["roleName"]){
				_isLogged = true;
			}
			
			//如果用户登录过了，则从缓存中初始化用户信息
			if(cs.data["userId"]) userId = cs.data["userId"];
			if(cs.data["roleName"]) roleName = cs.data["roleName"];
			
			//初始化保存过的浏览方式
			if(cs.data["browseType"]) _browseType = cs.data["browseType"];
			
			//观察微博授权日期
			//2012/06/01
			var expireTime:String = cs.data["expireTime"];
			if(expireTime && Number(expireTime)){
				var expireMilisecs:Number = Number(expireTime);
				var future:Date = new Date();
				future.time = expireMilisecs;
				Logger.debug("expireTime is: "+future.fullYear+"/"+(future.month+1)+"/"+future.date);
			}else{
				Logger.debug("NO EXPIRE TIME VALUE FOR WEIBO ...");
			}
			
		}
		/**
		 * 登录时用到
		 */ 
		public static function isGuestLogin(user:String):Boolean{
			if(user==GUEST_USER_ACCOUNT) return true;
			return false;
		}
		/**
		 * 转发时判断是否是GUEST用户登录了
		 */ 
		public static function isGuest():Boolean{
			if(userId==GUEST_USER_ACCOUNT) return true;
			return false;
		}
		
		/**
		 * 通过用户名密码登陆成功后，缓存用户信息
		 */ 
		public static function rememberUser(user:String, role:String):void{			
			//当前应用要保存下来
			userId = user;
			roleName = role;
			_isLogged = true;
			
			//FIXME, ADD LOACALPATH FOR MULTI SWF ACCESS
			//2012/02/01
			//同时保存到sharedobject文件
			cs = SharedObject.getLocal("ipintu", "/");			
			cs.data["userId"] = user;
			cs.data["roleName"] = role;
			//存文件
			var result:String = cs.flush(500);
			//判断是否保存成功
			if(result==SharedObjectFlushStatus.FLUSHED){
				Logger.debug("User login succeed!");
			}
			
		}
		
		public static function rememberBrowseType(browseType:String):void{
			
			_browseType = browseType;
			
			cs = SharedObject.getLocal("ipintu", "/");			
			cs.data["browseType"] = browseType;
			var result:String = cs.flush(500);
			//判断是否保存成功
			if(result==SharedObjectFlushStatus.FLUSHED){
				Logger.debug("save browse type succeed!");
				
				hintToUser("设置保存成功，下次访问生效！");
			}
		}
		
		public static function get browseType():String{
			return _browseType;
		}
		
		private static function hintToUser(info:String):void{
			var hint:PintuEvent = new PintuEvent(PintuEvent.HINT_USER, info);
			_context.dispatchEvent(hint);
		}
		
		public static function clearUser():void{
			//清空缓存
			cs.clear();
			_isLogged = false;
			//用户ID置为guest
			userId = GUEST_USER_ACCOUNT;
			Logger.debug("User log out!");
		}
		
		public static function get loggedUser():String{						
			return userId;
		}
		
		public static function get isLogged():Boolean{
			//如果是guest用户，则没有登录
			return _isLogged;
		}
		
		public static function get usePaperTile():Boolean{
			return true;
		}
		
		public static function isAdmin():Boolean{
			if(roleName=="admin") return true;
			return false;
		}
				
		/**
		 * 获得用户微博授权时间，如果为空表示未授权用户<br/>
		 * 判断这个值，如果为0，点击转发至微博时，就跳到授权页面<br/>
		 * 
		 * 2012/06/01
		 */ 
		public static function get weiboExpireTime():Number{
			cs = SharedObject.getLocal("ipintu", "/");
			var expireTime:String = cs.data["expireTime"];
			if(expireTime && expireTime.length){
				return Number(expireTime);
			}
			return 0;
		}
		
		
	}
}