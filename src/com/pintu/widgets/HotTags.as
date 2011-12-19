package com.pintu.widgets{
	
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.utils.Logger;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;
	
	public class HotTags extends CasaSprite{
		
		private var _model:IPintu;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		private var titleBackgroudColor:uint = StyleParams.COLUMN_TITLE_BACKGROUND;
		private var titleBackgroudHeight:int = InitParams.ANDI_TITLE_HEIGHT;
		
		//菜单使用颜色
		private var upColors:Array;
		private var overColors:Array;
		private var downColors:Array;		
		
		public function HotTags(model:IPintu){			
			super();
			_model = model;
			
			drawLoginBackGround();
			
			drawTitleBar();
			
		}
		
		private function drawTitleBar():void{
			this.graphics.lineStyle(1, titleBackgroudColor);
			this.graphics.beginFill(titleBackgroudColor, 1);
			this.graphics.drawRect(drawStartX,drawStartY,InitParams.ANDI_ASSETS_WIDTH,titleBackgroudHeight);
			this.graphics.endFill();
			
			var title:SimpleText = new SimpleText("热门标签", 0xFFFFFF, 13);
			title.x = drawStartX+(InitParams.ANDI_ASSETS_WIDTH-title.textWidth)/2;
			title.y = drawStartY+4;
			this.addChild(title);
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
			
			if(InitParams.isStretchHeight()){
				blockHeight = InitParams.appHeight
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.FOOTER_HEIGHT;
			}else{
				blockHeight = InitParams.MINAPP_HEIGHT
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.FOOTER_HEIGHT;
			}
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			//半透明效果似乎更好
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);				
			this.graphics.endFill();
		}
		
	} //end of class
}