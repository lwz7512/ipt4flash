package com.pintu.widgets
{
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.ErrorEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	public class MainDisplayArea extends Sprite{
		
		
		private var _model:IPintu;
		private var _initialized:Boolean;
		private var _toolBar:MainToolBar;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		

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
		
		public function MainDisplayArea(model:IPintu){
			super();
			this._model = model;
			drawMainDisplayBackground();
			
			PintuImpl(_model).addEventListener(ApiMethods.GETGALLERYBYTIME,thumbnailHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETGALLERYFORWEB,bigPicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETHOTPICTURE,hotPicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.CLASSICALSTATISTICS,classicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.COLLECTSTATISTICS,favoredPicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETTHUMBNAILSBYTAG,tagPicHandler);
			
			//TODO, ADD OTHER METHOD HANDLER...
						
			//初始化时，按浏览模式查询画廊
			this.addEventListener(Event.ADDED_TO_STAGE, initDisplayStage);
		}
		
		private function initDisplayStage(event:Event):void{
			_initialized = true;
			queryPicByType();
		}
		
		//根据_displayMode和_browseType来查看图片
		private function queryPicByType():void{
			
			switch(_browseType)
			{
				case CategoryTree.CATEGORY_GALLERY_TBMODE:					
					//缩略图模式					
					var startTime:String = sixHourAgo(_galleryLastRecordTime);
					var endTime:String = _galleryLastRecordTime.toString();
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
				//TODO, CREATE THE GALLERY  BY DATA...

				//TODO, CHECK THE LAST GALLERY RECORD TIME...
				
			}
			if(event is ErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.GETGALLERYBYTIME);
			}
		}
		
		private function bigPicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is ErrorEvent){
				
			}			
		}	
		private function hotPicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is ErrorEvent){
				
			}			
		}	
		private function classicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is ErrorEvent){
				
			}			
		}	
		private function favoredPicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is ErrorEvent){
				
			}			
		}	
		private function tagPicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is ErrorEvent){
				
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
			drawStartX = InitParams.startDrawingX()
													+InitParams.LEFTCOLUMN_WIDTH
													+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADERFOOTER_HEIGHT
													+InitParams.TOP_BOTTOM_GAP
													+InitParams.MAINMENUBAR_HEIGHT
													+InitParams.DEFAULT_GAP;
			var displayAreaHeight:Number = InitParams.CALLERY_HEIGHT;
			if(InitParams.isStretchHeight()){
				displayAreaHeight = InitParams.appHeight
													-drawStartY
													-InitParams.TOP_BOTTOM_GAP
													-InitParams.HEADERFOOTER_HEIGHT;
			}
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR);
			this.graphics.drawRect(drawStartX,drawStartY,
													InitParams.GALLERY_WIDTH,displayAreaHeight);
			this.graphics.endFill();
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