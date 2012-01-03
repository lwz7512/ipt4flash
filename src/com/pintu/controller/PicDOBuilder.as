package com.pintu.controller
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONParseError;
	import com.pintu.api.*;
	import com.pintu.common.IconButton;
	import com.pintu.config.*;
	import com.pintu.controller.GlobalController;
	import com.pintu.events.*;
	import com.pintu.utils.Logger;
	import com.pintu.utils.PintuUtils;
	import com.pintu.vos.TPMessage;
	import com.pintu.vos.TPicDesc;
	import com.pintu.vos.TPicDetails;
	import com.pintu.vos.TPicItem;
	import com.pintu.widgets.MainDisplayArea;
	import com.pintu.widgets.MainDisplayBase;
	import com.pintu.widgets.MessageItem;
	import com.pintu.widgets.PicDetailView;
	import com.pintu.widgets.PicItemView;
	import com.pintu.widgets.Thumbnail;
	
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.ui.layout.CellConfig;
	import org.as3commons.ui.layout.HLayout;
	import org.as3commons.ui.layout.constants.Align;
	import org.as3commons.ui.layout.framework.IDisplay;
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;

	/**
	 * 用于主显示区域建立图片和画廊
	 * 构造函数中添加的监听，必须在destroy方法中移除
	 */ 
	public class PicDOBuilder{
		
		private var _model:IPintu;
		
		//所创建内容的显示容器
		private var _context:CasaSprite;
		
		/**
		 * 拥有本实例的对象，用来调用显示进度条和提示方法
		 */ 
		private var _owner:MainDisplayBase;
		
		/**
		 * 画廊起始位置，由主显示区指定，不能随意改变
		 */ 
		private var _drawStartX:Number;
		/**
		 * 画廊起始位置，由主显示区指定，不能随意改变
		 */ 
		private var _drawStartY:Number;
		
		//画廊行数
		private var rowNum:int;
		private var tpics:Array;
		
		//缩略图大小
		private var _thumbnailSize:int = 100;
		//MINI画廊列数
		private var _miniGalleryColumnNum:int = 7;
		//画廊边距
		private var _margin:int = 10;		
		
		//大图之间的间距
		private	var verticalGap:Number = 4;
		
		//大图模式下生成的列表对象，缓存下来用来重新排列位置
		private var bigPicViews:Array;
				
		//固定一个绘制路径的画布，必须是全局变量
		//这样才能在render事件中重新调整位置
		private var pathShape:CasaShape;			
		
		//缩略图模式
		private static const THUMBNAIL_MODE:String = "tbMode";		
		//大图模式
		private static const BIGPIC_MODE:String = "bpMode";
		//当前模式
		private static var currentMode:String;	
		
		//是否显示返回按钮
		private var showBackBtn:Boolean;
		
		
		
		
		
		
		
		/**
		 * ------------------ construction ----------------------------------
		 */ 	
		public function PicDOBuilder(container:CasaSprite, model:IPintu){
			_model = model;
			//图片容器在原点
			_context = container;
			//每次渲染事件都重新排列位置
			_context.addEventListener(Event.RENDER, delayRelayoutBigPicList);	
			
			//缩略图详情响应
			PintuImpl(_model).addEventListener(ApiMethods.GETPICDETAIL,detailPicHandler);
		}
		
		public function set drawStartX(sx:Number):void{
			_drawStartX = sx;
		}
		public function set drawStartY(sy:Number):void{
			_drawStartY = sy;
		}
		public function set owner(o:MainDisplayBase):void{
			_owner = o;
		}
		
		/**
		 * 给MainDisplayArea调用
		 * @param json 生成画廊的数据
		 * @return 生成画廊缩略图的个数
		 */ 
		public function createScrollableMiniGallery(json:String):int{		
			var thumnails:Array;
			//捕捉解析异常
			try{
				
//				Logger.debug("mini gallery: \n"+json);
				
				thumnails = JSON.decode(json) as Array;
			}catch(e:JSONParseError){
				
				hintEvt = new PintuEvent(PintuEvent.HINT_USER, ">>>data parse error!");
				_owner.dispatchEvent(hintEvt);	
								
				return 0;
			}					
			
			//画廊没新图片
			if(thumnails.length==0){
				var nopic:String = "没有最新的图片，不然随便看看？";
				var hintEvt:PintuEvent = new PintuEvent(PintuEvent.HINT_USER, nopic);
				_owner.dispatchEvent(hintEvt);			
				Logger.debug(nopic);
				return 0;
			}
			
			//准备生成画廊
			cleanUp();
			//记下画廊行数以计算画廊高度
			rowNum = Math.floor(thumnails.length/_miniGalleryColumnNum)+1;
			
			//存下来，返回时好重绘
			tpics = objToTPicDescArray(thumnails);	
			//颠倒下顺序，好让最近的放在最前面
			tpics = tpics.reverse();
			
			//布局缩略图
			layoutThumbnails();
			
			//记下当前模式，好从详情返回
			currentMode = THUMBNAIL_MODE;
			
			return thumnails.length;
		}
		
		/**
		 * 创建列表式大图画廊，创建多个PicDetailView
		 * 
		 * 解析json字符串可能异常，可能是由于其中有windows下图片路径反斜杠字符串
		 * 造成转义字符解析异常，偶尔出现，现在还没找到明确原因
		 * 后台已经去除了数据中的关于图片路径属性，但是该方法还是该捕捉这个异常
		 * 2011/12/8
		 * 严重怀疑是flashplayer版本问题，在小明的fp10上就没问题
		 * 2011/12/14
		 * 
		 * @param json 生成画廊需要的数据
		 * @return 生成的图片个数
		 */ 
		public function createScrollableBigGallery(json:String):int{			
			var detailObjs:Array;
			var hintEvt:PintuEvent;
			
//			Logger.debug("big gallery: \n"+json);
			
			//捕捉解析异常
			try{
				detailObjs = JSON.decode(json);
			}catch(e:JSONParseError){
				hintEvt = new PintuEvent(PintuEvent.HINT_USER, ">>>data parse error!");
				_owner.dispatchEvent(hintEvt);	
				
				Logger.error(e.getStackTrace());
				return 0;
			}
			
			//画廊没新图片
			if(detailObjs.length==0){
				hintEvt = new PintuEvent(PintuEvent.HINT_USER, "没有最新的图片，不然随便看看？");
				_owner.dispatchEvent(hintEvt);				
				return 0;
			}			
			
			//准备生成画廊
			cleanUp();
			
			//先把路径线放在底部，然后放图片			
			drawPath(InitParams.DEFAULT_BIGPIC_WIDTH);
			
			//大图数据列表
			var tpicDatas:Array = [];
			for(var i:int=0; i<detailObjs.length; i++){
				var tpidData:TPicDetails = objToTPicData(detailObjs[i]);
				tpicDatas.push(tpidData);
			}
			
			//初始化视图对象集，好重新排列时使用
			bigPicViews = [];
			
			for(var j:int=0; j<tpicDatas.length; j++){	
				var logged:Boolean = GlobalController.isLogged;
				var picDetails:PicDetailView = new PicDetailView(tpicDatas[j], _model, logged);
				picDetails.x = _drawStartX;
				//按照每个详情高度往下排，初始高度是一样的
				picDetails.y = _drawStartY+picDetails.height*j+verticalGap;				
				//显示空容器
				_context.addChild(picDetails);	
				
				//存一份视图引用
				bigPicViews.push(picDetails);
			}
			
			return detailObjs.length;
			
		}
		
		/**
		 * 我的作品和我的收藏，都用它来生成
		 * 作品简单列表
		 * 2011/12/19
		 * @param json 生成图片列表的数据
		 * @return 列表长度
		 */ 
		public function createScrollableSimpleGallery(json:String):int{
			var picObjs:Array;
			var hintEvt:PintuEvent;			
//			Logger.debug("my pics: \n"+json);			
			//捕捉解析异常
			try{
				picObjs = JSON.decode(json);
			}catch(e:JSONParseError){
				hintEvt = new PintuEvent(PintuEvent.HINT_USER, ">>>data parse error!");
				_owner.dispatchEvent(hintEvt);				
				return 0;
			}
			
			//画廊没新图片
			if(picObjs.length==0){
				hintEvt = new PintuEvent(PintuEvent.HINT_USER, "没有最新的图片，不然随便看看？");
				_owner.dispatchEvent(hintEvt);				
				return 0;
			}			
			
			//准备生成画廊
			cleanUp();
			
			//先把路径线放在底部，然后放图片			
			drawPath(InitParams.DEFAULT_BIGPIC_WIDTH);
			
			//转换为对象
			tpics = [];
			for(var i:int=0; i<picObjs.length; i++){
				var tpItem:TPicItem = objToTPicItem(picObjs[i]);
				tpics.push(tpItem);
			}
			//将tpic转换为视图对象
			layoutPicItems();
			
			//记下当前模式，好从详情返回
			currentMode = BIGPIC_MODE;
			
			return picObjs.length;
		}
		
		private function layoutPicItems():void{
			//初始化视图对象集，好重新排列时使用
			bigPicViews = [];
			
			//布局显示
			for(var j:int=0; j<tpics.length; j++){				
				var picView:PicItemView = new PicItemView(tpics[j]);
				picView.addEventListener(PintuEvent.GETPICDETAILS,getDetails);
				picView.x = _drawStartX;
				//按照每个详情高度往下排，初始高度是一样的
				picView.y = _drawStartY+picView.height*j+verticalGap;				
				//显示空容器
				_context.addChild(picView);	
				
				//存一份视图引用，重新计算位置时用到
				bigPicViews.push(picView);
			}			
		}
		
		/**
		 * 唯一一个创建非图片类内容的方法
		 * 放心的去创建，不需要校验数据
		 */
		public function createMsgList(msgs:Array):void{
			//先清理舞台
			cleanUp();			
			
			var msgVOs:Array = [];
			//转换对象
			for each(var msg:Object in msgs){
				var tpMsg:TPMessage = new TPMessage();
				tpMsg.id = msg["id"];
				tpMsg.sender = msg["sender"];
				tpMsg.senderName = PintuUtils.getShowUserName(msg["senderName"]);
				tpMsg.content = msg["content"];
				tpMsg.msgType = msg["msgType"];
				tpMsg.reference = msg["reference"];
				tpMsg.writeTime = PintuUtils.getRelativeTimeFromNow(msg["writeTime"]);
				tpMsg.senderAvatarUrl = _model.composeImgUrlByPath(msg["senderAvatar"]);
				msgVOs.push(tpMsg);
			}
			
			//创建消息列表					
			var msgStartX:Number = _drawStartX;
			var msgStartY:Number = _drawStartY;
			for(var i:int = 0; i<msgVOs.length; i++){
				var msgView:MessageItem = new MessageItem(msgVOs[i]);
				msgView.x = msgStartX;
				msgView.y = msgStartY;				
				_context.addChild(msgView);				
				msgStartY += msgView.height;
			}
						
		}
		
		private function detailPicHandler(event:Event):void{	
			
			//很怪异有时出不来图，先隐藏掉进度条吧	
			//2011/12/20
			_owner.hideMiddleLoading();
						
			//只处理结果事件，不处理状态事件
			if((event is PTStatusEvent)) return;						
			
			//数据到了准备显示
			cleanUp();	
			
			//CREATE PIC DETAILS...
			var details:Object =  JSON.decode(ResponseEvent(event).data) as Object;					
			
			var logged:Boolean = GlobalController.isLogged;
			var picDetails:PicDetailView = new PicDetailView(objToTPicData(details), _model, logged);
			picDetails.x = _drawStartX;
			picDetails.y = _drawStartY;
			//工具栏左侧给返回按钮让位
			if(showBackBtn) picDetails.showBackBtn = true;
			_context.addChild(picDetails);					
			
			//如果不显示返回按钮，则不生成
			if(!showBackBtn) return;
			
			//BACK BUTTON
			var back:IconButton = new IconButton(26,26);
			back.iconPath = "assets/back.png";
			back.addEventListener(MouseEvent.CLICK, restoreGallery);
			back.x = _drawStartX+2;
			//往下移动下跟工具栏对齐
			back.y = _drawStartY+2;
			back.textOnRight = true;
			back.label = "返回";
			back.setLabelStyle(null, 12, 
				StyleParams.HEADERBAR_TOP_LIGHTGREEN, 
				StyleParams.HEADERBAR_TOP_LIGHTGREEN, 
				StyleParams.HEADERBAR_TOP_LIGHTGREEN);
			
			_context.addChild(back);			
			
		}
		

		//点击返回按钮，回到列表画廊
		private function restoreGallery(evt:MouseEvent):void{
			cleanUp();
			
			if(currentMode == BIGPIC_MODE){
				layoutPicItems();
			}else if(currentMode == THUMBNAIL_MODE){
				layoutThumbnails();				
			}
		}		

		
		private function layoutThumbnails():void{
			//画廊剩余宽度减去左右边距，然后按列数平分
			var columnGap:Number = (InitParams.GALLERY_WIDTH-
				_miniGalleryColumnNum*_thumbnailSize-2*_margin)/(_miniGalleryColumnNum-1);						
			
			var grid:HLayout = new HLayout();
			//每行最多放7个
			grid.maxItemsPerRow = _miniGalleryColumnNum;
			grid.minWidth = InitParams.GALLERY_WIDTH;
			grid.minHeight = rowNum*(_thumbnailSize+columnGap);
			var xOffset:Number = _margin;
			var yOffset:Number = _margin;	
			//指定画廊起始位置
			grid.marginX = _drawStartX +xOffset;
			grid.marginY = _drawStartY +yOffset;			
			grid.vGap = columnGap;
			grid.hGap = columnGap;
			
			var cellConfig:CellConfig = new CellConfig();			
			cellConfig.width = _thumbnailSize;
			cellConfig.height = _thumbnailSize;
			grid.setCellConfig(cellConfig);
			
			for(var i:int=0; i<tpics.length; i++){
				var thumbnail:Thumbnail = new Thumbnail(TPicDesc(tpics[i]));
				thumbnail.addEventListener(PintuEvent.GETPICDETAILS,getDetails);				
				grid.add(thumbnail);
			}
			//展示画廊
			grid.layout(_context);
		}
		
		private function getDetails(event:PintuEvent):void{	
			
			showBackBtn = true;
			
			//清空舞台		
			cleanUp();
			
			//展示进度条
			_owner.showMiddleLoading();
			//查询详情
			var tpId:String = event.data;
			_model.getPicDetail(tpId);
			
			//修改页面所在的url
			ExternalInterface.call("setCurrentPicUrl", tpId);
		}
		
		public function createPicDetailById(tpId:String):void{
			showBackBtn = false;
			//查询详情			
			_model.getPicDetail(tpId);
		}
				
		
		/**
		 * 每个详情视图发生内容变化时，整个列表项的位置都要发生重排
		 */ 
		private function delayRelayoutBigPicList(evt:Event):void{
//			Logger.debug(".... send layout event... ");
			invalidate();
		}
		
		private function invalidate():void{
			if(!_context.hasEventListener(Event.ENTER_FRAME))
				_context.addEventListener(Event.ENTER_FRAME, relayout);
		}
		private function relayout(evt:Event):void{
//			Logger.debug(".... to relayout... ");
			_context.removeEventListener(Event.ENTER_FRAME, relayout);
			
			if(!bigPicViews) return;
			
			var realPicsHeight:Number = 0;
			for each(var pic:DisplayObject in bigPicViews){
				realPicsHeight += pic.height;
			}

			//这时有高度了，重绘			
			drawPath(realPicsHeight);
			
			var localStartY:Number = _drawStartY;
			//重新排列所有的图片
			for(var i:int=0; i<bigPicViews.length; i++){
				var bigPicView:DisplayObject = bigPicViews[i];				
				//按照每个详情高度往下排，初始高度是一样的
				bigPicView.y = localStartY;
				//记下下一个图的位置
				localStartY += bigPicView.height+verticalGap;
			}
		}
		
		/**
		 * 图片背景上画根竖线，当做Path
		 * 2011/12/09
		 * 绘制path方法中的绘制对象不能做成局部变量
		 * 否则重绘时高度不准确
		 * 2011/12/20
		 */		
		private function drawPath(picsHeight:Number):void{
			if(!pathShape )pathShape = new CasaShape();			
			if(_context.contains(pathShape)){
				//移除了重新绘制，这样高度才能准确
				_context.removeChild(pathShape);
			}
			//添加在显示列表底部
			_context.addChildAt(pathShape,0);
			
			var pathLineX:Number = _drawStartX+InitParams.DEFAULT_BIGPIC_WIDTH+20;
			var pathStartY:Number = _drawStartY+4;
			var pathEndY:Number = picsHeight;
			var pathThickness:int = 4;
			pathShape.graphics.clear();
			pathShape.graphics.lineStyle(pathThickness, StyleParams.PICDETAIL_BACKGROUND_GRAY, 1, true, "normal", JointStyle.BEVEL);
			pathShape.graphics.moveTo(pathLineX, pathStartY);
			pathShape.graphics.lineTo(pathLineX, pathEndY);
		}
		
		private function cleanUp():void{
			_context.graphics.clear();
			_context.removeChildren(true,true);
			//恢复滚动前的位置
			_context.y = 0;
		}
		
		private function objToTPicDescArray(thumnails:Array):Array{
			var tpics:Array = [];
			for each(var thumbnail:Object in thumnails){
				if(!thumbnail) continue;				
				var tpic:TPicDesc = new TPicDesc();
				tpic.tpId = thumbnail["tpId"];
				tpic.thumbnailId = thumbnail["thumbnailId"];
				var creationLongTime:String = thumbnail["creationTime"];				
				tpic.creationTime = Number(creationLongTime);
				tpic.url = _model.composeImgUrlById(thumbnail["thumbnailId"]);
				tpics.push(tpic);
			}
			return tpics;
			
		}
		
		
		private function objToTPicItem(tpitem:Object):TPicItem{
			var pic:TPicItem = new TPicItem();
			pic.id = tpitem["id"];
			pic.owner = tpitem["owner"];
			pic.browseCount = tpitem["browseCount"];
			pic.isOriginal = tpitem["isOriginal"];
			pic.publishTime = tpitem["publishTime"];
			pic.mobImgUrl =  _model.composeImgUrlById(tpitem["mobImgId"]);
			
			return pic;
		}
		
		private function objToTPicData(details:Object):TPicDetails{
			var pic:TPicDetails = new TPicDetails();
			pic.id = details["id"];
			pic.picName = details["name"];
			pic.owner = details["owner"];
			pic.author = details["author"];
			pic.avatarUrl = _model.composeImgUrlByPath(details["avatarImgPath"]);
			pic.score = details["score"];
			pic.level = details["level"];
			pic.publishTime = details["publishTime"];
			pic.browseCount = details["browseCount"];
			pic.tags = details["tags"];
			pic.description = details["description"];
			pic.isOriginal = details["isOriginal"];
			pic.source = details["source"];
			pic.mobImgUrl =  _model.composeImgUrlById(details["mobImgId"]);
			pic.rawImgUrl =  _model.composeImgUrlById(details["rawImgId"]);
			pic.commentsNum = details["storiesNum"];
			pic.coolCount = details["coolCount"];
			
			return pic;
		}
		
		
		public function destroy():void{
			_context.removeEventListener(Event.RENDER, delayRelayoutBigPicList);
			PintuImpl(_model).removeEventListener(ApiMethods.GETPICDETAIL,detailPicHandler);
			bigPicViews = null;
			_model = null;
		}
		
		
	}
}