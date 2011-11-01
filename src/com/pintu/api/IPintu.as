package com.pintu.api
{
	import flash.net.FileReference;
	
	public interface IPintu{		
		
		function updateUser(userId:String):void;
		function getServiceUrl():String;
		function composeImgUrlById(imgId:String):String;
		function composeImgUrlByPath(imgPath:String):String;
		
		function getGalleryByTime(startTime:String, endTime:String):void;
		function getGalleryForWeb(pageNum:String):void;
		function logon(account:String, password:String):void;
		
		function postPicture(file:FileReference, tags:String, description:String, isOriginal:String):void;
		
		
	}
}