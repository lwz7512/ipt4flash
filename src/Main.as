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
	import com.pintu.modules.IDestroyableModule;
	import com.pintu.modules.IMenuClickResponder;
	import com.pintu.utils.Logger;
	import com.pintu.widgets.FooterBar;
	import com.pintu.widgets.HeaderBar;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	import org.casalib.util.ColorUtil;
	import org.libspark.ui.SWFWheel;
		
	public class Main extends Sprite{
		
		
		private var delayIntervalID:int;
		
		private var model:IPintu;
				
		private var navigator:GlobalNavigator;
		private var factory:ModuleFactory;
		
		private var header:HeaderBar;
		private var footer:FooterBar;
		private var currentModule:Sprite;
		
		private var tileImagePath:String = "assets/paper103.png";
		
		private var _currentModule:IMenuClickResponder;
		
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
		
		/**
		 * 初始化系统参数，构建系统界面，并监听导航事件
		 */ 
		protected function buildApp(event:Event):void{			
			this.removeEventListener(Event.ADDED_TO_STAGE, buildApp);
			//如果舞台大小为0
			if(!stage.stageWidth) {
				Logger.warn("Stage is unavailable, stop to build app!");
				return;
			}	
			
			//主应用只监听来自headerbar退出和loginBlock的登录引起的导航事件
			//其他系统事件一概不予处理，放在各自的模块中处理
			//2011/11/26
			this.addEventListener(PintuEvent.NAVIGATE, navigateTo);
			
			//init stage size
			InitParams.appWidth = this.stage.stageWidth;
			InitParams.appHeight = this.stage.stageHeight;	
			
			//初始化客户端缓存对象
			GlobalController.initClientStorage(this);
			//这时该知道是否已经登录过了没
			var isLogged:Boolean = GlobalController.isLogged;
			
			var currentUser:String = GlobalController.loggedUser;
			model = new PintuImpl(currentUser);
			factory = new ModuleFactory(this,model);
			navigator = new GlobalNavigator(this,factory);	
			
			//画纹理背景
			var usePaperBG:Boolean = GlobalController.usePaperTile;
			if(usePaperBG) drawPaperBackground();
			
			//全局模块固定不变
			buildHeaderMenu(isLogged);			
			buildFooterContent();			
								
			//display home page
			if(isLogged){
				_currentModule = navigator.switchTo(GlobalNavigator.HOMPAGE);				
			}else{
				_currentModule = navigator.switchTo(GlobalNavigator.UNLOGGED);		
			}				
			//主菜单栏再顶部，好让菜单浮在画廊上面
			moveHeaderBarTop();
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
			
			//开始切换模块
			_currentModule = navigator.switchTo(event.data);

			moveHeaderBarTop();
		}		
		
		
		private function buildHeaderMenu(isLogged:Boolean):void{
			header = new HeaderBar(isLogged);
			header.addEventListener(PintuEvent.BROWSE_CHANGED, browseTypeChanged);
			this.addChild(header);			
		}
		
		private function browseTypeChanged(evt:PintuEvent):void{
			_currentModule.menuHandler(PintuEvent.BROWSE_CHANGED, evt.data);
		}
		
		
		private function buildFooterContent():void{
			footer = new FooterBar();
			this.addChild(footer);
		}
		
		/**
		 * 主菜单置顶，好让它盖住下面的子菜单，这样子菜单可以在画廊上面显示
		 */ 
		private function moveHeaderBarTop():void{
			this.setChildIndex(header, this.numChildren-1);
		}
		
		private function drawPaperBackground():void{
			var canvas:Sprite = this;
			var imgloader:ImageLoad = new ImageLoad(tileImagePath);
			imgloader.addEventListener(LoadEvent.COMPLETE,function():void{
				var bmdata:BitmapData = imgloader.contentAsBitmapData;
				canvas.graphics.beginBitmapFill(bmdata);
				canvas.graphics.drawRect(0,0,InitParams.appWidth,InitParams.appHeight);
				canvas.graphics.endFill();
			});
			imgloader.start();
		}
		
		
		
	} //end of class
}
