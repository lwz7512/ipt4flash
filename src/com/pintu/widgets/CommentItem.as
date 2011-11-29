package com.pintu.widgets{
	import com.cartogrammar.drawing.DashedLine;
	import com.pintu.common.SimpleText;
	import com.pintu.config.InitParams;
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
			authorTxt = new SimpleText(getShowUserName(), 0x177cb0, 14, true);
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
			var bottomLine:DashedLine = new DashedLine(1,0xa1afc9,[2,1,2,1]);
			bottomLine.moveTo(2, drawStartY);
			bottomLine.lineTo(InitParams.GALLERY_WIDTH-4, drawStartY);
			this.addChild(bottomLine);
			
		}
		
		private function getShowUserName():String{
			var account:String = _data.author;
			if(account.indexOf("@")>-1){
				return account.split("@")[0];
			}
			return account;
		}
		
	} //end of class
}