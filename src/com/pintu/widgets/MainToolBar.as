package com.pintu.widgets
{
	import com.pintu.common.BusyIndicator;
	import com.pintu.common.IconButton;
	import com.pintu.common.SimpleIcon;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.controller.GlobalController;
	import com.pintu.events.PintuEvent;
	import com.sibirjak.asdpc.textfield.TextInput;
	import com.sibirjak.asdpc.textfield.TextInputEvent;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import org.casalib.display.CasaSprite;
	
	public class MainToolBar extends CasaSprite{
		
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var buttonGap:Number = 2;
		
		
		private var postPic:IconButton;
		private var refresh:IconButton;
		private var randomView:IconButton;
		
		//第一个图标的水平位置		
		private var firstButtonX:Number;
		//第二个图标的水平位置
		private var secondButtonX:Number;
		//第三个图标的水平位置
		private var thirdButtonX:Number;
		//搜索框的水平位置
		private var searchingX:Number;
		//查询进度条的水平位置
		private var loadingX:Number;
		
		private var searchInput:TextInput;
		private var searchIcon:SimpleIcon;
		private var loading:BusyIndicator;
		private var searchIconPath:String = "assets/system_search.png";
		
		private var postPicPath:String = "assets/post_pic.png";
		private var refreshPath:String = "assets/refresh.png";
		private var bigPicPath:String = "assets/bigpic_mode.png";
		private var randomViewPath:String = "assets/randomview.png";
		
		//图片展示模式
		private var _displayMode:String; 		
		private var _isLogged:Boolean
		
		public function MainToolBar(logged:Boolean){
			super();
			_isLogged = logged;				
			//计算位置
			initVisualPartsPos();
			//画背景框
			drawTooBarBackground();
			//生成图标按钮
			createMainTools();
		}
		
		public function get displayMode():String{
			return _displayMode;
		}
		
		
		private function initVisualPartsPos():void{
			
			drawStartX = InitParams.startDrawingX();
			drawStartY = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;	
			//第一按钮位置
			firstButtonX = drawStartX+buttonGap;	
			//判断登录状态
			if(GlobalController.isLogged){
				secondButtonX = firstButtonX+InitParams.MAINMENUBAR_HEIGHT+buttonGap;
			}else{
				secondButtonX = firstButtonX;
			}	
			//第三按钮位置
			thirdButtonX = secondButtonX+InitParams.MAINMENUBAR_HEIGHT+buttonGap;	
			
			
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
			
			//第一按钮：贴图按钮
			if(GlobalController.isLogged){
				postPic = new IconButton(InitParams.MAINMENUBAR_HEIGHT,InitParams.MAINMENUBAR_HEIGHT-buttonGap);			
				postPic.setSkinStyle(upColors,overColors,downColors);
				postPic.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
					StyleParams.DEFAULT_TEXT_FONTSIZE,
					StyleParams.DEFAULT_TEXT_COLOR,
					StyleParams.DEFAULT_TEXT_COLOR,
					StyleParams.DEFAULT_TEXT_COLOR);
				postPic.label = "贴图";
				postPic.x = firstButtonX;
				postPic.y = drawStartY+buttonGap;	
				//图标路径
				postPic.iconPath = postPicPath;
				postPic.addEventListener(MouseEvent.CLICK, function():void{				
					dispatchEvent(new PintuEvent(PintuEvent.UPLOAD_IMAGE,null));
				});
				this.addChild(postPic);
				
			}
			
			//第二按钮：刷新按钮
			refresh = new IconButton(InitParams.MAINMENUBAR_HEIGHT,InitParams.MAINMENUBAR_HEIGHT-buttonGap);			
			refresh.setSkinStyle(upColors,overColors,downColors);
			refresh.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);
			refresh.label = "刷新";
			refresh.x = secondButtonX;
			refresh.y = drawStartY+buttonGap;	
			//图标路径
			refresh.iconPath = refreshPath;
			refresh.addEventListener(MouseEvent.CLICK, function():void{				
				dispatchEvent(new PintuEvent(PintuEvent.REFRESH_GALLERY,null));
			});
			this.addChild(refresh);
			
			//第三按钮：随机画廊
			//AT SAME TIME, SELECT THE TBMODE IN CATEGORY TREE...
			randomView = new IconButton(InitParams.MAINMENUBAR_HEIGHT,InitParams.MAINMENUBAR_HEIGHT-buttonGap);			
			randomView.setSkinStyle(upColors,overColors,downColors);
			randomView.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);
			randomView.label = "随便看看";
			randomView.x = thirdButtonX;
			randomView.y = drawStartY+buttonGap;	
			//图标路径
			randomView.iconPath = randomViewPath;
			randomView.addEventListener(MouseEvent.CLICK, function():void{				
				dispatchEvent(new PintuEvent(PintuEvent.RANDOM_GALLERY,null));
			});
			this.addChild(randomView);
			
			//TODO, ADD MORE ICON...			
			
			//搜索输入框
			searchInput = new TextInput();
			searchInput.defaultText = "input tag tag ...";
			searchInput.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			searchInput.setSize(InitParams.SEARCH_INPUT_WIDTH,32);
			searchInput.setStyle(TextInput.style.size,StyleParams.SEARCHINPUT_FONTSIZE);
			searchInput.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);
			searchInput.setStyle(TextInput.style.maxChars,StyleParams.TEXTINPUT_MAXCHARS);
			searchInput.x = searchingX;
			searchInput.y = drawStartY+InitParams.MAINMENUBAR_HEIGHT/2-searchInput.height/2;	
			searchInput.addEventListener(TextInputEvent.SUBMIT,function():void{
				var keywords:String = searchInput.text;
				if(keywords.length>0)
					dispatchEvent(new PintuEvent(PintuEvent.SEARCH_BYTAGS,keywords));
			});
			this.addChild(searchInput);
			//search icon
			searchIcon = new SimpleIcon(searchIconPath);
			searchIcon.showUpSkin = true;
			searchIcon.x = searchInput.x+searchInput.width-30;
			searchIcon.y = searchInput.y;	
			searchIcon.addEventListener(MouseEvent.CLICK, function():void{
				var keywords:String = searchInput.text;
				if(keywords.length>0)
					dispatchEvent(new PintuEvent(PintuEvent.SEARCH_BYTAGS,keywords));
			});
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