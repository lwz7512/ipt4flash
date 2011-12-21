package com.pintu.window{
	
	import flash.display.Stage;
	
	
	public class AboutWin extends EditWinBase{
		
		
		public function AboutWin(ctxt:Stage, w:Number=320, h:Number=350){
			super(ctxt, w, h, "关于本产品");
			
			//不是提交数据窗口
			this.showProgressbar = false;
			
			_elementStartX += 10;
			_elementStartY += 10;
			
		}
		
		override protected function get submitLabel():String{
			return "知道了";
		}
		
	} //end of class
}