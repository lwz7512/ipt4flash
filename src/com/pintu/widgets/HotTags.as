package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.events.*;
	import com.pintu.utils.Logger;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	
	
	public class HotTags extends AbstractWidget{
				
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		private var titleBackgroudColor:uint = StyleParams.COLUMN_TITLE_BACKGROUND;
		private var titleBackgroudHeight:int = InitParams.ANDI_TITLE_HEIGHT;
		
		//菜单使用颜色
		private var upColors:Array;
		private var overColors:Array;
		private var downColors:Array;		
		
		private var tagObjs:Array;
		private var tagsContainer:CasaSprite;
		
		public function HotTags(model:IPintu){			
			super(model);			
			
			drawLoginBackGround();
			
			drawTitleBar();
			
			tagsContainer = new CasaSprite();
			tagsContainer.x = drawStartX;
			tagsContainer.y = drawStartY+titleBackgroudHeight;
			this.addChild(tagsContainer);
		}
		
		override protected function initModelListener(evt:Event):void{
			super.initModelListener(evt);
			
			PintuImpl(_clonedModel).addEventListener(ApiMethods.GETHOTTAGS, hotTagsHandler);
			_clonedModel.getHotTags();
		}
		
		override protected function cleanUpModelListener(evt:Event):void{
			//先移除事件
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.GETHOTTAGS, hotTagsHandler);
			//后清空模型
			super.cleanUpModelListener(evt);
		}
		
		private function hotTagsHandler(evt:Event):void{
			if(evt is ResponseEvent){
				var tags:String = ResponseEvent(evt).data;
				if(!tags) return;
//				Logger.debug("tags: \n"+tags);
				
				tagObjs = JSON.decode(tags);
				if(!tagObjs) {
					Logger.error("tagObjs is null !");
					return;
				}
				if(tagObjs.length==0) {
					Logger.error("tagObjs length is 0 !");
					return;
				}
				
				buildTagsLink();
								
			}
			if(evt is PTErrorEvent){
				Logger.error("get hot tags error!!!");
			}
		}
		
		private function buildTagsLink():void{
			var tagStartX:Number = 4;
			var tagStartY:Number = 4;
			var tagVGap:Number = 26;					
			
			tagsContainer.removeChildren();
			
			var tagLength:int = tagObjs.length;
			//最多放10个
			if(tagLength>10) tagLength = 10;
			
			//只放10个
			for(var i:int=0; i<tagLength; i++){
				var tagObj:Object = tagObjs[i];
				if(tagObj==null) continue;
				
				var tagStr:String = tagObj["name"]+" ("+tagObj["browseCount"]+")";
				var tagId:String = tagObj["id"];
				var tagView:LinkRow = new LinkRow(tagStr, tagId);
				tagView.x = 1;
				tagView.y = i*tagVGap+tagStartY;
				tagView.width = blockWidth-1;
				tagView.height = tagVGap;
				//偶数行放背景
				if(i%2==0){
					tagView.backgroundColor = StyleParams.PICDETAIL_BACKGROUND_THIRD;							
				}
				//指定派发： 查询缩略图事件
				tagView.eventType = PintuEvent.GETTB_BYTAG;				
				tagsContainer.addChild(tagView);
			}
		}
		
		private function drawTitleBar():void{
			this.graphics.lineStyle(1, titleBackgroudColor);
			this.graphics.beginFill(titleBackgroudColor, 1);
			this.graphics.drawRect(drawStartX,drawStartY,InitParams.ANDI_ASSETS_WIDTH,titleBackgroudHeight);
			this.graphics.endFill();
			
			var title:SimpleText = new SimpleText("热门标签", 0xFFFFFF, 13);
			title.x = drawStartX+(InitParams.ANDI_ASSETS_WIDTH-title.textWidth)/2;
			title.y = drawStartY+4;
			this.addChild(title);
		}
		
		private function drawLoginBackGround():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT
				+InitParams.TOP_BOTTOM_GAP
				+InitParams.USER_DETAIL_HEIGHT
				+InitParams.DEFAULT_GAP
				+InitParams.ANDI_ASSETS_HEIGHT
				+InitParams.DEFAULT_GAP;
			
			blockWidth = InitParams.LOGIN_FORM_WIDTH;
			
			if(InitParams.isStretchHeight()){
				blockHeight = InitParams.appHeight
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.FOOTER_HEIGHT;
			}else{
				blockHeight = InitParams.MINAPP_HEIGHT
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.FOOTER_HEIGHT;
			}
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			//半透明效果似乎更好
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);				
			this.graphics.endFill();
		}
		
	} //end of class
}