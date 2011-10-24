package com.pintu.widgets
{
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class CategoryTree extends Sprite{
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		public function CategoryTree(){
			super();
			
			drawLeftCategoryBackground();
			createCategoryTree();
		}
		
		private function drawLeftCategoryBackground():void{
			drawStartX = InitParams.startDrawingX();
			drawStartY = InitParams.HEADERFOOTER_HEIGHT
													+InitParams.TOP_BOTTOM_GAP
													+InitParams.MAINMENUBAR_HEIGHT
													+InitParams.DEFAULT_GAP;
			var leftColumnHeight:Number = InitParams.LEFTCOLUMN_HEIGHT;			
			if(InitParams.isStretchHeight()){
				leftColumnHeight = InitParams.appHeight
												-drawStartY
												-InitParams.TOP_BOTTOM_GAP
												-InitParams.HEADERFOOTER_HEIGHT;
			}
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR);
			this.graphics.drawRect(drawStartX,drawStartY,
				InitParams.LEFTCOLUMN_WIDTH,leftColumnHeight);
			this.graphics.endFill();
		}
		//TODO, Create category tree by data...
		private function createCategoryTree():void{
			
		}
		
		
	}
}