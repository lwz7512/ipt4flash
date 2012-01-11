package com.pintu.widgets{
	import com.cartogrammar.drawing.DashedLine;
	import com.pintu.common.SimpleImage;
	import com.pintu.common.SimpleLinkTxt;
	import com.pintu.common.SimpleText;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PintuEvent;
	import com.pintu.vos.TPMessage;
	
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaSprite;
	
	
	public class MessageItem extends CasaSprite{
		
		private var _msg:TPMessage;
		
		//头像
		private var avatar:SimpleImage;		
		//用户名
		private var sender:SimpleText;
		//时间
		private var writeTime:SimpleText;
		//内容
		private var msgContent:SimpleText;
		//回复链接
		private var reply:SimpleLinkTxt;
		
		private var drawStartX:Number = 4;
		private var drawStartY:Number = 4;
		
		public function MessageItem(msg:TPMessage){
			this._msg = msg;
			
			var textHGap:Number = 4;
			var textVGap:Number = 26;
			var rightMarging:Number = 4;
			
			avatar = new SimpleImage(_msg.senderAvatarUrl);
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
			
			//底部虚线分割
			var lineStartX:Number = drawStartX;
			var lineStartY:Number = msgContent.y+msgContent.height+textVGap;
			var bottomLine:DashedLine = new DashedLine(1,StyleParams.DEFAULT_BORDER_COLOR,[2,1,2,1]);
			bottomLine.moveTo(lineStartX, lineStartY);
			bottomLine.lineTo(InitParams.GALLERY_WIDTH-rightMarging, lineStartY);
			this.addChild(bottomLine);
			
		}
		
		private function notifyHomePageToWriteMsg(evt:MouseEvent):void{
			var receiverId:String = _msg.sender;
			var postMsgEvt:PintuEvent = new PintuEvent(PintuEvent.POST_MSG,receiverId);
			postMsgEvt.extra = _msg.senderName;
			dispatchEvent(postMsgEvt);
		}
		
	} //end of class
}