package com.pintu.widgets
{
	
	import com.pintu.common.SimpleText;
	import com.pintu.config.*;
	import com.pintu.config.StyleParams;
	
	import flash.display.Sprite;
	
	public class FooterBar extends Sprite{
		public function FooterBar(){
			super();
			
			drawBackground();
			createTextMenus();
		}
		
		private function drawBackground():void{
			var footerX:Number = InitParams.startDrawingX();
			var footerY:Number =0;
			//如果舞台大小大于默认应用大小，就贴到底部绘制
			if(InitParams.isStretchHeight()){
				footerY = InitParams.appHeight - InitParams.FOOTER_HEIGHT;
			}else{
				footerY = InitParams.MINAPP_HEIGHT - InitParams.FOOTER_HEIGHT;
			}
			
			this.graphics.clear();
			this.graphics.beginFill(StyleParams.FOOTER_SOLID_GRAY);
			this.graphics.drawRect(footerX,footerY,InitParams.MINAPP_WIDTH,InitParams.FOOTER_HEIGHT);
			this.graphics.endFill();
		}
		
		//TODO, create text menu...
		private function createTextMenus():void{
			
			var copyRight:SimpleText = new SimpleText("北京远博畅享科技有限公司版权所有",StyleParams.HEADERBAR_BOTTOM_LIGHTGREEN);
			copyRight.width = 300;
			copyRight.x = InitParams.startDrawingX()+InitParams.MINAPP_WIDTH-200;
			if(InitParams.isStretchHeight()){
				copyRight.y = InitParams.appHeight - InitParams.FOOTER_HEIGHT+4;
			}else{
				copyRight.y = InitParams.MINAPP_HEIGHT - InitParams.FOOTER_HEIGHT+4;
			}
			this.addChild(copyRight);
			
		}
		
		
	}
}