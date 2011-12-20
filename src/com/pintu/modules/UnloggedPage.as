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
	public class UnloggedPage extends CasaSprite implements IDestroyableModule, IMenuClickResponder{
		
		private var _model:IPintu;
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
			
			login = new LoginBlock(_model);
			this.addChild(login);
			
			activeUser = new ActiveUserBlock(_model);
			activeUser.addEventListener(PintuEvent.GETPICS_BYUSER, getPicsOfUser);
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
		
		private function getPicsOfUser(evt:PintuEvent):void{
			mainDisplayArea.browseType = MainDisplayArea.GETPICS_BYUSER;
			mainDisplayArea.user = evt.data;
		}
		
		/**
		 * 在Main中的browseTypeChanged监听器中调用该方法
		 */ 
		public function menuHandler(operation:String, extra:String):void{
			//随机模式
			if(operation==PintuEvent.BROWSE_CHANGED 
				&& extra==BrowseMode.CATEGORY_RANDOM_TBMODE){
				//告诉显示区，按照随机模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_RANDOM_TBMODE;
			}
			//缩略图模式
			if(operation==PintuEvent.BROWSE_CHANGED 
				&& extra==BrowseMode.CATEGORY_GALLERY_TBMODE){
				//告诉显示区，按照随机模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_GALLERY_TBMODE;
			}
			
			//大图列表模式
			if(operation==PintuEvent.BROWSE_CHANGED 
				&& extra==BrowseMode.CATEGORY_GALLERY_BPMODE){
				//告诉显示区，按照随机模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_GALLERY_BPMODE;
			}
			
			//热点模式
			if(operation==PintuEvent.BROWSE_CHANGED 
				&& extra==BrowseMode.CATEGORY_HOT){
				//告诉显示区，按照随机模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_HOT;
			}
			
			//经典模式
			if(operation==PintuEvent.BROWSE_CHANGED 
				&& extra==BrowseMode.CATEGORY_CLASSICAL){
				//告诉显示区，按照随机模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_CLASSICAL;
			}
			
			//最近收藏模式
			if(operation==PintuEvent.BROWSE_CHANGED 
				&& extra==BrowseMode.CATEGORY_FAVORED){
				//告诉显示区，按照随机模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_FAVORED;
			}
		}
		
		//重写销毁函数
		public  function killMe():void{	
			super.destroy();
			//清空引用
			_model = null;
			removeChildren(true,true);			
		}
		
	} //end of class
}