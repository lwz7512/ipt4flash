package com.pintu.modules{
	
	/**
	 * HeaderBar与当前模块交互接口：
	 * 菜单点击、搜索
	 * 2011/12/21
	 */
	public interface IMenuClickResponder{
		
		function menuHandler(operation:String, extra:String):void;
		function searchable(key:String):void;
		
	}
}