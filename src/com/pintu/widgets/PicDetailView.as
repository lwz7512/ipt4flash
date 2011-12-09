package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.cartogrammar.drawing.DashedLine;
	import com.greensock.TweenLite;
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.events.*;
	import com.pintu.utils.*;
	import com.pintu.vos.CmntData;
	import com.pintu.vos.TPicData;
	import com.sibirjak.asdpc.button.ButtonEvent;
	
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	import org.casalib.display.CasaTextField;
	
	/**
	 * 图片详情对象，大图模式下，多个详情有同时出现的情况
	 * 包括内容：可浮动的工具栏、图片及相关信息、评论列表以及评论发表	
	 * 
	 * 由PicDOBuilder大图对象创建
	 */ 
	public class PicDetailView extends CasaSprite{
		
		//当前图片详情对应数据
		private var _data:TPicData;
		private var _clonedModel:IPintu;	
//		private var _miniClient:LiteHttpClient;
		
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
		private var _mobImgDefaultSize:Number = 440;
		private var _mobImgWidth:Number = _mobImgDefaultSize;
		private var _mobImgHeight:Number = _mobImgDefaultSize;
		
		//图片占位最小宽度，也是工具栏的宽度
		private var defaultImgWidth:Number = 440;
		//描述内容高度
		private var defaultDescTextHeight:Number = 80;	
		//工具栏高度
		private var toolbarHeight:Number = InitParams.TREEITEM_HEIGHT;
		
		//图片未展示前出现
		private var mobImgPlaceHolder:CasaShape;
		private var imgLoading:CasaTextField;		
		
		//详情内容
		private var mobImage:SimpleImage;
		private var toolHolder:CasaSprite;
		private var imgInfoHolder:CasaSprite;
		
		//评论相关内容
		private var commentsHolder:CasaSprite;
		//评论输入框
		private var cmtInput:TextArea;		
		//评论提交和查询进度条
		private var cmtLoading:BusyIndicator;
		//鼠标如果在工具栏区域，显示工具栏
		private var mouseOnToolZone:Boolean;
		
		
		
		
		/*
		 * construction function....
		 */
		public function PicDetailView(data:TPicData, model:IPintu){
			_data = data;
			if(!_data) return;
			
			//每个视图中，都有各自不同的模型，这样就不会干扰了
			_clonedModel = model.clone();						
			
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
			
			this.addEventListener(Event.ADDED_TO_STAGE, initDetailView);			
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
		}
		
		/**
		 * 给PicDOBuilder使用，用来在查看详情时可以返回画廊
		 */ 
		public function set showBackBtn(v:Boolean):void{
			_showBackBtn = v;
		}
		
		private function initDetailView(evt:Event):void{
			PintuImpl(_clonedModel).addEventListener(ApiMethods.ADDSTORY, cmntPostHandler);
			PintuImpl(_clonedModel).addEventListener(ApiMethods.GETSTORIESOFPIC, cmntListHandler);
			PintuImpl(_clonedModel).addEventListener(ApiMethods.MARKTHEPIC, markPicHandler);
			PintuImpl(_clonedModel).addEventListener(ApiMethods.ADDVOTE, votePicHandler);
		}
		
		/**
		 * 清除给模型添加的事件
		 * 清空模型引用
		 */ 
		private function cleanUp(evt:Event):void{
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.ADDSTORY, cmntPostHandler);
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.GETSTORIESOFPIC, cmntListHandler);
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.MARKTHEPIC, markPicHandler);
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.ADDVOTE, votePicHandler);
			//这个是复制出来的，一定要销毁
			_clonedModel.destory();
			_clonedModel = null;
		}
		
		private function cmntPostHandler(evt:Event):void{								
			//因为有舞台的invalidate方法，这时舞台可能丢失，所以要处理
			if(!stageAvailable()) return;
			
			if(evt is PTStatusEvent){
				Logger.debug("comment post once...");
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
			if(evt is ResponseEvent){
				Logger.debug("ResponseEvent arrived once...");
			}			
			
			if(!stageAvailable()) return;
			
			if(evt is ResponseEvent){
				var jsonCmnt:String = ResponseEvent(evt).data;
				Logger.debug("json comments: "+jsonCmnt);
				createCommentList(jsonCmnt);
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
			mobImgPlaceHolder = new CasaShape();	
			//每次绘制前清空
			mobImgPlaceHolder.graphics.clear();						
			//填充
			mobImgPlaceHolder.graphics.beginFill(StyleParams.PICDETAIL_BACKGROUND_THIRD);
			//矩形，这个高度重绘时，改变，但是宽度保持不变
			mobImgPlaceHolder.graphics.drawRect(_xStartOffset, _yStartOffset, _mobImgDefaultSize, _mobImgHeight);
			mobImgPlaceHolder.graphics.endFill();
			
			this.addChild(mobImgPlaceHolder);
			
		}
		
		private function displayHidePart(evt:MouseEvent):void{
			if(!imgLoadedFlag) return;
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, checkMousePosition);
			
		}
		
		
		private function hideToolAndDesc(evt:MouseEvent):void{
			if(!imgLoadedFlag) return;
			
			this.removeEventListener(MouseEvent.MOUSE_MOVE, checkMousePosition);
			//鼠标离开后，隐藏工具栏
			if(toolHolder){
				TweenLite.to(toolHolder, 0.3, {alpha: 0});
			}

		}	
		
		private function checkMousePosition(evt:MouseEvent):void{
			//必须都按照全局坐标计算才行
			var globalMouseY:Number = evt.stageY;
			//当前视图由于有滚动操作，所以必须转换为全局位置
			var diffY:Number = globalMouseY-this.localToGlobal(new Point(0,0)).y;				
			
			if(diffY<2*toolbarHeight){
				mouseOnToolZone = true;				
				if(toolHolder){
					//显示工具栏				
					TweenLite.to(toolHolder, 0.3, {alpha: 1});
				}
			}else{
				mouseOnToolZone = false;				
				if(toolHolder){
					//隐藏工具栏					
					TweenLite.to(toolHolder, 0.3, {alpha: 0});
				}
			}
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
		
		/**
		 * 顺序别弄乱了，否则盖住了，最终顺序从下到上：
		 * -----imgInfoHolder-----
		 * -----mobImgPlaceHolder-----
		 * -----mobImage-----
		 * -----toolHolder-----
		 */ 
		private function imgLoaded(evt:PintuEvent):void{			
			
			removeChild(mobImgPlaceHolder);
			removeChild(imgLoading);
			
			//固定图片宽度为默认宽度让文字都能对齐
			//这个数据是绘制其他内容的依据
			_mobImgWidth = InitParams.DEFAULT_BIGPIC_WIDTH;
			_mobImgHeight = mobImage.bitmap.height;	
			
			//右侧详情所在背景，先放让它能位于图的底部，使得图片的一部分绘制内容能露出来
			buildPicInfoBlackBG();
			
			//如果图片宽度不够440，让图片靠右与所有的图片对齐
			if(mobImage.bitmap.width<InitParams.DEFAULT_BIGPIC_WIDTH){
				mobImage.x = (InitParams.DEFAULT_BIGPIC_WIDTH-mobImage.bitmap.width);
			}
			
			//白色边框加黑色带三角形边线，指向原创
			drawImageTriangleBorder();
			
			//重绘占位符，因为图片高度改变了，所以占位符也要相应改变			
			drawImgePlaceHolder();
			//这时它位于图片上方了，要与图片交换层级
			this.swapChildren(mobImage, mobImgPlaceHolder);			
			
			//图片相关内容：
			//靠右侧放置，只有展开的评论在图片下面显示			
			buildPicRelateInfo();				
			
			//最后创建图片工具栏，使其浮在顶部
			buildPicOperaTools(_mobImgWidth);		
						
			imgLoadedFlag = true;
			
			//图片加载结束，第一次通知外围，渲染完成
			rendered();		
		}
		
		private function drawImageTriangleBorder():void{
			//在图片mobImage中添加个shape，盖住图片
			var frameThickness:int = 4;
			var mobImageMask:CasaShape = new CasaShape();			
			
			var offset:int = 2;
			var originalY:Number = 80;
			var triangleSize:int = 14;
			var imageWidth:Number = mobImage.width;
			var imageHeight:Number = mobImage.height;
			//起点
			var triangleStartX:Number = imageWidth+1;
			var triangleStartY:Number = originalY;
			//三角形顶点
			var triangleVertixX:Number = imageWidth+triangleSize/2;
			var triangleVertixY:Number = originalY+triangleSize/2;
			//终点
			var triangleEndX:Number = imageWidth+1;
			var triangleEndY:Number = originalY+triangleSize;				
			
			//直角白色角边框
			mobImageMask.graphics.lineStyle(frameThickness, 0xFFFFFF, 1, true, "normal", null, JointStyle.MITER);
			mobImageMask.graphics.drawRect(frameThickness, frameThickness, 
				mobImage.width-frameThickness, mobImage.height-frameThickness);
			
			//用白色填充下三角形
			mobImageMask.graphics.beginFill(0xFFFFFF);
			mobImageMask.graphics.moveTo(triangleStartX, triangleStartY+offset);
			mobImageMask.graphics.lineTo(triangleVertixX-offset, triangleVertixY);
			mobImageMask.graphics.lineTo(triangleEndX, triangleEndY-offset);
			mobImageMask.graphics.lineTo(triangleStartX, triangleStartY+offset);
			mobImageMask.graphics.endFill();
			
			//墨绿细边框，在白色边框的外围，有个三角对圆圈
			mobImageMask.graphics.lineStyle(1, StyleParams.DEFAULT_DARK_GREEN, 1,true, "normal", null, JointStyle.MITER);
			//左上角
			mobImageMask.graphics.moveTo(offset,offset);
			//右上角
			mobImageMask.graphics.lineTo(imageWidth+1,offset);
			//右侧三角开始
			mobImageMask.graphics.lineTo(triangleStartX, triangleStartY);
			//右侧三角形顶点
			mobImageMask.graphics.lineTo(triangleVertixX, triangleVertixY);
			//右侧三角结束
			mobImageMask.graphics.lineTo(triangleEndX, triangleEndY);
			//右下角
			mobImageMask.graphics.lineTo(imageWidth+1, imageHeight+1);
			//左下角
			mobImageMask.graphics.lineTo(offset, imageHeight+1);
			//回左上角
			mobImageMask.graphics.lineTo(offset,offset);					
									
			mobImage.addChild(mobImageMask);
		}
		
		private function buildPicInfoBlackBG():void{
			imgInfoHolder = new CasaSprite();
			//画背景色
			imgInfoHolder.graphics.beginFill(StyleParams.PICDETAIL_BACKGROUND_THIRD);
			var rightBlackColumnWidth:Number = 
				InitParams.GALLERY_WIDTH - _mobImgWidth;
			imgInfoHolder.graphics.drawRect(_mobImgWidth, _yStartOffset,
				rightBlackColumnWidth,_mobImgHeight);
			imgInfoHolder.graphics.endFill();
			
			//TODO, 画个类似Path的竖线
			//2011/12/08
			var vLineXoffset:Number = 20;
			var vLineThickness:int = 4;
			imgInfoHolder.graphics.lineStyle(vLineThickness,StyleParams.PICDETAIL_BACKGROUND_GRAY, 1, true, "normal", JointStyle.BEVEL);
			imgInfoHolder.graphics.moveTo(_mobImgWidth+vLineXoffset, 3);
			imgInfoHolder.graphics.lineTo(_mobImgWidth+vLineXoffset, _mobImgHeight+1);
		
			
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
			var marging:Number = 44;
			var startX:Number = _mobImgWidth+marging;			
			var startY:Number = 4;	
			var textItemVGap:Number = 26;
			var textItemHGap:Number = 26;
			var avatarSize:Number = 64;
			var avatarToTextGap:Number = 4;
			
			var green:uint = StyleParams.GREEN_TEXT_COLOR;
			var white:uint = StyleParams.WHITE_TEXT_COLOR;
			var dark:uint = StyleParams.DEFAULT_BLACK_COLOR;
			var gray:uint = StyleParams.GRAY_TEXT_COLOR;
			var normaTXTSize:int = 12;
			var bigTXTSize:int = 16;
			
			//头像
			var avatarImg:SimpleImage = new SimpleImage(_data.avatarUrl);
			avatarImg.x = startX;
			avatarImg.y = startY;	
			avatarImg.maxSize = 64;
			imgInfoHolder.addChild(avatarImg);
			
			
			//用户名
			var userNameStr:String = getShowUserName();
			var userNameTF:SimpleText = new SimpleText(userNameStr,dark,bigTXTSize,true);
			userNameTF.x = startX+avatarImg.maxSize+avatarToTextGap;
			userNameTF.y = startY;
			imgInfoHolder.addChild(userNameTF);
			
			//积分
			var scoreStr:String = "积分 "+_data.score;
			var scoreTF:SimpleText = new SimpleText(scoreStr, dark, normaTXTSize);
			scoreTF.x = userNameTF.x;
			scoreTF.y = userNameTF.y+46;
			imgInfoHolder.addChild(scoreTF);
			
			//是否原创
			var isOriginalStr:String = _data.isOriginal=="0"?"非原创":"原创";
			var isOriginal:Boolean = _data.isOriginal=="0"?false:true;
			var origColor:uint;
			var origFontSize:int;
			if( !isOriginal){//非原创
				origColor = dark;
				origFontSize = normaTXTSize;
			}else{//原创
				origColor = green;
				origFontSize = bigTXTSize;
			}
			var isOriginalTF:SimpleText = new SimpleText(isOriginalStr, origColor, origFontSize, true);
			isOriginalTF.x = startX;
			isOriginalTF.y = scoreTF.y+textItemVGap;
			imgInfoHolder.addChild(isOriginalTF);
			
			//在原创的旁边竖线上，画个圆圈
			//非原创，用灰色圈，原创，用绿色圈
			var origCircleRadius:Number = 10;
			var vLineXoffset:Number = 20;
			var origCircleX:Number = _mobImgWidth+vLineXoffset;
			var origCircleY:Number = isOriginalTF.y+10;
			//跟竖线一样的颜色
			imgInfoHolder.graphics.lineStyle(2, StyleParams.PICDETAIL_BACKGROUND_GRAY);
			if(isOriginal){//画绿色圈
				imgInfoHolder.graphics.beginFill(green, 1);
			}else{//画与背景色相同颜色圈
				imgInfoHolder.graphics.beginFill(StyleParams.PICDETAIL_BACKGROUND_THIRD, 1);
			}
			imgInfoHolder.graphics.drawCircle(origCircleX, origCircleY, origCircleRadius);
			imgInfoHolder.graphics.endFill();
			//里边再画个白圈
			imgInfoHolder.graphics.lineStyle(2, 0xFFFFFF);
			imgInfoHolder.graphics.drawCircle(origCircleX, origCircleY, origCircleRadius-2);						
			
			
			//发布时间，靠右边放置，这点跟手机版类似
			var pubTimeStr:String = PintuUtils.getRelativeTimeFromNow(_data.publishTime);
			var pubTimeTF:SimpleText = new SimpleText(pubTimeStr,dark, normaTXTSize);
			pubTimeTF.x = InitParams.GALLERY_WIDTH - pubTimeTF.textWidth-textItemHGap;
			pubTimeTF.y = scoreTF.y+textItemVGap;
			imgInfoHolder.addChild(pubTimeTF);
			
			//浏览次数
			var browseCountStr:String = "浏览次数 "+_data.browseCount;
			var browseCountTF:SimpleText = new SimpleText(browseCountStr,dark, normaTXTSize);
			browseCountTF.x = startX;
			browseCountTF.y = isOriginalTF.y+textItemVGap;
			imgInfoHolder.addChild(browseCountTF);									
			
			//评论数目
			var commentsStr:String = "评论个数 "+_data.commentsNum;
			var commentsTF:SimpleText = new SimpleText(commentsStr,dark, normaTXTSize);
			commentsTF.x = browseCountTF.x+browseCountTF.textWidth+textItemHGap;
			commentsTF.y = isOriginalTF.y+textItemVGap;
			imgInfoHolder.addChild(commentsTF);
			
			//喜欢人数
			var likeNumStr:String = "喜欢人数 "+_data.coolCount;
			var likeTF:SimpleText = new SimpleText(likeNumStr, dark, normaTXTSize);
			likeTF.x = commentsTF.x+commentsTF.textWidth+textItemHGap;
			likeTF.y = isOriginalTF.y+textItemVGap;
			imgInfoHolder.addChild(likeTF);
			
			//标签
			var tagsStr:String = "标签 "+_data.tags;
			var tagsTF:SimpleText = new SimpleText(tagsStr,dark, normaTXTSize);
			tagsTF.x = startX;
			tagsTF.y = browseCountTF.y+textItemVGap;
			imgInfoHolder.addChild(tagsTF);
						
			//描述摘要
			var origDescContent:String = _data.description;	
			origDescContent = "描述 "+origDescContent;
			//描述是多行文本，全部显示
			var descTF:SimpleText = new SimpleText(origDescContent,dark, normaTXTSize);
			descTF.x = startX;
			descTF.y = tagsTF.y+textItemVGap;
			descTF.width = InitParams.GALLERY_WIDTH - startX-marging;
			descTF.height = _mobImgHeight-descTF.y-marging;
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
				_toolBGWidth, toolbarHeight);
			toolbg.graphics.endFill();
			toolHolder.addChild(toolbg);
			
			//ADD COMMENT BUTTON			
			//提交评论成功后，在客户端评论列表顶部增加刚才发送的评论
			//再次点击，恢复原状，图片复位，评论收起			
			var comment:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			comment.iconPath = "assets/comment.png";
			comment.addEventListener(MouseEvent.CLICK, addComment);
			comment.x = drawStartX;
			comment.y = iconYOffset;
			comment.textOnRight = true;
			comment.label = "评论";			
			toolHolder.addChild(comment);
			
			//ADD TO FAVORITE
			var favorite:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			favorite.iconPath = "assets/favorite.png";
			favorite.addEventListener(MouseEvent.CLICK, addToFavorite);
			favorite.x = comment.x +iconHGap;
			favorite.y = iconYOffset;
			favorite.textOnRight = true;
			favorite.label = "收藏";			
			toolHolder.addChild(favorite);
			
			//喜欢投票
			var like:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			like.iconPath = "assets/heart.png";
			like.addEventListener(MouseEvent.CLICK, likeIt);
			like.x = favorite.x +iconHGap;
			like.y = iconYOffset;
			like.textOnRight = true;
			like.label = "喜欢";			
			toolHolder.addChild(like);
			
			
			//SAVE TO LOCAL BUTTON
			var save:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			save.iconPath = "assets/save.png";
			save.addEventListener(MouseEvent.CLICK, saveToLocal);
			save.x = like.x +iconHGap;
			save.y = iconYOffset;
			save.textOnRight = true;
			save.label = "保存";			
			toolHolder.addChild(save);
			
			//FORWAR TO WEIBO BUTTON
			var forward:IconButton = new IconButton(toolbarHeight,toolbarHeight);
			forward.iconPath = "assets/forward.png";
			forward.addEventListener(MouseEvent.CLICK, todo);
			forward.x = save.x +iconHGap;
			forward.y = iconYOffset;
			forward.textOnRight = true;
			forward.label = "转发";
			forward.enabled = false;
			toolHolder.addChild(forward);
			
			//REPORT TO ADMIN BUTTON
			var report:IconButton = new IconButton(toolbarHeight,toolbarHeight);
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
				trace("input area height: "+cmtInput.height);
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
				_clonedModel.getComments(_data.id);
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
		
		private function addToFavorite(evt:MouseEvent):void{			
			_clonedModel.markThePic(null,_data.id);
		}
		
		//保存原图到本地，在HomePage中处理该事件
		private function saveToLocal(evt:MouseEvent):void{			
			var globalEvt:PintuEvent = new PintuEvent(PintuEvent.DNLOAD_IMAGE, _data.rawImgUrl);
			globalEvt.extra = _data.picName;
			this.dispatchEvent(globalEvt);
		}
		
		private function likeIt(evt:MouseEvent):void{		
			
			if(_data.owner == PintuImpl(_clonedModel).currentUser){
				//在主显示区弹出提示
				this.dispatchEvent(new PintuEvent(PintuEvent.HINT_USER, "不能给自己投票哟"));
			}else{
				_clonedModel.postVote(_data.owner, _data.id, "cool", "1");							
			}
		}
		
		private function todo(evt:MouseEvent):void{
			//TODO, ADD COMMENT...
			
		}
		
		/**
		 * 6次改变详情视图高度的渲染事件：
		 * 1. 图片加载完成通知渲染，imgLoaded触发
		 * 2. 点击评论按钮增加输入框和按钮，addComment触发
		 * 3. 再次点击评论按钮，收回评论内容，addComment触发
		 * 4. 同时，获取评论列表结果，createCommentList个数大于0时触发
		 * 5. 输入框高度发生变化，relayoutComments派发
		 * 6. 提交评论成功后，新评论置顶，relayoutComments再次派发
		 *
		 */ 
		private function rendered():void{
			//派发尺寸改变事件	
			if(this.stage) {
				this.stage.invalidate();	
				Logger.debug("pic detail view rendered...");
			}else{
				Logger.warn("stage in pic detail view lost!");
			}
		}
		
		/**
		 * 该方法与stage.invalidate()同时使用
		 * 当调用invalidate一次后，舞台将暂时失效
		 */ 
		private function stageAvailable():Boolean{
			if(this.stage){
				return true;
			}else{
				return false;
			}
		}

		
	} //end of class
}