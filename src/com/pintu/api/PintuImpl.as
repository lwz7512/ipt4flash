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
			
			addClientListener(ApiMethods.LOGON,false);		
			
			addClientListener(ApiMethods.GETGALLERYBYTIME);			
			addClientListener(ApiMethods.GETGALLERYFORWEB);			
			addClientListener(ApiMethods.GETGALLERYRANDOM);			
			addClientListener(ApiMethods.GETHOTPICTURE);			
			addClientListener(ApiMethods.CLASSICALSTATISTICS);			
			addClientListener(ApiMethods.COLLECTSTATISTICS);			
			addClientListener(ApiMethods.GETTHUMBNAILSBYTAG);	
			
			addClientListener(ApiMethods.GETPICDETAIL);	
			
			addClientListener(ApiMethods.ADDSTORY,false);			
			addClientListener(ApiMethods.GETSTORIESOFPIC);			
			addClientListener(ApiMethods.MARKTHEPIC,false);			
			addClientListener(ApiMethods.ADDVOTE,false);
			
			addClientListener(ApiMethods.GETUSERDETAIL);			
			addClientListener(ApiMethods.GETUSERESTATE);	
			
			addClientListener(ApiMethods.SENDMSG,false);			
			addClientListener(ApiMethods.GETUSERMSG);			
			addClientListener(ApiMethods.CHANGEMSGSTATE,false);			
			
			addClientListener(ApiMethods.GETTPICSBYUSER);	
			addClientListener(ApiMethods.GETFAVORITEPICS);	
			
			addClientListener(ApiMethods.GETHOTTAGS);					
			addClientListener(ApiMethods.GETTHUMBNAILSBYTAG);					
			addClientListener(ApiMethods.SEARCHBYTAG);	
			
			addClientListener(ApiMethods.ACTIVEUSERRANKING);
			
			addClientListener(ApiMethods.GETMINIADS);		
			
			addClientListener(ApiMethods.FORWARDTOWEIBO);	
			
			//---------- 社区方法 -------------------------
			addClientListener(ApiMethods.GETCOMMUNITYNOTES);	
			addClientListener(ApiMethods.GETUSERNOTES);	
			addClientListener(ApiMethods.ADDNOTE,false);	
			addClientListener(ApiMethods.DELETENOTE,false);	
			addClientListener(ApiMethods.UPDATENOTE,false);	
			addClientListener(ApiMethods.ADDATTENTION,false);	
			addClientListener(ApiMethods.ADDINTEREST,false);				
			
			
			//TODO, add market event listener...
			
			
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
		
		public function markThePic(picId:String):void{
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
		
		public function postMsg(receiver:String, content:String, reference:String):void{
			var params:Array = [{name:"receiver",value:receiver}, {name:"content",value:content}];
			params.push({name:"reference",value:reference});
			addHttpTask(params, ApiMethods.SENDMSG);
		}
		
		public function getUserMsgs():void{
			addHttpTask([], ApiMethods.GETUSERMSG);
		}
		
		public function markMsgReaded(msgIds:String):void{
			var params:Array = [{name:"msgIds",value:msgIds}];
			addHttpTask(params, ApiMethods.CHANGEMSGSTATE);
		}
		
		public function getMyPostPics(pageNum:String):void{
			var params:Array = [{name:"pageNum",value:pageNum}];
			addHttpTask(params, ApiMethods.GETTPICSBYUSER);
		}
		
		public function getMyFavorites(pageNum:String):void{
			var params:Array = [{name:"pageNum",value:pageNum}];
			addHttpTask(params, ApiMethods.GETFAVORITEPICS);
		}
		
		public 	function getHotTags():void{
			addHttpTask([], ApiMethods.GETHOTTAGS);
		}
		
		public function getThumbnailsByTag(tagId:String,pageNum:String):void{
			var params:Array = [{name:"tagId",value:tagId},{name:"pageNum",value:pageNum}];
			addHttpTask(params, ApiMethods.GETTHUMBNAILSBYTAG);
		}
		
		public function searchPicByTagsInput(tags:String):void{
			var params:Array = [{name:"tags",value:tags}];
			addHttpTask(params, ApiMethods.SEARCHBYTAG);
		}
		
		public function getActiveUserRanking():void{
			addHttpTask([], ApiMethods.ACTIVEUSERRANKING);
		}		
		
		public function getPicsByUser(userId:String, pageNum:String):void{
			var params:Array = [{name:"userId",value:userId}, {name:"pageNum",value:pageNum}];
			addHttpTask(params, ApiMethods.GETTPICSBYUSER);
		}
		
		public function getMiniAds():void{
			//查询管理员发布的广告
			//2012/03/21
			var venderId:String = GlobalController.ADMIN_ID;
			var params:Array = [{name:"venderId",value:venderId}];
			addHttpTask(params, ApiMethods.GETMINIADS);
		}
		
		public function forwardToWeibo(userId:String, picId:String):void{
			var params:Array = [{name:"userId",value:userId}, {name:"picId", value:picId}];
			addHttpTask(params, ApiMethods.FORWARDTOWEIBO);
		}
		
		//-------------- 社区模块使用的方法 ----------------------------
		public function getCommunityNotesBy(pageNum:String):void{
			var params:Array = [{name:"pageNum",value:pageNum}];
			addHttpTask(params, ApiMethods.GETCOMMUNITYNOTES);
		}
		
		public function createNote(userId:String,type:String,title:String,content:String):void{
			var params:Array = [{name:"type",value:type}];
			params.push({name:"title",value:title});
			params.push({name:"content",value:content});
			addHttpTask(params, ApiMethods.ADDNOTE);
		}
		
		public function deleteNoteBy(noteId:String):void{
			var params:Array = [{name:"noteId",value:noteId}];
			addHttpTask(params, ApiMethods.DELETENOTE);
		}
		
		public function updateNoteBy(noteId:String, type:String, title:String, content:String):void{
			var params:Array = [{name:"noteId",value:noteId}];
			params.push({name:"type",value:type});
			params.push({name:"title",value:title});
			params.push({name:"content",value:content});
			addHttpTask(params, ApiMethods.UPDATENOTE);
		}
		
		public function addAttentionBy(noteId:String, count:String):void{
			var params:Array = [{name:"noteId",value:noteId},{name:"count",value:1}];
			addHttpTask(params, ApiMethods.ADDATTENTION);
		}
		
		public function addInterestBy(noteId:String, count:String):void{
			var params:Array = [{name:"noteId",value:noteId},{name:"count",value:1}];
			addHttpTask(params, ApiMethods.ADDINTEREST);
		}
		
		public function getUserNotesBy(userId:String):void{
			addHttpTask([], ApiMethods.GETUSERNOTES);
		}
		
		
		//------------- 市场模块使用的方法 ------------------------------			
		
		
		
		//------------- 与业务无关的方法 -------------------------------------
		
		/**
		 * 必须加个事件监听阻止方法，放置重复对模型添加事件监听
		 * 所有的重复事件，在这里就能发出警告
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