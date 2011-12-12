package com.pintu.common{
	
	import com.greensock.TweenLite;
	import com.pintu.config.StyleParams;
	import com.pintu.utils.Logger;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 对被滚动对象进行监控，实时改变的滚动条
	 * 只需指定target，和滚动条高度即可
	 */ 
	public class ScrollBar extends CasaSprite{
		
		private var _scrlTarget:CasaSprite;
		private var _trackLenth:Number;			
		
		private var thumb:CasaSprite;		
		private var thumbWidth:Number = 10;			
		
		private var trackDrawStartX:Number = thumbWidth/2;
		
		private var thumbUpColor:uint = StyleParams.PICDETAIL_BACKGROUND_GRAY;
		private var thumbOverColor:uint = StyleParams.HEADER_MENU_MOUSEOVER;
		private var thumbDownColor:uint = StyleParams.HEADER_MENU_SELECTED;		
		private var trackColor:uint = StyleParams.PICDETAIL_BACKGROUND_GRAY;
		
		//记下上次滚动的高度，以判断是否改改变thumb的大小
		private var _oldTargetHeight:Number;
		//记下上次滚动的位置，以判断是否该改变thumb的位置
		private var _oldTargetY:Number;
		//这个值是要被运行时改变，也是主要的运算目标
		private var _thumbHeight:Number = 100;
		//鼠标按下时记录的位置
		private var _globalStartMouseY:Number;
		
		private var mouseDownOnThumb:Boolean;		
		
		/**
		 * 是否对target位置和高度监听的开关
		 * 鼠标在滚动条上按下时置为false，即不监听，而主动改变target位置
		 */ 
		private var watchingTarget:Boolean = true;
		/**
		 * 设置是否显示滚动条与否，滚动内容太小不显示
		 */ 
		private var hided:Boolean;
				
		
		
		public function ScrollBar(target:CasaSprite, visibleHight:Number){
			super();
			_scrlTarget = target;
			_trackLenth = visibleHight;
			
			_oldTargetHeight = _scrlTarget.width;
			_oldTargetY = _scrlTarget.y;
						
			this.addEventListener(Event.ENTER_FRAME, detectTargetPropChanged);
			this.addEventListener(Event.ADDED_TO_STAGE, scrollBarAdded);
			
			thumb = new CasaSprite();
			thumb.addEventListener(MouseEvent.MOUSE_OVER, onThumbOver);
			thumb.addEventListener(MouseEvent.MOUSE_OUT, onThumbOut);
			
			//添加MouseEvent.MOUSE_MOVE事件
			thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbDown);
			
			this.addChild(thumb);
			
		}
		
		private function scrollBarAdded(evt:Event):void{
			
			//有可能鼠标在thumb外面释放
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onThumbUp);
			
		}
		
		override public function get width():Number{
			return thumbWidth;
		}
		
		/**
		 * 实时监测被滚动对象的位置和大小变化，以便改变thumb的状态
		 * 如果是鼠标在thumb上按下，就不再监测
		 */ 
		private function detectTargetPropChanged(evt:Event):void{
			if(!watchingTarget) return;
			
			if(_scrlTarget.height<_trackLenth){
				hideScrollBar();
				return;
			}
			
			//准备显示
			hided = false;
			
			//实时改变thumb的大小
			if(_oldTargetHeight!=_scrlTarget.height){				
				drawTrack();				
				drawThumb();				
				_oldTargetHeight = _scrlTarget.height;
			}
			//实时改变thumb的位置
			if(_oldTargetY!=_scrlTarget.y){
				moveThumb();
				_oldTargetY = _scrlTarget.y;
			}
			
		}
		
		private function hideScrollBar():void{
			if(!hided){
				thumb.graphics.clear();
				this.graphics.clear();
				hided = true;
			}
		}
	
		
		/**
		 * 画高亮色
		 */ 
		private function onThumbOver(evt:MouseEvent):void{
			thumb.graphics.clear();
			thumb.graphics.lineStyle(1,trackColor);
			thumb.graphics.beginFill(thumbOverColor);
			thumb.graphics.drawRect(0,0,thumbWidth,_thumbHeight);
			thumb.graphics.endFill();
		}
		/**
		 * 画正常色
		 */ 
		private function onThumbOut(evt:MouseEvent):void{
			thumb.graphics.clear();
			thumb.graphics.lineStyle(1,trackColor);
			thumb.graphics.beginFill(thumbUpColor);
			thumb.graphics.drawRect(0,0,thumbWidth,_thumbHeight);
			thumb.graphics.endFill();
		}
		
		/**
		 * 添加MouseEvent.MOUSE_MOVE事件
		 */ 
		private function onThumbDown(evt:MouseEvent):void{
			//记下鼠标状态，准备拖动
			mouseDownOnThumb = true;	
			//关闭监听
			watchingTarget = false;
			
			_globalStartMouseY = evt.stageY;
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onThumbMove);
			
			thumb.graphics.clear();
			thumb.graphics.lineStyle(1,trackColor);
			thumb.graphics.beginFill(thumbDownColor);
			thumb.graphics.drawRect(0,0,thumbWidth,_thumbHeight);
			thumb.graphics.endFill();
		}
		/**
		 * 移除MouseEvent.MOUSE_MOVE事件
		 * 必须是鼠标在thumb上按下后抬起，才触发
		 */ 
		private function onThumbUp(evt:MouseEvent):void{
			//如果鼠标没有在thumb上按下，不处理
			if(!mouseDownOnThumb) return;			
			
			//开启监听
			watchingTarget = true;
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onThumbMove);
			
			thumb.graphics.clear();
			thumb.graphics.lineStyle(1,trackColor);
			thumb.graphics.beginFill(thumbUpColor);
			thumb.graphics.drawRect(0,0,thumbWidth,_thumbHeight);
			thumb.graphics.endFill();
		}
		
		//拖动Thumb，改变_scrlTarget位置
		private function onThumbMove(evt:MouseEvent):void{		
			
			var currentGlobalMouseY:Number = evt.stageY;
			var thumbMoveDiff:Number = currentGlobalMouseY-_globalStartMouseY;
			
			var trackRatio:Number = (_scrlTarget.height-_trackLenth)/(_trackLenth-thumb.height);
			if(mouseDownOnThumb){
				//不能超过顶部
				if((thumb.y+thumbMoveDiff)<0) return;
				//不能超过底部
				if((thumb.y+thumb.height+thumbMoveDiff)>_trackLenth) return;
				
				//正常滚动
				
				//移动操作滑块
				thumb.y += thumbMoveDiff;
				//移动滚动对象
				_scrlTarget.y -= thumbMoveDiff*trackRatio;

				//更新鼠标位置
				_globalStartMouseY = currentGlobalMouseY;
			}			
		}
				
		
		private function drawTrack():void{
			if(_trackLenth>_scrlTarget.height) return;
			
			this.graphics.clear();
			this.graphics.lineStyle(1,trackColor);
			this.graphics.moveTo(trackDrawStartX, 0);
			this.graphics.lineTo(trackDrawStartX, _trackLenth);
		}
		
		//计算高度，用up颜色绘制
		private function drawThumb():void{
			if(_trackLenth>_scrlTarget.height) return;
			
			var thumbRatio:Number = _trackLenth/_scrlTarget.height;
			//把新计算的高度保留下来
			_thumbHeight = _trackLenth*thumbRatio;
			thumb.graphics.clear();
			thumb.graphics.beginFill(thumbUpColor);
			thumb.graphics.drawRect(0,0,thumbWidth,_thumbHeight);
			thumb.graphics.endFill();
		}
		
		private function moveThumb():void{
			if(_trackLenth>_scrlTarget.height) return;
			//轨迹比例
			var trackRatio:Number = (_scrlTarget.height-_trackLenth)/(_trackLenth-thumb.height);
			//滑块的移动距离与滚动对象位置相反
			var thumbYPos:Number = -(_scrlTarget.y/trackRatio);
			thumb.y = thumbYPos;
		}
		

		
		
	} //end of class
}