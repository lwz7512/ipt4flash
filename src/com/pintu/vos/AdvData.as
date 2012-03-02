package com.pintu.vos{
	
	/**
	 * 微广告数据
	 * 有两类：文字链接、横条图片链接
	 * 按优先级和发布时间顺序展示
	 * 
	 * 2012/02/29
	 */ 
	public class AdvData{
		
		public var id:String;
		
		public var adName:String;
		public var adContent:String;
		public var adType:String;
		//广告图片URL地址？
		public var adImgPath:String;
		//文字或者图片指向的链接
		public var adLink:String;
		//广告商
		public var adVendor:String;
		
		public var createTime:String;
		public var startTime:String;
		public var endTime:String;
		//优先级字段，1、2、3，其中1最优先
		public var priority:String;
		
		
	} //end of class
}