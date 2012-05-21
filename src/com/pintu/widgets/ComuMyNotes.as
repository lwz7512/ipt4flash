package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.common.LinkRow;
	import com.pintu.common.SimpleText;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PintuEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.utils.PintuUtils;
	import com.pintu.utils.Logger;
	
	import flash.events.Event;
	
	import org.casalib.display.CasaSprite;
	
	
	/**
	 * 社区模块，我的条子
	 * 
	 * 2012/05/14
	 */ 
	public class ComuMyNotes extends AbstractWidget{
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		private var titleBackgroudColor:uint = StyleParams.COLUMN_TITLE_BACKGROUND;
		private var titleBackgroudHeight:int = InitParams.ANDI_TITLE_HEIGHT;
		
		private var noteObjs:Array = [];
		private var notesContainer:CasaSprite;
		
		private var _titleTxt:String = "我的条子";
		private var _titleTF:SimpleText;
		
		
		
		public function ComuMyNotes(model:IPintu){
			super(model);
			
			initDrawPoint();
			drawBackGround();			
			drawTitleBar();
			
			notesContainer = new CasaSprite();
			notesContainer.x = drawStartX;
			notesContainer.y = drawStartY+titleBackgroudHeight;
			this.addChild(notesContainer);
		}
		
		override protected function safeAddModelListener():void{
			PintuImpl(_clonedModel).addEventListener(ApiMethods.GETUSERNOTES, onNotesFetched);
			_clonedModel.getUserNotesBy(null);
		}
		
		override protected function safeClearModelListener():void{
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.GETUSERNOTES, onNotesFetched);
		}
		
		/**
		 * 重新取遍数据
		 */ 
		public function refresh():void{
			_clonedModel.getUserNotesBy(null);
		}
		
		private function onNotesFetched(evt:Event):void{
			if(evt is ResponseEvent){
				var notes:String = ResponseEvent(evt).data;
				if(!notes) return;
//				Logger.debug("my notes: \n"+notes);
				
				noteObjs = JSON.decode(notes);
				if(!noteObjs) {
					Logger.error("noteObjs is null !");
					return;
				}
				buildMyNotes();
				updateTitle(noteObjs.length.toString());
			}
			if(evt is PTErrorEvent){
				Logger.error("get my notes error!!!");
			}
		}
		
		//FIXME, JUST FOR TEST 
		private function buildMyNotes():void{
			var noteStartX:Number = 4;
			var noteStartY:Number = 4;
			var noteVGap:Number = 26;					
			
			notesContainer.removeChildren();
			
			var noteLength:int = noteObjs.length;
			//最多放10个
			if(noteLength>10) noteLength = 10;					
			
			//只放10个
			for(var i:int=0; i<noteLength; i++){
				var noteObj:Object = noteObjs[i];
				if(noteObj==null) continue;
				
				var noteStr:String = noteObj["title"];
				var noteId:String = noteObj["id"];
				//FIXME, 限制条子的标题跟小条子的长度一致：16
				noteStr = PintuUtils.truncateStr(noteStr,16);
				var titleView:LinkRow = new LinkRow(noteStr, noteId);
				titleView.x = 1;
				titleView.y = i*noteVGap+noteStartY;
				titleView.width = blockWidth-1;
				titleView.height = noteVGap;
				//偶数行放背景
				if(i%2==0){
					titleView.backgroundColor = StyleParams.PICDETAIL_BACKGROUND_THIRD;							
				}
				//指定派发： 查看该条子
				titleView.eventType = PintuEvent.VIEW_NOTE;
				notesContainer.addChild(titleView);
			}
		}
		
		
		private function initDrawPoint():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT
				+InitParams.TOP_BOTTOM_GAP
				+InitParams.USER_DETAIL_HEIGHT
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
		}
		
		private function drawTitleBar():void{
			this.graphics.lineStyle(1, titleBackgroudColor);
			this.graphics.beginFill(titleBackgroudColor, 1);
			this.graphics.drawRect(drawStartX,drawStartY,InitParams.ANDI_ASSETS_WIDTH,titleBackgroudHeight);
			this.graphics.endFill();
			
			_titleTF = new SimpleText(_titleTxt, 0xFFFFFF, 13);
			_titleTF.x = drawStartX+(InitParams.ANDI_ASSETS_WIDTH-_titleTF.textWidth)/2;
			_titleTF.y = drawStartY+4;
			this.addChild(_titleTF);
		}
		
		//更新条子数目
		private function updateTitle(postNum:String):void{
			_titleTF.text = _titleTxt+"（"+postNum+"）";
		}
		
		private function drawBackGround():void{
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			//半透明效果似乎更好
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);				
			this.graphics.endFill();
		}
		
		
	} //end of class
}