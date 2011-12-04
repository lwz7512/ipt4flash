package com.pintu.widgets{
	
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.utils.Logger;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;

	/**
	 * 类似于微博中的“我的首页”下面的内容
	 * 就是把主工具栏中的“俺滴”菜单项拆到右边栏
	 */ 
	public class AndiBlock extends CasaSprite{
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		public function AndiBlock(){
			super();
			
			drawLoginBackGround();
			
			
		}
		
		private function drawLoginBackGround():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT
				+InitParams.TOP_BOTTOM_GAP
				+InitParams.USER_DETAIL_HEIGHT
				+InitParams.DEFAULT_GAP;
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			//半透明效果似乎更好
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 0.6);
			this.graphics.drawRect(drawStartX,drawStartY,
				InitParams.ANDI_ASSETS_WIDTH,InitParams.ANDI_ASSETS_HEIGHT);
			this.graphics.endFill();
		}
		
		
	}//end of class
}