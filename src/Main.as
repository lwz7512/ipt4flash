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
		
		private var _isLogged:Boolean = false;
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
			//如果舞台大小为0
			if(!stage.stageWidth) {
				Logger.warn("Stage is unavailable, stop to build app!");
				return;
			}	
			
			//listen navigate event
			//may be from login to homepage...
			this.addEventListener(PintuEvent.NAVIGATE, navigateTo);
			
			//init stage size
			InitParams.appWidth = this.stage.stageWidth;
			InitParams.appHeight = this.stage.stageHeight;	
			
			//初始化客户端缓存对象
			GlobalController.initClientStorage(this);
			//这时该知道是否已经登录过了没
			_isLogged = GlobalController.isLogged;
			
			var currentUser:String = GlobalController.loggedUser;
			model = new PintuImpl(currentUser);
			factory = new ModuleFactory(this,model);
			navigator = new GlobalNavigator(this,factory);					
			
			//全局模块固定不变
			buildHeaderMenu(_isLogged);			
			buildFooterContent();			
								
			//display home page
			if(_isLogged){
				navigator.switchTo(GlobalNavigator.HOMPAGE);				
			}else{
				navigator.switchTo(GlobalNavigator.UNLOGGED);		
			}	
					
		}		
		
		//运行时切换模块状态，比如从未登录到登陆
		private function navigateTo(event:PintuEvent):void{
//			Logger.debug("To navigating ... "+event.data);			
			
			//进入登录状态
			if(event.data==GlobalNavigator.HOMPAGE){
				header.showExit();
			}
			//进入未登录状态
			if(event.data==GlobalNavigator.UNLOGGED){
				header.hideExit();
				GlobalController.clearUser();
			}
			
			//开始切换状态
			navigator.switchTo(event.data);

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
