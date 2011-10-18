package com.pintu.modules
{
	import com.pintu.api.IPintu;
	import com.pintu.widgets.ActiveUserBlock;
	import com.pintu.widgets.LoginBlock;
	
	import flash.display.Sprite;
	
	public class UnloggedPage extends Sprite
	{
		
		private var model:IPintu;
		
		public function UnloggedPage(model:IPintu)
		{
			super();
			this.model = model;
				
			buildMainToolBar();
			buildLeftCategoryTree();
			buildMainDisplayArea();
			buildSlideToolBar();
			buildRightColumns();
		}
		
		private function buildMainToolBar():void{
			
		}
		
		private function buildLeftCategoryTree():void{
			
		}
		
		private function buildMainDisplayArea():void{
			
		}
		
		private function buildSlideToolBar():void{
			
		}
		
		private function buildRightColumns():void{
			var login:LoginBlock = new LoginBlock();
			this.addChild(login);
			var activeUser:ActiveUserBlock = new ActiveUserBlock();
			this.addChild(activeUser);
		}
		
		
	}
}