package com.pintu.api
{
	import flash.net.FileReference;
	
	import org.httpclient.HttpClient;
	
	public interface IPintu{		
					
		function getServiceUrl():String;
		function composeImgUrlById(imgId:String):String;
		function composeImgUrlByPath(imgPath:String):String;
		
		function cancelRequest():void;
		
		function updateUser(userId:String):void;
		function logon(account:String, password:String):void;		
		function postPicture(file:FileReference, tags:String, description:String, isOriginal:String):void;
		
		function getGalleryByTime(startTime:String, endTime:String):void;
		
		function getPicDetail(tpId:String):void;
		
		function getGalleryForWeb(pageNum:String):void;
		function getHotPicture():void;
		function getClassicalPics():void;
		function getFavoredPics():void;
		function getThumbnailsByTag(tagId:String,pageNum:String):void;
		

		
		
		
	}
}