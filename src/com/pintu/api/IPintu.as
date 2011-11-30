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
		function getRandomGallery():void;
		function getHotPicture():void;
		function getClassicalPics():void;
		function getFavoredPics():void;
		function getThumbnailsByTag(tagId:String,pageNum:String):void;
		
		function postComment(follow:String, content:String):void;
		function getComments(tpId:String):void;
		/**
		 * 这里可以不用传userId值，client已经有该参数值了
		 */ 
		function markThePic(userId:String, picId:String):void
		function postVote(receiver:String, follow:String, type:String, amount:String):void
			
		
	}
}