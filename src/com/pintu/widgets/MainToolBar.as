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
		private var buttonGap:Number = 2;
		
		private var postPic:IconButton;
		private var thumbnailMode:IconButton;
		private var bigPicMode:IconButton;
		
		private var postPicPath:String = "assets/post_pic.png";
		private var thumbnailPath:String = "assets/thumbnail_mode.png";
		private var bigPicPath:String = "assets/bigpic_mode.png";
		
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
			var upColors:Array = [0xFFFFFF,0xFFFFFF];
			var overColors:Array = [StyleParams.ICONMENU_MOUSEOVER_TOP,
				StyleParams.ICONMENU_MOUSEOVER_BOTTOM];
			var downColors:Array = [StyleParams.ICONMENU_SELECTED_TOP,
				StyleParams.ICONMENU_SELECTED_BOTTOM];
			
			thumbnailMode = new IconButton(
				InitParams.MAINMENUBAR_HEIGHT,
				InitParams.MAINMENUBAR_HEIGHT-buttonGap);
			
			thumbnailMode.setSkinStyle(upColors,overColors,downColors);
			thumbnailMode.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);
			thumbnailMode.label = "缩略图";
			thumbnailMode.x = drawStartX+buttonGap;
			thumbnailMode.y = drawStartY+buttonGap;
			//默认是缩略图模式
			thumbnailMode.selected = true;
			//指定图标
			thumbnailMode.iconPath = thumbnailPath;
			this.addChild(thumbnailMode);
			
			bigPicMode = new IconButton(
				InitParams.MAINMENUBAR_HEIGHT,
				InitParams.MAINMENUBAR_HEIGHT-buttonGap);
			
			bigPicMode.setSkinStyle(upColors,overColors,downColors);
			bigPicMode.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);
			bigPicMode.label = "大图";
			bigPicMode.x = drawStartX+buttonGap+thumbnailMode.width+buttonGap;
			bigPicMode.y = drawStartY+buttonGap;			
			//指定图标
			bigPicMode.iconPath = bigPicPath;
			this.addChild(bigPicMode);
			
			//add other tool...
			
		}
		
	}
}