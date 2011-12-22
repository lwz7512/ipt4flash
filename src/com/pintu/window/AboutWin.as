package com.pintu.window{
	
	import com.pintu.common.SimpleImage;
	import com.pintu.common.SimpleText;
	import com.pintu.config.PublishParams;
	import com.pintu.config.StyleParams;
	
	import flash.display.Stage;
	
	import org.casalib.display.CasaShape;
	
	/**
	 * 应用的全局窗口，不需要实现销毁方法
	 * 2011/12/22
	 */ 
	public class AboutWin extends EditWinBase{
		
		private var logoPath:String = "assets/logo.png";
		
		public function AboutWin(ctxt:Stage, w:Number=300, h:Number=350){
			super(ctxt, w, h, "关于本产品");
			
			//不是提交数据窗口
			this.showProgressbar = false;
			
			createFrame();
			
			createConent();
			
		}
		
		private function createFrame():void{
			var marging:Number = 4;
			var frame:CasaShape = new CasaShape();		
			frame.x = marging;
			frame.y = _elementStartY;
			frame.graphics.lineStyle(1, StyleParams.DARKER_BORDER_COLOR);
			frame.graphics.drawRect(marging,marging,width-16,height-80);
			this.addChild(frame);
		}
		
		private function createConent():void{
			
			_elementStartX += 10;
			_elementStartY += 10;	
			
			var itemVGap:Number = 10;
			var logoSize:Number = 72;
			
			var logo:SimpleImage = new SimpleImage(logoPath);
			logo.x = _elementStartX+this.width/2-36;
			logo.y = _elementStartY;
			this.addChild(logo);
			
			var productName:SimpleText = new SimpleText(PublishParams.PRODUCT_NAME+PublishParams.VERSION);
			productName.x = logo.x;
			productName.y = logo.y+logoSize+itemVGap;
			this.addChild(productName);
			
			var releaseTime:SimpleText = new SimpleText("发布时间："+PublishParams.RELEASE_TIME);
			releaseTime.width = 200;
			releaseTime.x = (this.width-releaseTime.textWidth)/2;
			releaseTime.y = productName.y+itemVGap+productName.textHeight;
			this.addChild(releaseTime);
			
			var productIntro:SimpleText = new SimpleText(PublishParams.PRODUCT_INTRO);
			productIntro.width = 260;
			productIntro.height = 100;			
			productIntro.x = _elementStartX+6;
			productIntro.y = releaseTime.y+40;
			this.addChild(productIntro);
			
			var producer:SimpleText = new SimpleText(PublishParams.PRODUCER);
			producer.width = 200;
			producer.x = (this.width-producer.textWidth)/2;
			producer.y = this.height-70;
			this.addChild(producer);
		}
		
		override protected function get submitLabel():String{
			return "知道了";
		}
		
	} //end of class
}