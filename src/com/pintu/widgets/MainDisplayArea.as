package com.pintu.widgets{

	import com.adobe.utils.StringUtil;
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.common.BusyIndicator;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.controller.PicDOBuilder;
	import com.pintu.events.*;
	import com.pintu.utils.Logger;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	
	import org.casalib.display.CasaSprite;

	/**
	 * 主工作类，用来生成和展示图片及相关信息
	 * 主要是跟数据交互有关的操作类
	 */ 
	public class MainDisplayArea extends MainDisplayBase{
							
		
		private var _model:IPintu;
		private var _picBuilder:PicDOBuilder;
		private var _toolBar:MainToolBar;					
		
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
		
		/**
		 * 从非登陆状态切换到登陆状态时，很奇怪有两次事件响应
		 * 用开关值来防止重复创建画廊，数据到达后只生成一次画廊
		 * 2011/11/21	
		 * 已经修正这个bug了，是由于对模型重复添加事件监听引起的
		 * 2011/12/02
		 */ 		
		private var galleryCreated:Boolean;
		
		
		
		public function MainDisplayArea(model:IPintu){							
			//父类MainDisplayBase用来创建显示内容
			super();		
			
			Logger.debug("Create MainDisplayArea once...");
			
			this._model = model;
			//画廊内容生成工具
			this._picBuilder = new PicDOBuilder(_picsContainer,_model);
			//图片工厂要知道放置起始位置
			this._picBuilder.drawStartX = drawStartX;
			this._picBuilder.drawStartY = drawStartY;
			//为了让他可以调用以展示进度条和提示
			this._picBuilder.owner = this;
			
			//初始化添加模型监听
			this.addEventListener(Event.ADDED_TO_STAGE, initDisplayStage);
			//销毁时，移除模型监听
			this.addEventListener(Event.REMOVED_FROM_STAGE, destroyDisplayStage);											
					
		}			
		
	
		/**
		 * 当HomePage初始化时，或者点击HeaderBar子菜单时调用
		 * 在menuHandler方法中调用该方法，从菜单到触发查询的整个流程为：
		 * 
		 * BrowseMode-->HeaderBar-->Main-->_currentModule-->
		 * menuHandler()-->mainDisplayArea.browseType
		 */ 
		public function set browseType(type:String):void{
			//FIXME, 先不拦截同类请求了，方便刷新按钮
			//			if(type == _browseType) return;			
			this._browseType = type;
//			Logger.debug("browseType: "+_browseType);
			
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
			
			//初始化没完成不查询
			if(!_initialized) return;			
			
			//delay query..
			invalidate();
		}							
		
		private function initDisplayStage(event:Event):void{
			_initialized = true;
			
			//按照HomePage设置的模式进行查询			
			queryPicByType();					
			
			PintuImpl(_model).addEventListener(ApiMethods.GETGALLERYBYTIME,latestGalleryHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETGALLERYRANDOM,latestGalleryHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETGALLERYFORWEB,bigPicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETHOTPICTURE,hotPicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.CLASSICALSTATISTICS,classicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.COLLECTSTATISTICS,favoredPicHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETTHUMBNAILSBYTAG,tagPicHandler);
		}
		
		private function destroyDisplayStage(event:Event):void{			
			PintuImpl(_model).removeEventListener(ApiMethods.GETGALLERYBYTIME,latestGalleryHandler);
			PintuImpl(_model).removeEventListener(ApiMethods.GETGALLERYRANDOM,latestGalleryHandler);
			PintuImpl(_model).removeEventListener(ApiMethods.GETGALLERYFORWEB,bigPicHandler);
			PintuImpl(_model).removeEventListener(ApiMethods.GETHOTPICTURE,hotPicHandler);
			PintuImpl(_model).removeEventListener(ApiMethods.CLASSICALSTATISTICS,classicHandler);
			PintuImpl(_model).removeEventListener(ApiMethods.COLLECTSTATISTICS,favoredPicHandler);
			PintuImpl(_model).removeEventListener(ApiMethods.GETTHUMBNAILSBYTAG,tagPicHandler);
			queryAvailableTimer.stop();
			queryAvailableTimer = null;
		}
		
		private function invalidate():void{
			this.addEventListener(Event.ENTER_FRAME,delayQuery);
		}
		
		private function delayQuery(event:Event):void{
			this.removeEventListener(Event.ENTER_FRAME,delayQuery);
			queryPicByType();
		}
		
		/**
		 * 根据菜单选择，或者设定的浏览模式来查询数据
		 */ 
		private function queryPicByType():void{			
			
			//定时器运行期间或者正在查询期间，不能重新查询
			if(queryAvailableTimer.running || isRunning){
				//定时器已启动，查询正在进行，不能再次查询				
				//在主显示区弹出提示
				this.dispatchEvent(new PintuEvent(PintuEvent.HINT_USER, "不能在2秒内持续查询..."));
				return;
			}else{
				queryAvailableTimer.start();
//				Logger.debug("Start to query for type:"+_browseType);				
			}
			//开启查询开关
			galleryCreated = false;
			
			Logger.debug(">>>To query by type: "+_browseType+" ...");
			//显示进度条
			showMiddleLoading();
			
			//按类型查询数据
			switch(_browseType){
				
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
					_model.getHotPicture();
					
					break;
				
				case CategoryTree.CATEGORY_CLASSICAL:					
					_model.getClassicalPics();
					
					break;
				
				case CategoryTree.CATEGORY_FAVORED:					
					_model.getFavoredPics();
					
					break;
				
				case CategoryTree.CATEGORY_RANDOM_TBMODE:
					_model.getRandomGallery();				
					
					break;
				
				default:					
					_tagPageNum++;
					//TODO, GET THUMBNIALS BY TAG...
//					_model.getThumbnailsByTag(_browseType,_tagPageNum.toString());
					
					break;				
			}					
			
		}		
		
		/**
		 * 默认的查询方式，查询最近6小时画廊数据
		 */ 
		private function latestGalleryHandler(event:Event):void{						
			//移除进度条
			hideMiddleLoading();
			
			if(event is ResponseEvent){				
				var galleryData:String = ResponseEvent(event).data;
				var thumbnails:int;
//				Logger.debug("thumbnail data: \n"+galleryData);										
				if(!galleryCreated){
//					Logger.debug("to create mini gallery...");
					
					//创建画廊
					thumbnails = _picBuilder.createScrollableMiniGallery(galleryData);
					galleryCreated = true;
										
				}
				
				//TODO, CHECK THE LAST GALLERY RECORD TIME...
				//SO, GET THE NEWEST...
				
			}
			if(event is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.GETGALLERYBYTIME);
			}

		}
		
		
		private function bigPicHandler(event:Event):void{			
			//移除进度条
			hideMiddleLoading();
			
			if(event is ResponseEvent){
//				Logger.debug("to create big gallery...");		
				
				var galleryData:String = ResponseEvent(event).data;				
//				Logger.debug("big gallery data: \n"+galleryData);
				
				_picBuilder.createScrollableBigGallery(galleryData);				
			}
			if(event is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.GETGALLERYFORWEB);
			}			
		}	
		
		private function hotPicHandler(event:Event):void{
			//移除进度条
			hideMiddleLoading();
			
			if(event is ResponseEvent){
//				Logger.debug("to create hotPic gallery...");		
				
				var galleryData:String = ResponseEvent(event).data;				
//				Logger.debug("hotPic data: \n"+galleryData);
				
				_picBuilder.createScrollableBigGallery(galleryData);
			}
			if(event is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.GETHOTPICTURE);
			}		
		}	
		
		private function classicHandler(event:Event):void{
			//移除进度条
			hideMiddleLoading();
			
			if(event is ResponseEvent){
				Logger.debug("to create classic gallery...");		
				
				var galleryData:String = ResponseEvent(event).data;				
//				Logger.debug("classic data: \n"+galleryData);
				
				//渲染事件在PicDetailView中派发
				_picBuilder.createScrollableBigGallery(galleryData);
			}
			if(event is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.CLASSICALSTATISTICS);
			}
		}	
		
		private function favoredPicHandler(event:Event):void{
			//移除进度条
			hideMiddleLoading();
			
			if(event is ResponseEvent){
				Logger.debug("to create favored gallery...");		
				
				var galleryData:String = ResponseEvent(event).data;				
//				Logger.debug("favored data: \n"+galleryData);
				
				_picBuilder.createScrollableBigGallery(galleryData);
			}
			if(event is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.COLLECTSTATISTICS);
			}		
		}
		
		
		/**
		 * 这个数据结构？
		 */ 
		private function tagPicHandler(event:Event):void{
			//移除进度条
			hideMiddleLoading();
			
			if(event is ResponseEvent){
				
				
			}
			if(event is PTErrorEvent){
				
			}			
		}	
		

		//6小时以前
		private function sixHourAgo(endTime:Number):String{
			return (endTime-6*60*60*1000).toString();			 
		}
		
		protected function rendered():void{
			//派发尺寸改变事件	
			if(this.stage) {
				this.stage.invalidate();	
//				Logger.debug("pic detail view rendered...");
			}else{
				Logger.warn("stage in pic Main Display Area lost!");
			}
		}
		
				
		//重写销毁函数
		//凡是在本类中，对_model加过事件监听的都要在这里置空
		override public  function destroy():void{
			super.destroy();
			_picBuilder.destroy();
			_picBuilder = null;
			galleryCreated = false;
			this.removeChildren(true,true);
			Logger.debug("MainDisplayArea destroyed...");
		}
		
	
	} //end of class
}