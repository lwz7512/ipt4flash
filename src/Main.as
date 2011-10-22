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
	import com.pintu.controller.VisualFactory;
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
		private var factory:VisualFactory;
		
		private var header:HeaderBar;
		private var footer:FooterBar;
		private var currentModule:Sprite;
		
		public function Main(){
			super();
			addEventListener(Event.ADDED_TO_STAGE, buildApp);
		}
		
		protected function buildApp(event:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, buildApp);
			//init stage size
			InitParams.appWidth = stage.width;
			InitParams.appHeight = stage.height;			
			
			buildHeaderMenu(isLogged);			
			buildFooterContent();
			
			model = new PintuImpl();
			factory = new VisualFactory(this,model);
			navigator = new GlobalNavigator(this,factory);					
			
			checkLogonStatus();	
			//display home page
			if(isLogged){
				navigator.switchTo(GlobalNavigator.HOMPAGE);				
			}else{
				navigator.switchTo(GlobalNavigator.UNLOGGED);		
			}
			
		}
		
		
		private function checkLogonStatus():void{
			//TODO, is logged in?
			
			InitParams.isLogged = isLogged;
		}
		
		
		private function buildHeaderMenu(isLogged:Boolean):void{
			header = new HeaderBar(isLogged);
			this.addChild(header);
			this.addEventListener(PintuEvent.NAVIGATE, navigateTo);
		}
		
		private function navigateTo(event:PintuEvent):void{
			navigator.switchTo(event.data);
		}
		
		private function buildFooterContent():void{
			footer = new FooterBar();
			this.addChild(footer);
		}
		
	
		
	} //end of class
}
