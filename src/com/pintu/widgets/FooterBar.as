package com.pintu.widgets
{
	
	import com.pintu.common.SimpleLinkTxt;
	import com.pintu.common.SimpleText;
	import com.pintu.config.*;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.graphics.RadialGradient;
	
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
		
		
		private function createTextMenus():void{
			var vOffset:Number = 2;
			//	版权				
			var copyRightStr:String = PublishParams.COPYRIGHT;
			var copyRightST:SimpleText = new SimpleLinkTxt(copyRightStr,StyleParams.HEADERBAR_BOTTOM_LIGHTGREEN);
			copyRightST.width = 500;
			copyRightST.x = InitParams.startDrawingX()+10;
			if(InitParams.isStretchHeight()){
				copyRightST.y = InitParams.appHeight - InitParams.FOOTER_HEIGHT+vOffset;
			}else{
				copyRightST.y = InitParams.MINAPP_HEIGHT - InitParams.FOOTER_HEIGHT+vOffset;
			}
			copyRightST.addEventListener(MouseEvent.CLICK,openCompanyWin);
			this.addChild(copyRightST);
			
			var rightSide:Number = InitParams.startDrawingX()+InitParams.MINAPP_WIDTH;
			
			//联系我们
			var contactUs:SimpleText = new SimpleText(PublishParams.CONTACT_US+PublishParams.CONTACT_MAIL,
				StyleParams.HEADERBAR_BOTTOM_LIGHTGREEN,12,false,false,true);
			contactUs.width = 150;
			contactUs.x = rightSide-250;
			contactUs.y = copyRightST.y;
			this.addChild(contactUs);
			
			//官方微博
			var weibo:SimpleLinkTxt = new SimpleLinkTxt(PublishParams.SINA_WEIBO, StyleParams.HEADERBAR_BOTTOM_LIGHTGREEN);
			weibo.x = rightSide-60;
			weibo.y = copyRightST.y;
			weibo.addEventListener(MouseEvent.CLICK, openWeiboWin);
			this.addChild(weibo);
			
			
		}
		
		private function openWeiboWin(evt:MouseEvent):void{
			var address:URLRequest = new URLRequest(PublishParams.WEIBO_URL);
			navigateToURL(address, "_blank");
		}
		
		private function openCompanyWin(evt:MouseEvent):void{
			var address:URLRequest = new URLRequest(PublishParams.COMPANY_URL);
			navigateToURL(address, "_blank");
		}
	}
}