package com.pintu.vos{
	
	/**
	 * 图片基本数据，介于缩略图和详情之间
	 * 
	 */ 
	public class TPicItem{
		
		//贴图ID
		public var  id:String;
		//贴图名称
		public var picName:String;
		//作者ID
		public var owner:String;
		//浏览次数
		public var browseCount:String;
		//到达客户端时，再格式化为xx分钟或者xx小时前
		public var publishTime:String;	
		
		//用于显示的相对时间
		public var relativeTime:String;
		//是否允许品图，这个比较重要
		public var isOriginal:String;
		
		//生成的移动图ID，这个ID是由pId+"_Mob"构成
		public var mobImgId:String;
		
		//移动图像url
		public var mobImgUrl:String;
		
	} //end of class
}