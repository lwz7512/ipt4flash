package com.pintu.api
{
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpClient;
	
	/**
	 * 大部分的查询内容方法，都在主显示区调用
	 */ 
	public interface IPintu{	
		
		//-------------- 6个方法基本在ModelBase中实现 -----------------------
		/**
		 * client是否空闲
		 */
		function get isIdle():Boolean;
		/**
		 * 停止队列和计时器，这个很重要，必须在视图移除时调用
		 */
		function destory():void;		
		//登录成功更新用户
		function updateUser(userId:String):void;					
		//服务地址
		function getServiceUrl():String;				
		function composeImgUrlById(imgId:String):String;
		function composeImgUrlByPath(imgPath:String):String;
		//新增根据相对路径获取图片
		//2012/03/05
		function composeImgUrlByRelativePath(relaPath:String):String;
		
		//-------------- 业务逻辑方法 -------------------------------------------
		
		function logon(account:String, password:String):void;	
		/**
		 * 单独操作，不存在并发请求
		 */ 
		function postPicture(file:FileReference, tags:String, description:String, isOriginal:String):void;
		function postAvatar(imgData:ByteArray, nickName:String):void;
		
		function getGalleryByTime(startTime:String, endTime:String):void;		
		function getPicDetail(tpId:String):void;		
		function getGalleryForWeb(pageNum:String):void;
		function getRandomGallery():void;
		function getHotPicture():void;
		function getClassicalPics():void;
		function getFavoredPics():void;		
		
		function postComment(follow:String, content:String):void;
		function getComments(tpId:String):void;
		
		function markThePic(picId:String):void;
		function postVote(receiver:String, follow:String, type:String, amount:String):void;
		
		function getUserDetail(userId:String):void;
		function getUserEstate(userId:String):void;
		
		function postMsg(receiverId:String, content:String):void;
		function getUserMsgs():void;
		function markMsgReaded(msgIds:String):void;
		
		function getMyPostPics(pageNum:String):void;
		function getMyFavorites(pageNum:String):void;
		
		function getHotTags():void;
		function getThumbnailsByTag(tagId:String, pageNum:String):void;
		function searchPicByTagsInput(tags:String):void;
		
		function getActiveUserRanking():void;
		function getPicsByUser(userId:String, pageNum:String):void;
		
		//获取微广告数据
		//2012/03/02
		function getMiniAds():void;
		
		//转发到新浪微博
		//2012/05/04
		function forwardToWeibo(userId:String, picId:String):void;
		
		//-------------- 社区模块使用方法 -----------------------
		function getCommunityNotesBy(pageNum:String):void;
		function createNote(userId:String,type:String,title:String,content:String):void;
		function deleteNoteBy(noteId:String):void;
		function updateNoteBy(noteId:String, type:String, title:String, content:String):void;
		function addAttentionBy(noteId:String, count:String):void;
		function addInterestBy(noteId:String, count:String):void;
		function getUserNotesBy(userId:String):void;
		
		
		//--------------- 市场模块使用的方法 -------------------
		
		
		
		
		
		/**
		 * 多个视图用到同样的模型，为了防止事件监听干扰，各自使用各自的模型 
		 * 比如在PicDetailView组件中，多个图片都要有各自的动作，都要用到模型
		 * 2011/12/06
		 */
		function clone():IPintu;
		
	}
}