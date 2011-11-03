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
		
		public function SimpleHttpClient(serviceUrl:String, userId:String)
		{
			this._serviceUrl = serviceUrl;
			this._userId = userId;
		}
		
		public function set userId(userId:String):void{
			this._userId = userId;
		}
		
		
		/**
		 * params format:
		 * [{name:"key1", value:"FirstName1"}, {name:"key2", value: "LastName1"}];
		 */ 
		public function post(params:Array, method:String):void{
			var client:HttpClient = new HttpClient();
			var uri:URI = new URI(_serviceUrl);
			
			params = params.concat([ {name:"method", value: method}]);
			params = params.concat([ {name:"userId", value: _userId}]);
			params = params.concat([ {name:"source", value: "desktop"}]);
			
			client.listener.onStatus = function(event:HttpStatusEvent):void {
				// Notified of response (with headers but not content)
				var statusCode:String = event.code;
				Logger.debug("Method: "+method+" , status: "+statusCode);
			};
			
			client.listener.onData = function(event:HttpDataEvent):void {
				// For string data
				var result:String = event.readUTFBytes();
				var dataEvent:ResponseEvent = new ResponseEvent(method,result);
				dispatchEvent(dataEvent);
			};
			
			client.listener.onComplete = function(event:HttpResponseEvent):void {
				// Notified when complete (after status and data)
				var response:String = event.response.message;
				Logger.debug("Method: "+method+" , response: "+response);				
			};
			
			client.listener.onError = function(event:ErrorEvent):void {
				var errorMessage:String = event.text;
				Logger.error("Method: "+method+" , error: "+errorMessage);
				var errorEvent:PTErrorEvent = new PTErrorEvent(method,errorMessage);
				dispatchEvent(errorEvent);
			};  					
			
			client.postFormData(uri, params);			
		}
		
		/**		 
		 * 
		 */ 
		public function upload(file:FileReference, params:Array):void{
			var client:HttpClient = new HttpClient();
			var uri:URI = new URI(_serviceUrl);
			var contentType:String = "text/plain";
			
			var fileName:String = file.name;
			
			var data:ByteArray = new ByteArray();
			file.data.readBytes(data,0,file.data.length);
			
			//添加参数filename，作为文件上传时指定文件名
			params = params.concat([ { name:"filename", value:fileName } ]);
			params = params.concat([ {name:"userId", value: _userId}]);
			params = params.concat([ {name:"source", value: "desktop"}]);
			
			var multipart:Multipart = new Multipart([ 				
				new Part("file", data, contentType, params)
			]);
						
			client.listener.onComplete = function(event:HttpResponseEvent):void {
				// Notified when complete (after status and data)
				var response:String = event.response.message;
				Logger.debug("Method: upload , response: "+response);
				var completeEvent:ResponseEvent = new ResponseEvent("upload",response);
				dispatchEvent(completeEvent);
			};
			
			client.listener.onError = function(event:ErrorEvent):void {
				var errorMessage:String = event.text;
				Logger.error("Method: upload, error: "+errorMessage);
				var errorEvent:PTErrorEvent = new PTErrorEvent("upload",errorMessage);
				dispatchEvent(errorEvent);
			}; 
			
			client.postMultipart(uri, multipart);
			
		}
		
		
	}
}