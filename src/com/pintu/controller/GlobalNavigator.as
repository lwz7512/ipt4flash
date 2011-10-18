package com.pintu.controller
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.pintu.api.IPintu;
	import com.pintu.events.PintuEvent;
	import com.pintu.modules.HomePage;
	import com.pintu.modules.UnloggedPage;
	
	import flash.display.Sprite;
	
	import org.as3commons.collections.Map;
	
	public class GlobalNavigator
	{		
		
		//module names...
		public static const HOMPAGE:String = "homepage";
		public static const UNLOGGED:String = "unloggedin";

		//cache the displayed module
		private var modules:Map = new Map();
		
		//need to known what module currently in stage
		private var _currentModule:Sprite;
		//top level sprite
		private var _canvas:Sprite;
		
		
		public function GlobalNavigator(canvas:Sprite){
			this._canvas = canvas;
		}
		
		public function get currentModule():Sprite{
			return _currentModule;
		}
		
		public function switchTo(module:String, model:IPintu):void{
			switch(module){
				case HOMPAGE:
					enterHomePage(model);
					break;
				
				case 	UNLOGGED:
					enterUnloggedin(model);
					break;
				
				//...
				
			}
		}
		
		private function enterHomePage(model:IPintu):void{
			var homePage:Sprite;
			if(!modules.hasKey(HOMPAGE)){
				homePage = new HomePage(model);
				modules.add(HOMPAGE,homePage);
				this._canvas.addChild(homePage);
			}else{
				homePage = modules.itemFor(HOMPAGE) as Sprite;
			}			
			transition(_currentModule,homePage);			
		}
		
		private function enterUnloggedin(model:IPintu):void{
			var unlogged:Sprite;
			if(!modules.hasKey(UNLOGGED)){
				unlogged = new UnloggedPage(model);
				modules.add(UNLOGGED,unlogged);
				this._canvas.addChild(unlogged);
			}else{
				unlogged = modules.itemFor(UNLOGGED) as Sprite;
			}			
			transition(_currentModule,unlogged);			
		}
		
		/**
		 * 模块切换时渐变过渡
		 */
		private function transition(prev:Sprite, next:Sprite):void{
			//校验
			if(!next) return;
			//直接显示下一个
			if(!prev) {
				next.alpha = 1;
				return;
			}
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
		}
		
	} //end of classs
}