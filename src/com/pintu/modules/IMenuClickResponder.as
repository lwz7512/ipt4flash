package com.pintu.modules{
	
	/**
	 * HeaderBar与当前模块交互接口：
	 * 菜单点击、搜索
	 * 2011/12/21
	 * 从html页面url参数进来查看图片详情
	 * 2012/01/03
	 */
	public interface IMenuClickResponder{
		
		//从首页的子菜单点击进来执行
		function menuHandler(operation:String, extra:String):void;
		
		//从主工具栏的搜索框进来执行
		function searchable(key:String):void;
				
		
	}
}