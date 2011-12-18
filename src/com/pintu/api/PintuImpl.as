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
	import flash.utils.ByteArray;
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
	 * FileManager是个例外
	 * 
	 * 为什么要这样：
	 * 监听器保证回收正常，不会造成到新建的同类对象重复派发事件
	 */ 
	public class PintuImpl extends ModelBase implements IPintu{
						
		
		public function PintuImpl(userId:String){
			super(userId);															
			
			addClientListener(ApiMethods.LOGON);		
			
			addClientListener(ApiMethods.GETGALLERYBYTIME);			
			addClientListener(ApiMethods.GETGALLERYFORWEB);			
			addClientListener(ApiMethods.GETGALLERYRANDOM);			
			addClientListener(ApiMethods.GETHOTPICTURE);			
			addClientListener(ApiMethods.CLASSICALSTATISTICS);			
			addClientListener(ApiMethods.COLLECTSTATISTICS);			
			addClientListener(ApiMethods.GETTHUMBNAILSBYTAG);			
			addClientListener(ApiMethods.GETPICDETAIL);	
			
			addClientListener(ApiMethods.ADDSTORY);			
			addClientListener(ApiMethods.GETSTORIESOFPIC);			
			addClientListener(ApiMethods.MARKTHEPIC);			
			addClientListener(ApiMethods.ADDVOTE);
			
			addClientListener(ApiMethods.GETUSERDETAIL);			
			addClientListener(ApiMethods.GETUSERESTATE);	
			
			addClientListener(ApiMethods.SENDMSG);			
			addClientListener(ApiMethods.GETUSERMSG);			
			addClientListener(ApiMethods.CHANGEMSGSTATE);			
			
			
			
			//TODO, ADD OTHER LISTENER...
			
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
			myClient.addEventListener(ApiMethods.UPLOAD,function(evt:Event):void{
				//通知文件管理器
				dispatchEvent(evt);	
			});			
			myClient.addEventListener(ApiMethods.UPLOAD,function():void{
				myClient.disconnect();
			});		
			myClient.uploadImage(file, params, ApiMethods.UPLOAD);		
		}
		
		public function postAvatar(imgData:ByteArray, nickName:String):void{
			var params:Array = [{name:"nickName",value:nickName}];				
			var myClient:SimpleHttpClient = new SimpleHttpClient(getServiceUrl(),this.currentUser);
			myClient.addEventListener(ApiMethods.UPLDAVATAR,function(evt:Event):void{
				//通知文件管理器
				dispatchEvent(evt);	
			});			
			myClient.addEventListener(ApiMethods.UPLDAVATAR,function():void{
				myClient.disconnect();
			});		
			myClient.uploadAvatar(imgData, params, ApiMethods.UPLDAVATAR);
			
		}
		
		public function logon(account:String, password:String):void{
			var params:Array = [{name:"account",value:account},{name:"password",value:password}];
			addHttpTask(params, ApiMethods.LOGON);
		}
		
		public function getGalleryByTime(startTime:String, endTime:String):void{
			var params:Array = [{name:"startTime",value:startTime},{name:"endTime",value:endTime}];			
			addHttpTask(params, ApiMethods.GETGALLERYBYTIME);				
		}
		
		public function getRandomGallery():void{
			addHttpTask([], ApiMethods.GETGALLERYRANDOM);
		}
		
		public function getGalleryForWeb(pageNum:String):void{
			var params:Array = [{name:"pageNum",value:pageNum}];			
			addHttpTask(params, ApiMethods.GETGALLERYFORWEB);				
		}
		
		public function getHotPicture():void{
			addHttpTask([], ApiMethods.GETHOTPICTURE);
		}
		
		public function getClassicalPics():void{
			addHttpTask([], ApiMethods.CLASSICALSTATISTICS);
		}
		
		public function getFavoredPics():void{
			addHttpTask([],ApiMethods.COLLECTSTATISTICS);
		}
		
		public function getThumbnailsByTag(tagId:String,pageNum:String):void{
			var params:Array = [{name:"tagId",value:tagId},{name:"pageNum",value:pageNum}];
			addHttpTask(params, ApiMethods.GETTHUMBNAILSBYTAG);
		}
		
		public function getPicDetail(tpId:String):void{
			var params:Array = [{name:"tpId",value:tpId}];
			addHttpTask(params,ApiMethods.GETPICDETAIL);
		}
		
		public function postComment(follow:String, content:String):void{
			var params:Array = [{name:"follow",value:follow},{name:"content",value:content}];
			addHttpTask(params, ApiMethods.ADDSTORY);
		}
		
		public function getComments(tpId:String):void{
			var params:Array = [{name:"tpId",value:tpId}];
			addHttpTask(params, ApiMethods.GETSTORIESOFPIC);
		}
		
		public function markThePic(userId:String, picId:String):void{
			//其实在client中已经把userId传进去了
			var params:Array = [{name:"picId",value:picId}];
			addHttpTask(params, ApiMethods.MARKTHEPIC);
		}
		
		public function postVote(receiver:String, follow:String, type:String, amount:String):void{
			var params:Array = [{name:"receiver",value:receiver},{name:"follow",value:follow},
				{name:"type",value:type},{name:"amount",value:amount}];
			addHttpTask(params, ApiMethods.ADDVOTE);
		}
		
		public function getUserDetail(userId:String):void{
			var params:Array = [{name:"userId",value:userId}];
			addHttpTask(params, ApiMethods.GETUSERDETAIL);
		}
		
		public function getUserEstate(userId:String):void{
			var params:Array = [{name:"userId",value:userId}];
			addHttpTask(params, ApiMethods.GETUSERESTATE);
		}
		
		public function postMsg(receiver:String, content:String):void{
			var params:Array = [{name:"receiver",value:receiver}, {name:"content",value:content}];
			addHttpTask(params, ApiMethods.SENDMSG);
		}
		
		public function getUserMsgs():void{
			addHttpTask([], ApiMethods.GETUSERMSG);
		}
		
		public function markMsgReaded(msgIds:String):void{
			var params:Array = [{name:"msgIds",value:msgIds}];
			addHttpTask(params, ApiMethods.CHANGEMSGSTATE);
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