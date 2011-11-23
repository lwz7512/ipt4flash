package com.pintu.controller
{
	import com.pintu.api.IPintu;
	import com.pintu.modules.HomePage;
	import com.pintu.modules.UnloggedPage;
	
	import flash.display.Sprite;
	
	import org.as3commons.collections.Map;
	import org.casalib.display.CasaSprite;
	
	/**
	 * 应用主模块创建工厂
	 */ 
	public class ModuleFactory{
		
		//cache the displayed module
		private var modules:Map = new Map();

		//top level sprite
		private var _canvas:Sprite;
		
		private var _model:IPintu;

		public function ModuleFactory(canvas:Sprite, model:IPintu){
			this._canvas = canvas;
			this._model = model;
		}
		
		public function createModuleByName(module:String):CasaSprite{
			var moduleToDisplay:CasaSprite;
			
			switch(module){
				case GlobalNavigator.HOMPAGE:
					
					if(!modules.hasKey(GlobalNavigator.HOMPAGE)){
						moduleToDisplay = new HomePage(_model);
						modules.add(GlobalNavigator.HOMPAGE,moduleToDisplay);
						this._canvas.addChild(moduleToDisplay);
					}else{
						moduleToDisplay = modules.itemFor(GlobalNavigator.HOMPAGE) as CasaSprite;
					}
					break;
					
				case 	GlobalNavigator.UNLOGGED:
					
					if(!modules.hasKey(GlobalNavigator.UNLOGGED)){
						moduleToDisplay = new UnloggedPage(_model);
						modules.add(GlobalNavigator.UNLOGGED,moduleToDisplay);
						this._canvas.addChild(moduleToDisplay);
					}else{
						moduleToDisplay = modules.itemFor(GlobalNavigator.UNLOGGED) as CasaSprite;
					}			

					
					break;

			}
			return moduleToDisplay;
		}
		
		public function createWidgetByName(widget:String):Sprite{
			return null;
		}
		
		
	}
}