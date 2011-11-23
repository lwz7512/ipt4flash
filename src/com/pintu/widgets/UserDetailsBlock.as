package com.pintu.widgets{
		
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.utils.Logger;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 显示在应用右上角的个人详情部分
	 */ 
	public class UserDetailsBlock extends CasaSprite{
		
		private var _model:IPintu;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		public function UserDetailsBlock(model:IPintu){
			super();
			_model = model;
			
			drawLoginBackGround();
			
		}
		
		private function drawLoginBackGround():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR);
			this.graphics.drawRect(drawStartX,drawStartY,
				InitParams.USER_DETAIL_WIDTH,InitParams.USER_DETAIL_HEIGHT);
			this.graphics.endFill();
		}
		
		
	} //end of class
}