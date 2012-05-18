package com.pintu.modules{
	
	import com.greensock.TweenLite;
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.common.SimpleText;
	import com.pintu.config.InitParams;
	import com.pintu.events.PintuEvent;
	import com.pintu.vos.Note;
	import com.pintu.widgets.ComuDisplayArea;
	import com.pintu.widgets.ComuMyNotes;
	import com.pintu.widgets.ComuPostBlock;
	import com.pintu.window.BigNoteWin;
	import com.pintu.window.EditWinBase;
	import com.pintu.window.NoteEditWin;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.casalib.display.CasaSprite;
	
	
	
	public class CommunityPage extends CasaSprite implements IDestroyableModule, IMenuClickResponder{
		
		private var _model:IPintu;
		
		private var _comuDisplayArea:ComuDisplayArea;		
		private var _comuWriteNote:ComuPostBlock;		
		private var _comuMyPosts:ComuMyNotes;
		
		private var _noteDetails:BigNoteWin;
		private var _postNoteWin:NoteEditWin;
				
		
		public function CommunityPage(model:IPintu){
			super();
			this._model = model;
			
			initModuleViews();
			
			this.addEventListener(PintuEvent.VIEW_NOTE,onSmallClicked);
			this.addEventListener(PintuEvent.POST_NOTE, onWriteNote);
		}
		
		private function initModuleViews():void{
			_comuDisplayArea = new ComuDisplayArea(_model);
			this.addChild(_comuDisplayArea);
			
			_comuWriteNote = new ComuPostBlock(_model);
			this.addChild(_comuWriteNote);
			
			_comuMyPosts = new ComuMyNotes(_model);
			this.addChild(_comuMyPosts);
		}
		
		private function onWriteNote(evt:PintuEvent):void{
			if(!_postNoteWin){
				_postNoteWin = new NoteEditWin(this.stage);
				_postNoteWin.sourceModel = _model;
			}
			dropCenterWindow(_postNoteWin);
		}
		
		//open window...
		private function onSmallClicked(evt:PintuEvent):void{
			var noteId:String = evt.data;
			var note:Note = getNoteBy(noteId);
			if(!note) return;
			
			if(!_noteDetails){
				_noteDetails = new BigNoteWin(this.stage,"");
				_noteDetails.sourceModel = _model;
				_noteDetails.owner = this;
				_noteDetails.addEventListener(ApiMethods.DELETENOTE, onNoteDeleted);
			}
			//重新赋值
			_noteDetails.data = note;
			fadeInFromDisplayAreaCenter(_noteDetails);
		}
		
		private function onNoteDeleted(evt:Event):void{
			_comuDisplayArea.refresh();
			_comuMyPosts.refresh();
		}
		
		private function fadeInFromDisplayAreaCenter(win:EditWinBase):void{
			win.x = (InitParams.GALLERY_WIDTH-win.width)/2+InitParams.startDrawingX();
			var endY:Number;
			if(InitParams.isStretchHeight()){
				endY = (InitParams.appHeight-win.height)/2;
			}else{
				endY = (InitParams.MINAPP_HEIGHT-win.height)/2;
			}
			win.y = endY;
			win.alpha = 0;
			//FIXME, 注意：必须添加在顶级
			this.stage.addChild(win);
			
			//动画切入
			TweenLite.to(win, 0.8, {alpha:1});
		}
				
		private function getNoteBy(id:String):Note{
			var note:Note;
			var notes:Array = _comuDisplayArea.notes;
			if(!notes) return null;
			
			for(var i:int=0; i<notes.length; i++){
				var eachNote:Note = notes[i] as Note;
				if(eachNote.id==id){
					note = eachNote;
					break;
				}
			}
			
			return note;
		}
		
		
		/**
		 * 向下滑出窗口
		 */ 
		private function dropCenterWindow(win:EditWinBase):void{
			win.x = (InitParams.appWidth-win.width)/2;
			//屏幕上方
			win.y = -win.height;
			
			//FIXME, 注意：必须添加在顶级
			this.stage.addChild(win);
			
			var endY:Number;
			if(InitParams.isStretchHeight()){
				endY = (InitParams.appHeight-win.height)/2;
			}else{
				endY = (InitParams.MINAPP_HEIGHT-win.height)/2;
			}
			//动画切入
			TweenLite.to(win, 0.6, {y:endY});
		}
		
		/**
		 * 在Main中的browseTypeChanged监听器中调用该方法
		 */ 
		public function menuHandler(operation:String, extra:String):void{
			trace("do nothing here...");
		}
		
		public function searchable(key:String):void{
			trace(".... to search by: "+key);
		}
		
		//重写销毁函数
		public  function killMe():void{
			//移除自己，并销毁事件监听
			super.destroy();
			_model = null;
			removeChildren(true,true);
		}
		
	}
}