package com.pintu.api{
	
	import com.pintu.controller.GlobalController;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.events.PintuEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.http.LiteHttpClient;
	import com.pintu.http.SimpleHttpClient;
	import com.pintu.utils.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	import org.as3commons.collections.ArrayList;
	
	/**
	 * 服务类的基础类，主要是对SimpleHttpClient的封装
	 * 以实现一个任务队列，来解决并发查询的问题
	 * 
	 * 其他功能还有：
	 * client状态检查、服务类销毁、用户更新
	 * 
	 * 该类不做任何与业务有关的事情
	 * 
	 * 2011/12/08
	 */ 
	public class ModelBase extends EventDispatcher{
		
		private var client:SimpleHttpClient;	
		
		private var lite:LiteHttpClient;
		
		private  var _currentUser:String;	
		/**
		 * HTTP任务队列，每隔100毫秒去检查一下
		 * 如果客户端空闲就执行第一个
		 * 执行完就移除队列的第一个
		 */ 
		private var taskQueue:ArrayList;
		private var taskTimer:Timer;
				
		private var debugService:String = "http://localhost:8080/ipintu/pintuapi";
		private var remoteService:String = "http://ipintu.com/ipintu/pintuapi";		
		
		
		public function ModelBase(userId:String){
			_currentUser = userId;
			
			lite = new LiteHttpClient(getServiceUrl());
			lite.addEventListener("complete",clearHeaderTask);
			lite.addEventListener("error",clearHeaderTask);
			
			client = new SimpleHttpClient(getServiceUrl(),userId);
			//执行一个，清除一个			
			client.addEventListener("complete",clearHeaderTask);
			//FIXME, 这有一个没执行完，其余的都挂了！！！
			//2011/12/21
			client.addEventListener("error",clearHeaderTask);
			
			taskQueue = new ArrayList();
			
			//慎用啊，销毁时一定要停掉
			//丫在不停的跑，真慎得慌
			//没关系，destory收拾你
			//2011/12/21
			taskTimer = new Timer(100);
			taskTimer.addEventListener(TimerEvent.TIMER, excuteTaskQueue);
			taskTimer.start();			
			
		}
		
		public function getServiceUrl():String{
			if(GlobalController.isDebug){
				return debugService;
			}else{
				return remoteService;
			}
			return null;
		}
		
		public function composeImgUrlById(imgId:String):String{
			return getServiceUrl() + "?method=" + ApiMethods.GETIMAGEFILE 
				+ "&tpId="+ imgId;
		}
		
		public function composeImgUrlByPath(imgPath:String):String{
			return getServiceUrl() + "?method=" + ApiMethods.GETIMAGEBYPATH
				+ "&path="+ imgPath;
		}
		
		public function get currentUser():String{
			return _currentUser;
		}
		
		//widget里被克隆出来的模型实例，必须各自销毁
		//Main中的全局模型不需要销毁
		public function destory():void{
			if(client) client.disconnect();
			if(taskTimer) taskTimer.stop();
			taskTimer = null;
		}
		
		/**
		 * 这个方法目前没用到啊，似乎没必要对外暴露啊
		 * 有了队列没必要整这个了
		 * 2011/12/21
		 */ 
		public function get isIdle():Boolean{
			return client.isRunning();
		}
		//登录成功后更新用户
		public function updateUser(userId:String):void{
			client.userId = userId;
			_currentUser = userId;
		}		
		
		/**
		 * 模型对client运行状态的监听
		 * 添加新的服务事件
		 */ 
		protected function addClientListener(method:String):void{
			if(useLiteClient(method)){
				lite.addEventListener(method, responseHander);			
			}else{
				client.addEventListener(method,responseHander);			
			}
		}
		
		//这里指定泛型事件，因为可能是ResponseEvent，也可能是PTErrorEvent
		//也有可能是状态事件PTStatusEvent，用于提交动作的响应
		//2011/11/29
		private function responseHander(event:Event):void{			
			
			//通知使用模型的模块
			dispatchEvent(event);	
			
			if(event is PTErrorEvent){
				var errorMsg:String = PTErrorEvent(event).type+" operation failed!";
				var hint:PintuEvent = new PintuEvent(PintuEvent.HINT_USER, errorMsg);
				dispatchEvent(hint);
			}
		}
		
		
		/**
		 * 新建任务到队列中<br/>
		 * 只管往进放，只是在模型调用层做查询拦截，例如：<br/>
		 * MainDisplayArea.queryPicByType用开关值和定时器拦截频繁调用<br/>
		 * 2011/12/21
		 */ 
		protected function addHttpTask(nameValues:Array, methodName:String):void{
			var task:Object = {method:methodName, params:nameValues};
			taskQueue.add(task);
			Logger.debug("Add Task: "+methodName);
		}		
		/**
		 * 定时查看队列，并执行第一个任务
		 * 只有在：队列不为空，而且客户端空闲时执行查询
		 * 这样保证只有一个客户端只有一个HTTP链接
		 */ 
		private function excuteTaskQueue(evt:TimerEvent):void{
			if(taskQueue.size>0 && !client.isRunning() && !lite.isRunning()){
				var params:Array = taskQueue.first.params;
				var method:String = taskQueue.first.method;	
				
				if(useLiteClient(method)){
					var vs:URLVariables = arrayToURLVariables(params);
					vs["method"] = method;
					lite.send(vs);
					Logger.debug("Start Execute: "+method+" -- liteClient...");
				}else{
					client.post(params, method);	
					Logger.debug("Start Execute: "+method+" -- socketClient...");
				}
			}
		}
		/**
		 * 执行完成后，清除第一个任务
		 */ 
		private function clearHeaderTask(evt:Event):void{
			var task:Object = taskQueue.removeFirst();
			Logger.debug("Task removed: "+task.method);
		}
		
		private function arrayToURLVariables(params:Array):URLVariables{
			var values:URLVariables = new URLVariables();
			//默认的用户参数是指向自己，如果params中有该参数，则覆盖它
			values["userId"] = _currentUser;
			for each(var param:Object in params){
				values[param.name] = param.value;
			}
			return values;
		}
		
		//FIXME, 新加的方法，获取数据的操作，都要在这里添加
		//2012/03/02
		private function useLiteClient(method:String):Boolean{
			var result:Boolean = false;
			if(method==ApiMethods.GETGALLERYFORWEB ||
				method==ApiMethods.GETGALLERYBYTIME ||
				method==ApiMethods.GETGALLERYRANDOM ||
				method==ApiMethods.GETHOTPICTURE ||
				method==ApiMethods.CLASSICALSTATISTICS ||
				method==ApiMethods.COLLECTSTATISTICS ||
				method==ApiMethods.GETTHUMBNAILSBYTAG ||
				method==ApiMethods.GETTPICSBYUSER ||
				method==ApiMethods.GETFAVORITEPICS ||
				method==ApiMethods.SEARCHBYTAG ||
				method==ApiMethods.ACTIVEUSERRANKING ||
				method==ApiMethods.GETMINIADS){
				
				result = true;
				
			}
			return result;
		}
		
	} //end of class
}