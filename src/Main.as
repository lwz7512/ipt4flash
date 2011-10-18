/**
 * ipintu flash client
 * by lwz7512
 * on 2011/10/14
 */ 
package{
	
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.config.InitParams;
	import com.pintu.controller.GlobalNavigator;
	import com.pintu.events.PintuEvent;
	import com.pintu.widgets.FooterBar;
	import com.pintu.widgets.HeaderBar;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	public class Main extends Sprite{
		
		private var model:IPintu;
		
		private var isLogged:Boolean = false;
		private var navigator:GlobalNavigator;
		
		private var header:HeaderBar;
		private var footer:FooterBar;
		private var currentModule:Sprite;
		
		public function Main(){
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//init stage size
			InitParams.appWidth = stage.width;
			InitParams.appHeight = stage.height;			
			
			//TODO, is logged in?
			checkLogonStatus();	
			
			//TODO, construct skelecton
			buildHeaderMenu(isLogged);			
			buildFooterContent();
			
			model = new PintuImpl();
			navigator = new GlobalNavigator(this);		
			//display home page
			if(isLogged){
				navigator.switchTo(GlobalNavigator.HOMPAGE,model);				
			}else{
				navigator.switchTo(GlobalNavigator.UNLOGGED,model);		
			}
			
		}
		
		
		private function checkLogonStatus():void{
			
			InitParams.isLogged = isLogged;
		}
		
		
		private function buildHeaderMenu(isLogged:Boolean):void{
			header = new HeaderBar(isLogged);
			this.addChild(header);
			this.addEventListener(PintuEvent.NAVIGATE, navigateTo);
		}
		
		private function navigateTo(event:PintuEvent):void{
			navigator.switchTo(event.data,model);
		}
		
		private function buildFooterContent():void{
			footer = new FooterBar();
			this.addChild(footer);
		}
		
	
		
	} //end of class
}
