package com.pintu.widgets{
	
	import com.pintu.config.StyleParams;
	import com.pintu.vos.Note;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 九宫格条子，只负责按照数据创建条子
	 * 按照显示区域大小，均分间距
	 */ 
	public class NotesGrid extends CasaSprite{
		
		private var _width:Number;
		private var _height:Number;
		
		private var _horiGap:Number = 20;
		private var _veritGap:Number = 10;
		
		private var _noteWidth:Number;
		private var _noteHeight:Number;
		
		
		
		
		public function NotesGrid(w:Number, h:Number){
			super();
			
			_width = w;
			_height = h;
			
			_noteWidth = Math.floor((w-2*_horiGap)/3);
			_noteHeight = Math.floor((h-2*_veritGap)/3);
			
		}
		
		private function drawFrame():void{
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.drawRect(0,0,_width,_height);
		}
		
		/**
		 * 每页九个
		 */ 
		public function createNotes(notes:Array):void{
						
			this.removeChildren(true,true);
			
			for(var i:int=0; i<notes.length; i++){
				var rowIndex:int = i/3;
				var colIndex:int = i % 3;
				var noteObj:Note = notes[i] as Note;					
				var noteView:ComuNoteSmall = new ComuNoteSmall(noteObj);
				//水平放置，行满后放列
				noteView.x = colIndex*(noteView.width+_horiGap);
				noteView.y = rowIndex*(noteView.height+_veritGap);				
				this.addChild(noteView);
			}
		}		
		
	} //end of class
}