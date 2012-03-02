package com.pintu.widgets{
	
	import com.pintu.api.IPintu;
	
	import flash.events.Event;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 所有用到服务类Model的小部件，都应该继承这个类
	 * 并重载initModelListener和cleanUpModelListener
	 * 这样可以保证事件监听器能够正常移除，资源能够回收
	 * 2011/12/09
	 */ 
	public class AbstractWidget extends CasaSprite{
		
		protected var _clonedModel:IPintu;
		
		public function AbstractWidget(model:IPintu){
			//每个视图中，都有各自不同的模型，这样就不会干扰了
			_clonedModel = model.clone();						
			
			this.addEventListener(Event.ADDED_TO_STAGE, initModelListener);			
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanUpModelListener);
		}
		
		/**
		 * 这里添加对_clonedModel的事件监听
		 * 而不能在构造函数中直接添加_clonedModel的事件监听
		 */ 
		protected function initModelListener(evt:Event):void{
			//防止重复添加事件
			this.removeEventListener(Event.ADDED_TO_STAGE, initModelListener);
		}
		
		/**
		 * 这里移除initModelLitener里添加的事件
		 * 同时回收_clonedModel
		 */ 
		protected function cleanUpModelListener(evt:Event):void{
			//TODO, TO REMOVE MODEL EVENT LISTENER IN SUB WIDGET...
			//THEN, USE: super.cleanUpModelListener(evt);
			
			//这个是复制出来的，一定要销毁
			_clonedModel.destory();
			_clonedModel = null;
		}
		
		
	} //end of class
}