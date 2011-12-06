package com.pintu.api
{
	import com.pintu.api.ApiMethods;
	import com.pintu.controller.GlobalController;
	import com.pintu.events.*;
	import com.pintu.http.SimpleHttpClient;
	import com.pintu.utils.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.Timer;
	
	import org.as3commons.collections.ArrayList;
	import org.httpclient.HttpClient;
	import org.osmf.events.TimeEvent;
	
	/**
	 * 应用内部所有引用PintuImpl实例model的widget
	 * 如果要对model添加事件监听时要：
	 * 在Event.ADDED_TO_STAGE进行服务事件的添加
	 * 在Event.REMOVED_FROM_STAGE进行服务事件的移除
	 * 不能在widget的构造函数中对服务事件监听
	 * 
	 * 约定：只有widget才能监听PintuImpl实例的服务事件ApiMethods.*
	 * 
	 * 为什么要这样：
	 * 监听器保证回收正常，不会造成到新建的同类对象重复派发事件
	 */ 
	public class PintuImpl extends ModelBase implements IPintu{
				
		private var eventSended:Event;
		
		public function PintuImpl(userId:String){
			super(userId);															
			
			client.addEventListener(ApiMethods.LOGON,responseHander);
			
			client.addEventListener(ApiMethods.GETGALLERYBYTIME,responseHander);
			client.addEventListener(ApiMethods.GETGALLERYFORWEB,responseHander);
			client.addEventListener(ApiMethods.GETGALLERYRANDOM,responseHander);
			
			client.addEventListener(ApiMethods.GETHOTPICTURE,responseHander);
			client.addEventListener(ApiMethods.CLASSICALSTATISTICS,responseHander);
			client.addEventListener(ApiMethods.COLLECTSTATISTICS,responseHander);
			client.addEventListener(ApiMethods.GETTHUMBNAILSBYTAG,responseHander);
			client.addEventListener(ApiMethods.GETPICDETAIL,responseHander);
			
			client.addEventListener(ApiMethods.ADDSTORY,responseHander);
			client.addEventListener(ApiMethods.GETSTORIESOFPIC,responseHander);
			client.addEventListener(ApiMethods.MARKTHEPIC,responseHander);
			client.addEventListener(ApiMethods.ADDVOTE,responseHander);
			
			client.addEventListener(ApiMethods.GETUSERDETAIL,responseHander);
			
			//TODO, ADD OTHER LISTENER...
			
		}
				
		//这里指定泛型事件，因为可能是ResponseEvent，也可能是PTErrorEvent
		//也有可能是状态事件PTStatusEvent，用于提交动作的响应
		//2011/11/29
		private function responseHander(event:Event):void{
			if(event is PTStatusEvent){
				Logger.debug("*** Model to dispatch PTStatusEvent event ***");
			}
			if(event is ResponseEvent){
				Logger.debug("*** Model to dispatch ResponseEvent event ***");
			}
			//通知使用模型的模块
			dispatchEvent(event);
			//remember it
			eventSended = event;
		}
				
		
		
		public function composeImgUrlById(imgId:String):String{
			return getServiceUrl() + "?method=" + ApiMethods.GETIMAGEFILE 
				+ "&tpId="+ imgId;
		}
		
		public function composeImgUrlByPath(imgPath:String):String{
			return getServiceUrl() + "?method=" + ApiMethods.GETIMAGEBYPATH
				+ "&path="+ imgPath;
		}
		
		public function postPicture(file:FileReference, tags:String, description:String, isOriginal:String):void{
			var params:Array = [{name:"tags",value:tags},{name:"description",value:description},
											{name:"isOriginal",value:isOriginal}];				
			var myClient:SimpleHttpClient = new SimpleHttpClient(getServiceUrl(),this.currentUser);
			myClient.addEventListener(ApiMethods.UPLOAD,responseHander);
			myClient.addEventListener(ApiMethods.UPLOAD,function():void{
				myClient.disconnect();
			});		
			myClient.uploadImage(file,params);		
		}		
		
		public function logon(account:String, password:String):void{
			var params:Array = [{name:"account",value:account},{name:"password",value:password}];			
//			var myClient:SimpleHttpClient = new SimpleHttpClient(getServiceUrl(),this.currentUser);
//			myClient.addEventListener(ApiMethods.LOGON,responseHander);
//			myClient.addEventListener("complete",function():void{
//				myClient.disconnect();
//			});		
//			myClient.post(params, ApiMethods.LOGON);		
			addHttpTask(params, ApiMethods.LOGON);
		}
		
		public function getGalleryByTime(startTime:String, endTime:String):void{
			var params:Array = [{name:"startTime",value:startTime},{name:"endTime",value:endTime}];			
			addHttpTask(params, ApiMethods.GETGALLERYBYTIME);				
		}
		
		public function getRandomGallery():void{
			addHttpTask([],ApiMethods.GETGALLERYRANDOM);
		}
		
		public function getGalleryForWeb(pageNum:String):void{
			var params:Array = [{name:"pageNum",value:pageNum}];			
			addHttpTask(params, ApiMethods.GETGALLERYFORWEB);				
		}
		
		public function getHotPicture():void{
			addHttpTask([],ApiMethods.GETHOTPICTURE);
		}
		
		public function getClassicalPics():void{
			addHttpTask([],ApiMethods.CLASSICALSTATISTICS);
		}
		
		public function getFavoredPics():void{
			addHttpTask([],ApiMethods.COLLECTSTATISTICS);
		}
		
		public function getThumbnailsByTag(tagId:String,pageNum:String):void{
			var params:Array = [{name:"tagId",value:tagId},{name:"pageNum",value:pageNum}];
			addHttpTask(params,ApiMethods.GETTHUMBNAILSBYTAG);
		}
		
		public function getPicDetail(tpId:String):void{
			var params:Array = [{name:"tpId",value:tpId}];
			addHttpTask(params,ApiMethods.GETPICDETAIL);
		}
		
		public function postComment(follow:String, content:String):void{
			var params:Array = [{name:"follow",value:follow},{name:"content",value:content}];
			addHttpTask(params,ApiMethods.ADDSTORY);
		}
		
		public function getComments(tpId:String):void{
			var params:Array = [{name:"tpId",value:tpId}];
			addHttpTask(params,ApiMethods.GETSTORIESOFPIC);
		}
		
		public function markThePic(userId:String, picId:String):void{
			//其实在client中已经把userId传进去了
			var params:Array = [{name:"picId",value:picId}];
			addHttpTask(params,ApiMethods.MARKTHEPIC);
		}
		
		public function postVote(receiver:String, follow:String, type:String, amount:String):void{
			var params:Array = [{name:"receiver",value:receiver},{name:"follow",value:follow},
				{name:"type",value:type},{name:"amount",value:amount}];
			addHttpTask(params,ApiMethods.ADDVOTE);
		}
		
		public function getUserDetail(userId:String):void{
			var params:Array = [{name:"userId",value:userId}];
			addHttpTask(params,ApiMethods.GETUSERDETAIL);
		}
		

		
		
		
		/**
		 * 必须加个事件监听阻止方法，放置重复对模型添加事件监听
		 * 所有的重复事件，可能就是没有这个处理引起的
		 */
		override public function addEventListener(type:String, listener:Function, userCapture:Boolean=false,priority:int=0,useWeakReference:Boolean=false):void{
			if(this.hasEventListener(type)){
				Logger.warn(" Duplicate event listener registration, for : "+type);
				return;
			}
			super.addEventListener(type,listener);
		}
		
		public function clone():IPintu{
			return new PintuImpl(currentUser);
		}
		
	} //end of class
}