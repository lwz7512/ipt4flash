package com.pintu.window{
	
	import flash.display.Stage;
	
	
	public class FeedbackWin extends EditWinBase{
		
		public function FeedbackWin(ctxt:Stage, w:Number=320, h:Number=350){
			super(ctxt, w, h, "给我们反馈意见");
			
			//不是提交数据窗口
			this.showProgressbar = false;
			
		}
		
	} //end of class
}