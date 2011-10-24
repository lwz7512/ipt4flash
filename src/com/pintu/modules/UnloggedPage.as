package com.pintu.modules
{
	import com.pintu.api.IPintu;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.widgets.ActiveUserBlock;
	import com.pintu.widgets.CategoryTree;
	import com.pintu.widgets.LoginBlock;
	import com.pintu.widgets.MainDisplayArea;
	import com.pintu.widgets.MainToolBar;
	import com.pintu.widgets.SlideToolBar;
	
	import flash.display.Sprite;
	
	public class UnloggedPage extends Sprite{
		
		private var model:IPintu;
		
		public function UnloggedPage(model:IPintu){
			super();
			this.model = model;
				
			var mainToolBar:MainToolBar = new MainToolBar();
			this.addChild(mainToolBar);
			
			var categoryTree:CategoryTree = new CategoryTree();
			this.addChild(categoryTree);
			
			var mainDisplayArea:MainDisplayArea = new MainDisplayArea();
			this.addChild(mainDisplayArea);
			
			var slideToolBar:SlideToolBar = new SlideToolBar();
			this.addChild(slideToolBar);
			
			var login:LoginBlock = new LoginBlock();
			this.addChild(login);
			
			var activeUser:ActiveUserBlock = new ActiveUserBlock();
			this.addChild(activeUser);
			
		}
		
	

		
		
	}
}