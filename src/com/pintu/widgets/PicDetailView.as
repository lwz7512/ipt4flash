package com.pintu.widgets{
	
	import com.cartogrammar.drawing.DashedLine;
	import com.greensock.TweenLite;
	import com.pintu.config.*;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.*;
	import com.pintu.vos.TPicData;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	import org.casalib.display.CasaTextField;
	import org.casalib.load.ImageLoad;
	
	/**
	 * 包括内容：
	 * 可浮动的工具栏
	 * 图片及相关信息
	 * 评论列表以及评论发表
	 */ 
	public class PicDetailView extends CasaSprite{
		
		private var _data:TPicData;
		
		//看查看缩略图详情的返回按钮让位
		//正常的大图列表是不需要此设置的
		private var _showBackBtn:Boolean = false;
		
		//图片加载结束标志
		private var imgLoadedFlag:Boolean = false;
		
		//左边空点距离
		private var _xStartOffset:Number = 2;
		//上面有工具栏，给工具栏让位
		private var _yStartOffset:Number = 2;	
		//默认图片大小，图片加载结束时改变
		private var _mobImgWidth:Number = 440;
		private var _mobImgHeight:Number = 440;
		//图片占位最小宽度，也是工具栏的宽度
		private var defaultImgWidth:Number = 440;
		//描述内容高度
		private var defaultDescTextHeight:Number = 80;		
		
		//视图总高度
		private var totalHeight:Number = _mobImgHeight;
		
		//图片未展示前出现
		private var mobImgPlaceHolder:DashedLine;
		private var imgLoading:CasaTextField;		
		
		//详情内容
		private var _mobImage:SimpleImage;
		private var toolHolder:CasaSprite;
		private var imgInfoHolder:CasaSprite;
		private var imgDescText:CasaSprite;
		
		//TODO, 评论相关内容
		
		
		/*
		 * construction function....
		 */
		public function PicDetailView(data:TPicData){
			_data = data;	
			if(!_data) return;
			
			//draw image place hoder
			drawImgePlaceHolder();			
			//loading image...
			drawLoadingText();
			
			//先生成图片，等图片加载完成后，再生成其他内容
			_mobImage = new SimpleImage(data.mobImgUrl);
			_mobImage.addEventListener(PintuEvent.IMAGE_LOADED,imgLoaded);
			this.addChild(_mobImage);			
						
			this.addEventListener(MouseEvent.MOUSE_OVER, displayHidePart);
			this.addEventListener(MouseEvent.MOUSE_OUT, hideToolAndDesc);
		}
		
		public function set showBackBtn(v:Boolean):void{
			_showBackBtn = v;
		}
		
		override public function get width():Number{
			return totalHeight;
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
					{y: _mobImgHeight-defaultDescTextHeight, scaleY:1, 
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
				TweenLite.to(imgDescText, 0.3, {y: (_mobImgHeight), scaleY:0,
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
			_mobImgWidth = _mobImage.bitmap.width;
			_mobImgHeight = _mobImage.bitmap.height;
			
			//当前视图总高度等于图片高度
			totalHeight = _mobImgHeight;
			
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
			//图片宽度小话，就往下移动头像
			if(_mobImgWidth<defaultImgWidth)
				startY = 30;		
			
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
//			userNameTF.x = startX;
//			userNameTF.y = avatarImg.y+avatarSize+avatarToTextGap;
			userNameTF.x = startX+avatarImg.maxSize+avatarToTextGap;
			userNameTF.y = startY;
			imgInfoHolder.addChild(userNameTF);
			
			//积分
			var scoreStr:String = "积分 "+_data.score;
			var scoreTF:SimpleText = new SimpleText(scoreStr, green);
			scoreTF.x = userNameTF.x;
			scoreTF.y = userNameTF.y+2*textItemVGap;
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
			descTF.y = commentsTF.y+textItemVGap;
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
				InitParams.GALLERY_WIDTH-2, defaultDescTextHeight+2);
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
		 * 评论、收藏、转发、保存、举报
		 */ 
		private function buildPicOperaTools(imgWidth:Number):void{
			//工具栏不能小于defaultImgWidth
			if(imgWidth<defaultImgWidth){
				imgWidth = defaultImgWidth;
			}
			var iconYOffset:int = 0;
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
				imgWidth-_xStartOffset, InitParams.TREEITEM_HEIGHT);
			toolbg.graphics.endFill();
			toolHolder.addChild(toolbg);
			
			//ADD COMMENT BUTTON
			//TODO, 点击评论，将图片上滚，展开输入框并查询评论列表
			//提交评论成功后，刷新评论列表
			//再次点击，恢复原状，图片复位，评论收起
			//图片详情中的评论文字按钮操作与此类似
			var comment:IconButton = new IconButton(26,26);
			comment.iconPath = "assets/comment.png";
			comment.addEventListener(MouseEvent.CLICK, addComment);
			comment.x = drawStartX;
			comment.y = iconYOffset;
			comment.textOnRight = true;
			comment.label = "评论";
			comment.enabled = false;
			toolHolder.addChild(comment);
			
			//ADD TO FAVORITE
			var favorite:IconButton = new IconButton(26,26);
			favorite.iconPath = "assets/favorite.png";
			favorite.addEventListener(MouseEvent.CLICK, todo);
			favorite.x = comment.x +iconHGap;
			favorite.y = iconYOffset;
			favorite.textOnRight = true;
			favorite.label = "收藏";
			favorite.enabled = false;
			toolHolder.addChild(favorite);
			
			//FORWAR TO WEIBO BUTTON
			var forward:IconButton = new IconButton(26,26);
			forward.iconPath = "assets/forward.png";
			forward.addEventListener(MouseEvent.CLICK, todo);
			forward.x = favorite.x +iconHGap;
			forward.y = iconYOffset;
			forward.textOnRight = true;
			forward.label = "转发";
			forward.enabled = false;
			toolHolder.addChild(forward);
			
			//SAVE TO LOCAL BUTTON
			var save:IconButton = new IconButton(26,26);
			save.iconPath = "assets/save.png";
			save.addEventListener(MouseEvent.CLICK, todo);
			save.x = forward.x +iconHGap;
			save.y = iconYOffset;
			save.textOnRight = true;
			save.label = "保存";
			save.enabled = false;
			toolHolder.addChild(save);
			
			//REPORT TO ADMIN BUTTON
			var report:IconButton = new IconButton(26,26);
			report.iconPath = "assets/report.png";
			report.addEventListener(MouseEvent.CLICK, todo);
			report.x = save.x +iconHGap;
			report.y = iconYOffset;
			report.textOnRight = true;
			report.label = "收藏";
			report.enabled = false;
			toolHolder.addChild(report);
			
		}
		
		private function addComment(evt:MouseEvent):void{
			//TODO, ADD COMMENT...
			
		}
		
		private function todo(evt:MouseEvent):void{
			//TODO, ADD COMMENT...
			
		}

		
	} //end of class
}