package com.pintu.vos{
	
	/**
	 * 条子，便条数据
	 */ 
	public class Note{
		//条子编号
		public var id:String;
		//标题
		public var title:String;
		//内容
		public var content:String;
		//贴条人用户ID
		public var publisherId:String;
		//贴条人昵称
		public var publiserName:String;
		
		//发布时间: YYYY-MM-DD hh:mm:ss
		public var publishTime:String;
		
		//条子类型: ???
		public var type:String;
		
		//关注度
		public var attention:String = "1";
		//感兴趣人数
		public var interest:String = "0";
		
		
		public function Note(){
		}
		
	} //end of class
}