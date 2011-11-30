package com.pintu.controller
{
	import com.adobe.serialization.json.JSON;
	import com.pintu.api.*;
	import com.pintu.common.IconButton;
	import com.pintu.config.*;
	import com.pintu.events.PintuEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
	import com.pintu.vos.TPicData;
	import com.pintu.vos.TPicDesc;
	import com.pintu.widgets.MainDisplayArea;
	import com.pintu.widgets.PicDetailView;
	import com.pintu.widgets.Thumbnail;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.ui.layout.CellConfig;
	import org.as3commons.ui.layout.HLayout;
	import org.as3commons.ui.layout.constants.Align;
	import org.as3commons.ui.layout.framework.IDisplay;
	import org.casalib.display.CasaSprite;

	/**
	 * 用于主显示区域建立图片和画廊
	 */ 
	public class PicDOBuilder{
		
		private var _model:IPintu;
		
		//所创建内容的显示容器
		private var _context:CasaSprite;
		//拥有本实例的对象，用来调用显示进度条和提示方法
		private var _owner:MainDisplayArea;
		
		private var _drawStartX:Number;
		private var _drawStartY:Number;
		//画廊行数
		private var rowNum:int;
		private var tpics:Array;
		
		//缩略图大小
		private var _thumbnailSize:int = 100;
		//MINI画廊列数
		private var _miniGalleryColumnNum:int = 5;
		//画廊边距
		private var _margin:int = 10;		
		
			
		public function PicDOBuilder(container:CasaSprite, model:IPintu){
			_context = container;
			_model = model;
			//缩略图详情响应
			PintuImpl(_model).addEventListener(ApiMethods.GETPICDETAIL,detailPicHandler);
		}
		
		public function set drawStartX(sx:Number):void{
			_drawStartX = sx;
		}
		public function set drawStartY(sy:Number):void{
			_drawStartY = sy;
		}
		public function set owner(o:MainDisplayArea):void{
			_owner = o;
		}
		
		private function detailPicHandler(event:Event):void{	
			//只处理结果事件，不处理状态事件
			if(!(event is ResponseEvent)) return;
						
			//展示详情前，先清理
			cleanUp();					
			Logger.debug("pic details: \n"+ResponseEvent(event).data);
			//CREATE PIC DETAILS...
			var details:Object =  JSON.decode(ResponseEvent(event).data) as Object;
			var picDetails:PicDetailView = new PicDetailView(objToTPicData(details), _model);
			picDetails.x = _drawStartX;
			picDetails.y = _drawStartY;
			//工具栏左侧给返回按钮让位
			picDetails.showBackBtn = true;
			_context.addChild(picDetails);					
			
			//BACK BUTTON
			var back:IconButton = new IconButton(26,26);
			back.iconPath = "assets/back.png";
			back.addEventListener(MouseEvent.CLICK, restoreGallery);
			back.x = _drawStartX+2;
			//往下移动下跟工具栏对齐
			back.y = _drawStartY+2;
			back.textOnRight = true;
			back.label = "返回";
			_context.addChild(back);
			
			//移除进度条
			_owner.hideMiddleLoading();
			
		}
		

		
		private function restoreGallery(evt:MouseEvent):void{
			cleanUp();
			layoutThumbnails();		
		}

		
		//给MainDisplayArea调用
		public function createScrollableMiniGallery(json:String):void{			
			
			var thumnails:Array = JSON.decode(json) as Array;
			if(!thumnails) return;
			
			//画廊没新图片
			if(thumnails.length==0){
				_owner.hintToUser("没有最新的图片，不然随便看看？");
				_owner.hideMiddleLoading();
				return;
			}
			
			//准备生成画廊
			cleanUp();
			//记下画廊行数以计算画廊高度
			rowNum = Math.floor(thumnails.length/_miniGalleryColumnNum)+1;
			
			//解析Json字符串为对象
			tpics = objToTPicDescArray(thumnails);	
			//颠倒下顺序，好让最近的放在最前面
			tpics = tpics.reverse();
			
			//布局缩略图
			layoutThumbnails();
					
		}
		
		private function layoutThumbnails():void{
			//画廊剩余宽度减去左右边距，然后按列数平分
			var columnGap:Number = (InitParams.GALLERY_WIDTH-
				_miniGalleryColumnNum*_thumbnailSize-2*_margin)/(_miniGalleryColumnNum-1);						
			
			var grid:HLayout = new HLayout();
			//每行最多放5个
			grid.maxItemsPerRow = _miniGalleryColumnNum;
			grid.minWidth = InitParams.GALLERY_WIDTH;
			grid.minHeight = rowNum*(_thumbnailSize+columnGap);
			var xOffset:Number = _margin;
			var yOffset:Number = _margin;	
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
			//清空舞台		
			cleanUp();
			
			//展示进度条
			_owner.showMiddleLoading();
			//查询详情
			var tpId:String = event.data;
			_model.getPicDetail(tpId);
		}

		
		//TODO, 创建列表式大图画廊...
		//创建多个PicDetailView
		public function createScrollableBigGallery(json:String):void{
			
			
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
				tpic.creationTime = Number(thumbnail["creationTime"]);
				tpic.url = _model.composeImgUrlById(thumbnail["thumbnailId"]);
				tpics.push(tpic);
			}
			return tpics;
			
		}
		
		
		private function objToTPicData(details:Object):TPicData{
			var pic:TPicData = new TPicData();
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
			pic.mobImgUrl =  _model.composeImgUrlById(details["mobImgId"]);
			pic.rawImgUrl =  _model.composeImgUrlById(details["rawImgId"]);
			pic.commentsNum = details["storiesNum"];
			pic.coolCount = details["coolCount"];
			
			return pic;
		}
		
		
	}
}