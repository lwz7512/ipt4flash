package com.pintu.window{
	
	import com.greensock.TweenLite;
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.common.IconButton;
	import com.pintu.common.LazyImage;
	import com.pintu.common.SimpleText;
	import com.pintu.config.StyleParams;
	import com.pintu.controller.GlobalController;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.PintuUtils;
	import com.pintu.vos.Note;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaShape;
	
	/**
	 * 条子详情，带完整内容和底部工具栏
	 */ 
	public class BigNoteWin extends EditWinBase{
		
		private var _data:Note;
				
		private var _contentTxt:SimpleText;
		
		private var _pmBtn:IconButton;
		private var _deleteBtn:LazyImage;
		
		private var _attentionBtn:IconButton;
		private var _attentionPrefix:String = "关注：";
		
		private var _interestBtn:IconButton;
		private var _interestPrefix:String = "感兴趣：";
		
		private var overColors:Array;
		private var downColors:Array;
		
		private var deleteCounter:int = 0;
		
		
		public function BigNoteWin(ctxt:Stage, title:String){
			super(ctxt, 320, 300, title,false);
			
			this.showProgressbar = false;
			
			overColors = [StyleParams.HEADER_MENU_MOUSEOVER,StyleParams.HEADER_MENU_MOUSEOVER];
			downColors = [StyleParams.DEFAULT_DARK_GREEN,StyleParams.DEFAULT_DARK_GREEN];
			
			createFrame();
			
			createPMBtn();
			createAttention();
			createInterest();
		}
		
		private function createFrame():void{
			var marging:Number = 4;
			var frame:CasaShape = new CasaShape();		
			frame.x = marging;
			frame.y = _elementStartY;
			frame.graphics.lineStyle(1, StyleParams.DARKER_BORDER_COLOR);
			frame.graphics.drawRect(marging,marging,width-16,height-80);
			this.addChild(frame);
		}
		
		/**
		 * 条子对象，需要里面的各种属性
		 */ 
		public function set data(data:Note):void{
			_data = data;
		}
		
		override protected function onStageHandler():void{			
			createContent();
			
			processDeleteBtn();
		}
		
		private function processDeleteBtn():void{
			var currentUser:String = GlobalController.loggedUser;
			if(currentUser==_data.publisherId){
				_deleteBtn.visible = true;
			}else{
				_deleteBtn.visible = false;
			}
		}
		
		override public function set sourceModel(_model:IPintu):void{
			super.sourceModel = _model;
			
			//TODO, 提交关注和兴趣的事件响应
			this.cloneModel.addEventListener(ApiMethods.ADDATTENTION, addAttentionHandler);
			this.cloneModel.addEventListener(ApiMethods.ADDINTEREST, addInterestHandler);
			this.cloneModel.addEventListener(ApiMethods.DELETENOTE, deleteNoteHandler);
		}
		
		private function addAttentionHandler(evt:Event):void{			
			_attentionBtn.label = _attentionPrefix+(Number(_data.attention)+1);
			_attentionBtn.invalidate();
		}
		private function addInterestHandler(evt:Event):void{
			_interestBtn.label = _interestPrefix+(Number(_data.interest)+1);
			_interestBtn.invalidate();
		}
		private function deleteNoteHandler(evt:Event):void{
			closeMe(null);
			this.dispatchEvent(new Event(ApiMethods.DELETENOTE));
		}
		
		
		/**
		 * 放图片，而不是绘制背景了
		 */ 
		override protected function drawBackground():void{
			//FIXME, 根据分类重新绘制标题栏的颜色
			super.drawBackground();
		}
		
		private function createAttention():void{
			var attentionPath:String = "assets/community/attention.png";
			_attentionBtn = new IconButton(26,26);
			_attentionBtn.iconPath = attentionPath;
			_attentionBtn.textOnRight = true;
			
			_attentionBtn.x = 140;
			_attentionBtn.y = this.height - 40;
			_attentionBtn.setSkinStyle(null,overColors,downColors);	
			_attentionBtn.setLabelStyle("宋体",12,0x000000,StyleParams.GREEN_TEXT_COLOR,0x000000);
			_attentionBtn.addEventListener(MouseEvent.CLICK, onATClicked);
			this.addChild(_attentionBtn);
			
		}
		
		private function createInterest():void{
			
			var interestPath:String = "assets/community/interest.png";
			_interestBtn = new IconButton(26,26);
			_interestBtn.iconPath = interestPath;
			_interestBtn.textOnRight = true;
			
			_interestBtn.x = 220;
			_interestBtn.y = this.height - 40;
			_interestBtn.setSkinStyle(null,overColors,downColors);	
			_interestBtn.setLabelStyle("宋体",12,0x000000,StyleParams.GREEN_TEXT_COLOR,0x000000);
			_interestBtn.addEventListener(MouseEvent.CLICK, onITClicked);
			this.addChild(_interestBtn);
		}
		
		/**
		 * 发送私信按钮
		 */ 
		private function createPMBtn():void{
						
			_pmBtn = new IconButton(26,26);
			_pmBtn.iconPath = "assets/community/kuser.png";
			_pmBtn.x = _elementStartX+10;
			_pmBtn.y = this.height - 40;
			_pmBtn.textOnRight = true;
			_pmBtn.label = "私信我";
			_pmBtn.setSkinStyle(null,overColors,downColors);	
			_pmBtn.setLabelStyle("宋体",12,0x000000,StyleParams.GREEN_TEXT_COLOR,0x000000);
			_pmBtn.addEventListener(MouseEvent.CLICK, onPMClicked);
			this.addChild(_pmBtn);
			
		}
		
		/**
		 * 关闭当前窗口，打开发私信窗口
		 */ 
		private function onPMClicked(evt:MouseEvent):void{
			closeMe(null);
			//发私信
			var msg:PintuEvent = new PintuEvent(PintuEvent.POST_MSG,_data.publisherId);
			msg.extra = _data.publiserName;
			msg.third = _data.id;
			dispatchEvent(msg);
		}
		//提交关注
		private function onATClicked(evt:MouseEvent):void{
			if(!_data) return;
			
			_attentionBtn.enabled = false;
			this.cloneModel.addAttentionBy(_data.id,"1");
		}
		//TODO, 提交感兴趣
		private function onITClicked(evt:MouseEvent):void{
			if(!_data) return;
			
			_interestBtn.enabled = false;
			this.cloneModel.addInterestBy(_data.id,"1");
		}
		
		/**
		 * 延迟创建文本和工具栏
		 */ 
		private function createContent():void{
			//FIXME, 限制可展示文字长度：240，是小条子的3倍
			var contentStr:String = PintuUtils.truncateStr(_data.content, 240);
			if(!_contentTxt){
				_contentTxt = new SimpleText(contentStr,0,12,false,true,true,true);
				_contentTxt.x = _elementStartX+4;
				_contentTxt.y = _elementStartY+4;
				_contentTxt.width = 300;
				this.addChild(_contentTxt);				
			}else{//必须是HTML格式
				_contentTxt.htmlText = contentStr;
			}
			
			var atNum:String = "0";
			if(_data) atNum = _data.attention;
			_attentionBtn.label = _attentionPrefix+atNum;
			_attentionBtn.invalidate();
			
			_interestBtn.label = _interestPrefix+_data.interest;
			_interestBtn.invalidate();
			
			//更新标题
			this.updateTitle(_data.title);
		}
		
		override protected function addTitleBtn():void{
			var deleteIconPath:String = "assets/community/delete.png";
			_deleteBtn = new LazyImage(deleteIconPath);
			_deleteBtn.buttonMode = true;
			_deleteBtn.x = this.width-60;
			_deleteBtn.y = 0;
			_deleteBtn.addEventListener(MouseEvent.CLICK, deleteNote);
			this.addChild(_deleteBtn);
		}
		
		private function deleteNote(evt:MouseEvent):void{
			deleteCounter++;
			if(deleteCounter==1){
				var hint:PintuEvent = new PintuEvent(PintuEvent.HINT_USER, "确认要删除吗，确认请再点一下！");
				this.owner.dispatchEvent(hint);
				return;
			}
			if(deleteCounter==2){
				this.cloneModel.deleteNoteBy(_data.id);
				this.showLoading(this.width-90,0);
			}
			
		}
		
		override protected function closeMe(evt:Event):void{
			TweenLite.to(this, 0.4, {alpha:0, onComplete:reset});
		}
		
		override protected function reset():void{
			super.reset();			
			
			_contentTxt.text = "";
			_interestBtn.label = "";
			_attentionBtn.label = "";
			
			deleteCounter = 0;
		}
		
		
		
	} //end of class
}