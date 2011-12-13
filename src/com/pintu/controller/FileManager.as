package com.pintu.controller{
	
	import com.pintu.api.*;
	import com.pintu.events.*;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.ByteArray;
	
	import org.casalib.display.CasaSprite;
	
	[Event(name="imgInMemLoad", type="flash.events.Event")]
	[Event(name="imgDownload", type="flash.events.Event")]
	[Event(name="imgUploadSucces", type="flash.events.Event")]
	
	public class FileManager extends EventDispatcher{
		//上传图片被选定后，载入内存后派发的事件
		public static const IMG_INMEMLOAD:String = "imgInMemLoad";
		//下载完成
		public static const IMG_DOWNLOAD:String = "imgDownload";
		//上传成功
		public static const IMG_UPLOAD_SUCCESS:String = "imgUploadSucces";
		public static const IMG_UPLOAD_FAILURE:String = "imgUploadFailure";
		
		//得到的图片数据，供上传窗口预览使用
		public var availableImgData:ByteArray;
		
		private var m_upload:FileReference;
		private var m_download:FileReference;
		
		private var m_downloadURL : URLRequest;
		private var m_fileName : String;
		
		private var _model:IPintu;
		
		
		public function FileManager(model:IPintu){			
			_model = model;
			PintuImpl(_model).addEventListener(ApiMethods.UPLOAD,uploadSuccesHandler);
			
			m_upload = new FileReference();
			//上传文件已经选择
			m_upload.addEventListener( Event.SELECT, uploadSelectHandler);		
			//上传文件已经载入内存
			m_upload.addEventListener( Event.COMPLETE, imgLoadedHandler);			
			
			m_download = new FileReference();
			//文件下载完成
			m_download.addEventListener( Event.COMPLETE, downloadCompleteHandler );
		}
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		
		public function browse () : void{
			m_upload.browse( getImageTypes() );
		}
		
		public function download (picURL : String, picName : String ) : void{
			m_downloadURL = new URLRequest(picURL)
			m_fileName = picName;
			//打开对话框，让用户指定下载文件的保存目录
			m_download.download( m_downloadURL, m_fileName);
		}
		
		//PicEditWin调用
		public function uploadPicture(isOriginal:Boolean, tags:String, desc:String):void{
			_model.postPicture(m_upload,tags,desc,isOriginal?"1":"0");
		}
		
		/**
		 *	handlers for file upload ( complete set );	
		 **/
		
		private function uploadSelectHandler ( e : Event ) : void {			
			//必须载入文件数据
			m_upload.load();
			
			m_fileName = m_upload.name;
			trace( "selected image: "+m_fileName );						
		}
		//to show the selected pic in prev section...
		private function imgLoadedHandler(evt:Event):void{
			//保存获得的图片数据
			availableImgData = m_upload.data;
			dispatchEvent(new Event(IMG_INMEMLOAD));
			trace( "upload image loaded in memory;");		
		}
		
		private function uploadSuccesHandler(evt:Event):void{
			if(evt is ResponseEvent){
				dispatchEvent(new Event(IMG_UPLOAD_SUCCESS));
			}
			if(evt is PTErrorEvent){
				dispatchEvent(new Event(IMG_UPLOAD_FAILURE));
			}
		}
		
		/**
		 *	handler for file download;
		 **/
		private function downloadCompleteHandler ( e : Event ) : void{
			availableImgData = m_download.data;
			dispatchEvent(new Event(IMG_DOWNLOAD));
			trace( 'file download complete;' );
		}
		
		
		private function getImageTypes () : Array
		{
			return new Array( new FileFilter( "Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png" ) );
		}
		
		/**
		 *	returns new string representing the month, day, hour, minute and millisecond of creation for use as the image name;	
		 */
		private function getUniqueName () : String
		{
			var d : Date = new Date();
			
			return d.getMonth() + 1 + '' + d.getDate() + '' + d.getHours() + '' + d.getMinutes() + ''  + d.getMilliseconds();
		}
		
		public function cleanUp():void{
			PintuImpl(_model).removeEventListener(ApiMethods.UPLOAD,uploadSuccesHandler);
		}
		
		
	} //end of class
}