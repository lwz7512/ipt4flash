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
		
		private var _model:IPintu;
		private var mainToolBar:MainToolBar;
		private var categoryTree:CategoryTree;
		private var mainDisplayArea:MainDisplayArea;
		private var slideToolBar:SlideToolBar;
		private var login:LoginBlock;
		private var activeUser:ActiveUserBlock;
		
		
		public function UnloggedPage(model:IPintu){
			super();
			this._model = model;
				
			mainToolBar = new MainToolBar(false);
			//TODO, ADD BUTTON EVENT LISTENER...
			
			this.addChild(mainToolBar);
			
			categoryTree = new CategoryTree();
			//TODO, ADD CHANGE EVENT LISTENTER...
			
			this.addChild(categoryTree);
			
			mainDisplayArea = new MainDisplayArea(_model);
			//未登录，默认画廊
			mainDisplayArea.browseType = categoryTree.browseType;			
			this.addChild(mainDisplayArea);
			
			slideToolBar = new SlideToolBar();
			this.addChild(slideToolBar);
			
			login = new LoginBlock();
			this.addChild(login);
			
			activeUser = new ActiveUserBlock();
			this.addChild(activeUser);
			
		}
		
	

		
		
	} //end of class
}