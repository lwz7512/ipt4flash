package com.pintu.widgets
{
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class HeaderBar extends Sprite{
		
		private var isLogged:Boolean;
		
		public function HeaderBar(isLoggedin:Boolean){
			super();
			this.isLogged = isLoggedin;
			
			drawBackground();
			createTextMenus();
		}
		
		private function drawBackground():void{
			this.graphics.clear();
			var colors:Array = [StyleParams.HEADERBAR_TOP_LIGHTGREEN,
				StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN,
				StyleParams.HEADERBAR_BOTTOM_LIGHTGREEN];
			var alphas:Array = [1,1,1];
			var ratios:Array = [0,245,255];
			var matrix:Matrix = new Matrix();
			//需要旋转90度，垂直渐变
			matrix.createGradientBox(InitParams.appWidth,InitParams.HEADERFOOTER_HEIGHT,Math.PI/2);
			this.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matrix);
			this.graphics.drawRect(0,0,InitParams.appWidth,InitParams.HEADERFOOTER_HEIGHT);
			this.graphics.endFill();

		}
		
		//TODO, create text menu...
		private function createTextMenus():void{
			
		}
		
		
		
	} //end of class
}