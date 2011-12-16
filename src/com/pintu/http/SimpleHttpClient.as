package com.pintu.http
{
	import com.adobe.net.URI;
	import com.adobe.utils.StringUtil;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.events.PTStatusEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
	
	import flash.events.*;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpClient;
	import org.httpclient.events.*;
	import org.httpclient.http.multipart.*;
	
	
	public class SimpleHttpClient extends EventDispatcher{
		
		private var _serviceUrl:String;
		private var _userId:String;
		//延迟生成，不在构造函数中生成
		//方便在销毁时判断
		private var _client:HttpClient;
		
		private var _isRuning:Boolean;
		
		public function SimpleHttpClient(serviceUrl:String, userId:String)
		{
			this._serviceUrl = serviceUrl;
			this._userId = userId;			
		}
		
		public function set userId(userId:String):void{
			this._userId = userId;
		}		
		
		/**
		 * 判断当前提交是否完成
		 */ 
		public function isRunning():Boolean{
			return _isRuning;
		}
		
		public function disconnect():void{
			if(_client) _client.close();			
		}
		
		/**
		 * params format:
		 * [{name:"key1", value:"FirstName1"}, {name:"key2", value: "LastName1"}];
		 */ 
		public function post(params:Array, method:String):void{
			//服务
			var uri:URI = new URI(_serviceUrl);
			//延迟生成客户端
			if(!_client) this._client = new HttpClient();
			if(!params) params = [];
			
			params = params.concat([ {name:"method", value: method}]);
			params = params.concat([ {name:"userId", value: _userId}]);
			params = params.concat([ {name:"owner", value: _userId}]);
			params = params.concat([ {name:"source", value: "desktop"}]);
			
			_client.listener.onStatus = function(event:HttpStatusEvent):void {
				// Notified of response (with headers but not content)
				var statusCode:String = event.code;
				var statusEvent:PTStatusEvent = new PTStatusEvent(method, statusCode);
				dispatchEvent(statusEvent);
//				Logger.debug("Method: "+method+" , status: "+statusCode);
			};
			
			_client.listener.onData = function(event:HttpDataEvent):void {
				// For string data
				var result:String = event.readUTFBytes();
				result = StringUtil.trim(result);
				var dataEvent:ResponseEvent = new ResponseEvent(method,result);
				dispatchEvent(dataEvent);
//				Logger.debug("Method: "+method+"\n"+"result: "+result);	
			};
			
			_client.listener.onComplete = function(event:HttpResponseEvent):void {
				// Notified when complete (after status and data)
				var response:String = event.response.message;
				
//				Logger.debug("Method: "+method+" , response: "+response);	
				
				//FIXME, HTTP任务执行完成后，ModelBase依据此方法来清除执行过的任务
				dispatchEvent(new Event("complete"));
				//提交结束
				_isRuning = false;
			};
			
			_client.listener.onError = function(event:ErrorEvent):void {
				var errorMessage:String = event.text;
				Logger.error("Method: "+method+" , error: "+errorMessage);
				var errorEvent:PTErrorEvent = new PTErrorEvent(method,errorMessage);
				dispatchEvent(errorEvent);
				//提交结束
				_isRuning = false;
			};  					
			
			_client.addEventListener(HttpErrorEvent.ERROR,function(evt:HttpErrorEvent):void{
				Logger.error("Method:"+method+" , error: "+evt.text);
			});
			_client.addEventListener(HttpErrorEvent.TIMEOUT_ERROR,function(evt:HttpErrorEvent):void{
				Logger.error("Method:"+method+" , error: "+evt.text);
			});
			_client.addEventListener(IOErrorEvent.IO_ERROR,function(evt:IOErrorEvent):void{
				Logger.error("Method:"+method+" , error: "+evt.text);
			});
			_client.addEventListener(SecurityErrorEvent.SECURITY_ERROR,function(evt:SecurityErrorEvent):void{
				Logger.error("Method:"+method+" , error: "+evt.text);
			});
			
			//提交
			_client.postFormData(uri, params);	
			//正在运行
			_isRuning = true;
		}
		
		/**		 
		 * params format:
		 * [{name:"key1", value:"FirstName1"}, {name:"key2", value: "LastName1"}];
		 */ 
		public function uploadImage(file:FileReference, params:Array):void{						
			if(!file.data){
				Logger.error("NO FILE DATA, EXECUTE FileReference.load() first!");
				return;
			}
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
				//字符集必须指定啊，否则中文是乱码
				//2011/11/27
				parts.push(new Part(param.name, param.value, "text/plain; charset=UTF-8"));
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
			
			//延迟生成客户端
			if(!_client) this._client = new HttpClient();
			
			_client.listener.onComplete = function(event:HttpResponseEvent):void {
				// Notified when complete (after status and data)
				var response:String = event.response.message;
//				Logger.debug("Method: upload , response: "+response);
				var completeEvent:ResponseEvent = new ResponseEvent("upload",response);
				dispatchEvent(completeEvent);
				//提交结束
				_isRuning = false;
			};
			
			_client.listener.onError = function(event:ErrorEvent):void {
				var errorMessage:String = event.text;
//				Logger.error("Method: upload, error: "+errorMessage);
				var errorEvent:PTErrorEvent = new PTErrorEvent("upload",errorMessage);
				dispatchEvent(errorEvent);
				//提交结束
				_isRuning = false;
			}; 
			
			_client.postMultipart(new URI(_serviceUrl), new Multipart(parts));
			//正在运行
			_isRuning = true;
		}
		
		
	}
}