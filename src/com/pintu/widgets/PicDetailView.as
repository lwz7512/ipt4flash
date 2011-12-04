package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.cartogrammar.drawing.DashedLine;
	import com.greensock.TweenLite;
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.controller.GlobalController;
	import com.pintu.events.*;
	import com.pintu.utils.*;
	import com.pintu.vos.CmntData;
	import com.pintu.vos.TPicData;
	import com.sibirjak.asdpc.button.Button;
	import com.sibirjak.asdpc.button.ButtonEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	import org.casalib.display.CasaTextField;
	import org.casalib.load.ImageLoad;
	
	/**
	 * 包括内容：可浮动的工具栏、图片及相关信息、评论列表以及评论发表	
	 * 
	 * 由PicDOBuilder中的detailPicHandler方法创建
	 */ 
	public class PicDetailView extends CasaSprite{
		
		//当前图片详情对应数据
		private var _data:TPicData;
		private var _model:IPintu;	
		
		//看查看缩略图详情的返回按钮让位
		//正常的大图列表是不需要此设置的
		private var _showBackBtn:Boolean = false;		
		//图片加载结束标志
		private var imgLoadedFlag:Boolean = false;
		
		//左边空点距离
		private var _xStartOffset:Number = 2;
		//上面有工具栏，给工具栏让位
		private var _yStartOffset:Number = 2;	
		//工具栏背景宽度
		private var _toolBGWidth:Number = InitParams.GALLERY_WIDTH-4;
		
		//默认图片大小，图片加载结束时改变
		private var _mobImgWidth:Number = 440;
		private var _mobImgHeight:Number = 440;
		
		//图片占位最小宽度，也是工具栏的宽度
		private var defaultImgWidth:Number = 440;
		//描述内容高度
		private var defaultDescTextHeight:Number = 80;					
		
		//图片未展示前出现
		private var mobImgPlaceHolder:DashedLine;
		private var imgLoading:CasaTextField;		
		
		//详情内容
		private var mobImage:SimpleImage;
		private var toolHolder:CasaSprite;
		private var imgInfoHolder:CasaSprite;
		private var imgDescText:CasaSprite;
		
		//评论相关内容
		private var commentsHolder:CasaSprite;
		//评论输入框
		private var cmtInput:TextArea;		
		//评论提交和查询进度条
		private var cmtLoading:BusyIndicator;
		//很奇怪，评论列表会返回3次，做个开关屏蔽掉
		private var commentsHandleFlag:Boolean;
		
		/*
		 * construction function....
		 */
		public function PicDetailView(data:TPicData, model:IPintu){
			_data = data;
			if(!_data) return;
			
			_model = model;
			PintuImpl(_model).addEventListener(ApiMethods.ADDSTORY, cmntPostHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETSTORIESOFPIC, cmntListHandler);
			PintuImpl(_model).addEventListener(ApiMethods.MARKTHEPIC, markPicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.ADDVOTE, votePicHandler);
			
			//draw image place hoder
			drawImgePlaceHolder();			
			//loading image...
			drawLoadingText();
			
			//先生成图片，等图片加载完成后，再生成其他内容
			mobImage = new SimpleImage(data.mobImgUrl);
			mobImage.addEventListener(PintuEvent.IMAGE_LOADED,imgLoaded);
			this.addChild(mobImage);			
						
			this.addEventListener(MouseEvent.MOUSE_OVER, displayHidePart);
			this.addEventListener(MouseEvent.MOUSE_OUT, hideToolAndDesc);
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
		}
		
		public function set showBackBtn(v:Boolean):void{
			_showBackBtn = v;
		}
		//清空模型引用
		private function cleanUp(evt:Event):void{
			_model = null;
		}
		
		private function cmntPostHandler(evt:Event):void{
			if(evt is PTStatusEvent){
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
			}
			
			if(evt is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.ADDSTORY);
			}
		}
		
		private function cmntListHandler(evt:Event):void{
			if(!commentsHandleFlag) return;
			
			if(evt is ResponseEvent){
				var jsonCmnt:String = ResponseEvent(evt).data;
//				Logger.debug("json comments: "+jsonCmnt);
				createCommentList(jsonCmnt);
				commentsHandleFlag = false;
			}
			if(evt is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.ADDSTORY);
			}
			
		}
		
		private function markPicHandler(evt:Event):void{
			if(evt is PTStatusEvent){
				//在主显示区弹出提示
				this.dispatchEvent(new PintuEvent(PintuEvent.HINT_USER, "图片收藏成功"));
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
		
		private function hideCmntLoading():void{
			if(!cmtLoading) return;
			if(commentsHolder.contains(cmtLoading)){
				commentsHolder.removeChild(cmtLoading);
				cmtInput.text = "";				
			}
		}
		
		private function showCmntLoading():void{
			cmtLoading = new BusyIndicator(24);
			//进度条位于提交评论按钮的左侧
			cmtLoading.x = InitParams.GALLERY_WIDTH-94;
			cmtLoading.y = cmtInput.height+2;;
			commentsHolder.addChild(cmtLoading);
		}
		
		private function drawImgePlaceHolder():void{
			//draw mobile image placeholder...
			mobImgPlaceHolder = new DashedLine(1,0x333333,[6,2,6,2]);
			//起点
			mobImgPlaceHolder.moveTo(_xStartOffset, _yStartOffset);
			//填充
			mobImgPlaceHolder.beginFill(0xFFFFFF);
			//水平边
			mobImgPlaceHolder.lineTo(_xStartOffset+_mobImgWidth, _yStartOffset);
			//右侧边
			mobImgPlaceHolder.lineTo(_xStartOffset+_mobImgWidth, _yStartOffset+_mobImgHeight);
			//底部边
			mobImgPlaceHolder.lineTo(_xStartOffset, _yStartOffset+_mobImgHeight);
			//左侧边
			mobImgPlaceHolder.lineTo(_xStartOffset, _yStartOffset);
			mobImgPlaceHolder.endFill();
			
			this.addChild(mobImgPlaceHolder);
			
		}
		
		private function displayHidePart(evt:MouseEvent):void{
			if(!imgLoadedFlag) return;
			
			if(toolHolder){
				TweenLite.to(toolHolder, 0.3, {alpha: 1});
			}
			//显示图片描述
			if(imgDescText){	
				//向上走，并长高
				TweenLite.to(imgDescText, 0.3,
					{y: _yStartOffset+_mobImgHeight-defaultDescTextHeight, scaleY:1, 
						onComplete: showDescTxt });
			}
		}
		
		private  function showDescTxt():void{			
			imgDescText.getChildAt(0).visible = true;
		}
		
		private function hideToolAndDesc(evt:MouseEvent):void{
			if(!imgLoadedFlag) return;
			
			if(toolHolder){
				TweenLite.to(toolHolder, 0.3, {alpha: 0});
			}
			//隐藏图片描述
			if(imgDescText){
				//向下走，并缩小
				TweenLite.to(imgDescText, 0.3, {y: (_yStartOffset+_mobImgHeight), scaleY:0,
					onStart: hideDescTxt });
			}
		}	
		
		private  function hideDescTxt():void{
			imgDescText.getChildAt(0).visible = false;
		}
		
		private function drawLoadingText():void{
			imgLoading = new CasaTextField();			
			imgLoading.autoSize = "left";
			imgLoading.defaultTextFormat = new TextFormat(null,14);
			
			imgLoading.text = "loading...";
			imgLoading.x = _xStartOffset+180;
			imgLoading.y = _yStartOffset+220;
			this.addChild(imgLoading);
		}
		
		private function imgLoaded(evt:PintuEvent):void{			
			
			removeChild(mobImgPlaceHolder);
			removeChild(imgLoading);
			
			//获得图片大小
			_mobImgWidth = mobImage.bitmap.width;
			_mobImgHeight = mobImage.bitmap.height;			
			
			Logger.debug("_mobImgWidth: "+_mobImgWidth);
			Logger.debug("_mobImgHeight: "+_mobImgHeight);								
			
			//右侧详情所在背景
			buildPicInfoBlackBG();
			
			//图片相关内容：
			//靠右侧放置，只有展开的评论在图片下面显示			
			buildPicRelateInfo();
			
			//在图片底部上下滑动展示的文字描述内容
			bulidSlideDescription();			
			
			//最后创建图片工具栏，使其浮在顶部
			buildPicOperaTools(_mobImgWidth);		
						
			imgLoadedFlag = true;
			
			//通知外围，渲染完成
			rendered();		
		}
		
		private function buildPicInfoBlackBG():void{
			imgInfoHolder = new CasaSprite();
			imgInfoHolder.graphics.beginFill(StyleParams.DEFAULT_BLACK_COLOR);
			//右侧相关信息占位宽度
			var rightBlackColumnWidth:Number = 
				InitParams.GALLERY_WIDTH - _mobImgWidth;
			imgInfoHolder.graphics.drawRect(_mobImgWidth, _yStartOffset,
				rightBlackColumnWidth,_mobImgHeight);
			imgInfoHolder.graphics.endFill();
			this.addChild(imgInfoHolder);
			//从右侧划滑出
			TweenLite.from(imgInfoHolder, 0.3, {x: rightBlackColumnWidth});
		}
		
		/**
		 * 9项内容：
		 * 头像、用户名、积分、发布时间、浏览次数
		 * 是否原创、标签、评论数目、描述摘要6个字
		 */ 
		private function buildPicRelateInfo():void{
			var startX:Number = _mobImgWidth+4;			
			var startY:Number = 4;	
			
			var textItemVGap:Number = 26;
			var avatarSize:Number = 64;
			var avatarToTextGap:Number = 4;
			
			//头像
			var avatarImg:SimpleImage = new SimpleImage(_data.avatarUrl);
			avatarImg.x = startX;
			avatarImg.y = startY;		
			avatarImg.maxSize = 64;
			imgInfoHolder.addChild(avatarImg);
			
			var green:uint = StyleParams.GREEN_TEXT_COLOR;
			//用户名
			var userNameStr:String = getShowUserName();
			var userNameTF:SimpleText = new SimpleText(userNameStr,green,14,true);
			userNameTF.x = startX+avatarImg.maxSize+avatarToTextGap;
			userNameTF.y = startY;
			imgInfoHolder.addChild(userNameTF);
			
			//积分
			var scoreStr:String = "积分 "+_data.score;
			var scoreTF:SimpleText = new SimpleText(scoreStr, green);
			scoreTF.x = userNameTF.x;
			scoreTF.y = userNameTF.y+46;
			imgInfoHolder.addChild(scoreTF);
			
			//发布时间
			var pubTimeStr:String = PintuUtils.getRelativeTimeFromNow(_data.publishTime);
			var pubTimeTF:SimpleText = new SimpleText(pubTimeStr,green);
			pubTimeTF.x = startX;
			pubTimeTF.y = scoreTF.y+textItemVGap;
			imgInfoHolder.addChild(pubTimeTF);
			
			//浏览次数
			var browseCountStr:String = "浏览次数 "+_data.browseCount;
			var browseCountTF:SimpleText = new SimpleText(browseCountStr,green);
			browseCountTF.x = startX;
			browseCountTF.y = pubTimeTF.y+textItemVGap;
			imgInfoHolder.addChild(browseCountTF);
			
			//是否原创
			var isOriginalStr:String = _data.isOriginal=="0"?"非原创":"原创";
			var isOriginalTF:SimpleText = new SimpleText(isOriginalStr, green);
			isOriginalTF.x = startX;
			isOriginalTF.y = browseCountTF.y+textItemVGap;
			imgInfoHolder.addChild(isOriginalTF);
			
			//标签
			var tagsStr:String = "标签 "+_data.tags;
			var tagsTF:SimpleText = new SimpleText(tagsStr,green);
			tagsTF.x = startX;
			tagsTF.y = isOriginalTF.y+textItemVGap;
			imgInfoHolder.addChild(tagsTF);
			
			//评论数目
			var commentsStr:String = "评论个数 "+_data.commentsNum;
			var commentsTF:SimpleText = new SimpleText(commentsStr,green);
			commentsTF.x = startX;
			commentsTF.y = tagsTF.y+textItemVGap;
			imgInfoHolder.addChild(commentsTF);
			
			//喜欢人数
			var likeNumStr:String = "喜欢人数 "+_data.coolCount;
			var likeTF:SimpleText = new SimpleText(likeNumStr, green);
			likeTF.x = startX;
			likeTF.y = commentsTF.y+textItemVGap;
			imgInfoHolder.addChild(likeTF);
			
			//描述摘要
			var origDescContent:String = _data.description;
			var descStr:String;
			//描述摘要最多10个字
			if(origDescContent.length>10){
				origDescContent = origDescContent.substr(0,10);
				descStr = origDescContent+"...";
			}else{
				descStr = origDescContent;
			}			
			var descTF:SimpleText = new SimpleText(descStr,green);
			descTF.x = startX;
			descTF.y = likeTF.y+textItemVGap;
			imgInfoHolder.addChild(descTF);			
						
		}
		
		private function getShowUserName():String{
			var account:String = _data.author;
			if(account.indexOf("@")>-1){
				return account.split("@")[0];
			}
			return account;
		}		
		
		/**
		 * 描述内容完整部分
		 * 默认是隐藏的，鼠标滑过时显示，与工具栏同时出现
		 */ 
		private function bulidSlideDescription():void{
			imgDescText = new CasaSprite();
			
			imgDescText.graphics.beginFill(StyleParams.DEFAULT_BLACK_COLOR);
			imgDescText.graphics.drawRect(0,0,
				InitParams.GALLERY_WIDTH-2, defaultDescTextHeight);
			imgDescText.graphics.endFill();
			//先放在图片底部
			imgDescText.y = _yStartOffset+_mobImgHeight;
			imgDescText.x = _xStartOffset;
			//初始化高度为0
			imgDescText.scaleY = 0;			
			this.addChild(imgDescText);
			
			//描述完整文字
			var green:uint = StyleParams.GREEN_TEXT_COLOR;
			var descContent:SimpleText = new SimpleText(_data.description,green,12);
			descContent.width = InitParams.GALLERY_WIDTH-2*_xStartOffset;
			descContent.height = defaultDescTextHeight;
			imgDescText.addChild(descContent);
			//初始隐藏，动画结束显示
			descContent.visible = false;
			
		}
		
		/**
		 * 5项操作：
		 * 评论、收藏、转发、保存、喜欢、举报
		 */ 
		private function buildPicOperaTools(imgWidth:Number):void{
			//工具栏不能小于defaultImgWidth
			if(imgWidth<defaultImgWidth){
				imgWidth = defaultImgWidth;
			}
			var iconYOffset:int = 2;
			var iconHGap:int = 66;
			
			var drawStartX:Number = 0;
			//如果是看单个缩略图的详情，就要给返回按钮让位
			if(_showBackBtn){
				drawStartX = iconHGap;
			}
			//所有工具的容器，方便整体控制可见性
			toolHolder = new CasaSprite();
			//先隐藏起来
			toolHolder.alpha = 0;
			this.addChild(toolHolder);
			
			//DRAW BACKGROUND RECTANGLE
			var toolbg:CasaShape = new CasaShape();
			toolbg.graphics.beginFill(StyleParams.DEFAULT_BLACK_COLOR);
			//与图片左对齐
			toolbg.graphics.drawRect(_xStartOffset, _yStartOffset,
				_toolBGWidth, InitParams.TREEITEM_HEIGHT);
			toolbg.graphics.endFill();
			toolHolder.addChild(toolbg);
			
			//ADD COMMENT BUTTON			
			//提交评论成功后，在客户端评论列表顶部增加刚才发送的评论
			//再次点击，恢复原状，图片复位，评论收起			
			var comment:IconButton = new IconButton(26,26);
			comment.iconPath = "assets/comment.png";
			comment.addEventListener(MouseEvent.CLICK, addComment);
			comment.x = drawStartX;
			comment.y = iconYOffset;
			comment.textOnRight = true;
			comment.label = "评论";			
			toolHolder.addChild(comment);
			
			//ADD TO FAVORITE
			var favorite:IconButton = new IconButton(26,26);
			favorite.iconPath = "assets/favorite.png";
			favorite.addEventListener(MouseEvent.CLICK, addToFavorite);
			favorite.x = comment.x +iconHGap;
			favorite.y = iconYOffset;
			favorite.textOnRight = true;
			favorite.label = "收藏";			
			toolHolder.addChild(favorite);
			
			//喜欢投票
			var like:IconButton = new IconButton(26,26);
			like.iconPath = "assets/heart.png";
			like.addEventListener(MouseEvent.CLICK, likeIt);
			like.x = favorite.x +iconHGap;
			like.y = iconYOffset;
			like.textOnRight = true;
			like.label = "喜欢";			
			toolHolder.addChild(like);
			
			
			//SAVE TO LOCAL BUTTON
			var save:IconButton = new IconButton(26,26);
			save.iconPath = "assets/save.png";
			save.addEventListener(MouseEvent.CLICK, saveToLocal);
			save.x = like.x +iconHGap;
			save.y = iconYOffset;
			save.textOnRight = true;
			save.label = "保存";			
			toolHolder.addChild(save);
			
			//FORWAR TO WEIBO BUTTON
			var forward:IconButton = new IconButton(26,26);
			forward.iconPath = "assets/forward.png";
			forward.addEventListener(MouseEvent.CLICK, todo);
			forward.x = save.x +iconHGap;
			forward.y = iconYOffset;
			forward.textOnRight = true;
			forward.label = "转发";
			forward.enabled = false;
			toolHolder.addChild(forward);
			
			//REPORT TO ADMIN BUTTON
			var report:IconButton = new IconButton(26,26);
			report.iconPath = "assets/report.png";
			report.addEventListener(MouseEvent.CLICK, todo);
			report.x = forward.x +iconHGap;
			report.y = iconYOffset;
			report.textOnRight = true;
			report.label = "举报";
			report.enabled = false;
			toolHolder.addChild(report);
						
			
		}
		
		/**
		 * 评论输入框和评论列表
		 * 如果没有就创建，如果有了销毁
		 */ 
		private function addComment(evt:MouseEvent):void{
						
			//初始化
			if(!commentsHolder) commentsHolder = new CasaSprite();
			//如果存在就销毁
			if(this.contains(commentsHolder)){
				commentsHolder.removeChildren(true,true);
				this.removeChild(commentsHolder);				
				//通知外围，渲染完成
				rendered();						
				return;
				
			}else{
				commentsHolder.x = _xStartOffset;
				commentsHolder.y = 2*_yStartOffset+_mobImgHeight;
				this.addChild(commentsHolder);
			}
			//输入框改变大小时跟这个比较得到增减的大小
			//从而改变评论列表的位置
			var origInputHeight:Number;
			
			//创建评论输入框，和提交按钮
			cmtInput = new TextArea();
			cmtInput.text = "";
			cmtInput.setSize(InitParams.GALLERY_WIDTH-4, 24);
			cmtInput.autoStretchHeight = true;			
			cmtInput.autoFocus = true;	
			//记录下来
			origInputHeight = cmtInput.height;
			
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
			
			var cmtSubmit:GreenButton = new GreenButton();
			cmtSubmit.label = "评论";
			cmtSubmit.setSize(60,24);
			//在输入框的下面，右端对齐
			cmtSubmit.x = InitParams.GALLERY_WIDTH-64;
			cmtSubmit.y =  cmtInput.height+2;
			cmtSubmit.addEventListener(ButtonEvent.CLICK, postComment);
			commentsHolder.addChild(cmtSubmit);
			
			//如果评论数大于0，获取评论列表，评论获得后增加视图高度	
			if(Number(_data.commentsNum)){
				_model.getComments(_data.id);
				commentsHandleFlag = true;
			}
			//通知外围，渲染完成
			rendered();		
		}
		
		private function createCommentList(jsonCmnt:String):void{
			var cmnts:Array = JSON.decode(jsonCmnt) as Array;
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
				_model.postComment(_data.id, cmtTxt);
				showCmntLoading();
			}
		}
		
		private function addToFavorite(evt:MouseEvent):void{			
			_model.markThePic(null,_data.id);
		}
		
		//保存原图到本地，在HomePage中处理该事件
		private function saveToLocal(evt:MouseEvent):void{			
			var globalEvt:PintuEvent = new PintuEvent(PintuEvent.DNLOAD_IMAGE, _data.rawImgUrl);
			globalEvt.extra = _data.picName;
			this.dispatchEvent(globalEvt);
		}
		
		private function likeIt(evt:MouseEvent):void{		
			
			if(_data.owner == PintuImpl(_model).currentUser){
				//在主显示区弹出提示
				this.dispatchEvent(new PintuEvent(PintuEvent.HINT_USER, "不能给自己投票哟"));
			}else{
				_model.postVote(_data.owner, _data.id, "cool", "1");							
			}
		}
		
		private function todo(evt:MouseEvent):void{
			//TODO, ADD COMMENT...
			
		}
		
		private function rendered():void{
			//派发尺寸改变事件	
			if(this.stage) this.stage.invalidate();			
		}

		
	} //end of class
}