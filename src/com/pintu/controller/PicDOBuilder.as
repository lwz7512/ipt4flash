package com.pintu.controller
{
	import com.adobe.serialization.json.JSON;
	import com.pintu.api.*;
	import com.pintu.config.InitParams;
	import com.pintu.events.PintuEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
	import com.pintu.vos.TPicData;
	import com.pintu.vos.TPicDesc;
	import com.pintu.widgets.IconButton;
	import com.pintu.widgets.MainDisplayArea;
	import com.pintu.widgets.PicDetails;
	import com.pintu.widgets.Thumbnail;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
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
		
		private var _displayArea:CasaSprite;
		private var _drawStartX:Number;
		private var _drawStartY:Number;
		private var _owner:MainDisplayArea;
		
		private var rowNum:int;
		private var tpics:Array;
		//用于滚动计算位置
		private var _currentGalleryHeight:Number;
		//缩略图大小
		private var _thumbnailSize:int = 100;
		//MINI画廊列数
		private var _miniGalleryColumnNum:int = 5;
		//画廊边距
		private var _margin:int = 10;
		

		
		public function PicDOBuilder(displayArea:CasaSprite, model:IPintu){
			_displayArea = displayArea;
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
		
		private function detailPicHandler(event:ResponseEvent):void{
			Logger.debug(" Detail is: \n"+event.data);
			
			cleanUp();					
			
			//TODO, CREATE PIC DETAILS...
			var details:Object =  JSON.decode(event.data) as Object;
			var picDetails:PicDetails = new PicDetails(objToTPicData(details));
			picDetails.x = _drawStartX;
			picDetails.y = _drawStartY;			
			_displayArea.addChild(picDetails);
			
			//BACK BUTTON
			var back:IconButton = new IconButton(32,32);
			back.iconPath = "assets/back.png";
			back.addEventListener(MouseEvent.CLICK, restoreGallery);
			back.x = _drawStartX;
			back.y = _drawStartY;
			_displayArea.addChild(back);
		}
		
		private function objToTPicData(details:Object):TPicData{
			var pic:TPicData = new TPicData();
			pic.id = details["id"];
			pic.owner = details["owner"];
			pic.author = details["author"];
			pic.avatarUrl = _model.composeImgUrlByPath(details["avatarImgPath"]);
			pic.score = details["score"];
			pic.level = details["level"];
			pic.publishTime = details["publishTime"];
			pic.tags = details["tags"];
			pic.description = details["description"];
			pic.isOriginal = details["isOriginal"];
			pic.mobImgUrl =  _model.composeImgUrlById(details["mobImgId"]);
			pic.commentsNum = details["storiesNum"];
			return pic;
		}
		
		private function restoreGallery(evt:MouseEvent):void{
			cleanUp();
			layoutThumbnails();
		}
		
		//给MainDisplayArea调用
		public function createScrollableMiniGallery(json:String):void{
			cleanUp();
			
			var thumnails:Array = JSON.decode(json) as Array;
			if(!thumnails) return;
			
			rowNum = Math.floor(thumnails.length/_miniGalleryColumnNum)+1;
			
			//解析Json字符串为对象
			tpics = objToTPicDescArray(thumnails);	
			//布局缩略图
			layoutThumbnails();
			
		}
		
		private function layoutThumbnails():void{
			//画廊剩余宽度减去左右边距，然后按列数平分
			var columnGap:Number = (InitParams.GALLERY_WIDTH-
				_miniGalleryColumnNum*_thumbnailSize-2*_margin)/(_miniGalleryColumnNum-1);
						
			//需要计算新的画廊高度
			//高度就是行数*(缩略图高度+2倍行距)
			//保存实际的画廊高度，供滚动计算需要
			_currentGalleryHeight = rowNum*(_thumbnailSize+columnGap);	
			
			var grid:HLayout = new HLayout();
			//每行最多放5个
			grid.maxItemsPerRow = _miniGalleryColumnNum;
			grid.minWidth = InitParams.GALLERY_WIDTH;
			grid.minHeight = _currentGalleryHeight;
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
			grid.layout(_displayArea);
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

		//获得事件视图的高度，以决定是否滚轮滚动
		public function get galleryHeight():Number{			
			return _currentGalleryHeight;
		}
		
		//TODO, 创建列表式大图画廊...
		public function createScrollableBigGallery(json:String):void{
			
			
		}
		
		private function cleanUp():void{
			_displayArea.removeChildren(true,true);
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
		
		
		
		
	}
}