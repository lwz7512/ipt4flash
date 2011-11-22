package com.pintu.common{
	
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import org.casalib.display.CasaSprite;
	import org.osmf.events.TimeEvent;
	
	
	public class Toast extends CasaSprite{
		
		private static var _instance:Toast;
		private static var _text:SimpleText;
		private static var _parent:CasaSprite;
		private static var _timer:Timer;
		
		public function Toast(lokr:Locker){			
			//显示3秒
			_timer = new Timer(2000,1);
			//显示结束
			_timer.addEventListener(TimerEvent.TIMER, timeToElapse);
			//显示时画出背景
			this.addEventListener(Event.ADDED_TO_STAGE, drawBackground);
		}
		
		private function timeToElapse(evt:TimerEvent):void{
			//清理上次显示内容
			_text.destroy();
			_text = null;			
			//移除自己
			_parent.removeChild(this);			
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
		}
		
		public static function getInstance(context:CasaSprite):Toast{
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
			if(_parent && _parent.contains(this))
				return;
			
			//创建文字
			_text = new SimpleText(text,0xFFFFFF,12,false,false);
			this.addChild(_text);
						
			if(_parent)
				_parent.addChild(this);
			
			//居中显示
			this.x = toastX - _text.width/2;
			this.y = toastY;			
			
			//开始显示计时
			_timer.start();
			
			TweenLite.from(this, 0.5, {alpha:0});
		}
		
	} //end of class
}
class Locker{	}