package com.pintu.widgets
{
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.ErrorEvent;
	import com.pintu.events.ResponseEvent;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	public class MainDisplayArea extends Sprite{
		
		private var _model:IPintu;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		//thumbnail or big pic
		private var _displayMode:String;
		private var _browseType:String;
		
		private var _initialized:Boolean;
		
		public function MainDisplayArea(model:IPintu){
			super();
			this._model = model;
			PintuImpl(_model).addEventListener(ApiMethods.GETGALLERYBYTIME,thumbnailHandler);
			PintuImpl(_model).addEventListener(ApiMethods.GETGALLERYFORWEB,bigPicHandler);
			
			drawMainDisplayBackground();
			//初始化查询
			this.addEventListener(Event.ADDED_TO_STAGE, initDisplayStage);
		}
		
		private function initDisplayStage(event:Event):void{
			_initialized = true;
			queryPicByType();
		}
		
		//TODO, 根据_displayMode和_browseType来查看图片
		private function queryPicByType():void{
			
		}
		
		private function thumbnailHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is ErrorEvent){
				
			}
		}
		
		private function bigPicHandler(event:Event):void{
			if(event is ResponseEvent){
				
			}
			if(event is ErrorEvent){
				
			}			
		}	
		
		public function set displayMode(mode:String):void{
			if(mode == _displayMode) return;
			
			this._displayMode = mode;
			//初始化时不查询
			if(!_initialized) return;
			//delay query..
			invalidate();
		}
		
		public function set browseType(type:String):void{
			if(type == _browseType) return;
			
			this._browseType = type;
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
		

	
	} //end of class
}