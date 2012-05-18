package com.pintu.widgets{
	
	import com.pintu.config.StyleParams;
	import org.casalib.display.CasaSprite;
	
	
	/**
	 * 条子图例
	 */ 
	public class NoteLegend extends CasaSprite{
		
		private var _width:Number;
		private var _height:Number;
		
		public function NoteLegend(w:Number, h:Number){
			super();
			
			_width = w;
			_height = h;
			
			drawBackground();
		}
		
		
		
		private function drawBackground():void{
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.drawRect(0,0,_width,_height);
			this.graphics.endFill();
		}
		
	} //end of class
}