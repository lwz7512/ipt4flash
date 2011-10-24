package com.pintu.widgets
{
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class MainToolBar extends Sprite{
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		public function MainToolBar(){
			super();
			drawTooBarBackground();
			createMainTools();
		}
		
		private function drawTooBarBackground():void{
			drawStartX = InitParams.startDrawingX();
			drawStartY = InitParams.HEADERFOOTER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			var colors:Array = [StyleParams.MENUBAR_TOP_ICE,
				StyleParams.MENUBAR_NEARBOTTOM_ICE,
				StyleParams.MENUBAR_BOTTOM_ICE];
			var alphas:Array = [1,1,1];
			var ratios:Array = [0,245,255];
			var matrix:Matrix = new Matrix();
			//需要旋转90度，垂直渐变
			//如果绘制起点不在0,0点，还需要对填充区域做个偏移
			matrix.createGradientBox(
				InitParams.MAINMENUBAR_WIDTH,InitParams.MAINMENUBAR_HEIGHT,
				Math.PI/2,
				drawStartX,drawStartY);
			this.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matrix);
			this.graphics.drawRect(drawStartX,drawStartY,
				InitParams.MAINMENUBAR_WIDTH,InitParams.MAINMENUBAR_HEIGHT);
			this.graphics.endFill();
		}		
		//TODO, Create icon buttons...
		private function createMainTools():void{
			
		}
		
	}
}