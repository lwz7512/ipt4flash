package com.pintu.modules{

	import com.greensock.TweenLite;
	import com.pintu.api.*;
	import com.pintu.config.InitParams;
	import com.pintu.controller.FileManager;
	import com.pintu.controller.GlobalController;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	import com.pintu.widgets.*;
	import com.pintu.window.*;
	import com.pintu.window.EditWinBase;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	
	import org.as3commons.ui.layout.shortcut.display;
	import org.casalib.display.CasaSprite;
	
	
	public class HomePage extends CasaSprite implements IDestroyableModule, IMenuClickResponder{		
		
		private var _model:IPintu;
		private var _fileManager:FileManager;		
		
		private var mainDisplayArea:MainDisplayArea;
		private var slideToolBar:SlideToolBar;
		
		private var userDetails:UserDetailsBlock;
		private var andiAssets:AndiBlock;
		private var hotTags:HotTags;
		
		private var picEditWin:PicEditWin;
		private var msgEditWin:MsgEditWin;
		private var userEditWin:UserEditWin;
		
		public function HomePage(model:IPintu){
			super();
			_model = model;	
			_fileManager = new FileManager(_model);
			//监听我的资产和消息回复动作派发的事件
			this.addEventListener(PintuEvent.POST_MSG, editMsg);
			
			buildMainDisplayArea();
			buildSlideToolBar();
			buildUserDetail();
			buildAndiMenu();
			buildHotTags();
		
		}
		
		private function buildMainDisplayArea():void{
			//呈现图片的主要区域，大部分逻辑都在这里
			mainDisplayArea = new MainDisplayArea(_model);			
			//设置即将执行的查询模式：缩略图模式画廊
			var savedBrowseType:String = GlobalController.browseType;
			if(savedBrowseType){
				mainDisplayArea.browseType = savedBrowseType;
			}else{
				mainDisplayArea.browseType = BrowseMode.CATEGORY_GALLERY_TBMODE;				
			}
			//设置显示网页url指定的图片详情
			if(ExternalInterface.available){
				var tpId:String = ExternalInterface.call("getPicIdAfterAnchor");
				if(tpId && tpId!="") {
					mainDisplayArea.browseType = MainDisplayArea.GETPIC_BYID;
					mainDisplayArea.tpId = tpId;
				}
			}	
			
			//PicDetailView派发的事件，内部无法处理下载动作
			mainDisplayArea.addEventListener(PintuEvent.DNLOAD_IMAGE, downLoadRawPic);
			mainDisplayArea.addEventListener(PintuEvent.MARK_SUCCSS, showMarkHint);
			this.addChild(mainDisplayArea);
		}
		
		private function buildSlideToolBar():void{
			slideToolBar = new SlideToolBar();
			slideToolBar.alpha = 0;
			slideToolBar.addEventListener(PintuEvent.BROWSE_CHANGED, browseTypeChanged);
			this.addChild(slideToolBar);
		}
		
		private function buildUserDetail():void{
			userDetails = new UserDetailsBlock(_model);
			userDetails.addEventListener(PintuEvent.UPLOAD_IMAGE, editPic);			
			userDetails.addEventListener(PintuEvent.POST_USERINFO, editUserInfo);
			this.addChild(userDetails);
		}
		
		private function buildAndiMenu():void{
			andiAssets = new AndiBlock(_model);
			andiAssets.addEventListener(PintuEvent.SHOW_MSGS, displayMsgList);
			andiAssets.addEventListener(PintuEvent.GET_MYPICS, displayMyPics);
			andiAssets.addEventListener(PintuEvent.GET_MYFAVS, displayMyFavs);
			this.addChild(andiAssets);
		}
		
		private function buildHotTags():void{
			hotTags = new HotTags(_model);
			hotTags.addEventListener(PintuEvent.GETTB_BYTAG, displayThumbnailsOfTag);
			this.addChild(hotTags);
		}
		
		
		private function displayThumbnailsOfTag(evt:PintuEvent):void{
			mainDisplayArea.browseType = MainDisplayArea.THUMBNAIL_BYTAG;
			mainDisplayArea.tag = evt.data;
		}
		
		private function browseTypeChanged(evt:PintuEvent):void{
			this.menuHandler(PintuEvent.BROWSE_CHANGED, evt.data);
		}
		
		private function displayMsgList(evt:PintuEvent):void{
			var msgObjs:Array = andiAssets.msgs;
			if(msgObjs==null) return;
			if(msgObjs.length==0) return;
			//创建消息列表
			mainDisplayArea.createUserMsgs(msgObjs);			
		}
		
		private function displayMyPics(evt:PintuEvent):void{
			mainDisplayArea.browseType = AndiBlock.CATEGORY_GALLERY_MINE;
		}
		
		private function displayMyFavs(evt:PintuEvent):void{
			mainDisplayArea.browseType = AndiBlock.CATEGORY_GALLERY_MYFAV;
		}
		
		
		private function downLoadRawPic(evt:PintuEvent):void{
			var picName:String = evt.extra;
			//打开文件保存路径选择窗口，确定后开始下载
			_fileManager.download(evt.data, picName);
		}
		
		private function showMarkHint(evt:PintuEvent):void{
			andiAssets.showNewMarked();
		}
		
		
		private function editPic(evt:PintuEvent):void{			
			if(!picEditWin){
				//只生成一次，必须添加在舞台上，这样才产生全局的Mask
				picEditWin = new PicEditWin(this.stage, _fileManager);	
				picEditWin.addEventListener(PintuEvent.HINT_USER,sendSuccessHandler);
			}			
			dropCenterWindow(picEditWin);
		}
		
		private function editMsg(evt:PintuEvent):void{
			if(!msgEditWin){
				msgEditWin = new MsgEditWin(this.stage);
				msgEditWin.sourceModel = _model;
				msgEditWin.addEventListener(PintuEvent.HINT_USER,sendSuccessHandler);
			}
			//回复消息需要这两个参数
			var receiverId:String = evt.data;
			var receiverName:String = evt.extra;
			if(receiverId) msgEditWin.receiverId = receiverId;
			if(receiverName) msgEditWin.receiverName = receiverName;
			
			dropCenterWindow(msgEditWin);
		}
		
		private function editUserInfo(evt:PintuEvent):void{
			if(!userEditWin){
				userEditWin = new UserEditWin(this.stage, _fileManager);
				userEditWin.addEventListener(PintuEvent.REFRESH_USER,refreshUserAvatar);
			}
			dropCenterWindow(userEditWin);
		}
		
		private function refreshUserAvatar(evt:PintuEvent):void{
			userDetails.refreshUserEstate();
		}
		
		/**
		 * 向下滑出窗口
		 */ 
		private function dropCenterWindow(win:EditWinBase):void{
			win.x = (InitParams.appWidth-win.width)/2;
			//屏幕上方
			win.y = -win.height;
			
			//FIXME, 注意：必须添加在顶级
			this.stage.addChild(win);
			
			var endY:Number;
			if(InitParams.isStretchHeight()){
				endY = (InitParams.appHeight-win.height)/2;
			}else{
				endY = (InitParams.MINAPP_HEIGHT-win.height)/2;
			}
			//动画切入
			TweenLite.to(win, 0.6, {y:endY});
		}
		
		//Main来监听此事件，弹出提示
		private function sendSuccessHandler(evt:PintuEvent):void{			
			this.dispatchEvent(evt);
		}
		
		/**
		 * 在Main中的browseTypeChanged监听器中调用该方法
		 */ 
		public function menuHandler(operation:String, extra:String):void{
			//FIXME, 恢复URL地址，去掉#...
			//2012/01/13
			ExternalInterface.call("resetAppUrl");			
			
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
		
		public function searchable(key:String):void{			
			mainDisplayArea.browseType = MainDisplayArea.SEARCHRESULT_BYTAG;
			mainDisplayArea.tag = key;
		}
		
		
		public  function killMe():void{
			super.destroy();
			//清除事件监听
			_fileManager.cleanUp();
			_fileManager = null;
			
			//清理窗口实例
			if(picEditWin) picEditWin.destroy();
			picEditWin = null;
			
			if(msgEditWin) msgEditWin.destroy();
			msgEditWin = null;
			
			if(userEditWin) userEditWin.destroy();
			userEditWin = null;
						
			//清空引用
			_model = null;
			removeChildren(true, true);		
			
			Logger.debug("HomePage destroyed...");
		}
		
		
	} //end of class
}