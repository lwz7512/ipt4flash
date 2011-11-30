package com.pintu.modules{

	import com.greensock.TweenLite;
	import com.pintu.api.*;
	import com.pintu.config.InitParams;
	import com.pintu.controller.FileManager;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	import com.pintu.widgets.*;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;	
	
	
	public class HomePage extends CasaSprite implements IDestroyableModule{		
		
		private var _model:IPintu;
		private var _fileManager:FileManager;
		
		private var mainToolBar:MainToolBar;		
		private var categoryTree:CategoryTree;		
		private var mainDisplayArea:MainDisplayArea;
		private var slideToolBar:SlideToolBar;
		
		private var userDetails:UserDetailsBlock;
		private var andiAssets:AndiBlock;
		private var weiboFriends:WeiboFriendsBlock;
		
		private var picEditWin:PicEditWin;
		
		public function HomePage(model:IPintu){
			super();
			this._model = model;	
			this._fileManager = new FileManager(_model);
			//PicDetailView派发的保存事件
			this.addEventListener(PintuEvent.DNLOAD_IMAGE, downLoadRawPic);			
			
			mainToolBar = new MainToolBar(true);
			mainToolBar.addEventListener(PintuEvent.REFRESH_GALLERY, refreshGallery);
			mainToolBar.addEventListener(PintuEvent.RANDOM_GALLERY, randomGallery);
			mainToolBar.addEventListener(PintuEvent.UPLOAD_IMAGE, editPic);
			//将来还要加搜索监听
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
		
		private function downLoadRawPic(evt:PintuEvent):void{
			var picName:String = evt.extra;
			//打开文件保存路径选择窗口，确定后开始下载
			_fileManager.download(evt.data, picName);
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
		
		private function editPic(evt:PintuEvent):void{
			if(!picEditWin){
				picEditWin = new PicEditWin(this, _fileManager);
			}
			
			picEditWin.x = (InitParams.appWidth-picEditWin.width)/2;
			//屏幕上方
			picEditWin.y = -picEditWin.height;
			this.addChild(picEditWin);
			var endY:Number = (InitParams.appHeight-picEditWin.height)/2;
			//动画切入
			TweenLite.to(picEditWin, 0.6, {y:endY});
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		//重写销毁函数
		public  function killMe():void{
			//移除自己，并销毁事件监听
			super.destroy();
			_model = null;
			removeChildren(true,true);		
		}
		
		
	} //end of class
}