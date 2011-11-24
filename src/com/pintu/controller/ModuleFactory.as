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
		private var moduleToDisplay:CasaSprite;

		//top level sprite
		private var _canvas:Sprite;
		
		private var _model:IPintu;

		public function ModuleFactory(canvas:Sprite, model:IPintu){
			this._canvas = canvas;
			this._model = model;
		}
		
		public function createModuleByName(module:String):CasaSprite{			
			
			switch(module){
				case GlobalNavigator.HOMPAGE:					
						moduleToDisplay = new HomePage(_model);						
						this._canvas.addChild(moduleToDisplay);
					break;
					
				case 	GlobalNavigator.UNLOGGED:					
						moduleToDisplay = new UnloggedPage(_model);						
						this._canvas.addChild(moduleToDisplay);					
					break;

			}
			return moduleToDisplay;
		}
		
		public function createWidgetByName(widget:String):Sprite{
			return null;
		}
		
		
	}
}