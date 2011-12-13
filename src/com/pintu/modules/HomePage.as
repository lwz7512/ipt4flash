package com.pintu.modules{

	import com.greensock.TweenLite;
	import com.pintu.api.*;
	import com.pintu.config.InitParams;
	import com.pintu.controller.FileManager;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	import com.pintu.widgets.*;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	
	import org.casalib.display.CasaSprite;
	
	
	public class HomePage extends CasaSprite implements IDestroyableModule, IMenuClickResponder{		
		
		private var _model:IPintu;
		private var _fileManager:FileManager;		
		
		private var categoryTree:CategoryTree;		
		private var mainDisplayArea:MainDisplayArea;
		private var slideToolBar:SlideToolBar;
		
		private var userDetails:UserDetailsBlock;
		private var andiAssets:AndiBlock;
		private var weiboFriends:HotTags;
		
		private var picEditWin:PicEditWin;
		
		public function HomePage(model:IPintu){
			super();
			this._model = model;	
			this._fileManager = new FileManager(_model);
			
			//PicDetailView派发的保存事件
			this.addEventListener(PintuEvent.DNLOAD_IMAGE, downLoadRawPic);				
			//UserDetailsBlock派发的贴图事件
			this.addEventListener(PintuEvent.UPLOAD_IMAGE, editPic);						
			
			//呈现图片的主要区域，大部分逻辑都在这里
			mainDisplayArea = new MainDisplayArea(_model);
			//设置即将执行的查询模式：缩略图模式画廊
			//TODO, 后面如果保存了浏览模式，就要修改这里的值
			mainDisplayArea.browseType = BrowseMode.CATEGORY_GALLERY_TBMODE;				
			this.addChild(mainDisplayArea);
			
			slideToolBar = new SlideToolBar();
			this.addChild(slideToolBar);
			
			userDetails = new UserDetailsBlock(_model);
			this.addChild(userDetails);
			
			andiAssets = new AndiBlock();
			this.addChild(andiAssets);
			
			weiboFriends = new HotTags(_model);
			this.addChild(weiboFriends);
			
		}
		
		private function downLoadRawPic(evt:PintuEvent):void{
			var picName:String = evt.extra;
			//打开文件保存路径选择窗口，确定后开始下载
			_fileManager.download(evt.data, picName);
		}
		
		
		private function editPic(evt:PintuEvent):void{
			
			if(!picEditWin){
				//只生成一次，必须添加在舞台上，这样才产生全局的Mask
				picEditWin = new PicEditWin(this.stage, _fileManager);				
			}
			
			picEditWin.x = (InitParams.appWidth-picEditWin.width)/2;
			//屏幕上方
			picEditWin.y = -picEditWin.height;
			//添加在顶级
			this.stage.addChild(picEditWin);
			
			var endY:Number = (InitParams.appHeight-picEditWin.height)/2;
			//动画切入
			TweenLite.to(picEditWin, 0.6, {y:endY});
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
				//告诉显示区，按照最新画廊模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_GALLERY_TBMODE;
			}
			
			//大图列表模式
			if(operation==PintuEvent.BROWSE_CHANGED 
				&& extra==BrowseMode.CATEGORY_GALLERY_BPMODE){
				//告诉显示区，按照大图模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_GALLERY_BPMODE;
			}
			
			//热点模式
			if(operation==PintuEvent.BROWSE_CHANGED 
				&& extra==BrowseMode.CATEGORY_HOT){
				//告诉显示区，按照热图模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_HOT;
			}
			
			//经典模式
			if(operation==PintuEvent.BROWSE_CHANGED 
				&& extra==BrowseMode.CATEGORY_CLASSICAL){
				//告诉显示区，按照经典模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_CLASSICAL;
			}
			
			//最近收藏模式
			if(operation==PintuEvent.BROWSE_CHANGED 
				&& extra==BrowseMode.CATEGORY_FAVORED){
				//告诉显示区，按照最近收藏模式查询
				mainDisplayArea.browseType = BrowseMode.CATEGORY_FAVORED;
			}
			
		}
		
		
		public  function killMe():void{
			//移除自己，并销毁事件监听
			super.destroy();
			//清除事件监听
			_fileManager.cleanUp();
			_fileManager = null;
			//清空引用
			_model = null;
			removeChildren(true,true);		
		}
		
		
	} //end of class
}