package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.common.BusyIndicator;
	import com.pintu.common.GalleryPageBtn;
	import com.pintu.config.*;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
	import com.pintu.vos.Note;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 条子主显示区：条子九宫格、左右翻页按钮、底部图例
	 * 
	 */ 
	public class ComuDisplayArea extends CasaSprite{
		
		private var _model:IPintu;
		
		private var _initialized:Boolean;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		private var displayAreaWidth:Number;
		private var displayAreaHeight:Number;
		
		private var padding:Number = 10;
		private var gap:Number = 10;
		private var btnWidth:Number = 50;
		//这个需要计算
		private var btnHeight:Number;
		//图例宽
		private var legendWidth:Number = 400;
		//图例高
		private var legendHeight:Number = 20;
		
		//保留一份数据，主模块需要用
		private var _currentNotes:Array;
		/**
		 * 使用增强的显示对象CasaSprite，以更好的管理子对象
		 * 条子容器
		 */ 
		private var _notesGrid:NotesGrid;		

		/**
		 * 翻页按钮
		 */ 
		private var _leftPageBtn:GalleryPageBtn;
		private var _rightPageBtn:GalleryPageBtn;
		
		/**
		 * 底部图列
		 */ 
		private var _postTypeLegend:NoteLegend;
		
		//翻页页面计数器
		private var _notesPageCounter:int = 0;
		//加载进度条
		private var loading:BusyIndicator;
		/**
		 * 查询状态开关，定时器使用
		 */ 
		private var isRunning:Boolean;
		
		
		public function ComuDisplayArea(model:IPintu){
			super();
			
			_model = model;
			
			initDrawPoint();
			drawDisplayBackground();
			
			createContent();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, offStage);
		}
		/**
		 * 保留得到的条子数据，主显示区用
		 */ 
		public function get notes():Array{
			return _currentNotes;
		}
		
		private function onStage(evt:Event):void{
			this.removeEventListener(evt.type,arguments.callee);
			
			PintuImpl(_model).addEventListener(ApiMethods.GETCOMMUNITYNOTES, onCmntNotesFetched);
			
			goForward();
		}
		private function offStage(evt:Event):void{
			this.removeEventListener(evt.type,arguments.callee);
			
			PintuImpl(_model).removeEventListener(ApiMethods.GETCOMMUNITYNOTES, onCmntNotesFetched);
		}
		
		/**
		 * 重新取遍数据
		 */ 
		public function refresh():void{
			_notesPageCounter = 1;
			_model.getCommunityNotesBy(_notesPageCounter.toString());
			showMiddleLoading();
		}
		
		private function onCmntNotesFetched(evt:Event):void{
			hideMiddleLoading();
			
			if(evt is ResponseEvent){				
				var notesStr:String = ResponseEvent(evt).data;
				//FIXME, 看看粗体那个文字怎么回事？？
//				Logger.debug("comunity notes: "+notesStr);
				//创建条子
				var jsonNotes:Array = JSON.decode(notesStr);
				_currentNotes = jsonToNotes(jsonNotes);				
				_notesGrid.createNotes(_currentNotes);
			}
			if(evt is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.GETCOMMUNITYNOTES);
			}
		}
		
		private function goForward():void{
			_notesPageCounter++;
			_model.getCommunityNotesBy(_notesPageCounter.toString());
			showMiddleLoading();			
		}
		
		private function goBack():void{
			if(_notesPageCounter<2) return;
			
			_notesPageCounter--;
			_model.getCommunityNotesBy(_notesPageCounter.toString());
			showMiddleLoading();			
		}
				
		private function jsonToNotes(notes:Array):Array{
			var results:Array = [];
			for(var i:int=0; i<notes.length; i++){
				var nt:Object = notes[i];
				var note:Note = new Note();
				note.id = nt["id"];
				note.publisherId = nt["publisher"];
				note.publiserName = nt["authorName"];
				note.type = nt["type"];
				note.title = nt["title"];
				note.content = nt["content"];
				note.publishTime = nt["publishTime"];
				note.interest = nt["interest"];
				note.attention = nt["attention"];
				results.push(note);
			}
			
			return results;
		}
		
		/**
		 * 显示进度条，并打开查询开关
		 * public 是因为：
		 * 点击缩略图，展示图片详情时也用该方法
		 */ 
		public function showMiddleLoading():void{
			var middleX:Number = drawStartX+displayAreaWidth/2;
			var middleY:Number = drawStartY+displayAreaHeight/2;			
			if(!loading)
				loading = new BusyIndicator(32);
			loading.x = middleX-16;
			loading.y = middleY-16;
			if(!this.contains(loading))
				this.addChild(loading);
			//打开查询开关，防止短时间重复查询
			isRunning = true;
		}		
		public function hideMiddleLoading():void{
			if(this.contains(loading)){
				this.removeChild(loading);				
			}
			//查询结束
			isRunning = false;			
		}
		
		private function createContent():void{
			
			_leftPageBtn = new GalleryPageBtn(btnWidth,displayAreaHeight);
			_leftPageBtn.icon = "assets/community/back.png";
			_leftPageBtn.x = drawStartX;
			_leftPageBtn.y = drawStartY;
			_leftPageBtn.offsetIcon("left",-4);
			_leftPageBtn.addEventListener(MouseEvent.CLICK, onBackClicked);
			this.addChild(_leftPageBtn);
			
			var notesWidth:Number = displayAreaWidth-2*gap-2*btnWidth;
			var notesHeight:Number = displayAreaHeight-2*gap;					
			
			_notesGrid = new NotesGrid(notesWidth,notesHeight);
			_notesGrid.x = drawStartX+btnWidth+2*gap;
			_notesGrid.y = drawStartY+1.5*padding;
			this.addChild(_notesGrid);
			
			_rightPageBtn = new GalleryPageBtn(btnWidth,displayAreaHeight);
			_rightPageBtn.icon = "assets/community/forward.png";
			//与外边框重合
			_rightPageBtn.x = _notesGrid.x+notesWidth+gap;
			_rightPageBtn.y = drawStartY;
			_rightPageBtn.offsetIcon("right",-8);
			_rightPageBtn.addEventListener(MouseEvent.CLICK, onForwardClicked);
			this.addChild(_rightPageBtn);
								
		}
		
		private function onBackClicked(evt:MouseEvent):void{
			if(isRunning) return;
			goBack();
		}
		private function onForwardClicked(evt:MouseEvent):void{
			if(isRunning) return;
			goForward();
		}
		
		private function initDrawPoint():void{
			drawStartX = InitParams.startDrawingX();				
			drawStartY = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			
			if(InitParams.isStretchHeight()){
				//拉伸高度
				displayAreaHeight = InitParams.appHeight
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.FOOTER_HEIGHT;
			}else{
				//默认高度，也是最小高度
				displayAreaHeight = InitParams.MINAPP_HEIGHT
					-drawStartY-InitParams.FOOTER_HEIGHT-InitParams.TOP_BOTTOM_GAP;
			}
			displayAreaWidth = InitParams.GALLERY_WIDTH;
			
			btnHeight = displayAreaHeight;
		}
		
		private function drawDisplayBackground():void{						
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);			
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,displayAreaWidth,displayAreaHeight);
			this.graphics.endFill();
		}

		
	} //end of class
}