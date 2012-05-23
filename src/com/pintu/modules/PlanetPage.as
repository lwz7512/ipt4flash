package com.pintu.modules{
	
	import com.pintu.api.IPintu;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	import org.casalib.display.CasaSprite;
	import org.casalib.display.CasaTextField;
	
	/**
	 * 艺术星球，让艺术家开拓属于自己的世界。。。
	 * 
	 * 2012/05/23
	 */ 
	public class PlanetPage extends CasaSprite  implements IDestroyableModule, IMenuClickResponder{
		
		private var _model:IPintu;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		private var displayAreaWidth:Number;
		private var displayAreaHeight:Number;
		
		private var background:CasaSprite;
		
		public function PlanetPage(model:IPintu){
			super();
			this._model = model;
			
			initModuleViews();
		}
		
		private function initModuleViews():void{
			//TODO, BUILD A REAL UNIVERSE...
			initDrawPoint();
			
			background = new CasaSprite();
			this.addChild(background);
			
			var coming:CasaTextField = new CasaTextField();			
			coming.autoSize = "left";
			coming.defaultTextFormat = new TextFormat(null,14,0xFFFFFF);
			coming.text = "Art Planet is coming soon...";
			coming.selectable = false;
			coming.x = drawStartX+displayAreaWidth/2-coming.textWidth/2;
			coming.y = drawStartY+displayAreaHeight/2;
			this.addChild(coming);
			
			drawDisplayBackground();
		}
		
		private function initDrawPoint():void{
			drawStartX = InitParams.startDrawingX();				
			drawStartY = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			
			displayAreaWidth = InitParams.MINAPP_WIDTH-2;
			if(InitParams.isStretchHeight()){
				//拉伸高度
				displayAreaHeight = InitParams.appHeight
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.FOOTER_HEIGHT;
			}else{
				//默认高度，也是最小高度
				displayAreaHeight = InitParams.MINAPP_HEIGHT
					-drawStartY-InitParams.FOOTER_HEIGHT-InitParams.TOP_BOTTOM_GAP;
			}
		}
		
		private function drawDisplayBackground():void{						
			background.graphics.clear();
			background.graphics.lineStyle(1,StyleParams.DEFAULT_BLACK_COLOR);			
			background.graphics.beginFill(StyleParams.DEFAULT_BLACK_COLOR, 1);
			background.graphics.drawRect(drawStartX,drawStartY,displayAreaWidth,displayAreaHeight);
			background.graphics.endFill();
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