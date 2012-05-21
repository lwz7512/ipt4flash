package com.pintu.window{
	
	import com.bit101.components.ComboBox;
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.common.MustTextInput;
	import com.pintu.common.SimpleText;
	import com.pintu.common.TextArea;
	import com.pintu.config.StyleParams;
	import com.pintu.utils.Logger;
	import com.sibirjak.asdpc.button.ButtonEvent;
	import com.sibirjak.asdpc.textfield.TextInput;
	
	import flash.display.Stage;
	import flash.events.Event;
	
	/**
	 * 条子编辑窗口
	 */ 
	public class NoteEditWin extends EditWinBase{
		
		//类型列表
		private var items:Array;
		
		private var typeLabel:SimpleText;
		private var typeComboBox:ComboBox;
		
		private var titleLabel:SimpleText;
		private var titleField:MustTextInput;
		
		private var contentLabel:SimpleText;
		private var contentTextArea:TextArea;
		
		
		public function NoteEditWin(ctxt:Stage, w:Number=320, h:Number=360){
			super(ctxt, w, h, "贴条子");
			
			initPostTypes();	
			
			createFormElements();
		}
		
		private function initPostTypes():void{
			items = [];
			items.push({label:"发布外包",value:"AsmtRelease"});
			items.push({label:"发布承接",value:"AsmtReceive"});
			items.push({label:"作品买卖",value:"AtwkBargain"});
			items.push({label:"作品推广",value:"AtwkPopularize"});
			items.push({label:"求职信息",value:"JobHunting"});
			items.push({label:"招聘信息",value:"AdvertiseJob"});
			items.push({label:"活动宣传",value:"PubActivities"});
			items.push({label:"自由话题",value:"FreeTopic"});
		}
		
		//对克隆的模型进行事件监听
		override public function set sourceModel(_model:IPintu):void{
			super.sourceModel = _model;
			//添加发送条子的事件监听
			this.cloneModel.addEventListener(ApiMethods.ADDNOTE, sendNoteHandler);			
		}
		
		private function sendNoteHandler(evt:Event):void{
			closeMe(null);
			
			this.hintToUser("条子发送成功！");
		}
		
		override protected function submit(evt:ButtonEvent):void{	
			var type:String = typeComboBox.selectedItem["value"];
			var title:String = titleField.text;
			var content:String = contentTextArea.text;
			
			//先校验内容输入
			if(title.length==0){
				this.offsetErrorTxt(10,0);
				updateSuggest("标题不能为空");
				return;
			}
			if(content.length==0){
				this.offsetErrorTxt(10,0);
				updateSuggest("内容不能为空");
				return;
			}
			super.submit(evt);		
			
			//调用模型方法提交
			Logger.debug("to send note...");			
			
			if(this.cloneModel)
				this.cloneModel.createNote(null,type,title,content);
						
			this.offsetLoading(0,-10);
		}

		//TODO, ...ADD NOTE EDIT FORM...
		private function createFormElements():void{
			var vertiGap:Number = 35;
			
			typeLabel = new SimpleText("类型：");
			typeLabel.x = this._elementStartX+10;
			typeLabel.y = this._elementStartY+5;
			this.addChild(typeLabel);
			
			typeComboBox = new ComboBox(this,100,30,"选择类型",items);
			typeComboBox.setSize(100,24);			
			typeComboBox.x = 60;
			typeComboBox.y = this._elementStartY+6;
			typeComboBox.selectedIndex = 0;
			
			titleLabel = new SimpleText("标题：");
			titleLabel.x = this._elementStartX+10;
			titleLabel.y = typeLabel.y+vertiGap;
			this.addChild(titleLabel);
			
			titleField = new MustTextInput();			
			titleField.setSize(240,24);
			titleField.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			titleField.setStyle(TextInput.style.size,12);
			titleField.setStyle(TextInput.style.bold,true);
			titleField.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);	
			//FIXME, 标题长度统一限制：16
			titleField.setStyle(TextInput.style.maxChars,20);			
			titleField.x = _elementStartX+titleLabel.textWidth+18;
			titleField.y = titleLabel.y;
			this.addChild(titleField);
			
			contentLabel = new SimpleText("内容：");
			contentLabel.x = this._elementStartX+10;
			contentLabel.y = titleLabel.y+vertiGap;
			this.addChild(contentLabel);
			
			contentTextArea = new TextArea();
			contentTextArea.isMust = true;
			contentTextArea.defaultText = "条子内容，支持简单的html标记，换行用<br/>，加粗用<b>粗体文字</b>";
			contentTextArea.setSize(240,200);
			contentTextArea.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			contentTextArea.setStyle(TextInput.style.size,12);
			contentTextArea.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);
			//FIXME, 限制输入字符数目，最大240，与条子放大时展示数目一致
			contentTextArea.setStyle(TextInput.style.maxChars,240);			
			contentTextArea.x = _elementStartX+titleLabel.textWidth+18;
			contentTextArea.y = contentLabel.y;
			this.addChild(contentTextArea);
			
			this.offsetSubmitBtn(-10,-10);
		}
		
		override protected function reset():void{
			super.reset();			
			
			typeComboBox.selectedIndex = 0;
			titleField.text = "";
			contentTextArea.text = "";
		}
		
		override protected function get submitLabel():String{
			return "张贴";
		}
		
	} //end of class
}