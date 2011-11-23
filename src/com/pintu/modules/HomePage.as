package com.pintu.modules
{
	import com.pintu.api.IPintu;
	import com.pintu.events.PintuEvent;
	import com.pintu.widgets.*;
	import com.pintu.widgets.AndiBlock;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;
	
	public class HomePage extends CasaSprite{		
		
		private var _model:IPintu;
		
		private var mainToolBar:MainToolBar;
		
		private var categoryTree:CategoryTree;
		
		private var mainDisplayArea:MainDisplayArea;
		private var slideToolBar:SlideToolBar;
		
		private var userDetails:UserDetailsBlock;
		private var andiAssets:AndiBlock;
		private var weiboFriends:WeiboFriendsBlock;
		
		public function HomePage(model:IPintu){
			super();
			this._model = model;
			
			mainToolBar = new MainToolBar(true);
			mainToolBar.addEventListener(PintuEvent.REFRESH_GALLERY, refreshGallery);
			mainToolBar.addEventListener(PintuEvent.RANDOM_GALLERY, randomGallery);
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
			
			userDetails = new UserDetailsBlock(_model);
			this.addChild(userDetails);
			andiAssets = new AndiBlock();
			this.addChild(andiAssets);
			weiboFriends = new WeiboFriendsBlock(_model);
			this.addChild(weiboFriends);
			
		}
		
		
		private function changeBrowseType(event:PintuEvent):void{
			var type:String = event.data;
			mainDisplayArea.browseType = type;		
		}
		
		private function refreshGallery(evt:PintuEvent):void{
			mainDisplayArea.browseType = categoryTree.browseType;
		}
		private function randomGallery(evt:PintuEvent):void{
			//选中画廊模式节点
			categoryTree.browseType = CategoryTree.CATEGORY_GALLERY_TBMODE;
			//告诉显示区，按照随机模式查询
			mainDisplayArea.browseType = CategoryTree.CATEGORY_RANDOM_TBMODE;
		}
		
		//重写销毁函数
		override public  function destroy():void{
			super.destroy();
			_model = null;
			removeChildren(true,true);		
		}
		
		
	} //end of class
}