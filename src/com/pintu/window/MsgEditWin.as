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
	
	/**
	 * 消息撰写窗口，需要得到模型来发送
	 */ 
	public class MsgEditWin extends EditWinBase{
		
		private var receiverInpt:DisableTxtInput;
		private var msgContent:TextArea;
		
		private var _receiverId:String = GlobalController.KEFU_ID;
		private var _receiverName:String = GlobalController.KEFU_NAME;
		
		private var _refecence:String = "";
		
		
		public function MsgEditWin(ctxt:Stage, w:Number=320, h:Number=350){
			super(ctxt, w, h, "编辑消息");
			
			
			createFormElements();
			
			//延迟初始化要显示的接收人
			//这样就可以从set方法中接收数据了
			this.addEventListener(Event.ADDED_TO_STAGE, function():void{
				receiverInpt.defaultText = _receiverName;
			});
		}
		/**
		 * 接收人ID
		 */ 
		public function set receiverId(userId:String):void{
			if(userId) _receiverId = userId;
		}
		/**
		 * 接收人昵称
		 */ 
		public function set receiverName(userName:String):void{
			if(userName) _receiverName = userName;
		}
		/**
		 * 引用内容ID，比如条子、图片id
		 */ 
		public function set reference(ref:String):void{
			_refecence = ref;
		}
		
		//对克隆的模型进行事件监听
		override public function set sourceModel(_model:IPintu):void{
			super.sourceModel = _model;
			
			this.cloneModel.addEventListener(ApiMethods.SENDMSG, sendMsgHandler);			
		}
		
		//点击提交触发
		override protected function submit(evt:ButtonEvent):void{	
			//先校验内容输入
			if(msgContent.text.length==0){
				updateSuggest("消息内容不能为空");
				return;
			}			
			super.submit(evt);		
			
			//调用模型方法提交
			Logger.debug("to send msg...");
			this.cloneModel.postMsg(_receiverId,msgContent.text,_refecence);
			
		}
		//关闭时清理输入框，恢复初始值
		override protected function reset():void{
			super.reset();
			
			_receiverId = GlobalController.KEFU_ID;
			_receiverName = GlobalController.KEFU_NAME;
			msgContent.text = "";
		}		
		
		//移除克隆模型的事件监听，并销毁克隆模型
		//整个HomePage模块被移除时，才调用这个方法
		override public function destroy():void{
			super.destroy();
			//如果没用到模型，就此打住
			if(!cloneModel) return;
			
			//REMOVE MODEL EVENT LISTENER...
			this.cloneModel.removeEventListener(ApiMethods.SENDMSG, sendMsgHandler);
			
			cloneModel.destory();			
		}
		
		private function sendMsgHandler(evt:Event):void{
			closeMe(null);
			
			this.hintToUser("消息发送成功！");
		}
		
		private function createFormElements():void{						
			
			var margingTop:Number = 4;
			var textHGap:Number = 10;
			var textVGap:Number = 10;
			var inputWidth:Number = 254;
				
			var receiverLbl:SimpleText = new SimpleText("收信人");
			receiverLbl.x = _elementStartX;
			receiverLbl.y = _elementStartY+margingTop;	
			this.addChild(receiverLbl);
			
			//这个版本先默认只能给客服发
			receiverInpt = new DisableTxtInput();						
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
			msgContent.defaultText = "消息内容";
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