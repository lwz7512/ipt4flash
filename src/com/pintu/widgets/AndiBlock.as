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
		
		private var titleBackgroudColor:uint = StyleParams.HEADERBAR_TOP_LIGHTGREEN;
		private var titleBackgroudHeight:int = InitParams.ANDI_TITLE_HEIGHT;
		
		//菜单使用颜色
		private var upColors:Array;
		private var overColors:Array;
		private var downColors:Array;		
		
		public function AndiBlock(){
			super();
			
			drawLoginBackGround();
			drawTitleBar();
			drawMenus();
		}
		
		private function drawTitleBar():void{
			this.graphics.beginFill(titleBackgroudColor, 0.8);
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
			overColors = [StyleParams.ICONMENU_MOUSEOVER_BOTTOM,
				StyleParams.ICONMENU_MOUSEOVER_BOTTOM];
			downColors = [StyleParams.DARKER_BORDER_COLOR,
				StyleParams.DARKER_BORDER_COLOR];
			
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
			
			
			//我的消息
			
			
			
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
			//半透明效果似乎更好
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,
				InitParams.ANDI_ASSETS_WIDTH,InitParams.ANDI_ASSETS_HEIGHT);
			this.graphics.endFill();
		}
		
		
	}//end of class
}