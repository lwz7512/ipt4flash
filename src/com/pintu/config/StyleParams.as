package com.pintu.config
{
	public class StyleParams{
		public function StyleParams(){}		
		
		//全局的边框颜色，花白：白色和黑色混杂的。斑白的、夹杂有灰色的白
		public static const DEFAULT_BORDER_COLOR:uint = 0xC2CCD0;
		//较深的边框色，墨灰：即黑灰
		public static const DARKER_BORDER_COLOR:uint = 0x758A99;
		//默认背景色，荼白：如荼之白色
		public static const DEFAULT_FILL_COLOR:uint = 0xF3F9F1;
		//深绿色，黛绿：墨绿
		public static const DEFAULT_DARK_GREEN:uint = 0x426666;
		
		//迷你工具栏，图片详情时操作
		public static const MINI_TOOLBAR_FILLCOLOR:uint = 0x50616D;
		
		//黑色背景，漆黑：非常黑的
		public static const DEFAULT_BLACK_COLOR:uint = 0x161823;
		
		/**
		 * Header bar LIGHT GREEN style
		 * 颜色段比例：0~245~255
		 */ 
		//绿沈（沉）：深绿
		public static const HEADERBAR_TOP_LIGHTGREEN:uint = 0x0C8918;
		//油绿：光润而浓绿的颜色
		public static const HEADERBAR_NEARBOTTOM_LIGHTGREEN:uint = 0x00BC12;
		//黯：深黑色、泛指黑色
		public static const HEADERBAR_BOTTOM_LIGHTGREEN:uint = 0x41555D;
		
		//图片详情文字背景，苍色：即各种颜色掺入黑色后的颜色
		//这个是目前为止唯一觉得比较合适的颜色
		//2011/12/08
		public static const PICDETAIL_BACKGROUND_DARK:uint = 0x75878A;
		//银灰色
		public static const PICDETAIL_BACKGROUND_GRAY:uint = 0xC2CCD0;
		//亮棕绿色
		public static const PICDETAIL_BACKGROUND_BROWN:uint = 0xA3B2AD;
		/**
		 * 柔和的灰色，由专业人士建议
		 */  
		public static const PICDETAIL_BACKGROUND_THIRD:uint = 0xEEEEEE;
		
		//图片占位区域背景，霜色：白霜的颜色
		public static const PICTURE_HOLDER_BACKGROUND:uint = 0xE9F1F6;
		
		/**
		 * Header menu style
		 */ 
		//松花绿：亦作“松花”、“松绿”。偏黑的深绿色，墨绿
		public static const HEADER_MENU_SELECTED:uint = 0x057748;
		//豆绿：浅黄绿色
		public static const HEADER_MENU_MOUSEOVER:uint = 0x9ED048;
		//精白：纯白、洁白、净白、粉白
		public static const HEADER_MENU_COLOR:uint = 0xFFFFFF;
						
		/**
		 * Main Menu bar ICE style
		 * 颜色段比例：0~245~255
		 */
		//银白：带银光的白色
		public static const MENUBAR_TOP_ICE:uint = 0xE9E7EF;
		//雪白：如雪般洁白
		public static const MENUBAR_NEARBOTTOM_ICE:uint = 0xF0FCFF;
		//霜色：白霜的颜色
		public static const MENUBAR_BOTTOM_ICE:uint = 0xE9F1F6;
		
		/**
		 * Icon Menu Background style
		 * 颜色段比例：0~255
		 */ 
		//苍色：即各种颜色掺入黑色后的颜色
		public static const ICONMENU_SELECTED_TOP:uint = 0x75878A;
		//霜色：白霜的颜色
		public static const ICONMENU_SELECTED_BOTTOM:uint = 0xE9F1F6;
		
		//蓝灰色：一种近于灰略带蓝的深灰色
		public static const ICONMENU_MOUSEOVER_TOP:uint = 0xA1AFC9;
		//月白：淡蓝色
		public static const ICONMENU_MOUSEOVER_BOTTOM:uint = 0xD6ECF0;
		
		
		/**
		 * FOOTER BAR SILVER style
		 */ 
		//花白：白色和黑色混杂的。斑白的、夹杂有灰色的白
		public static const FOOTER_SOLID_GRAY:uint = 0xC2CCD0;
		
		
		/**
		 * Text font style ...
		 */
		public static const DEFAULT_TEXT_FONTNAME:String = "宋体";
		public static const DEFAULT_TEXT_FONTSIZE:int = 12;
		
		public static const HEADER_MENU_FONTSIZE:int = 14;
		public static const TOOL_MENU_FONTSIZE:int = 12;
		//xx xx xx xx or xxx xxx xxx, so total is 12;
		public static const TEXTINPUT_MAXCHARS:int = 12;
		
		public static const SEARCHINPUT_FONTSIZE:int = 14;
		public static const TEXTINPUT_FONTSIZE:int = 14;
		
		//黯：深黑色、泛指黑色
		public static const DEFAULT_TEXT_COLOR:uint = 0x41555D;		
		//黑色背景上使用的文字颜色：油绿：光润而浓绿的颜色
		public static const GREEN_TEXT_COLOR:uint = 0x00BC12;
		//老银：金属氧化后的色彩
		public static const GRAY_TEXT_COLOR:uint = 0xBACAC6;			
		public static const WHITE_TEXT_COLOR:uint = 0xFFFFFF;			
			
		//标准红色，大红：正红色，三原色中的红，传统的中国红，又称绛色
		public static const DEFAULT_ERROR_RED:uint = 0xFF2121;
		
		//子菜单颜色：
		//普通颜色，花白：白色和黑色混杂的。斑白的、夹杂有灰色的白
		public static const SUBMENU_UPCOLOR:uint = 0xC2CCD0;
		//高亮颜色，豆绿：浅黄绿色
		public static const SUBMENU_HLCOLOR:uint = 0x9ED048;
		
		
	} //end of color
}