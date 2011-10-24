package com.pintu.widgets
{
	
	import com.pintu.config.InitParams;
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
			var footerY:Number = InitParams.HEADERFOOTER_HEIGHT												
												+InitParams.TOP_BOTTOM_GAP
												+InitParams.MAINMENUBAR_HEIGHT
												+InitParams.DEFAULT_GAP
												+InitParams.LEFTCOLUMN_HEIGHT
												+InitParams.DEFAULT_GAP;
			//如果舞台大小大于默认应用大小，就贴到底部绘制
			var isSnapBottom:Boolean = InitParams.MINAPP_HEIGHT<InitParams.appHeight?false:true;
			if(!isSnapBottom){
				footerY = InitParams.appHeight - InitParams.HEADERFOOTER_HEIGHT;
			}
			
			this.graphics.clear();
			this.graphics.beginFill(StyleParams.FOOTER_SOLID_GRAY);
			this.graphics.drawRect(footerX,footerY,InitParams.MINAPP_WIDTH,InitParams.HEADERFOOTER_HEIGHT);
			this.graphics.endFill();
		}
		
		//TODO, create text menu...
		private function createTextMenus():void{
			
		}
		
		
	}
}