package com.pintu.common{
	
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import org.casalib.display.CasaSprite;
	import org.osmf.events.TimeEvent;
	
	
	public class Toast extends CasaSprite{
		
		private static var _instance:Toast;
		private static var _text:SimpleText;
		private static var _parent:Sprite;
		private static var _timer:Timer;
		
		public function Toast(lokr:Locker){			
			//显示3秒不长不短
			_timer = new Timer(3000,1);
			//时间到了隐藏起来
			_timer.addEventListener(TimerEvent.TIMER, timeToElapse);
			//显示时画出背景
			this.addEventListener(Event.ADDED_TO_STAGE, drawBackground);
		}
		
		private function timeToElapse(evt:TimerEvent):void{
			//隐藏自己	
			if(_parent.contains(this))
				_parent.removeChild(this);
			_parent = null;
			
			//确保定时器停止
			_timer.stop();
		}
		
		private function drawBackground(evt:Event):void{
			//必须要清除绘制内容，否则会重叠显示
			this.graphics.clear();
			
			var toastWidth:Number = _text.width+12;
			var toastHeight:Number = _text.height+12;
			//边框清晰模式
			this.graphics.lineStyle(1, 0x666666, 1, true);
			this.graphics.beginFill(0x333333,0.8);
			this.graphics.drawRoundRect(-4, -4, toastWidth, toastHeight, 6, 6);
			this.graphics.endFill();
			
			//加个阴影
			var shadow:DropShadowFilter = new DropShadowFilter(4,45,0x666666,0.8);
			this.filters = [shadow];
		}

		
		public static function getInstance(context:Sprite):Toast{			
			if(!_instance){
				_instance = new Toast(new Locker());				
			}
				
			_parent = context;
			
			if(_parent){
				return _instance;				
			}else{
				return null;
			}
		}
		
		public function show(text:String, toastX:Number, toastY:Number):void{
			//如果已经显示了，就不再显示
			if(_parent.contains(this)) return;			
			
			//创建文字
			if(!_text){
				//缓存起来
				_text = new SimpleText(text,0xFFFFFF,12,false,false);
				this.addChild(_text);				
			}else{
				//新的内容来了
				_text.text = text;
			}
						
			if(_parent)
				_parent.addChild(this);
			
			//居中显示
			this.x = toastX - _text.width/2;
			this.y = toastY;			
			
			//开始显示计时
			_timer.start();
			
			//FIXME, 我擦，还得必须设定下初始的透明度
			//否则动画会有问题，第二次就不出来了
			//2011/11/23
			this.alpha = 1;
			
			TweenLite.from(this, 0.6, {alpha:0});
		}
		
	} //end of class
}
class Locker{	}