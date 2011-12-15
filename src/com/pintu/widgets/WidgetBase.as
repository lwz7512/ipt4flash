package com.pintu.widgets{
	
	import com.pintu.api.*;
	
	import flash.events.Event;
	
	import org.casalib.display.CasaSprite;
	
	
	public class WidgetBase extends CasaSprite{
		
		protected var _model:IPintu;
		
		public function WidgetBase(model:IPintu){
			super();
			_model = model;
			
			this.addEventListener(Event.ADDED_TO_STAGE, addModelListener);
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanModelListener);
		}
		
		/**
		 * 加模型方法监听，并查询，子类来覆盖
		 */ 
		protected function addModelListener(evt:Event):void{
			
		}
		/**
		 * 移除模型方法监听，子类来覆盖
		 */ 
		protected function cleanModelListener(evt:Event):void{
			
		}
				
		
		
	} //end of class
}