package com.pintu.widgets
{
	import flash.display.Sprite;
	
	public class HeaderBar extends Sprite
	{
		
		private var isLogged:Boolean;
		
		public function HeaderBar(isLoggedin:Boolean)
		{
			super();
			this.isLogged = isLoggedin;
			
		}
	}
}