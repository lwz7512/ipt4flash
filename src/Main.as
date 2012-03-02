/**
 * ipintu flash client
 * by lwz7512
 * on 2011/10/14
 */ 
package{
	
	import com.greensock.TweenLite;
	import com.pintu.api.*;
	import com.pintu.common.Toast;
	import com.pintu.config.InitParams;
	import com.pintu.config.PopWinNames;
	import com.pintu.controller.*;
	import com.pintu.events.PintuEvent;
	import com.pintu.modules.IMenuClickResponder;
	import com.pintu.utils.Logger;
	import com.pintu.widgets.FooterBar;
	import com.pintu.widgets.HeaderBar;
	import com.pintu.window.AboutWin;
	import com.pintu.window.EditWinBase;
	import com.pintu.window.FeedbackWin;
	import com.pintu.window.SettingWin;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import org.casalib.events.LoadEvent;
	import org.casalib.load.ImageLoad;
	import org.libspark.ui.SWFWheel;
	
	//FIXME, 进度条应该加在这里
	//2011/12/31
	//lwz7512
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite{
						
		/**
		 * 整个应用只有一个模型，即服务实现的一个实例
		 * 各个widget都是用的这同一个实例
		 * 每个widget使用模型时，添加服务事件的监听
		 * 均在视图Event.ADDED_TO_STAGE进行添加
		 * 在视图Event.REMOVED_FROM_STAGE进行移除
		 */ 
		private var model:IPintu;
		/**
		 * 当前模块，比如HomePage
		 * 都要实现这个接口，以对菜单动作进行响应
		 */ 
		private var _currentModule:IMenuClickResponder;
				
		private var navigator:GlobalNavigator;
		
		private var header:HeaderBar;
		private var footer:FooterBar;
		private var currentModule:Sprite;
		
		private var tileImagePath:String = "assets/paper103.png";		
		
		private var settingWin:SettingWin;
		private var aboutWin:AboutWin;
		private var feedbackWin:FeedbackWin;
		
					
		public function Main(){
			super();			
			
			//舞台准备好后创建应用
			this.addEventListener(Event.ADDED_TO_STAGE, buildApp);						
		}
		
		private function setupStage():void{
			//不允许图形缩放
			this.stage.scaleMode =StageScaleMode.NO_SCALE;
			//从左上角开始绘制
			this.stage.align = StageAlign.TOP_LEFT;
			//隐藏所有默认右键菜单
			this.stage.showDefaultContextMenu = false;
			//阻止浏览器滚动条
			SWFWheel.initialize(stage);
			SWFWheel.browserScroll = false;		
		}
		
		/**
		 * 初始化系统参数，构建系统界面，并监听导航事件
		 */ 
		protected function buildApp(event:Event):void{			
			this.removeEventListener(Event.ADDED_TO_STAGE, buildApp);
			
			setupStage();				
			
			//如果舞台大小为0
			if(!stage.stageWidth) {
				Logger.warn("Stage is unavailable, stop to build app!");
				return;
			}
			
			//移除html页面中的div logo内容
			//这个内容是为chrome生成缩略图准备的
			//生产模式下使用
			//2012/12/15
			if(ExternalInterface.available){
				ExternalInterface.call("removeLogo");
				Logger.debug("logo div removed!");
			}			
			
			//主应用只监听来自headerbar退出和loginBlock的登录引起的导航事件
			//其他系统事件一概不予处理，放在各自的模块中处理
			//2011/11/26
			this.addEventListener(PintuEvent.NAVIGATE, navigateTo);
			//监听系统事件：弹出提示
			this.addEventListener(PintuEvent.HINT_USER, hintTextHandler);		
			
			//init stage size
			InitParams.appWidth = this.stage.stageWidth;
			InitParams.appHeight = this.stage.stageHeight;	
			
			//初始化客户端缓存对象
			GlobalController.initClientStorage(this);
			//这时该知道是否已经登录过了没
			var isLogged:Boolean = GlobalController.isLogged;
			//得到缓存的用户
			var currentUser:String = GlobalController.loggedUser;
			
			//初始化模型
			model = new PintuImpl(currentUser);
			//后台错误提示
			PintuImpl(model).addEventListener(PintuEvent.HINT_USER, hintTextHandler);			
			
			//全局模块固定不变
			buildHeaderBar(isLogged);			
			buildFooterContent();			

			//初始化导航器
			navigator = new GlobalNavigator(this,model);
			//展示首页
			if(isLogged){
				_currentModule = navigator.switchTo(GlobalNavigator.HOMPAGE);				
			}else{
				_currentModule = navigator.switchTo(GlobalNavigator.UNLOGGED);		
			}			
			
			//主菜单栏再顶部，好让菜单浮在画廊上面
			moveHeaderBarTop();			
			
			//判断运行状态
			var runningMode:Boolean = GlobalController.isDebug;
			if(runningMode){
				hintToUser("Warning, I'm in DEBUG mode!");
			}
			
			//app construction completed...
			Logger.debug("... app construction completed...");
		}
		
		private function hintToUser(info:String):void{
			var hint:PintuEvent = new PintuEvent(PintuEvent.HINT_USER, info);
			this.dispatchEvent(hint);
		}
		
		//运行时切换模块状态，比如从未登录到登陆
		private function navigateTo(event:PintuEvent):void{
			
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
		
		private function hintTextHandler(evt:PintuEvent):void{
			var hint:String = evt.data;
			var drawStartX:Number = InitParams.startDrawingX();				
			var drawStartY:Number = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			//默认高度，也是最小高度
			var displayAreaHeight:Number = InitParams.CALLERY_HEIGHT;
			if(InitParams.isStretchHeight()){
				//拉伸高度
				displayAreaHeight = InitParams.appHeight
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.FOOTER_HEIGHT;
			}
			var displayAreaWidth:Number = InitParams.GALLERY_WIDTH;
			var middleX:Number = drawStartX+displayAreaWidth/2;
			var middleY:Number = drawStartY+displayAreaHeight/2;
			Toast.getInstance(this).show(hint,middleX,middleY);
		}
			
		private function buildHeaderBar(isLogged:Boolean):void{
			header = new HeaderBar(isLogged, model);
			header.addEventListener(PintuEvent.BROWSE_CHANGED, browseTypeChanged);
			header.addEventListener(PintuEvent.SEARCH_BYTAGS, searchHandler);
			header.addEventListener(PintuEvent.OPEN_WIN, popUpWinHandler);
			
			this.addChild(header);			
		}
		
		private function browseTypeChanged(evt:PintuEvent):void{
			_currentModule.menuHandler(PintuEvent.BROWSE_CHANGED, evt.data);
		}
		private function searchHandler(evt:PintuEvent):void{
			var keyWord:String = evt.data;
			_currentModule.searchable(keyWord);
		}		
		private function popUpWinHandler(evt:PintuEvent):void{
			var winName:String = evt.data;
			
			var currentWin:EditWinBase;
			
			switch(winName){
				case PopWinNames.SETTING_WIN:
					if(!settingWin) settingWin = new SettingWin(this.stage);
					currentWin = settingWin;
					break;
				
				case PopWinNames.ABOUT_WIN:
					if(!aboutWin) aboutWin = new AboutWin(this.stage);
					currentWin = aboutWin;
					break;
				
				case PopWinNames.FEEDBACK_WIN:
					if(!feedbackWin) {
						feedbackWin = new FeedbackWin(this.stage);
						feedbackWin.sourceModel = model;
						feedbackWin.addEventListener(PintuEvent.HINT_USER, hintTextHandler);
					}
					currentWin = feedbackWin;
					break;				
			}
			//打开窗口
			dropCenterWindow(currentWin);
			
		}
		

		
		/**
		 * 向下滑出窗口
		 */ 
		private function dropCenterWindow(win:EditWinBase):void{
			win.x = (InitParams.appWidth-win.width)/2;
			//屏幕上方
			win.y = -win.height;
			
			//FIXME, 注意：必须添加在顶级
			this.stage.addChild(win);
			
			var endY:Number;
			if(InitParams.isStretchHeight()){
				endY = (InitParams.appHeight-win.height)/2;
			}else{
				endY = (InitParams.MINAPP_HEIGHT-win.height)/2;
			}
			//动画切入
			TweenLite.to(win, 0.6, {y:endY});
		}
		
		private function buildFooterContent():void{
			footer = new FooterBar();
			this.addChild(footer);
		}
		
		
	} //end of class
}
