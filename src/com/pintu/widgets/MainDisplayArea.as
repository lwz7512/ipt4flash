package com.pintu.widgets
{
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class MainDisplayArea extends Sprite{
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		
		public function MainDisplayArea(){
			super();
			
			drawMainDisplayBackground();
			
		}
		
		private function drawMainDisplayBackground():void{
			drawStartX = InitParams.startDrawingX()
													+InitParams.LEFTCOLUMN_WIDTH
													+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADERFOOTER_HEIGHT
													+InitParams.TOP_BOTTOM_GAP
													+InitParams.MAINMENUBAR_HEIGHT
													+InitParams.DEFAULT_GAP;
			var displayAreaHeight:Number = InitParams.CALLERY_HEIGHT;
			if(InitParams.isStretchHeight()){
				displayAreaHeight = InitParams.appHeight
													-drawStartY
													-InitParams.TOP_BOTTOM_GAP
													-InitParams.HEADERFOOTER_HEIGHT;
			}
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR);
			this.graphics.drawRect(drawStartX,drawStartY,
													InitParams.GALLERY_WIDTH,displayAreaHeight);
			this.graphics.endFill();
		}
		
		
	}
}