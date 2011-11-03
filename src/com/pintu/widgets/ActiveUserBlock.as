package com.pintu.widgets
{
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class ActiveUserBlock extends Sprite{
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		public function ActiveUserBlock(){
			super();
			
			drawActiveUserBackground();
			
		}
		
		private function drawActiveUserBackground():void{
			drawStartX = InitParams.startDrawingX()
								+InitParams.MAINMENUBAR_WIDTH
								+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT
								+InitParams.TOP_BOTTOM_GAP
								+InitParams.LOGIN_FORM_HEIGHT
								+InitParams.DEFAULT_GAP;			
			blockWidth = InitParams.LOGIN_FORM_WIDTH;
			blockHeight = InitParams.appHeight
								-drawStartY
								-InitParams.TOP_BOTTOM_GAP
								-InitParams.FOOTER_HEIGHT;
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);
			this.graphics.endFill();
			
		}
		
		
	}
}