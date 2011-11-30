package com.pintu.vos{
	
	/**
	 * 图片详情数据
	 */ 
	public class TPicData{
		
		//贴图ID
		public var  id:String;
		//贴图名称
		public var picName:String;
		//作者ID
		public var owner:String;
		//贴图作者
		public var author:String;	
		//用户头像文件路径
		public var avatarImgPath:String;
		//用户图像url
		public var avatarUrl:String;
		//浏览次数
		public var browseCount:String;
		//用户积分
		public var score:String;	
		//用户等级
		public var level:String;
		
		//到达客户端时，再格式化为xx分钟或者xx小时前
		public var publishTime:String;	
		
		//用于显示的相对时间
		public var relativeTime:String;
		
		//贴图标签
		public var tags:String;
		//贴图描述
		public var description:String;
		
		//是否允许品图，这个比较重要
		public var isOriginal:String;
		
		//生成的移动图ID，这个ID是由pId+"_Mob"构成
		public var mobImgId:String;
		
		//移动图像url
		public var mobImgUrl:String;
		
		//生成的原始图ID，这个ID是由pId+"_Raw"构成
		public var rawImgId:String;
		//原图的下载地址
		public var rawImgUrl:String;
				
		//评论数目
		public var commentsNum:String;
		
		//喜欢数目
		public var coolCount:String;
		
		
	} //end of class
}