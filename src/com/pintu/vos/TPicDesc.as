package com.pintu.vos{
	
	/**
	 * 缩略图数据
	 */ 
	public class TPicDesc{
		
		//贴图ID
		public var tpId:String;
		//缩略图ID，贴图ID加_Thumbnail
		public var thumbnailId:String;		
		//URL 地址，用作图片缓存索引
		public var url:String;
		//创建时间，毫秒数
		public var creationTime:Number;
		
		//图的状态，热图，经典等等
		//0: 默认状态
		//1: 有故事状态
		//2: 热图状态
		//3: 经典状态
		public var status:String;
		
		
	} //end of class
}