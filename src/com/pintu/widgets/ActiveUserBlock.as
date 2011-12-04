package com.pintu.widgets
{
	import com.pintu.api.IPintu;
	import com.pintu.common.SimpleText;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import org.casalib.display.CasaSprite;
	
	public class ActiveUserBlock extends CasaSprite{
		
		private var _model:IPintu;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		private var headerHeight:Number = 24;
		
		public function ActiveUserBlock(model:IPintu){
			super();
			_model = model;
			
			drawActiveUserBackground();
			
			//标题
			var title:SimpleText = new SimpleText("活跃用户排行榜",0x000000,12);
			//居中
			title.x = drawStartX+InitParams.LOGIN_FORM_WIDTH/2-title.textWidth/2;
			title.y = drawStartY+2;
			this.addChild(title);
			
			//TODO, 列表...
			
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
			//半透明效果似乎更好
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 0.6);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);
			this.graphics.endFill();
			
			//标题背景条
			this.graphics.beginFill(StyleParams.MENUBAR_BOTTOM_ICE);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,headerHeight);
			this.graphics.endFill();
		}
		
		
	}
}