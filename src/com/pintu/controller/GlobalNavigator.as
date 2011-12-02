package com.pintu.controller{
	
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.pintu.api.IPintu;
	import com.pintu.events.PintuEvent;
	import com.pintu.modules.IDestroyableModule;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;
	
	
	public class GlobalNavigator{		
		
		//module names...
		public static const HOMPAGE:String = "homepage";
		public static const UNLOGGED:String = "unloggedin";
		
		//the module hided to be destroyed
		private var _prevModule:CasaSprite;
		//need to known what module currently in stage
		private var _currentModule:CasaSprite;
		
		private var _moduleName:String;
		
		//top level sprite: Main
		private var _canvas:Sprite;
		private var _factory:ModuleFactory;
		
		
		public function GlobalNavigator(canvas:Sprite, factory:ModuleFactory){
			this._canvas = canvas;
			this._factory = factory;
		}

		
		public function switchTo(module:String):void{
			//我擦，这里竟然写错了
			//创建两次模块
			//2011/11/24
			if(_moduleName==module) return;
			
			switch(module){
				case HOMPAGE:
					var homePage:CasaSprite = _factory.createModuleByName(HOMPAGE);
					transition(_currentModule,homePage);
					break;
				
				case 	UNLOGGED:
					var unlogged:CasaSprite = _factory.createModuleByName(UNLOGGED);
					transition(_currentModule,unlogged);
					break;
				
				//...
				
			}
			
			//保存新建模块名称
			_moduleName = module;
		}
		
		
		/**
		 * 模块切换时渐变过渡
		 */
		private function transition(prev:CasaSprite, next:CasaSprite):void{
			//校验
			if(!next) return;
			//如果不是运行时切换，就直接显示下一个
			//比如一上来显示未登录状态，或者登录状态
			if(!prev) {
				next.alpha = 1;
				//保存第一次展示的模块
				_currentModule = next;
				//不用切换了
				return;
			}
			
			//状态切换开始：
			//比如：从未登录状态进入登录状态，或者反过来
			_prevModule = prev;
						
			//动画切换
			var myTimeline:TimelineLite = new TimelineLite({paused:true, 
				onComplete:saveTransitionState ,onCompleteParams:[next]});
			//隐藏前一个
			myTimeline.append( TweenLite.to(prev, 0.6, {alpha:0}) );
			//淡入下一个
			myTimeline.append( TweenLite.from(next, 0.6, {alpha:0}) );
			myTimeline.play();
		}
		
		private function saveTransitionState(next:CasaSprite):void{
			//记下当前模块
			_currentModule = next;
			
			//销毁前一个模块，销毁自己的事件监听和子对象
			//并将自己从显示列表中移除
			//这些模块都是IDestroyableModule
			IDestroyableModule(_prevModule).killMe();
		}
		
	} //end of classs
}