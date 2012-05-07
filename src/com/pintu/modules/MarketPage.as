package com.pintu.modules{
	
	import com.pintu.api.IPintu;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;
	
	public class MarketPage extends CasaSprite  implements IDestroyableModule, IMenuClickResponder{
		
		private var _model:IPintu;
		
		public function MarketPage(model:IPintu){
			super();
			this._model = model;
			
			
		}
		
		/**
		 * 在Main中的browseTypeChanged监听器中调用该方法
		 */ 
		public function menuHandler(operation:String, extra:String):void{
			
		}
		
		public function searchable(key:String):void{
			trace(".... to search by: "+key);
		}
		
		
		
		//重写销毁函数
		public  function killMe():void{
			//移除自己，并销毁事件监听
			super.destroy();
			_model = null;
			removeChildren(true,true);		
		}
		
	}
}