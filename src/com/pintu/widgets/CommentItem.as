package com.pintu.widgets{
	import com.cartogrammar.drawing.DashedLine;
	import com.pintu.common.SimpleText;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.utils.PintuUtils;
	import com.pintu.vos.CmntData;
	
	import org.casalib.display.CasaSprite;
	
	
	public class CommentItem extends CasaSprite{
		
		private var _data:CmntData;
		
		private var authorTxt:SimpleText;
		private var putTimeTxt:SimpleText;
		private var contentTxt:SimpleText;
		
		
		public function CommentItem(data:CmntData){
			_data = data;			
			//靛青：也叫“蓝靛”。用蓼蓝叶泡水调和与石灰沉淀所得的蓝色染料。呈深蓝绿色
			var authorStr:String = PintuUtils.getShowUserName(data.author);
			authorTxt = new SimpleText(authorStr, 0x177cb0, 14, true);
			authorTxt.width = 200;
			authorTxt.x = 2;
			authorTxt.y = 0;
			this.addChild(authorTxt);
			
			var relativeTime:String;
			if(_data.publishTime){
				relativeTime = PintuUtils.getRelativeTimeFromNow(_data.publishTime);
			}else{
				relativeTime = "刚才";
			}			 
			//蓝灰色：一种近于灰略带蓝的深灰色。
			putTimeTxt = new SimpleText(relativeTime, 0xa1afc9, 12);
			putTimeTxt.x = InitParams.GALLERY_WIDTH-100;
			putTimeTxt.y = 2;
			this.addChild(putTimeTxt);
			
			//漆黑：非常黑的
			contentTxt = new SimpleText(_data.content, 0x161823);
			contentTxt.x = 2;
			contentTxt.y = 24;
			contentTxt.width = InitParams.GALLERY_WIDTH-4;
			this.addChild(contentTxt);					
			
			//底线
			var drawStartY:Number = contentTxt.y+contentTxt.textHeight+12;
			var bottomLine:DashedLine = new DashedLine(1,StyleParams.DEFAULT_BORDER_COLOR,[2,1,2,1]);
			bottomLine.moveTo(2, drawStartY);
			bottomLine.lineTo(InitParams.GALLERY_WIDTH-4, drawStartY);
			this.addChild(bottomLine);
			
			
			//画评论背景，在黑色背景上，半透明色，这样才能露出path线来
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 0.6);
			this.graphics.drawRect(0,0,InitParams.GALLERY_WIDTH-4, drawStartY+4);
			this.graphics.endFill();
		}
		
		
	} //end of class
}