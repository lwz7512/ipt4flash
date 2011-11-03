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
			
			var tpics:Array = objToTPicDescArray(thumnails);
			
			var grid : HLayout = new HLayout();
			grid.maxItemsPerRow = 5;
			grid.minWidth = InitParams.GALLERY_WIDTH;
			grid.minHeight = InitParams.CALLERY_HEIGHT;
			var xOffset:Number = 10;
			var yOffset:Number = 10;	
			grid.marginX = _drawStartX +xOffset;
			grid.marginY = _drawStartY +yOffset;
			//左右各空10个像素，5个缩略图中间有4个间隔
			grid.hGap =  (InitParams.GALLERY_WIDTH-520)/4;
			grid.vGap = (InitParams.GALLERY_WIDTH-520)/4;
			
			var cellConfig:CellConfig = new CellConfig();			
			cellConfig.width = 100;
			cellConfig.height = 100;
			grid.setCellConfig(cellConfig);
			
			for(var i:int=0; i<32; i++){
				var thumbnail:Thumbnail = new Thumbnail(null);
				grid.add(thumbnail);
			}
			
			grid.layout(_displayArea);
			
		}
		
		public function get galleryHeight():Number{
			//如果是32个缩略图，高度就是7行*(100+10)
			return 7*110;
		}
		
		public function createScrollableBigGallery(json:String):void{
			_displayArea.removeChildren(true,true);
			
		}
		
		private function objToTPicDescArray(thumnails:Array):Array{
			var tpics:Array = [];
			for each(var thumbnail:Object in thumnails){
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