package com.pintu.modules{
	/**
	 * 由GlobalNavigator在模块切换时调用
	 */ 
	public interface IDestroyableModule{
		function killMe():void;		
	}
}