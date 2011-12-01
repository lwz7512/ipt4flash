package com.pintu.api{
	
	import com.pintu.controller.GlobalController;
	import com.pintu.http.SimpleHttpClient;
	import com.pintu.utils.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.as3commons.collections.ArrayList;
	
	public class ModelBase extends EventDispatcher{
		
		protected var client:SimpleHttpClient;		
		protected  var _currentUser:String;
		
		private var debugService:String = "http://localhost:8080/ipintu/pintuapi";
		private var remoteService:String = "http://ipintu.com/ipintu/pintuapi";		
		private var taskQueue:ArrayList;
		private var taskTimer:Timer;
				
		
		
		public function ModelBase(userId:String){
			_currentUser = userId;
			client = new SimpleHttpClient(getServiceUrl(),userId);
			//执行一个，清除一个
			client.addEventListener("complete",clearHeaderTask);
			
			taskQueue = new ArrayList();
			//慎用啊，销毁时一定要停掉
			taskTimer = new Timer(10);
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
		
		public function destory():void{
			taskTimer.stop();
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
		 * 新建任务到队列中
		 */ 
		public function addHttpTask(nameValues:Array, methodName:String):void{
			var task:Object = {method:methodName, params:nameValues};
			taskQueue.add(task);
			Logger.debug("Add Task: "+methodName);
		}		
		/**
		 * 定时查看队列，并执行第一个任务
		 */ 
		private function excuteTaskQueue(evt:TimerEvent):void{
			if(taskQueue.size>0 && !client.isRunning()){
				var method:String = taskQueue.first.method;
				var params:Array = taskQueue.first.params;
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