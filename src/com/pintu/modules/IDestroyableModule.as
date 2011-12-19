package com.pintu.modules{
	/**
	 * 由GlobalNavigator在模块切换时调用
	 */ 
	public interface IDestroyableModule{
		
		/**
		 * 模块的销毁接口方法
		 */ 
		function killMe():void;		
	}
}