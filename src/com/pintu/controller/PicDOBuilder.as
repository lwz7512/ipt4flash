package com.pintu.controller
{
	import com.adobe.serialization.json.JSON;
	import com.pintu.api.IPintu;
	import com.pintu.config.InitParams;
	import com.pintu.vos.TPicDesc;
	import com.pintu.widgets.Thumbnail;
	
	import flash.display.Sprite;
	
	import org.as3commons.ui.layout.CellConfig;
	import org.as3commons.ui.layout.HLayout;
	import org.as3commons.ui.layout.constants.Align;
	import org.casalib.display.CasaSprite;

	/**
	 * 用于主显示区域建立图片和画廊
	 */ 
	public class PicDOBuilder{
		
		private var _displayArea:CasaSprite;
		private var _model:IPintu;
		private var _drawStartX:Number;
		private var _drawStartY:Number;
		private var _displayAreaHeight:Number;
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
		}
		
		public function set drawStartX(sx:Number):void{
			_drawStartX = sx;
		}
		public function set drawStartY(sy:Number):void{
			_drawStartY = sy;
		}
		
		
		public function createScrollableMiniGallery(json:String):void{
			_displayArea.removeChildren(true,true);
			
			var thumnails:Array = JSON.decode(json) as Array;
			if(!thumnails) return;
			
			//画廊剩余宽度减去左右边距，然后按列数平分
			var columnGap:Number = (InitParams.GALLERY_WIDTH-
				_miniGalleryColumnNum*_thumbnailSize-2*_margin)/(_miniGalleryColumnNum-1);
			
			var rowNum:int = Math.floor(thumnails.length/_miniGalleryColumnNum)+1;
			//需要计算新的画廊高度
			//高度就是行数*(缩略图高度+2倍行距)
			//保存实际的画廊高度，供滚动计算需要
			_currentGalleryHeight = rowNum*(_thumbnailSize+columnGap);					
			
			var grid : HLayout = new HLayout();
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
			
			var tpics:Array = objToTPicDescArray(thumnails);	
			for(var i:int=0; i<tpics.length; i++){
				var thumbnail:Thumbnail = new Thumbnail(TPicDesc(tpics[i]));
				grid.add(thumbnail);
			}
			//展示画廊
			grid.layout(_displayArea);
			
		}
		
		public function get galleryHeight():Number{			
			return _currentGalleryHeight;
		}
		
		//TODO, 创建列表式大图画廊...
		public function createScrollableBigGallery(json:String):void{
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