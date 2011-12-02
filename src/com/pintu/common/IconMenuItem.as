package com.pintu.common{
	
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 一个带背景渐变色和图标的菜单项
	 * 输着放形成一组
	 */ 
	public class IconMenuItem extends CasaSprite{
		
		private var _iconPath:String = "assets/defaultimg.png";
		private var _menuText:String = "子菜单...";
		private var _defaultWidth:int = 100;
		private var _defaultHeight:int = 28;
		//深绿
		private var _firstBGColor:uint = 0xC2CCD0;
		private var _secdBGColor:uint = 0xFFFFFF;
		//浅绿
		private var _hiliBGColor:uint = 0x9ED048;
		
		public function IconMenuItem(text:String, icon:String=null){
			if(icon) _iconPath = icon;
			_menuText = text;
			
			drawBackground(_firstBGColor);		
			
			var iconImg:SimpleImage = new SimpleImage(_iconPath);
			iconImg.x = 2;
			iconImg.y = 2;
			this.addChild(iconImg);
			
			var txt:SimpleText = new SimpleText(text, 0x41555D);
			txt.x = 36;
			txt.y = 4;
			this.addChild(txt);
			
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
		}
		
		private function clickHandler(evt:MouseEvent):void{
			//do nothin here...
		}
		private function overHandler(evt:MouseEvent):void{
			drawBackground(_hiliBGColor);
		}
		//恢复原来的底色
		private function outHandler(evt:MouseEvent):void{
			drawBackground(_firstBGColor);
		}
		
		private function drawBackground(color:uint):void{
			var startColor:uint = color;
			var colors:Array = [startColor, _secdBGColor];
			var alphas:Array = [0.8,0.4];
			var ratios:Array = [120,255];		
			this.graphics.clear();
//			this.graphics.lineStyle(1, 0xC2CCD0, 0.6);
			this.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios);
			this.graphics.drawRect(0,0,_defaultWidth,_defaultHeight);
			this.graphics.endFill();
		}
		
	} //end of class
}