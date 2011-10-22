package com.pintu.config
{
	public class InitParams{
		
		//应用缺省宽度和高度
		public static const MINAPP_WIDTH:Number = 980;
		public static const MINAPP_HEIGHT:Number = 620;
		
		//Header footer height
		public static const HEADERFOOTER_HEIGHT:Number = 32;
		//Header menu background width
		public static const HEADERMENU_BG_WIDTH:Number = 60;
		
		//Main menu bar height
		public static const MAINMENUBAR_HEIGHT:Number = 57;
		//Main menu bar width
		public static const MAINMENUBAR_WIDTH:Number = 772;
		
		//Left column width
		public static const LEFTCOLUMN_WIDTH:Number = 170;
		//Left column height
		public static const LEFTCOLUMN_HEIGHT:Number = 476;
		
		//Log in form width
		public static const LOGIN_FORM_WIDTH:Number = 200;
		//Log in form height
		public static const LOGIN_FORM_HEIGHT:Number = 160;
		
		
		
		
		public static var appWidth:Number;
		public static var appHeight:Number;
		
		public static var isLogged:Boolean;
		public static var userId:String;
		
		
		public function InitParams(){}
		
		
		
	} //end of class
}