package com.pintu.modules{
	
	import com.pintu.api.IPintu;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;
	
	public class MarketPage extends CasaSprite  implements IDestroyableModule{
		
		private var _model:IPintu;
		
		public function MarketPage(model:IPintu){
			super();
			this._model = model;
			
			
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