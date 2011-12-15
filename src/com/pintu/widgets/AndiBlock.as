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
		
		private var titleBackgroudColor:uint = StyleParams.ICONMENU_MOUSEOVER_TOP;
		private var titleBackgroudHeight:int = InitParams.ANDI_TITLE_HEIGHT;
		
		//菜单使用颜色
		private var upColors:Array;
		private var overColors:Array;
		private var downColors:Array;		
		
		private var myMsgs:TextMenu;
		
		public function AndiBlock(){
			super();
			
			drawLoginBackGround();
			drawTitleBar();
			drawMenus();
		}
		
		private function drawTitleBar():void{
			this.graphics.beginFill(titleBackgroudColor, 1);
			this.graphics.drawRect(drawStartX,drawStartY,InitParams.ANDI_ASSETS_WIDTH,titleBackgroudHeight);
			this.graphics.endFill();
			
			var title:SimpleText = new SimpleText("我的首页", 0xFFFFFF, 13);
			title.x = drawStartX+(InitParams.ANDI_ASSETS_WIDTH-title.textWidth)/2;
			title.y = drawStartY+4;
			this.addChild(title);
		}
		private function drawMenus():void{
			
			//主菜单颜色设置
			upColors = [StyleParams.PICDETAIL_BACKGROUND_THIRD,
				StyleParams.PICDETAIL_BACKGROUND_THIRD];
			overColors = [StyleParams.HEADER_MENU_MOUSEOVER,
				StyleParams.HEADER_MENU_MOUSEOVER];
			downColors = [StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN,
				StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN];
			
			var menuVGap:Number = 2;
			var menuStartX:Number = drawStartX+1;
			var menuStartY:Number = drawStartY+titleBackgroudHeight+menuVGap;
			var menuWidth:Number = InitParams.ANDI_ASSETS_WIDTH-1;
			
			//我的贴图
			var myPics:TextMenu = new TextMenu(menuWidth, titleBackgroudHeight);
			myPics.setSkinStyle(upColors,overColors,downColors);
			myPics.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				0xFFFFFF);
			myPics.upAlpha = 1;
			myPics.label = "贴图";
			myPics.x = menuStartX;
			myPics.y = menuStartY;
			this.addChild(myPics);
			
			//我的收藏
			var myFavorites:TextMenu = new TextMenu(menuWidth, titleBackgroudHeight);
			myFavorites.setSkinStyle(upColors,overColors,downColors);
			myFavorites.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				0xFFFFFF);
			myFavorites.upAlpha = 1;
			myFavorites.label = "收藏";
			myFavorites.x = menuStartX;
			myFavorites.y = menuStartY+titleBackgroudHeight+menuVGap;
			this.addChild(myFavorites);
			
			//我的消息
			myMsgs = new TextMenu(menuWidth, titleBackgroudHeight);
			myMsgs.setSkinStyle(upColors,overColors,downColors);
			myMsgs.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				0xFFFFFF);
			myMsgs.upAlpha = 1;
			myMsgs.label = "消息";
			myMsgs.x = menuStartX;
			myMsgs.y = menuStartY+2*titleBackgroudHeight+2*menuVGap;
			this.addChild(myMsgs);
			
			
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
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,
				InitParams.ANDI_ASSETS_WIDTH,InitParams.ANDI_ASSETS_HEIGHT);
			this.graphics.endFill();
		}
		
		
	}//end of class
}