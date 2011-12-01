package com.pintu.api
{
	import flash.net.FileReference;
	
	import org.httpclient.HttpClient;
	
	public interface IPintu{	
		
		/**
		 * 这4个方法在ModelBase中实现
		 */ 
		//client是否空闲
		function get isIdle():Boolean;
		//停止队列
		function destory():void;
		//登录成功更新用户
		function updateUser(userId:String):void;	
		//服务地址
		function getServiceUrl():String;
		
		function composeImgUrlById(imgId:String):String;
		function composeImgUrlByPath(imgPath:String):String;			
		/**
		 * 单独操作，不存在并发请求
		 */ 
		function logon(account:String, password:String):void;	
		/**
		 * 单独操作，不存在并发请求
		 */ 
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
		
		function getUserDetail(userId:String):void
		
	}
}