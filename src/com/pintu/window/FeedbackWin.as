package com.pintu.window{
	
	import com.pintu.api.*;
	import com.pintu.common.DisableTxtInput;
	import com.pintu.common.SimpleText;
	import com.pintu.common.TextArea;
	import com.pintu.config.StyleParams;
	import com.pintu.controller.GlobalController;
	import com.pintu.utils.Logger;
	import com.sibirjak.asdpc.button.ButtonEvent;
	import com.sibirjak.asdpc.textfield.TextInput;
	
	import flash.display.Stage;
	import flash.events.Event;
	
	import org.casalib.display.CasaShape;
	
	/**
	 * 应用的全局窗口，不需要实现销毁方法
	 * 2011/12/22
	 */ 
	public class FeedbackWin extends EditWinBase{
		
		private var receiverInpt:DisableTxtInput;
		private var msgContent:TextArea;
		
		private var _receiverId:String = GlobalController.PRODUCT_MANAGER_ID;
		private var _receiverName:String = GlobalController.PRODUCT_MANAGER_NAME;
		
		public function FeedbackWin(ctxt:Stage, w:Number=300, h:Number=350){
			super(ctxt, w, h, "给我们反馈意见");
			
			//不是提交数据窗口
			this.showProgressbar = false;
						
			
			createFormElements();
		}
		
		//对克隆的模型进行事件监听
		override public function set sourceModel(_model:IPintu):void{
			super.sourceModel = _model;
			
			this.cloneModel.addEventListener(ApiMethods.SENDMSG, sendMsgHandler);			
		}
		
		private function sendMsgHandler(evt:Event):void{
			closeMe(null);
			
			this.hintToUser("感谢您的反馈，我们会及时处理！");
		}
		
		override protected function submit(evt:ButtonEvent):void{	
			//先校验内容输入
			if(msgContent.text.length==0){
				updateSuggest("消息内容不能为空");
				return;
			}
			super.submit(evt);		
			
			//调用模型方法提交
			Logger.debug("to send msg...");
			
			if(this.cloneModel)
				this.cloneModel.postMsg(_receiverId,msgContent.text);
			
		}

		//关闭时清理输入框，恢复初始值
		override protected function reset():void{
			super.reset();			
			
			msgContent.text = "";
		}
		
		private function createFormElements():void{
			
			var margingTop:Number = 4;
			var textHGap:Number = 10;
			var textVGap:Number = 10;
			var inputWidth:Number = 234;
			
			var receiverLbl:SimpleText = new SimpleText("收信人");
			receiverLbl.x = _elementStartX;
			receiverLbl.y = _elementStartY+margingTop;	
			this.addChild(receiverLbl);
			
			//给产品经理发
			receiverInpt = new DisableTxtInput();	
			receiverInpt.defaultText = _receiverName;
			receiverInpt.setSize(inputWidth,28);
			receiverInpt.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			receiverInpt.setStyle(TextInput.style.size,12);
			receiverInpt.setStyle(TextInput.style.borderDarkColor,StyleParams.DEFAULT_BORDER_COLOR);			
			receiverInpt.setStyle(TextInput.style.maxChars,12);			
			receiverInpt.x = _elementStartX+receiverLbl.textWidth+textHGap;
			receiverInpt.y = _elementStartY;
			this.addChild(receiverInpt);
			
			var contentLbl:SimpleText = new SimpleText("内容");
			contentLbl.x = _elementStartX+textHGap;
			contentLbl.y = _elementStartY+margingTop+receiverInpt.height+textVGap;	
			this.addChild(contentLbl);
			
			msgContent = new TextArea();
			msgContent.isMust = true;
			msgContent.defaultText = "反馈内容";
			msgContent.setSize(inputWidth,230);
			msgContent.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			msgContent.setStyle(TextInput.style.size,12);
			msgContent.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);			
			msgContent.setStyle(TextInput.style.maxChars,140);			
			msgContent.x = receiverInpt.x;
			msgContent.y = contentLbl.y;
			this.addChild(msgContent);
		}
		
		
		
	} //end of class
}