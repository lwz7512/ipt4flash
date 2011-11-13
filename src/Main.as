/**
 * ipintu flash client
 * by lwz7512
 * on 2011/10/14
 */ 
package{
	
	import com.pintu.api.*;
	import com.pintu.config.InitParams;
	import com.pintu.controller.*;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	import com.pintu.widgets.FooterBar;
	import com.pintu.widgets.HeaderBar;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import org.libspark.ui.SWFWheel;
		
	public class Main extends Sprite{
		
		
		private var delayIntervalID:int;
		
		private var model:IPintu;
		
		private var isLogged:Boolean = false;
		private var navigator:GlobalNavigator;
		private var factory:ModuleFactory;
		
		private var header:HeaderBar;
		private var footer:FooterBar;
		private var currentModule:Sprite;
		
//		[Frame(factoryClass="Preloader")]
		public function Main(){
			super();
			//不允许图形缩放
			this.stage.scaleMode =StageScaleMode.NO_SCALE;
			//从左上角开始绘制
			this.stage.align = StageAlign.TOP_LEFT;
			//隐藏所有默认右键菜单
			this.stage.showDefaultContextMenu = false;
			//阻止浏览器滚动条
			SWFWheel.initialize(stage);
			SWFWheel.browserScroll = false;
			//舞台准备好后创建应用
			addEventListener(Event.ADDED_TO_STAGE, buildApp);	
		}
		
		
		protected function buildApp(event:Event):void{			
			this.removeEventListener(Event.ADDED_TO_STAGE, buildApp);
			//listen navigate event
			//may be from login to homepage...
			this.addEventListener(PintuEvent.NAVIGATE, navigateTo);
			
			//init stage size
			InitParams.appWidth = this.stage.stageWidth;
			InitParams.appHeight = this.stage.stageHeight;	
			
			if(!checkStageValidity()) {
				Logger.warn("Stage is unavailable, stop to build app!");
				return;
			}
			//检查登录状态			
			checkLogonStatus();	
			
			model = new PintuImpl();
			factory = new ModuleFactory(this,model);
			navigator = new GlobalNavigator(this,factory);					
			
			//全局模块固定不变
			buildHeaderMenu(isLogged);			
			buildFooterContent();
			
			//display home page
			if(isLogged){
				navigator.switchTo(GlobalNavigator.HOMPAGE);				
			}else{
				navigator.switchTo(GlobalNavigator.UNLOGGED);		
			}	
			
		
		}
		
		private function checkStageValidity():Boolean{
			return InitParams.appWidth>0?true:false;
		}
		
		private function navigateTo(event:PintuEvent):void{
			navigator.switchTo(event.data);
		}		
		
		private function checkLogonStatus():void{
			//TODO, is logged in?
			
			GlobalController.isLogged = isLogged;
		}
		
		
		private function buildHeaderMenu(isLogged:Boolean):void{
			header = new HeaderBar(isLogged);
			this.addChild(header);			
		}
		
		
		private function buildFooterContent():void{
			footer = new FooterBar();
			this.addChild(footer);
		}
		

		
	} //end of class
}
