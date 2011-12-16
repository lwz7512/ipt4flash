package com.pintu.common{
	import org.casalib.display.CasaSprite;
	
	
	public class CircleNumText extends CasaSprite{
		
		private var _txt:SimpleText;
		
		public function CircleNumText(text:String){
			//不遮挡文字下面的组件点击
			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			_txt = new SimpleText(text, 0xFFFFFF, 14, true, false);
			this.addChild(_txt);
			
			this.graphics.lineStyle(1, 0x999999);
			this.graphics.beginFill(0x40de5a);
			this.graphics.drawCircle(6,11,9);
			this.graphics.endFill();
		}
		
	} //end of class
}