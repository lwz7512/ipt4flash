package com.pintu.http
{
	import com.adobe.net.URI;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
	
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpClient;
	import org.httpclient.events.*;
	import org.httpclient.http.multipart.*;
	
	
	public class SimpleHttpClient extends EventDispatcher{
		
		private var _serviceUrl:String;
		private var _userId:String;
		private var _client:HttpClient;
		
		public function SimpleHttpClient(serviceUrl:String, userId:String)
		{
			this._serviceUrl = serviceUrl;
			this._userId = userId;
			this._client = new HttpClient();
		}
		
		public function set userId(userId:String):void{
			this._userId = userId;
		}
		
		public function cancel():void{
			if(_client) _client.cancel();
		}
		
		/**
		 * params format:
		 * [{name:"key1", value:"FirstName1"}, {name:"key2", value: "LastName1"}];
		 */ 
		public function post(params:Array, method:String):void{
			
			var uri:URI = new URI(_serviceUrl);
			
			params = params.concat([ {name:"method", value: method}]);
			params = params.concat([ {name:"userId", value: _userId}]);
			params = params.concat([ {name:"source", value: "desktop"}]);
			
			_client.listener.onStatus = function(event:HttpStatusEvent):void {
				// Notified of response (with headers but not content)
				var statusCode:String = event.code;
//				Logger.debug("Method: "+method+" , status: "+statusCode);
			};
			
			_client.listener.onData = function(event:HttpDataEvent):void {
				// For string data
				var result:String = event.readUTFBytes();
				var dataEvent:ResponseEvent = new ResponseEvent(method,result);
				dispatchEvent(dataEvent);
			};
			
			_client.listener.onComplete = function(event:HttpResponseEvent):void {
				// Notified when complete (after status and data)
				var response:String = event.response.message;
//				Logger.debug("Method: "+method+" , response: "+response);				
			};
			
			_client.listener.onError = function(event:ErrorEvent):void {
				var errorMessage:String = event.text;
				Logger.error("Method: "+method+" , error: "+errorMessage);
				var errorEvent:PTErrorEvent = new PTErrorEvent(method,errorMessage);
				dispatchEvent(errorEvent);
			};  					
			
			_client.postFormData(uri, params);	
						
		}
		
		/**		 
		 * params format:
		 * [{name:"key1", value:"FirstName1"}, {name:"key2", value: "LastName1"}];
		 */ 
		public function uploadImage(file:FileReference, params:Array):void{						
			
			var fileName:String = file.name;
			var contentType:String = "image/jpeg";
			if(fileName.substr(fileName.length-2,3)=="png"){
				contentType = "image/png";
			}
			var sended:ByteArray = new ByteArray();
			//文件转为字节码data
			file.data.readBytes(sended,0,file.data.length);
			
			var parts:Array = [];
			//将参数解析封装
			for each(var param:Object in params){
				parts.push(new Part(param.name, param.value));
			}
			//方法参数必须传，后台用来区分上传图片的操作类型
			var method:Part = new Part("method", "upload");
			var user:Part = new Part("userId", _userId);
			var source:Part = new Part("source", "desktop");			
			var image:Part = new Part("file", sended, contentType, [{name:"filename", value:fileName}]);
			parts.push(method);
			parts.push(user);
			parts.push(source);
			parts.push(image);
						
			_client.listener.onComplete = function(event:HttpResponseEvent):void {
				// Notified when complete (after status and data)
				var response:String = event.response.message;
				Logger.debug("Method: upload , response: "+response);
				var completeEvent:ResponseEvent = new ResponseEvent("upload",response);
				dispatchEvent(completeEvent);
			};
			
			_client.listener.onError = function(event:ErrorEvent):void {
				var errorMessage:String = event.text;
				Logger.error("Method: upload, error: "+errorMessage);
				var errorEvent:PTErrorEvent = new PTErrorEvent("upload",errorMessage);
				dispatchEvent(errorEvent);
			}; 
			
			_client.postMultipart(new URI(_serviceUrl), new Multipart(parts));
			
		}
		
		
	}
}