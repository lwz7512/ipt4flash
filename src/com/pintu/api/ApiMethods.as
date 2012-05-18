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
		
		//查询图片详情
		public static const GETPICDETAIL:String = "getPicDetail";		
		//登录
		public static const LOGON:String = "logon";
		
		//上传贴图
		public static const UPLOAD:String = "upload";
		//上传头像
		public static const UPLDAVATAR:String = "uploadAvatar";
		
		public static const GETIMAGEFILE:String = "getImageFile";
		public static const GETIMAGEBYPATH:String = "getImageByPath";
		//2012/03/05
		public static const GETIMAGEBYRELAPATH:String = "getImgByRelativePath";
		
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
		
		//发送消息
		public static const SENDMSG:String = "sendMsg";
		//收消息
		public static const GETUSERMSG:String  = "getUserMsg";
		//更新消息状态为已读
		public static const CHANGEMSGSTATE:String = "changeMsgState";
		
		//获取自己的作品
		public static const GETTPICSBYUSER:String = "getTpicsByUser";
		//获取自己的收藏
		public static const GETFAVORITEPICS:String = "getFavoriteTpics";
		
		//获取热门标签
		public static const GETHOTTAGS:String = "getHotTags";
		//获取某标签的图片
		public static const GETTHUMBNAILSBYTAG:String = "getThumbnailsByTag";
		//按标签输入搜索
		public static const SEARCHBYTAG:String="searchByTag";		
		
		//获取活跃用户排行榜
		public static const ACTIVEUSERRANKING:String = "getActiveUserRanking";
		
		//获取微广告
		//2012/03/02
		public static const GETMINIADS:String = "getTodayAds";
		
		//转发到微博
		//2012/05/04
		public static const FORWARDTOWEIBO:String = "forwardToWeibo";
		
		//-------------社区模块相关API------------------
		//2012/05/17
		
		//翻页查看社区的条子
		public static const GETCOMMUNITYNOTES:String = "getCommunityNotes";
		//添加新条子
		public static const ADDNOTE:String = "addNote";
		//删除某个条子
		public static const DELETENOTE:String = "deleteNoteById";
		//修改某个条子
		public static const UPDATENOTE:String = "updateNoteById";
		//增加关注数
		public static const ADDATTENTION:String = "addAttentionById";
		//增加感兴趣数
		public static const ADDINTEREST:String = "addInterestById";
		//获取自己所发的条子
		public static const GETUSERNOTES:String = "getUserNotes";
		
		//----------------市场相关API--------------------------
		//TODO, COMING SOON....
		
		
		
	}
}