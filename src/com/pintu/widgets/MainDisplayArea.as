package com.pintu.widgets{
		
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
	
	import org.casalib.display.CasaSprite;

	public class MainDisplayArea extends Sprite{
		
		
		private var _model:IPintu;
		private var _picBuilder:PicDOBuilder;
		private var _initialized:Boolean;
		private var _toolBar:MainToolBar;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		private var displayAreaHeight:Number;
		private var displayAreaWidth:Number;
		
		
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
		private var _picContainer:CasaSprite;
		private var _clip:Shape;	
		
		//画廊移动速度
		private var _galleryMoveYSpeed:Number = 0;
		
		public function MainDisplayArea(model:IPintu){
			super();					
			initDrawPoint();
			
			this._model = model;
			this._picContainer = new CasaSprite();
			addChild(_picContainer);
			//画廊生成工具
			this._picBuilder = new PicDOBuilder(_picContainer,_model);
			this._picBuilder.drawStartX = drawStartX;
			this._picBuilder.drawStartY = drawStartY;
			
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
			this.addEventListener(MouseEvent.MOUSE_MOVE,scrollPicContainer);
			this.addEventListener(Event.ENTER_FRAME, moveGallery);
		}
		
		private function initDrawPoint():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.LEFTCOLUMN_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT
				+InitParams.TOP_BOTTOM_GAP
				+InitParams.MAINMENUBAR_HEIGHT
				+InitParams.DEFAULT_GAP;
			
			displayAreaHeight = InitParams.CALLERY_HEIGHT;
			if(InitParams.isStretchHeight()){
				displayAreaHeight = InitParams.appHeight
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.HEADER_HEIGHT;
			}
			displayAreaWidth = InitParams.GALLERY_WIDTH;
		}
		
		private function initDisplayStage(event:Event):void{
			_initialized = true;
			queryPicByType();
		}
		
		//TODO, 根据_galleryMoveYSpeed移动_picContainer
		//需要根据画廊的高度与displayAreaHeight相比较
		//从而决定_picContainer向上走的终点位置...
		private function moveGallery(event:Event):void{
			var galleryHeight:Number = _picBuilder.galleryHeight;
			
		}
		
		//TODO, 根据鼠标在展示区域的上下位置，决定了画廊移动速度
		private function scrollPicContainer(event:MouseEvent):void{											
			var relativeMouseY:Number = event.localY - drawStartY;
			trace(">>> Mouse Y in MainDisplayArea is: "+relativeMouseY);
			
		}
		
		//根据_displayMode和_browseType来查看图片
		private function queryPicByType():void{
			
			switch(_browseType)
			{
				case CategoryTree.CATEGORY_GALLERY_TBMODE:					
					//缩略图模式					
					var startTime:String = sixHourAgo(_galleryLastRecordTime);
					var endTime:String = _galleryLastRecordTime.toString();
					//查询画廊数据
					_model.getGalleryByTime(startTime,endTime);
					break;
				
				case CategoryTree.CATEGORY_GALLERY_BPMODE:					
						//大图模式
						_galleryPageNum++;						
						_model.getGalleryForWeb(_galleryPageNum.toString());				
					break;
				
				case CategoryTree.CATEGORY_HOT:
					//查询热图，禁用展示模式切换按钮
					_model.getHotPicture();
					
					break;
				
				case CategoryTree.CATEGORY_CLASSICAL:
					//查询经典，禁用展示模式切换按钮
					_model.getClassicalPics();
					
					break;
				
				case CategoryTree.CATEGORY_FAVORED:
					//查询被收藏，禁用展示模式切换按钮
					_model.getFavoredPics();
					
					break;
				
				default:
					// 按系统标签查询，禁用展示模式切换按钮
					_tagPageNum++;
					_model.getThumbnailsByTag(_browseType,_tagPageNum.toString());
					
					break;
				
			}
		}		
		//--------------------------------  handler start --------------------------------------------		
		private function thumbnailHandler(event:Event):void{
			if(event is ResponseEvent){
				var galleryData:String = ResponseEvent(event).data;
				Logger.debug("thumbnail data: \n"+galleryData);
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
			if(type == _browseType) return;
			
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
			_clip.graphics.drawRect(drawStartX,drawStartY,displayAreaWidth,displayAreaHeight);
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
		
		
		
		
	
	} //end of class
}