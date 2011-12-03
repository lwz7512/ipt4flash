package com.pintu.modules{
	
	/**
	 * 由各个模块实现，在点击菜单时调用当前舞台的模块进行操作
	 */
	public interface IMenuClickResponder{
		
		function menuHandler(operation:String, extra:String):void;
		
	}
}