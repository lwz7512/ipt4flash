package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.cartogrammar.drawing.DashedLine;
	import com.pintu.api.ApiMethods;
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.common.FloatTip;
	import com.pintu.common.LazyImage;
	import com.pintu.common.RestrictLengthText;
	import com.pintu.common.SimpleLinkTxt;
	import com.pintu.common.SimpleText;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.events.PintuEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
	import com.pintu.vos.TPMessage;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaSprite;
	
	
	public class MessageItem extends CasaSprite{
		
		private var _msg:TPMessage;
		
		//头像
		private var avatar:LazyImage;		
		//用户名
		private var sender:SimpleText;
		//时间
		private var writeTime:SimpleText;
		//内容
		private var msgContent:SimpleText;
		//回复链接
		private var reply:SimpleLinkTxt;
		
		//关于条子标题
		private var refeNote:RestrictLengthText;
		
		
		private var drawStartX:Number = 4;
		private var drawStartY:Number = 4;

		private var textHGap:Number = 4;
		private var textVGap:Number = 26;
		private var rightMarging:Number = 4;

		
		private var _model:IPintu;
		
		private var note:Object;
		
		private var tip:FloatTip;
		
		
		public function MessageItem(msg:TPMessage){
			this._msg = msg;
			
			createContent();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, offStage);
		}
		
		public function set model(model:IPintu):void{
			_model = model;
		}
		
		private function createContent():void{
			avatar = new LazyImage(_msg.senderAvatarUrl);
			avatar.x = drawStartX;
			avatar.y = 2*drawStartY;
			avatar.maxSize = 64;
			this.addChild(avatar);
			
			var txtColor:uint = StyleParams.DEFAULT_TEXT_COLOR;
			var grayColor:uint = StyleParams.GRAY_TEXT_COLOR;
			
			sender = new SimpleText(_msg.senderName, txtColor, 14, true);
			sender.x = drawStartX+avatar.maxSize+textHGap;
			sender.y = drawStartY;
			sender.width = 200;
			this.addChild(sender);
			
			writeTime = new SimpleText(_msg.writeTime, grayColor);
			writeTime.x = InitParams.GALLERY_WIDTH-60;
			writeTime.y = drawStartY;
			this.addChild(writeTime);
			
			reply = new SimpleLinkTxt("回复", txtColor);
			reply.x = writeTime.x - 50;
			reply.y = writeTime.y;
			//这里要添加回复事件
			reply.addEventListener(MouseEvent.CLICK, notifyHomePageToWriteMsg);
			
			this.addChild(reply);
			
			//内容高度让它自动扩展，不写死了
			//消息内容可以选择拷贝
			//2012/01/11
			msgContent = new SimpleText(_msg.content, txtColor, 12, false, true, true);
			msgContent.x = sender.x;
			msgContent.y = sender.y+textVGap;
			msgContent.width = InitParams.GALLERY_WIDTH-sender.x-rightMarging;
			this.addChild(msgContent);
			
			//加一个引用文字，为条子的私信联系加条子标题
			if(_msg.msgType=="contact"){
				refeNote = new RestrictLengthText("...",txtColor,16,false,true);
				refeNote.width = 160;
				refeNote.x = InitParams.GALLERY_WIDTH-20;
				refeNote.y = msgContent.y+msgContent.height+textVGap;	
				refeNote.addEventListener(MouseEvent.MOUSE_OVER,showTooltip);
				refeNote.addEventListener(MouseEvent.MOUSE_OUT,hideTooltip);
				this.addChild(refeNote);
			}
			
			//底部虚线分割
			var lineStartX:Number = drawStartX;
			var lineStartY:Number = msgContent.y+msgContent.height+textVGap;
			if(refeNote){
				lineStartY += 20;
			}
			var bottomLine:DashedLine = new DashedLine(1,StyleParams.DEFAULT_BORDER_COLOR,[2,1,2,1]);
			bottomLine.moveTo(lineStartX, lineStartY);
			bottomLine.lineTo(InitParams.GALLERY_WIDTH-rightMarging, lineStartY);
			this.addChild(bottomLine);

		}
		
		private function showTooltip(evt:MouseEvent):void{
			if(!note) return;
			
			if(!tip){
				tip = new FloatTip(200);
			}
			tip.x = evt.stageX-160;
			tip.y = evt.stageY;
			tip.content = note["content"];
			this.stage.addChild(tip);
		}
		private function hideTooltip(evt:MouseEvent):void{
			if(tip && this.stage.contains(tip))
				this.stage.removeChild(tip);
		}
		
		private function onStage(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);
			PintuImpl(_model).addEventListener(ApiMethods.GETNOTEBYID, onNoteHandler);
			if(_msg.msgType=="contact"){
				_model.getNoteById(_msg.reference);
				Logger.debug("query note...");
			}
		}
		private function offStage(evt:Event):void{
			this.removeEventListener(evt.type, arguments.callee);
			PintuImpl(_model).removeEventListener(ApiMethods.GETNOTEBYID, onNoteHandler);
		}		
		
		private function onNoteHandler(evt:Event):void{
			if(evt is ResponseEvent){				
				var notesStr:String = ResponseEvent(evt).data;				
//				Logger.debug("note in msg: "+notesStr);							
				
				//创建条子
				note = JSON.decode(notesStr);
				refeNote.text = ">> "+note["title"];
				refeNote.x = InitParams.GALLERY_WIDTH-180;
			}
			if(evt is PTErrorEvent){
				Logger.error("Error in calling: "+ApiMethods.GETNOTEBYID);
			}
		}
		

		
		private function notifyHomePageToWriteMsg(evt:MouseEvent):void{
			var receiverId:String = _msg.sender;
			var postMsgEvt:PintuEvent = new PintuEvent(PintuEvent.POST_MSG,receiverId);
			postMsgEvt.extra = _msg.senderName;
			dispatchEvent(postMsgEvt);
		}
		
		
		
	} //end of class
}