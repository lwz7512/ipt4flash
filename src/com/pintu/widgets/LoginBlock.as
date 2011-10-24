package com.pintu.widgets
{
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	
	import flash.display.Sprite;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	public class LoginBlock extends Sprite{
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		public function LoginBlock(){
			super();
			
			drawLoginBackGround();
			
		}
		
		private function drawLoginBackGround():void{
			drawStartX = InitParams.startDrawingX()
								+InitParams.MAINMENUBAR_WIDTH
								+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADERFOOTER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR);
			this.graphics.drawRect(drawStartX,drawStartY,
								InitParams.LOGIN_FORM_WIDTH,InitParams.LOGIN_FORM_HEIGHT);
			this.graphics.endFill();
		}
		
	}
}