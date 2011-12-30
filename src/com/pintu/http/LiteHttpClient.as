package com.pintu.http{
	
	import com.pintu.events.*;
	import com.pintu.utils.Logger;
	
	import flash.events.*;
	import flash.net.*;
	
	public class LiteHttpClient extends EventDispatcher{
		
		private var _url:String;
		private var _urlLoader:URLLoader;
		private var _params:URLVariables;
		private var _isRuning:Boolean;
		
		public function LiteHttpClient(url:String){									
			_url = url;
			// create the image loader & send the image to the server;
			_urlLoader = new URLLoader();			
			_urlLoader.addEventListener( Event.COMPLETE, onDataLoaded );			
			_urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onDataError );
			_urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onDataError );			
		}
		
		public function isRunning():Boolean{
			return _isRuning;
		}
		
		public function send(values:URLVariables):void{
			_params = values;
			var urlRequest : URLRequest = new URLRequest();
			urlRequest.url = _url;			
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = values;
			urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
			
			if(_params.method){
				_urlLoader.load( urlRequest );	
				_isRuning = true;
			}else{
				Logger.warn("Lite httpclient not send, for lack of method parameter!");
			}
		}
		
		private function onDataLoaded(evt:Event):void{
			var method:String = _params.method;
			var result:String = _urlLoader.data;
			if(method){
//				Logger.debug("Lite httpclient,  onDataLoad: "+method+", "+result);
				var dataEvent:ResponseEvent = new ResponseEvent(method,result);
				dispatchEvent(dataEvent);
				
				//同时要通知任务队列，清除该任务
				dispatchEvent(new Event("complete"));
				
				_isRuning = false;
			}
		}
		private function onDataError(evt:Event):void{
			var method:String = _params.method;			
			if(method){
				Logger.debug("Lite httpclient,  onDataError: "+method+", "+"IO_ERROR");
				var error:PTErrorEvent = new PTErrorEvent(method,"IO_ERROR");
				dispatchEvent(error);
				
				//同时要通知任务队列，清除该任务
				dispatchEvent(new Event("complete"));
				
				_isRuning = false;
			}
		}
		
	} //end of class
}