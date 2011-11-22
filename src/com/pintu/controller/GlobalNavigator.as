package com.pintu.controller
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.pintu.api.IPintu;
	import com.pintu.events.PintuEvent;
	
	import flash.display.Sprite;
	
	
	public class GlobalNavigator
	{		
		
		//module names...
		public static const HOMPAGE:String = "homepage";
		public static const UNLOGGED:String = "unloggedin";
		
		//need to known what module currently in stage
		private var _currentModule:Sprite;
		//top level sprite
		private var _canvas:Sprite;
		private var _factory:ModuleFactory;
		
		
		public function GlobalNavigator(canvas:Sprite, factory:ModuleFactory){
			this._canvas = canvas;
			this._factory = factory;
		}
		
		public function get currentModule():Sprite{
			return _currentModule;
		}
		
		public function switchTo(module:String):void{
			
			if(_currentModule==_factory.createModuleByName(module))
				return;
			
			switch(module){
				case HOMPAGE:
					var homePage:Sprite = _factory.createModuleByName(HOMPAGE);
					transition(_currentModule,homePage);
					break;
				
				case 	UNLOGGED:
					var unlogged:Sprite = _factory.createModuleByName(UNLOGGED);
					transition(_currentModule,unlogged);
					break;
				
				//...
				
			}
		}
		
		
		/**
		 * 模块切换时渐变过渡
		 */
		private function transition(prev:Sprite, next:Sprite):void{
			//校验
			if(!next) return;
			//如果不是运行时切换，就直接显示下一个
			//比如一上来显示未登录状态，或者登录状态
			if(!prev) {
				next.alpha = 1;
				return;
			}
			
			//从未登录状态进入登录状态，或者反过来
			
			//初始状态
			prev.alpha = 1;
			next.alpha = 0;
			//动画切换
			var myTimeline:TimelineLite = new TimelineLite({paused:true, 
				onComplete:saveTransitionState ,onCompleteParams:[next]});
			myTimeline.append( new TweenLite(prev, 1, {alpha:0}) );
			myTimeline.append( new TweenLite(next, 1, {alpha:1}) );
			myTimeline.play();
		}
		
		private function saveTransitionState(next:Sprite):void{
			_currentModule = next;
			_canvas.setChildIndex(_currentModule,_canvas.numChildren-1);
		}
		
	} //end of classs
}