package com.pintu.controller{
	
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.pintu.api.IPintu;
	import com.pintu.events.PintuEvent;
	import com.pintu.modules.*;
	
	import flash.display.Sprite;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 主要用于模块之间的切换，例如登录和退出状态的切换
	 * 2011/12/21
	 */ 
	public class GlobalNavigator{		
		
		//module names...
		public static const HOMPAGE:String = "homepage";
		public static const UNLOGGED:String = "unloggedin";
				
		//need to known what module currently in stage
		private var _currentModule:CasaSprite;
		
		private var _moduleName:String;
		
		//top level sprite: Main
		private var _canvas:Sprite;
		private var _model:IPintu;
		
		
		public function GlobalNavigator(canvas:Sprite, model:IPintu){
			this._canvas = canvas;
			this._model = model;
		}

		
		public function switchTo(module:String):IMenuClickResponder{
			
			var nextModule:IMenuClickResponder;
			
			//我擦，这里竟然写错了
			//创建两次模块
			//2011/11/24
			if(_moduleName==module) return null;
			
			
			switch(module){
				case HOMPAGE:
					var homePage:CasaSprite = new HomePage(_model);
					nextModule = IMenuClickResponder(homePage);
					transition(_currentModule,homePage);
					break;
				
				case 	UNLOGGED:
					var unlogged:CasaSprite = new UnloggedPage(_model);
					nextModule = IMenuClickResponder(unlogged);
					transition(_currentModule,unlogged);
					break;
				
				//...
				
			}
			
			//保存新建模块名称
			_moduleName = module;
			
			return nextModule;
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
				//保存第一次展示的模块
				_currentModule = next;
				_canvas.addChild(_currentModule);
				//不用切换了
				return;
			}
				
			//销毁前一个模块，销毁自己的事件监听和子对象
			//并将自己从显示列表中移除
			//这些模块都是IDestroyableModule
			IDestroyableModule(_currentModule).killMe();
			
			//准备显示下一个
			_canvas.addChild(next);
			//然后淡入
			next.alpha = 0;
			TweenLite.to(next, 0.6, {alpha:1});	
			
			//记下当前模块
			_currentModule = next;
		}
				
		
	} //end of classs
}