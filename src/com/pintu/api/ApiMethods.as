package com.pintu.api
{
	public class ApiMethods{
		
		//画廊缩略图，按时间分页，每页取32个
		public static const GETGALLERYBYTIME:String = "getGalleryByTime";
		//画廊大图，按页码分页，每页取12个
		public static const GETGALLERYFORWEB:String = "getGalleryForWeb";
		//随便看看
		public static const GETGALLERYRANDOM:String = "getRandGallery";
		//热图
		public static const GETHOTPICTURE:String = "getHotPicture";
		//经典
		public static const CLASSICALSTATISTICS:String = "classicalStatistics";
		//最近被收藏
		public static const COLLECTSTATISTICS:String = "collectStatistics";
		//按标签查询
		public static const GETTHUMBNAILSBYTAG:String = "getThumbnailsByTag";
		
		//查询图片详情
		public static const GETPICDETAIL:String = "getPicDetail";		
		//登录
		public static const LOGON:String = "logon";
		
		//上传贴图
		public static const UPLOAD:String = "upload";
		
		public static const GETIMAGEFILE:String = "getImageFile";
		public static const GETIMAGEBYPATH:String = "getImageByPath";
		
		//添加评论
		public static const ADDSTORY:String = "addStory";
		//获取评论列表
		public static const GETSTORIESOFPIC:String = "getStoriesOfPic";
		//收藏
		public static const MARKTHEPIC:String = "markThePic";
		//投票，喜欢
		public static const ADDVOTE:String= "addVote";
		
		//获取用户详情
		public static const GETUSERDETAIL:String = "getUserDetail";
		//获得用户资产
		public static const GETUSERESTATE:String = "getUserEstate";
		
		
		
	}
}