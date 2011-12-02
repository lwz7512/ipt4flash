package com.pintu.modules
{
	import com.pintu.api.IPintu;
	import com.pintu.config.*;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	import com.pintu.widgets.*;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 只负责初始化对象，以及对象间交互
	 */
	public class UnloggedPage extends CasaSprite implements IDestroyableModule{
		
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
			
			mainDisplayArea = new MainDisplayArea(_model);
			//未登录，默认画廊
			mainDisplayArea.browseType = BrowseMode.CATEGORY_GALLERY_TBMODE;	
			this.addChild(mainDisplayArea);
			
			slideToolBar = new SlideToolBar();
			this.addChild(slideToolBar);
			
			login = new LoginBlock(_model);
			this.addChild(login);
			
			activeUser = new ActiveUserBlock(_model);
			this.addChild(activeUser);
			
		}
		
		private function changeBrowseType(event:PintuEvent):void{
			var type:String = event.data;
			mainDisplayArea.browseType = type;		
		}

		private function refreshGallery(evt:PintuEvent):void{
//			mainDisplayArea.browseType = categoryTree.browseType;
		}
		private function randomGallery(evt:PintuEvent):void{			
			//告诉显示区，按照随机模式查询
			mainDisplayArea.browseType = BrowseMode.CATEGORY_RANDOM_TBMODE;
		}
		
		//重写销毁函数
		public  function killMe():void{
			//移除自己，并销毁事件监听
			super.destroy();
			//清空引用
			_model = null;
			removeChildren(true,true);			
		}
		
	} //end of class
}