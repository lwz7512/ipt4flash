package com.pintu.widgets
{
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.controller.GlobalController;
	import com.sibirjak.asdpc.textfield.TextInput;
	
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
		
		private var postButtonX:Number;
		private var thumbnailButtonX:Number;
		private var bigPicButtonX:Number;
		private var searchingX:Number;
		private var loadingX:Number;
		
		private var searchInput:TextInput;
		private var searchIcon:SimpleIcon;
		private var loading:BusyIndicator;
		
		private var postPicPath:String = "assets/post_pic.png";
		private var thumbnailPath:String = "assets/thumbnail_mode.png";
		private var bigPicPath:String = "assets/bigpic_mode.png";
		private var searchIconPath:String = "assets/system_search.png";
		
		public function MainToolBar(){
			super();
			
			initVisualPartsPos();
			drawTooBarBackground();
			createMainTools();
		}
		
		private function initVisualPartsPos():void{
			
			drawStartX = InitParams.startDrawingX();
			drawStartY = InitParams.HEADERFOOTER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			
			postButtonX = drawStartX+buttonGap;
			
			if(GlobalController.isLogged){
				thumbnailButtonX = postButtonX+InitParams.MAINMENUBAR_HEIGHT+buttonGap;
			}else{
				thumbnailButtonX = postButtonX;
			}
			
			bigPicButtonX = thumbnailButtonX+InitParams.MAINMENUBAR_HEIGHT+buttonGap;
			
			searchingX  = drawStartX+InitParams.MAINMENUBAR_WIDTH/2;
			loadingX = searchingX+InitParams.SEARCH_INPUT_WIDTH+2*buttonGap;
		}
		
		private function drawTooBarBackground():void{						
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
		
		private function createMainTools():void{
			//icon button colors
			var upColors:Array = [0xFFFFFF,0xFFFFFF];
			var overColors:Array = [StyleParams.ICONMENU_MOUSEOVER_TOP,
				StyleParams.ICONMENU_MOUSEOVER_BOTTOM];
			var downColors:Array = [StyleParams.ICONMENU_SELECTED_TOP,
				StyleParams.ICONMENU_SELECTED_BOTTOM];
			
			//thumbnail button
			thumbnailMode = new IconButton(
				InitParams.MAINMENUBAR_HEIGHT,
				InitParams.MAINMENUBAR_HEIGHT-buttonGap);			
			thumbnailMode.setSkinStyle(upColors,overColors,downColors);
			thumbnailMode.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);
			thumbnailMode.label = "缩略图";
			thumbnailMode.x = thumbnailButtonX;
			thumbnailMode.y = drawStartY+buttonGap;
			//默认是缩略图模式
			thumbnailMode.selected = true;
			//指定图标
			thumbnailMode.iconPath = thumbnailPath;
			this.addChild(thumbnailMode);
			
			//big pic button
			bigPicMode = new IconButton(
				InitParams.MAINMENUBAR_HEIGHT,
				InitParams.MAINMENUBAR_HEIGHT-buttonGap);			
			bigPicMode.setSkinStyle(upColors,overColors,downColors);
			bigPicMode.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);
			bigPicMode.label = "大图";
			bigPicMode.x =bigPicButtonX;
			bigPicMode.y = drawStartY+buttonGap;			
			//指定图标
			bigPicMode.iconPath = bigPicPath;
			this.addChild(bigPicMode);
			
			//search input
			searchInput = new TextInput();
			searchInput.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			searchInput.setSize(InitParams.SEARCH_INPUT_WIDTH,32);
			searchInput.setStyle(TextInput.style.size,StyleParams.TEXTINPUT_FONTSIZE);
			searchInput.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);
			searchInput.setStyle(TextInput.style.maxChars,StyleParams.TEXTINPUT_MAXCHARS);
			searchInput.x = searchingX;
			searchInput.y = drawStartY+InitParams.MAINMENUBAR_HEIGHT/2-searchInput.height/2;
			
			this.addChild(searchInput);
			//search icon
			searchIcon = new SimpleIcon(searchIconPath);
			searchIcon.x = searchInput.x+searchInput.width-30;
			searchIcon.y = searchInput.y+1;
			
			this.addChild(searchIcon);
						
			
		}
		
		private function showLoading():void{
			if(!loading){
				loading = new BusyIndicator();
			}
			loading.x = loadingX;
			loading.y = searchInput.y+2*buttonGap;
			this.addChild(loading);
		}
		
		private function hideLoading():void{
			this.removeChild(loading);
		}
		
		
		
	}
}