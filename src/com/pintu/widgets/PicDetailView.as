package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.controller.GlobalController;
	import com.pintu.events.*;
	import com.pintu.utils.*;
	import com.pintu.vos.CmntData;
	import com.pintu.vos.TPicDetails;
	import com.sibirjak.asdpc.button.ButtonEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 图片详情对象，大图模式下，多个详情有同时出现的情况
	 * 包括内容：可浮动的工具栏、图片及相关信息、评论列表以及评论发表	
	 * 
	 * 由PicDOBuilder大图对象创建
	 */ 
	public class PicDetailView extends PicDetailBase{
		
		
		private var _clonedModel:IPintu;	

		/*
		 * construction function....
		 */
		public function PicDetailView(data:TPicDetails, model:IPintu, logged:Boolean){			
			super(data, logged);
			//每个视图中，都有各自不同的模型，这样就不会干扰了
			_clonedModel = model.clone();						
						
			this.addEventListener(Event.ADDED_TO_STAGE, addModelListeners);			
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanUpClonedModel);
		}
		
		/**
		 * 给PicDOBuilder使用，用来在查看详情时可以返回画廊
		 */ 
		public function set showBackBtn(v:Boolean):void{
			_showBackBtn = v;
		}
		
		private function addModelListeners(evt:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, addModelListeners);
			
			PintuImpl(_clonedModel).addEventListener(ApiMethods.ADDSTORY, cmntPostHandler);
			PintuImpl(_clonedModel).addEventListener(ApiMethods.GETSTORIESOFPIC, cmntListHandler);
			PintuImpl(_clonedModel).addEventListener(ApiMethods.MARKTHEPIC, markPicHandler);
			PintuImpl(_clonedModel).addEventListener(ApiMethods.ADDVOTE, votePicHandler);
			PintuImpl(_clonedModel).addEventListener(ApiMethods.SENDMSG, reportPicHandler);
			PintuImpl(_clonedModel).addEventListener(ApiMethods.FORWARDTOWEIBO, forwardHandler);
		}
		
		/**
		 * 清除给模型添加的事件
		 * 清空模型引用
		 */ 
		private function cleanUpClonedModel(evt:Event):void{
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.ADDSTORY, cmntPostHandler);
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.GETSTORIESOFPIC, cmntListHandler);
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.MARKTHEPIC, markPicHandler);
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.ADDVOTE, votePicHandler);
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.SENDMSG, reportPicHandler);
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.FORWARDTOWEIBO, forwardHandler);
			
			//这个是复制出来的，一定要销毁
			_clonedModel.destory();
			_clonedModel = null;
		}
		
		private function cmntPostHandler(evt:Event):void{								
			//因为有舞台的invalidate方法，这时舞台可能丢失，所以要处理
			if(!stageAvailable()) return;
			
			if(evt is PTStatusEvent){
//				Logger.debug("comment post once...");
				//新的评论，先不添加进去
				var cmntObj:CmntData = new CmntData();
				cmntObj.author = "我";
				cmntObj.content = cmtInput.text;
				var cmntItem:CommentItem = new CommentItem(cmntObj);				
				
				//如果原来有评论，就将他们往下移动一个位置
				//检查commentsHolder中CommentItem对象，挨个移动位置
				relayoutComments(cmntItem.height);
				
				//添加我的评论到列表顶部
				cmntItem.x = 0;
				cmntItem.y = cmtInput.height+28;
				commentsHolder.addChild(cmntItem);
				
				//移除loading
				hideCmntLoading();
				
				//FIXME, 评论数加1
				//2012/02/21
				this.addCommentNum();
			}
			
			if(evt is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.ADDSTORY);
			}
		}
		
		private function cmntListHandler(evt:Event):void{
			if(evt is ResponseEvent){
				Logger.debug("ResponseEvent arrived once...");
			}			
			
			if(!stageAvailable()) return;
			
			if(evt is ResponseEvent){
				var jsonCmnt:String = ResponseEvent(evt).data;
				Logger.debug("json comments: "+jsonCmnt);
				createCommentList(jsonCmnt);
				//FIXME, HIDE PROGRESS...
				//2012/02/12
				this.dispatchEvent(new PintuEvent(PintuEvent.HIDE_PROGRESS,null));				
			}
			if(evt is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.ADDSTORY);
			}
			
		}
		
		private function markPicHandler(evt:Event):void{
			if(evt is ResponseEvent){
				//在主显示区弹出提示
				this.dispatchEvent(new PintuEvent(PintuEvent.HINT_USER, "图片收藏成功"));
				//通知HomePage，要给AndiBlock的收藏菜单旁边显示一个+1
				this.dispatchEvent(new PintuEvent(PintuEvent.MARK_SUCCSS, null));
			}
			if(evt is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.MARKTHEPIC);
			}
		}
		
		private function votePicHandler(evt:Event):void{
			if(evt is PTStatusEvent){
				//在主显示区弹出提示
				this.dispatchEvent(new PintuEvent(PintuEvent.HINT_USER, "图片投票成功"));
			}
			if(evt is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.ADDVOTE);
			}
		}
		
		private function reportPicHandler(evt:Event):void{
			if(evt is ResponseEvent){
				//在主显示区弹出提示
				this.dispatchEvent(new PintuEvent(PintuEvent.HINT_USER, "感谢您的举报，我们会及时处理！"));
			}
			if(evt is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.SENDMSG);
			}
		}
		
		private function forwardHandler(evt:Event):void{
			if(evt is ResponseEvent){
				//提示用户结果
				var result:String = ResponseEvent(evt).data;
				if(result=="true"){
					//在主显示区弹出提示
					this.dispatchEvent(new PintuEvent(PintuEvent.HINT_USER, "转发成功！"));
				}else{
					//在主显示区弹出提示
					this.dispatchEvent(new PintuEvent(PintuEvent.HINT_USER, "转发失败！"));
				}
			}
			if(evt is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.FORWARDTOWEIBO);
			}
		}
	

		/**
		 * 评论输入框和评论列表
		 * 如果没有就创建，如果有了销毁
		 */ 
		override protected function addComment(evt:MouseEvent):void{
			//点击评论按钮，画廊图片滚动使图片置顶
			var picGlobalY:Number = this.localToGlobal(new Point(0,0)).y;	
			//当前视图由于有滚动操作，所以必须转换为全局位置
			var galleryGlobalY:Number = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;			
			var diffY:Number = picGlobalY-galleryGlobalY;
			if(diffY>0){
				var scrollup:PintuEvent = new PintuEvent(PintuEvent.SCROLL_UP, diffY.toString());
				this.dispatchEvent(scrollup);
			}			
			
			//初始化
			if(!commentsHolder) commentsHolder = new CasaSprite();
			
			//如果已经展开评论列表了，就销毁评论列表，合上内容
			if(this.contains(commentsHolder)){
				commentsHolder.removeChildren(true,true);
				this.removeChild(commentsHolder);				
				//通知外围，渲染完成
				rendered();						
				return;
				
			}else{//如果没有展开列表，先添加一个评论容器
				commentsHolder.x = _xStartOffset;
				commentsHolder.y = 2*_yStartOffset+_mobImgHeight;
				this.addChild(commentsHolder);
			}
			//输入框改变大小时跟这个比较得到增减的大小
			//从而改变评论列表的位置
			//两行高度正好42
			var origInputHeight:Number = 42;
			
			//创建评论输入框，和提交按钮
			cmtInput = new TextArea();
			cmtInput.text = "";
			cmtInput.setSize(InitParams.GALLERY_WIDTH-4, origInputHeight);
			cmtInput.autoStretchHeight = true;			
			cmtInput.autoFocus = true;				
			
			cmtInput.addEventListener(TextArea.RESIZED, function():void{
				cmtSubmit.y = cmtInput.height+2;				
				//每次换行或者缩进都要调整评论列表的位置
				var diff:Number = cmtInput.height-origInputHeight;
				//如果下面有评论就往下移动
				relayoutComments(diff);
				//保存新的值
				origInputHeight = cmtInput.height;
								
			});
			commentsHolder.addChild(cmtInput);
			
			var cmtSubmitXoffset:Number = 70;
			var cmtSubmit:GreenButton = new GreenButton();
			cmtSubmit.label = "评论";
			cmtSubmit.setSize(60,24);
			//在输入框的下面，右端对齐
			cmtSubmit.x = InitParams.GALLERY_WIDTH-cmtSubmitXoffset;
			cmtSubmit.y =  cmtInput.height+2;
			cmtSubmit.addEventListener(ButtonEvent.CLICK, postComment);
			commentsHolder.addChild(cmtSubmit);
			
			//如果评论数大于0，获取评论列表，评论获得后增加视图高度	
			if(Number(_data.commentsNum)){
				_clonedModel.getComments(_data.id);
				//FIXME, ADD PROGRESS...
				//2012/02/12
				this.dispatchEvent(new PintuEvent(PintuEvent.SHOW_PROGRESS,null));
			}
			//通知外围，渲染完成
			rendered();		
		}
		
		private function createCommentList(jsonCmnt:String):void{
			var cmnts:Array = JSON.decode(jsonCmnt) as Array;
			if(cmnts.length==0) return;
			
			var cmntItems:Array = [];
			for each(var cmnt:Object in cmnts){
				if(!cmnt) continue;
				var cmntVO:CmntData = new CmntData();
				cmntVO.id = cmnt["id"];
				cmntVO.author = cmnt["author"];
				cmntVO.content = cmnt["content"];
				cmntVO.follow = cmnt["follow"];
				cmntVO.owner = cmnt["owner"];
				cmntVO.publishTime = cmnt["publishTime"];
				var cmntItem:CommentItem = new CommentItem(cmntVO);
				cmntItems.push(cmntItem);
			}
			
			if(!commentsHolder) return;
			
			//评论列表布局
			var layoutStartY:Number = commentsHolder.height+2;
			for(var i:int=0; i<cmntItems.length; i++){
				var eachItem:CommentItem = cmntItems[i];
				eachItem.y = layoutStartY;
				layoutStartY += eachItem.height;
				commentsHolder.addChild(eachItem);
			}
			
			//通知外围，渲染完成
			rendered();		
		}
		
		private function relayoutComments(yOffset:Number):void{
			//这里面除了有评论内容，还有输入框、按钮
			var cmnts:Array = commentsHolder.children;
			for each(var diplayObj:DisplayObject in cmnts){
				if(diplayObj is CommentItem)
					diplayObj.y += yOffset;
			}
			//通知外围，渲染完成
			rendered();		
		}		
		
		private function postComment(evt:ButtonEvent):void{
			var cmtTxt:String = cmtInput.text;
			if(cmtTxt.length>0){
				_clonedModel.postComment(_data.id, cmtTxt);
				showCmntLoading();
			}
		}
		
		override protected function addToFavorite(evt:MouseEvent):void{			
			_clonedModel.markThePic(_data.id);
		}
		
		/**
		 * 保存原图到本地，只能在HomePage中处理该事件
		 * 因为这个实例里没有文件管理器，没法进行下载操作
		 */ 
		override protected function saveToLocal(evt:MouseEvent):void{			
			var globalEvt:PintuEvent = new PintuEvent(PintuEvent.DNLOAD_IMAGE, _data.rawImgUrl);
			globalEvt.extra = _data.picName;
			this.dispatchEvent(globalEvt);
		}
		
		override protected function likeIt(evt:MouseEvent):void{		
			
			if(_data.owner == PintuImpl(_clonedModel).currentUser){
				//在主显示区弹出提示
				this.dispatchEvent(new PintuEvent(PintuEvent.HINT_USER, "不能给自己投票哟"));
			}else{
				_clonedModel.postVote(_data.owner, _data.id, "cool", "1");							
			}
		}
		
		override protected function reportIt(evt:MouseEvent):void{			
			//调用模型方法提交
			Logger.debug("to report pic: "+_data.id);
			var receiver:String = GlobalController.KEFU_ID;
			var reportContent:String = "I think the picture: "+_data.id+" is illegal, isn't it?";
			_clonedModel.postMsg(receiver,reportContent);
		}
		
		//FIXME, 暂时先用爱品图账号转发
		//2012/05/04
		override protected function sendToWeibo(evt:MouseEvent):void{
			super.sendToWeibo(evt);
			var userId:String = GlobalController.IPINTU_ID;
			_clonedModel.forwardToWeibo(userId, _data.id);
		}
		
		
		override protected function todo(evt:MouseEvent):void{
			//TODO, ADD FORWARD TO WEIBO,  AND REPORT ...
			
		}
		


		
	} //end of class
}