package com.pintu.modules
{
	import com.pintu.api.IPintu;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PintuEvent;
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
			mainToolBar.addEventListener(PintuEvent.REFRESH_GALLERY, refreshGallery);
			//TODO, ADD BUTTON EVENT LISTENER...
			
			this.addChild(mainToolBar);
			
			categoryTree = new CategoryTree(_model);
			categoryTree.addEventListener(PintuEvent.BROWSE_CHANGED,changeBrowseType);			
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
		
		private function changeBrowseType(event:PintuEvent):void{
			var type:String = event.data;
			mainDisplayArea.browseType = type;		
		}

		private function refreshGallery(evt:PintuEvent):void{
			mainDisplayArea.browseType = categoryTree.browseType;
		}
		
	} //end of class
}