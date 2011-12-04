package com.pintu.widgets{
	
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.utils.Logger;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;
	
	public class WeiboFriendsBlock extends CasaSprite{
		
		private var _model:IPintu;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		public function WeiboFriendsBlock(model:IPintu){			
			super();
			_model = model;
			
			drawLoginBackGround();
			
		}
		
		private function drawLoginBackGround():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT
				+InitParams.TOP_BOTTOM_GAP
				+InitParams.USER_DETAIL_HEIGHT
				+InitParams.DEFAULT_GAP
				+InitParams.ANDI_ASSETS_HEIGHT
				+InitParams.DEFAULT_GAP;
			
			blockWidth = InitParams.LOGIN_FORM_WIDTH;
			blockHeight = InitParams.appHeight
				-drawStartY
				-InitParams.TOP_BOTTOM_GAP
				-InitParams.FOOTER_HEIGHT;
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			//半透明效果似乎更好
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 0.6);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);				
			this.graphics.endFill();
		}
		
	} //end of class
}