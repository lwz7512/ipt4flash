package com.pintu.config
{
	public class InitParams{
		
		public function InitParams(){}
		
		
		//运行时初始化参数		
		public static var appWidth:Number = 0;
		public static var appHeight:Number = 0;				
		
		//应用缺省宽度和高度
		public static const MINAPP_WIDTH:Number = 980;
		public static const MINAPP_HEIGHT:Number = 620;
		
		//App section gap
		public static const TOP_BOTTOM_GAP:Number = 6;
		public static const DEFAULT_GAP:Number = 4;
		
		//Header footer height
		public static const HEADER_HEIGHT:Number = 32;
		public static const FOOTER_HEIGHT:Number = 26;
		//Header menu background width
		public static const HEADERMENU_BG_WIDTH:Number = 60;
		
		//Main menu bar height
		public static const MAINMENUBAR_HEIGHT:Number = 57;
		//Main menu bar width
		public static const MAINMENUBAR_WIDTH:Number = 772;
		//search input width
		public static const SEARCH_INPUT_WIDTH:Number = 200;
		
		//Gallery display section width
		public static const GALLERY_WIDTH:Number = 597;
		//Gallery display section height
		public static const CALLERY_HEIGHT:Number = 478;
		
		//Left column width
		public static const LEFTCOLUMN_WIDTH:Number = 170;
		//Left column height
		public static const LEFTCOLUMN_HEIGHT:Number = 478;
		
		//Log in form width
		public static const LOGIN_FORM_WIDTH:Number = 200;
		//Log in form height
		public static const LOGIN_FORM_HEIGHT:Number = 160;
		
		
		
		public static function startDrawingX():Number{
			var startX:Number;
			if(appWidth<MINAPP_WIDTH){
				startX = 0;
			}else{
				startX = (appWidth-MINAPP_WIDTH)/2;
			}
			return startX;
		}
		
		public static function isStretchHeight():Boolean{
			return InitParams.MINAPP_HEIGHT<InitParams.appHeight?true:false;
		}
		
	} //end of class
}