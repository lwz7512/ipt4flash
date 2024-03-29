package com.pintu.widgets
{
	import com.pintu.api.IPintu;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.controller.*;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	import com.sibirjak.asdpc.textfield.TextInput;
	import com.sibirjak.asdpc.textfield.TextInputEvent;
	
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	
	public class HeaderBar extends Sprite{
		
		private var _isLogged:Boolean;
		private var elementStartX:Number;
		
		//主菜单容器，放所有的功能菜单，并画背景
		//置于顶层
		private var mainMenuContainer:CasaSprite;	
		
		
		//主菜单
		private var homeMenu:TextMenu;
		private var communityMenu:TextMenu;
		//FIXME, 从市场-->到艺术星球的跨越
		//2012/05/23
		private var artPlanet:TextMenu;
		//当前被选中的菜单，方便做切换状态
		private var selectedMenu:TextMenu;
		
		private var settingMenu:TextMenu;
		private var aboutMenu:TextMenu;
		private var feedbackMenu:TextMenu;
		private var exitMenu:TextMenu;
		//菜单使用颜色
		private var upColors:Array;
		private var overColors:Array;
		private var downColors:Array;		
	
		private var logoLoader:ImageLoad;
		private var logoBitmap:Bitmap;
		private var version:TextField;
		private var logoPath:String = "assets/banner.png";
		private var versionText:String = "爱品图 v1.0";		
		private var logoVersionGap:Number = 36;
		private var versionHomeGap:Number = 100;
		private var menuGap:Number = 32;		
		
		private var searchInput:TextInput;
		private var searchIcon:SimpleIcon;
		private var loading:BusyIndicator;
		private var searchIconPath:String = "assets/system_search.png";
				
		//子菜单容器，放所有的水平子菜单条
		//置于主菜单容器的下面，让其盖住
		private var subMenuContainer:CasaSprite;
		//首页子菜单
		private var browseMode:BrowseMode;
		
		//这里需要个模型，没办法只能通过构造函数传进来了
		private var _model:IPintu;
		private var miniAds:MiniAds;
		
		//本来不需要模型，但是为了MiniAds传个模型进来
		//2012/03/02
		public function HeaderBar(isLogged:Boolean, mdl:IPintu){
			super();			
			_isLogged = isLogged;
			_model = mdl;
			
			elementStartX = InitParams.startDrawingX();
			
			//子菜单内容先放，在下面
			subMenuContainer = new CasaSprite();
			this.addChild(subMenuContainer);
			
			//主菜单内容后放，在上面
			mainMenuContainer = new CasaSprite();
			//绿色渐变背景条画在主容器中
			drawBackground();			
			this.addChild(mainMenuContainer);
			
			//所有的东西，都得等到logo加载后创建
			showLogo();
						
		}
		
		/**
		 * 主应用导航时调用
		 */ 
		public function showExit():void{
			exitMenu.visible = true;
			searchInput.visible = true;
			searchIcon.visible = true;
			feedbackMenu.visible = true;
		}
		/**
		 * 主应用导航时调用
		 */ 
		public function hideExit():void{
			exitMenu.visible = false;
			searchInput.visible = false;
			searchIcon.visible = false;
			feedbackMenu.visible = false;
		}
		
		private function showLogo():void{
			//load logo img...
			logoLoader = new ImageLoad(logoPath);
			logoLoader.addEventListener(LoadEvent.COMPLETE,onLoaded);
			logoLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			logoLoader.start();			
		}
		
		private function onLoaded(e:LoadEvent):void {
			logoBitmap = this.logoLoader.contentAsBitmap;
			logoBitmap.x = elementStartX-100;
			logoBitmap.y = 2;		
			mainMenuContainer.addChild(logoBitmap);
			
			//add a link layer for logo
			var maskLogo:Sprite = new Sprite();
			maskLogo.graphics.beginFill(0xFFFFFF,0.01);
			maskLogo.graphics.drawRect(0,0,logoBitmap.width,logoBitmap.height);
			maskLogo.graphics.endFill();
			maskLogo.x = logoBitmap.x;
			maskLogo.y = logoBitmap.y;
			maskLogo.useHandCursor = true;
			maskLogo.buttonMode = true;
			mainMenuContainer.addChild(maskLogo);
			maskLogo.addEventListener(MouseEvent.CLICK,goBacktoHomePage);
			
			//主菜单，都在主容器中
			createMainMenus();
			//先记下主菜单的选择
			switchSelectedMenu(homeMenu);
			
			createSearchInput();
			createFeedbackMenu();
			createExitMenu();	
			
			//子菜单都画在子容器中
			//放在HeaderBar后面隐藏，鼠标点击菜单滑出
			createSubMenus();
			
			//微广告部件
			//2012/03/02
			miniAds = new MiniAds(_model);
			//搜索框的左边
			miniAds.x = searchInput.x-miniAds.width-10;
			miniAds.y = 0;
			//FIXME, 调试社区模块，先屏蔽掉
//			this.addChild(miniAds);
		}
		
		private function goBacktoHomePage(evt:MouseEvent):void{
			var address:URLRequest = new URLRequest(PublishParams.HOME_URL);
			navigateToURL(address, "_blank");
		}
		
		private function createSubMenus():void{
			//首页子菜单
			browseMode = new BrowseMode();
			browseMode.x = homeMenu.x;
			browseMode.y = -browseMode.height;
			subMenuContainer.addChild(browseMode);
			
			//TODO, 其他子菜单
			
		}
		
		private function showVersion():void{
			//show version...
			version = new TextField();
			version.autoSize = "left";
			version.selectable = false;
			var versionFormat:TextFormat = new TextFormat(null,12,0xFFFFFF);
			version.defaultTextFormat = versionFormat;
			version.text = versionText;
			//位于Logo的右侧
			version.x = elementStartX+logoVersionGap;
			version.y = StyleParams.TOOL_MENU_FONTSIZE;
			mainMenuContainer.addChild(version);			
		}
		/**
		 * 在主菜单容器上画，这样分层处理
		 */ 
		private function drawBackground():void{
			mainMenuContainer.graphics.clear();
			var colors:Array = [StyleParams.HEADERBAR_TOP_LIGHTGREEN,
				StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN,
				StyleParams.HEADERBAR_BOTTOM_LIGHTGREEN];
			var alphas:Array = [1,1,1];
			var ratios:Array = [0,245,255];
			var matrix:Matrix = new Matrix();
			//需要旋转90度，垂直渐变
			matrix.createGradientBox(InitParams.appWidth,InitParams.HEADER_HEIGHT,Math.PI/2);
			mainMenuContainer.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matrix);
			mainMenuContainer.graphics.drawRect(0,0,InitParams.appWidth,InitParams.HEADER_HEIGHT);
			mainMenuContainer.graphics.endFill();

		}
		
		/**
		 * 如果菜单处于选中状态，鼠标滑过拉出下拉菜单
		 * 如果菜单未选中，鼠标点击拉出下拉菜单
		 * 主菜单只负责打开子菜单，但不负责收回
		 * 收回子菜单是它自己的事情
		 * 点击子菜单项，下拉菜单收回
		 */ 
		private function createMainMenus():void{
			//主菜单颜色设置
			upColors = [0xFFFFFF,0xFFFFFF];
			overColors = [StyleParams.HEADER_MENU_MOUSEOVER,
				StyleParams.HEADER_MENU_MOUSEOVER];
			downColors = [StyleParams.HEADER_MENU_SELECTED,
				StyleParams.HEADER_MENU_SELECTED];
			
			//首页菜单
			homeMenu = new TextMenu(InitParams.HEADERMENU_BG_WIDTH,InitParams.HEADER_HEIGHT);
			homeMenu.setSkinStyle(upColors,overColors,downColors);
			homeMenu.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.HEADER_MENU_FONTSIZE,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR);
			homeMenu.label = "首页";
			homeMenu.x = logoBitmap.x+logoBitmap.width+InitParams.HEADERMENU_BG_WIDTH;
			homeMenu.y = 0;
			//默认选中主菜单
			homeMenu.selected = true;
			homeMenu.addEventListener(MouseEvent.MOUSE_OVER, onHomeMenuOver);
			homeMenu.addEventListener(MouseEvent.MOUSE_OUT, onHomeMenuOut);
			homeMenu.addEventListener(MouseEvent.CLICK, onHomeMenuClick);
			mainMenuContainer.addChild(homeMenu);
			
			//社区菜单，对应社区模块
			communityMenu = new TextMenu(InitParams.HEADERMENU_BG_WIDTH,InitParams.HEADER_HEIGHT);
			communityMenu.setSkinStyle(upColors,overColors,downColors);
			communityMenu.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.HEADER_MENU_FONTSIZE,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR);
			communityMenu.label = "社区";
			communityMenu.x = homeMenu.x+InitParams.HEADERMENU_BG_WIDTH+menuGap;
			communityMenu.y = 0;			
			communityMenu.addEventListener(MouseEvent.CLICK, onSwitchToCommunity);
			mainMenuContainer.addChild(communityMenu);
			
			//夜市模块，对应市场模块
			artPlanet = new TextMenu(InitParams.HEADERMENU_BG_WIDTH+20,InitParams.HEADER_HEIGHT);
			artPlanet.setSkinStyle(upColors,overColors,downColors);
			artPlanet.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.HEADER_MENU_FONTSIZE,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR);
			artPlanet.label = "艺术星球";
			artPlanet.x = communityMenu.x+InitParams.HEADERMENU_BG_WIDTH+menuGap;
			artPlanet.y = 0;
			artPlanet.addEventListener(MouseEvent.CLICK, onSwitchToArtPlanet);
			mainMenuContainer.addChild(artPlanet);
			
			//	设置菜单，点击打开窗口
			settingMenu = new TextMenu(InitParams.HEADERMENU_BG_WIDTH,InitParams.HEADER_HEIGHT);
			settingMenu.setSkinStyle(upColors,overColors,downColors);
			settingMenu.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.HEADER_MENU_FONTSIZE,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR);
			settingMenu.label = "设置";
			settingMenu.x = artPlanet.x+InitParams.HEADERMENU_BG_WIDTH+menuGap+200;
			settingMenu.y = 0;
			settingMenu.addEventListener(MouseEvent.CLICK, openSettingWin);
			mainMenuContainer.addChild(settingMenu);
			
			//关于菜单， 点击打开窗口
			aboutMenu = new TextMenu(InitParams.HEADERMENU_BG_WIDTH,InitParams.HEADER_HEIGHT);
			aboutMenu.setSkinStyle(upColors,overColors,downColors);
			aboutMenu.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.HEADER_MENU_FONTSIZE,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR);
			aboutMenu.label = "关于";
			aboutMenu.x = settingMenu.x+InitParams.HEADERMENU_BG_WIDTH+menuGap;
			aboutMenu.y = 0;
			aboutMenu.addEventListener(MouseEvent.CLICK, openAboutWin);
			mainMenuContainer.addChild(aboutMenu);

		}

		
		private function createFeedbackMenu():void{
			
			feedbackMenu = new TextMenu(InitParams.HEADERMENU_BG_WIDTH,InitParams.HEADER_HEIGHT);
			feedbackMenu.setSkinStyle(upColors,overColors,downColors);
			feedbackMenu.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.HEADER_MENU_FONTSIZE,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR);
			feedbackMenu.label = "反馈";
			//FIXME, 1280分辨率下退出菜单跑到屏幕外面了
			//2012/04/08
			feedbackMenu.x = InitParams.appWidth-2*InitParams.HEADERMENU_BG_WIDTH-menuGap;
			feedbackMenu.y = 0;
			feedbackMenu.addEventListener(MouseEvent.CLICK, openFeedbackWin);
			mainMenuContainer.addChild(feedbackMenu);
			
			if(!_isLogged){
				feedbackMenu.visible = false;
			}
		}
		
		private function createSearchInput():void{
			//搜索输入框
			searchInput = new TextInput();
			searchInput.defaultText = "input tag tag ...";
			searchInput.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			searchInput.setSize(InitParams.SEARCH_INPUT_WIDTH,24);
			searchInput.setStyle(TextInput.style.size,StyleParams.SEARCHINPUT_FONTSIZE);
			searchInput.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);
			searchInput.setStyle(TextInput.style.maxChars,StyleParams.TEXTINPUT_MAXCHARS);
			searchInput.x = elementStartX
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			searchInput.y = 6;	
			searchInput.addEventListener(TextInputEvent.SUBMIT,function():void{
				var keywords:String = searchInput.text;
				if(keywords.length>0)
					dispatchEvent(new PintuEvent(PintuEvent.SEARCH_BYTAGS,keywords));
			});
			mainMenuContainer.addChild(searchInput);
			//search icon
			searchIcon = new SimpleIcon(searchIconPath);
			searchIcon.showUpSkin = true;
			searchIcon.x = searchInput.x+searchInput.width-24;
			searchIcon.y = searchInput.y;	
			searchIcon.addEventListener(MouseEvent.CLICK, function():void{
				var keywords:String = searchInput.text;
				if(keywords.length>0)
					dispatchEvent(new PintuEvent(PintuEvent.SEARCH_BYTAGS,keywords));
			});
			mainMenuContainer.addChild(searchIcon);						
			
			if(!_isLogged) {
				searchInput.visible = false;
				searchIcon.visible = false;
			}
		}
		
		
		private function createExitMenu():void{
			exitMenu = new TextMenu(
				InitParams.HEADERMENU_BG_WIDTH,
				InitParams.HEADER_HEIGHT);
			exitMenu.setSkinStyle(upColors,overColors,downColors);
			exitMenu.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.HEADER_MENU_FONTSIZE,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR);
			exitMenu.label = "退出";
			//FIXME, 1280分辨率下菜单位置跑到外面了
			//2012/04/08
			exitMenu.x = InitParams.appWidth-InitParams.HEADERMENU_BG_WIDTH;
			exitMenu.y = 0;
			
			exitMenu.visible = false;
			if(_isLogged) exitMenu.visible = true;
			//派发导航事件，退出到未登录状态
			exitMenu.addEventListener(MouseEvent.CLICK, logout);
			mainMenuContainer.addChild(exitMenu);
		}			
		
		private function logout(evt:MouseEvent):void{
			dispatchEvent(new PintuEvent(PintuEvent.NAVIGATE, GlobalNavigator.UNLOGGED));
		}
		
		
		private function onError(event:IOErrorEvent):void{
			Logger.error("load logo error: "+logoPath);
		}
		
		/**
		 * 只有主菜单选中，并且子菜单未展现时，才滑出
		 * 这样，鼠标从子菜单返回主菜单时，不做处理
		 */ 
		private function onHomeMenuOver(evt:MouseEvent):void{
			if(homeMenu.selected && browseMode.y<0){
				//Logger.debug("slide to sub menu...");
				browseMode.goDown();
			}
		}
		/**
		 * 通知子菜单，它已经离开了
		 */ 
		private function onHomeMenuOut(evt:MouseEvent):void{
			browseMode.inOwner = false;
		}
		
		/**
		 * 只有主菜单未选中时，才展现子菜单
		 */ 
		private function onHomeMenuClick(evt:MouseEvent):void{
			if(TextMenu(evt.currentTarget).selected) return;
			//展开子菜单，以及切换模块
			switchTo(GlobalNavigator.HOMPAGE, homeMenu);
		}
		
		
		/**
		 * 打开社区模块
		 */ 
		private function onSwitchToCommunity(evt:MouseEvent):void{
			if(TextMenu(evt.currentTarget).selected) return;
			switchTo(GlobalNavigator.COMMUNITY, communityMenu);
		}
		
		/**
		 * 打开星球模块
		 */ 
		private function onSwitchToArtPlanet(evt:MouseEvent):void{
			if(TextMenu(evt.currentTarget).selected) return;
			switchTo(GlobalNavigator.ARTPLANET, artPlanet);
		}
		
		/**
		 * 派发打开窗口事件，在主应用中处理
		 */ 
		private function openSettingWin(evt:MouseEvent):void{
			var openEvt:PintuEvent = new PintuEvent(PintuEvent.OPEN_WIN, PopWinNames.SETTING_WIN);
			this.dispatchEvent(openEvt);
		}
		/**
		 * 派发打开窗口事件，在主应用中处理
		 */
		private function openAboutWin(evt:MouseEvent):void{
			var openEvt:PintuEvent = new PintuEvent(PintuEvent.OPEN_WIN, PopWinNames.ABOUT_WIN);
			this.dispatchEvent(openEvt);
		}		
		/**
		 * 派发打开窗口事件，在主应用中处理
		 */
		private function openFeedbackWin(evt:MouseEvent):void{
			var openEvt:PintuEvent = new PintuEvent(PintuEvent.OPEN_WIN, PopWinNames.FEEDBACK_WIN);
			this.dispatchEvent(openEvt);
		}
		
		/**
		 * 导航事件
		 */
		private function switchTo(moduleName:String, currentMenu:TextMenu):void{
			dispatchEvent(new PintuEvent(PintuEvent.NAVIGATE, moduleName));
			switchSelectedMenu(currentMenu);
		}
		
		/**
		 * 选择某菜单前，先清空上次主菜单项的选中状态，然后记下当前选中的菜单项
		 */ 
		private function switchSelectedMenu(current:TextMenu):void{
			if(selectedMenu){
				selectedMenu.selected = false;				
			}
			selectedMenu = current;
			current.selected = true;
		}
		
		
		
		
	} //end of class
}