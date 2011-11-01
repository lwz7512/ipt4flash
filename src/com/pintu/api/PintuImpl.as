package com.pintu.api
{
	import com.pintu.api.ApiMethods;
	import com.pintu.controller.GlobalController;
	import com.pintu.events.ResponseEvent;
	import com.pintu.http.SimpleHttpClient;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	
	import org.as3commons.collections.utils.NullComparator;

	public class PintuImpl extends EventDispatcher implements IPintu{
		
		private var client:SimpleHttpClient;
		
		private var debugService:String = "http://localhost:8080/ipintu/pintuapi";
		private var remoteService:String = "http://ipintu.com/ipintu/pintuapi";
		
		
		public function PintuImpl(){
			
			client = new SimpleHttpClient(getServiceUrl(),GlobalController.userId);
			
			client.addEventListener(ApiMethods.GETGALLERYBYTIME,responseHander);
			client.addEventListener(ApiMethods.GETGALLERYFORWEB,responseHander);
			client.addEventListener(ApiMethods.LOGON,responseHander);
			client.addEventListener(ApiMethods.UPLOAD,responseHander);
			//TODO, ADD OTHER LISTENER...
			
		}
		
		//这里指定泛型事件，因为可能是ResponseEvent，也可能是ErrorEvent
		private function responseHander(event:Event):void{
			this.dispatchEvent(event);
		}
		
		//TODO, 登录成功后更新用户
		public function updateUser(userId:String):void{
			client.userId = userId;
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
		
		public function logon(account:String, password:String):void{
			var params:Array = [{name:"account",value:account},{name:"password",value:password}];			
			client.post(params, ApiMethods.LOGON);			
		}
		
		public function getGalleryByTime(startTime:String, endTime:String):void{
			var params:Array = [{name:"startTime",value:startTime},{name:"endTime",value:endTime}];			
			client.post(params, ApiMethods.GETGALLERYBYTIME);					
		}
		
		public function getGalleryForWeb(pageNum:String):void{
			var params:Array = [{name:"pageNum",value:pageNum}];			
			client.post(params, ApiMethods.GETGALLERYFORWEB);				
		}
		
		public function postPicture(file:FileReference, tags:String, description:String, isOriginal:String):void{
			var params:Array = [{name:"tags",value:tags},{name:"description",value:description},
											{name:"isOriginal",value:isOriginal}];			
			client.upload(file,params);		
		}
		
		
	} //end of class
}