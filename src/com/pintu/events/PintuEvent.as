package com.pintu.events
{
	import flash.events.Event;
	
	public class PintuEvent extends Event{
		
		/**
		 * 全局进度条
		 */ 
		public static const SHOW_PROGRESS:String = "showLoading";
		public static const HIDE_PROGRESS:String = "hideLoading";		
		/**
		 * 弹出提示事件，这是系统事件只有Main来监听并处理
		 */ 
		public static const HINT_USER:String = "hintToUser";
		
		public static const NAVIGATE:String = "navigate";
		public static const BROWSE_CHANGED:String = "browseChanged";
		
		public static const GETPICDETAILS:String = "getPicDetails";
		public static const IMAGE_LOADED:String = "imageLoaded";		
		public static const SEARCH_BYTAGS:String = "searchByTags";
		
		public static const REFRESH_GALLERY:String = "refreshGallery";
		
		public static const UPLOAD_IMAGE:String = "uploadImage";
		public static const DNLOAD_IMAGE:String = "dnloadImage";
		
		//发信
		public static const POST_MSG:String = "writeMsg";
		//修改用户资料
		public static const POST_USERINFO:String = "modifyUserInfo";
		

		//进度条事件
		public static const PROGRESS:String = "progress";
		//大图中点击评论按钮，通知画廊向上滚动事件
		public static const SCROLL_UP:String = "scrollUp";
		
		//显示个人消息
		public static const SHOW_MSGS:String = "showMsgs";
		//获取自己贴图
		public static const GET_MYPICS:String = "getMyPics";
		//获取自己收藏
		public static const GET_MYFAVS:String = "getMyFavs";
		
		//修改用户资料后刷新
		public static const REFRESH_USER:String = "refreshUser";
		
		//查看点击标签的图片缩略图
		public static const GETTB_BYTAG:String = "getThumbnailsBytag";
		
		//点击活跃用户查看他的贴图
		public static const GETPICS_BYUSER:String = "getPicsByUser";
		
		//HeaderBar派发事件，通知HomePage打开窗口
		public static const OPEN_WIN:String = "openWin";
		
		//PicDetailView派发的事件，收藏成功后在右侧提示一个+1
		public static const MARK_SUCCSS:String = "markSuccess";
		
		//贴条子
		public static const POST_NOTE:String = "postNote";
		//放大条子看详情
		public static const VIEW_NOTE:String = "viewNote";
		
		
		/**
		 * 通常带的参数
		 */ 
		public var data:String;
		/**
		 * 第二参数
		 */ 
		public var extra:String;
		/**
		 * 第三个参数，真多余啊，没办法，恢复条子的私信时，要传递reference<br/>
		 * 2012/05/21
		 */ 
		public var third:String;
		
		
		public function PintuEvent(type:String, context:String){
			//都是冒泡事件，可以传播到顶级对象
			super(type,true);
			this.data = context;
		}
		
		public override function  clone():Event{
			return new PintuEvent(type,data);
		}
		
	}
}