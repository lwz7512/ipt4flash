package com.pintu.widgets{
		
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.controller.PicDOBuilder;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
	
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	
	import org.casalib.display.CasaSprite;
	import com.pintu.common.BusyIndicator;

	/**
	 * 主工作类，用来生成和展示图片及相关信息
	 */ 
	public class MainDisplayArea extends Sprite{
				
		private var _model:IPintu;
		
		private var _initialized:Boolean;
		private var _picBuilder:PicDOBuilder;
		private var _toolBar:MainToolBar;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		private var displayAreaWidth:Number;
		private var displayAreaHeight:Number;
		
		
		//浏览类型，是画廊、热图、经典、被收藏、系统分类
		private var _browseType:String;				
		//画廊缩略图最后一条记录的时间，作为向后翻页的endTime
		//有两个设置点：
		//1. set browseType
		//2. 画廊数据到达后，找出最晚记录的时间
		private var _galleryLastRecordTime:Number;
		//画廊大图翻页页码
		private var _galleryPageNum:int;
		//按分类查询，翻页页码
		private var _tagPageNum:int;
				
		// 使用增强的显示对象CasaSprite，以更好的管理子对象	
		//画廊图片容器，也是被滚动对象
		private var _picsContainer:CasaSprite;
		private var _clip:Shape;	
		
		//画廊移动速度
		private var _galleryMoveYSpeed:Number = 0;
		//摩擦力系数，越小移动越快
		private var _frictionFactor:int = 15;
		//加速度系数
		private var _acceleration:int = 30;
		//保留上次鼠标位置以判断移动方向
		private var _lastMouseY:Number = 0;
		
		//查询保护装置，2秒内不允许重复查询
		private var queryAvailableTimer:Timer;
		
		
		public function MainDisplayArea(model:IPintu){
			super();					
			initDrawPoint();
			
			this._model = model;
			this._picsContainer = new CasaSprite();
			addChild(_picsContainer);
			//画廊内容生成工具
			this._picBuilder = new PicDOBuilder(_picsContainer,_model);
			this._picBuilder.drawStartX = drawStartX;
			this._picBuilder.drawStartY = drawStartY;
			this._picBuilder.owner = this;
			
			//默认舞台背景色
			drawMainDisplayBackground();
			//生成裁剪区域
			createClipMask();
			
			PintuImpl(_model).addEventListener(ApiMethods.GETGALLERYBYTIME,thumbnailHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETGALLERYFORWEB,bigPicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETHOTPICTURE,hotPicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.CLASSICALSTATISTICS,classicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.COLLECTSTATISTICS,favoredPicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETTHUMBNAILSBYTAG,tagPicHandler);
								
			//初始化时，按浏览模式查询画廊
			this.addEventListener(Event.ADDED_TO_STAGE, initDisplayStage);
			//滚轮处理画廊移动
			this.addEventListener(MouseEvent.MOUSE_WHEEL,scrollGallery);
			
			//2秒内运行检查，类型设置时启动
			queryAvailableTimer = new Timer(2000,1);
		}
		
		
		//点击缩略图，展示图片详情时也用
		public function showMiddleLoading():void{
			var middleX:Number = drawStartX+displayAreaWidth/2;
			var middleY:Number = drawStartY+displayAreaHeight/2;
			var loading:BusyIndicator = new BusyIndicator(32);
			loading.x = middleX-16;
			loading.y = middleY-16;			
			_picsContainer.addChild(loading);
		}
		
		private function initDrawPoint():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.LEFTCOLUMN_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT
				+InitParams.TOP_BOTTOM_GAP
				+InitParams.MAINMENUBAR_HEIGHT
				+InitParams.DEFAULT_GAP;
			//默认高度，也是最小高度
			displayAreaHeight = InitParams.CALLERY_HEIGHT;
			if(InitParams.isStretchHeight()){
				//拉伸高度
				displayAreaHeight = InitParams.appHeight
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.FOOTER_HEIGHT;
			}
			displayAreaWidth = InitParams.GALLERY_WIDTH;
		}
		
		private function initDisplayStage(event:Event):void{
			_initialized = true;
			queryPicByType();
		}
		
		private function scrollGallery(event:MouseEvent):void{
			//向后滚，负值，向前滚，正值
			var moveDirection:int = event.delta;
			_galleryMoveYSpeed = moveDirection*_acceleration;
			moveGallery(null);
		}
		
		private function moveGallery(event:Event):void{	
			//画廊默认位置
			var galleryHeight:Number = _picBuilder.galleryHeight;
			var galleryMoveStartY:Number = 0;			
			var galleryMoveEndY:Number = displayAreaHeight-galleryHeight;
			//如果是负数表示超过了展示高度，则滚动，如果不是，则不滚动
			if(galleryMoveEndY>=0)
				return;			
			
			//按照计算好的速度移动
			if(_galleryMoveYSpeed!=0)				
			TweenLite.to(_picsContainer,0.6,{y:(_picsContainer.y + _galleryMoveYSpeed), ease:Strong.easeOut});
			
			//位置复原
			if(_picsContainer.y>galleryMoveStartY){
				//缓动效果
				TweenLite.to(_picsContainer,0.4,{y:galleryMoveStartY,ease:Strong.easeOut});				
			}
			if(_picsContainer.y<galleryMoveEndY){
				TweenLite.to(_picsContainer,0.4,{y:galleryMoveEndY,ease:Strong.easeOut});
			}
		}
				

		//根据_displayMode和_browseType来查看图片
		private function queryPicByType():void{
			
			if(queryAvailableTimer.running){
				//定时器已启动，查询正在进行，不能再次查询
				Logger.warn("Can not excute query in 2 seconds...");
				return;
			}else{
				queryAvailableTimer.start();
				Logger.debug("Start to query for type:"+_browseType);
			}
			
			switch(_browseType)
			{
				case CategoryTree.CATEGORY_GALLERY_TBMODE:					
					//缩略图模式					
					var startTime:String = sixHourAgo(_galleryLastRecordTime);
					var endTime:String = _galleryLastRecordTime.toString();
					//查询画廊数据
					_model.getGalleryByTime(startTime,endTime);
					showMiddleLoading();
					break;
				
				case CategoryTree.CATEGORY_GALLERY_BPMODE:					
						//大图模式
						_galleryPageNum++;						
						_model.getGalleryForWeb(_galleryPageNum.toString());				
					break;
				
				case CategoryTree.CATEGORY_HOT:					
					_model.getHotPicture();
					
					break;
				
				case CategoryTree.CATEGORY_CLASSICAL:					
					_model.getClassicalPics();
					
					break;
				
				case CategoryTree.CATEGORY_FAVORED:					
					_model.getFavoredPics();
					
					break;
				
				default:					
					_tagPageNum++;
					//TODO, GET THUMBNIALS BY TAG...
//					_model.getThumbnailsByTag(_browseType,_tagPageNum.toString());
					
					break;
				
			}
		}		
		//--------------------------------  handler start --------------------------------------------		
		private function thumbnailHandler(event:Event):void{
			if(event is ResponseEvent){
				var galleryData:String = ResponseEvent(event).data;
//				Logger.debug("thumbnail data: \n"+galleryData);
				//创建画廊
				_picBuilder.createScrollableMiniGallery(galleryData);
				//TODO, CHECK THE LAST GALLERY RECORD TIME...
				
			}
			if(event is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.GETGALLERYBYTIME);
			}
		}
		
		private function bigPicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is PTErrorEvent){
				
			}			
		}	
		private function hotPicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is PTErrorEvent){
				
			}			
		}	
		private function classicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is PTErrorEvent){
				
			}			
		}	
		private function favoredPicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is PTErrorEvent){
				
			}			
		}	
		private function tagPicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is PTErrorEvent){
				
			}			
		}	
		
		//--------------------------------  handler end --------------------------------------------	
		
		
		//浏览类型，或者是标签id
		public function set browseType(type:String):void{
			//FIXME, 先不拦截同类请求了，方便刷新按钮
//			if(type == _browseType) return;
			
			this._browseType = type;
			Logger.debug("browseType: "+_browseType);
			
			//每次切换标签选项，就重置分页起始数
			_tagPageNum = 0;
			
			//每次进入画廊缩略图模式，就重置结束时间
			if(_browseType== CategoryTree.CATEGORY_GALLERY_TBMODE){				
				_galleryLastRecordTime = new Date().getTime();
			}
			//每次进入画廊大图模式，就重置分页起始数
			if(_browseType== CategoryTree.CATEGORY_GALLERY_BPMODE){				
				_galleryPageNum = 0;
			}
			//初始化时不查询
			if(!_initialized) return;
			//delay query..
			invalidate();
		}				

		
		private function drawMainDisplayBackground():void{						
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR);
			this.graphics.drawRect(drawStartX,drawStartY,displayAreaWidth,displayAreaHeight);
			this.graphics.endFill();
		}
		
		private function createClipMask():void{
			_clip = new Shape();
			_clip.graphics.beginFill(0x000000);
			_clip.graphics.drawRect(drawStartX,drawStartY,displayAreaWidth+1,displayAreaHeight+1);
			_clip.graphics.endFill();
			this.mask = _clip;
			this.addChild(_clip);
		}
		
		private function invalidate():void{
			this.addEventListener(Event.ENTER_FRAME,delayQuery);
		}
		
		private function delayQuery(event:Event):void{
			this.removeEventListener(Event.ENTER_FRAME,delayQuery);
			queryPicByType();
		}
		
		//6小时以前
		private function sixHourAgo(endTime:Number):String{
			return (endTime-6*60*60*1000).toString();			 
		}
		
		
		/**
		 * @deprecated
		 * 首先判断画廊的位置，
		 * 如果画廊在起点0，则鼠标在画廊中部以下时开始滚动画廊，
		 * 如果画廊在终点，则鼠标在画廊中部以上时开始滚动画廊，
		 * 根据鼠标在展示区域的上下位置，决定了画廊移动速度
		 */ 
		private function calculateMoveSpeed(event:MouseEvent):void{											
			var galleryHeight:Number = _picBuilder.galleryHeight;
			//画廊默认位置
			var galleryMoveStartY:Number = 0;			
			var galleryMoveEndY:Number = displayAreaHeight-galleryHeight;
			//如果是负数表示超过了展示高度，则滚动，如果不是，则不滚动
			if(galleryMoveEndY>=0){
				_galleryMoveYSpeed = 0;
				return;
			}
			
			var relativeMouseY:Number = event.stageY - drawStartY;
			var isMoveDown:Boolean = (relativeMouseY-_lastMouseY)>0?true:false;			
			if(isMoveDown){				
				var isInLowerHalf:Boolean = (relativeMouseY-displayAreaHeight/2)>0?true:false;				
				//画廊在起始位置以下，该往上移动
				if(isInLowerHalf){
					if(_picsContainer.y>galleryMoveEndY && _picsContainer.y<=galleryMoveStartY){
						//与底部越近，速度越快，这个速度是负值，以使画廊向上移动
						//中部时，速度为0
						_galleryMoveYSpeed = (-relativeMouseY+displayAreaHeight/2)/_frictionFactor;						
					}
				}
			}else{//Move up				
				var isInHigherHalf:Boolean = (relativeMouseY-displayAreaHeight/2)<0?true:false;				
				if(isInHigherHalf){
					//画廊在终点位置以下，该往下移动
					if(_picsContainer.y>=galleryMoveEndY && _picsContainer.y<galleryMoveStartY){
						//越与顶部接近，速度越快，这个速度是正值，以使画廊向下移动
						//中部时，速度为0
						_galleryMoveYSpeed = (-relativeMouseY+displayAreaHeight/2)/_frictionFactor;						
					}
				}
			}
			//取整
			_galleryMoveYSpeed = int(_galleryMoveYSpeed);			
			
			//保留上次的鼠标位置
			_lastMouseY = relativeMouseY;
		}
				
		
		
	
	} //end of class
}