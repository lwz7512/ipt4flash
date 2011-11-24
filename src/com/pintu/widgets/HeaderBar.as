package com.pintu.widgets
{
	import com.pintu.common.TextMenu;
	import com.pintu.config.*;
	import com.pintu.controller.*;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	
	public class HeaderBar extends Sprite{
		
		private var _isLogged:Boolean;
		
		private var logoLoader:ImageLoad;
		private var version:TextField;
		
		private var homeMenu:TextMenu;
		private var communityMenu:TextMenu;
		private var marketMenu:TextMenu;
		private var exitMenu:TextMenu;
		
		private var elementStartX:Number;
		
		private var logoPath:String = "assets/logo36.png";
		private var versionText:String = "爱品图 v1.0";
		
		private var logoVersionGap:Number = 36;
		private var versionHomeGap:Number = 100;
		private var menuGap:Number = 2;
		private var upColors:Array;
		private var overColors:Array;
		private var downColors:Array;
		
		public function HeaderBar(isLogged:Boolean){
			super();			
			_isLogged = isLogged;
			
			elementStartX = InitParams.startDrawingX();
			
			drawBackground();	
			
			showLogo();
			
			showVersion();
			
			createTextMenus();
						
			createExitMenu();	
				
		}
		
		public function showExit():void{
			exitMenu.visible = true;
		}
		
		public function hideExit():void{
			exitMenu.visible = false;
		}
		
		private function showLogo():void{
			//load logo img...
			logoLoader = new ImageLoad(logoPath);
			logoLoader.addEventListener(LoadEvent.COMPLETE,onLoaded);
			logoLoader.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onError);
			logoLoader.start();			
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
			this.addChild(version);			
		}
		
		private function drawBackground():void{
			this.graphics.clear();
			var colors:Array = [StyleParams.HEADERBAR_TOP_LIGHTGREEN,
				StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN,
				StyleParams.HEADERBAR_BOTTOM_LIGHTGREEN];
			var alphas:Array = [1,1,1];
			var ratios:Array = [0,245,255];
			var matrix:Matrix = new Matrix();
			//需要旋转90度，垂直渐变
			matrix.createGradientBox(InitParams.appWidth,InitParams.HEADER_HEIGHT,Math.PI/2);
			this.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matrix);
			this.graphics.drawRect(0,0,InitParams.appWidth,InitParams.HEADER_HEIGHT);
			this.graphics.endFill();

		}
		
		//TODO, add event listener...
		private function createTextMenus():void{
			upColors = [0xFFFFFF,0xFFFFFF];
			overColors = [StyleParams.HEADER_MENU_MOUSEOVER,
				StyleParams.HEADER_MENU_MOUSEOVER];
			downColors = [StyleParams.HEADER_MENU_SELECTED,
				StyleParams.HEADER_MENU_SELECTED];
			
			homeMenu = new TextMenu(
				InitParams.HEADERMENU_BG_WIDTH,
				InitParams.HEADER_HEIGHT);
			homeMenu.setSkinStyle(upColors,overColors,downColors);
			homeMenu.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.HEADER_MENU_FONTSIZE,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR);
			homeMenu.label = "首页";
			homeMenu.x = version.x+versionHomeGap;
			homeMenu.y = 0;
			homeMenu.selected = true;
			this.addChild(homeMenu);
			
			communityMenu = new TextMenu(
				InitParams.HEADERMENU_BG_WIDTH,
				InitParams.HEADER_HEIGHT);
			communityMenu.setSkinStyle(upColors,overColors,downColors);
			communityMenu.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.HEADER_MENU_FONTSIZE,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR);
			communityMenu.label = "社区";
			communityMenu.x = homeMenu.x+InitParams.HEADERMENU_BG_WIDTH+menuGap;
			communityMenu.y = 0;
			communityMenu.enabled = false;
			this.addChild(communityMenu);
			
			marketMenu = new TextMenu(
				InitParams.HEADERMENU_BG_WIDTH,
				InitParams.HEADER_HEIGHT);
			marketMenu.setSkinStyle(upColors,overColors,downColors);
			marketMenu.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.HEADER_MENU_FONTSIZE,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR,
				StyleParams.HEADER_MENU_COLOR);
			marketMenu.label = "夜市";
			marketMenu.x = communityMenu.x+InitParams.HEADERMENU_BG_WIDTH+menuGap;
			marketMenu.y = 0;
			marketMenu.enabled = false;
			this.addChild(marketMenu);
						
			
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
			exitMenu.x = elementStartX
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP
				+InitParams.LOGIN_FORM_WIDTH
				+InitParams.DEFAULT_GAP;
			exitMenu.y = 0;
			
			exitMenu.visible = false;
			if(_isLogged) exitMenu.visible = true;
			//派发导航事件，退出到未登录状态
			exitMenu.addEventListener(MouseEvent.CLICK, logout);
			this.addChild(exitMenu);
		}
		
		private function logout(evt:MouseEvent):void{
			dispatchEvent(new PintuEvent(PintuEvent.NAVIGATE, GlobalNavigator.UNLOGGED));
		}
		
		private function onLoaded(e:LoadEvent):void {
			this.addChild(this.logoLoader.contentAsBitmap);
			this.logoLoader.contentAsBitmap.x = elementStartX;
			
		}
		
		private function onError(event:IOErrorEvent):void{
			Logger.error("load logo error: "+logoPath);
		}
		
		
	} //end of class
}