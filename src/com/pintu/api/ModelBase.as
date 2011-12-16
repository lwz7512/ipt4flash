package com.pintu.api{
	
	import com.pintu.controller.GlobalController;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.events.PintuEvent;
	import com.pintu.http.SimpleHttpClient;
	import com.pintu.utils.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
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
		
		protected var client:SimpleHttpClient;		
		
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
			
			client = new SimpleHttpClient(getServiceUrl(),userId);
			//执行一个，清除一个
			client.addEventListener("complete",clearHeaderTask);
			
			taskQueue = new ArrayList();
			
			//慎用啊，销毁时一定要停掉			
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
		
		public function get isIdle():Boolean{
			return client.isRunning();
		}
		//登录成功后更新用户
		public function updateUser(userId:String):void{
			client.userId = userId;
			_currentUser = userId;
		}
		
		/**
		 * 添加新的服务事件
		 */ 
		protected function addClientListener(method:String):void{
			client.addEventListener(method,responseHander);
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
		 * 新建任务到队列中
		 */ 
		public function addHttpTask(nameValues:Array, methodName:String):void{
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
			if(taskQueue.size>0 && !client.isRunning()){
				var params:Array = taskQueue.first.params;
				var method:String = taskQueue.first.method;
				
				client.post(params, method);
				Logger.debug("Start Execute: "+method);
			}
		}
		/**
		 * 执行完成后，清除第一个任务
		 */ 
		private function clearHeaderTask(evt:Event):void{
			var task:Object = taskQueue.removeFirst();
			Logger.debug("Task removed: "+task.method);
		}
		
	} //end of class
}