package com.pintu.widgets{
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	import com.pintu.api.IPintu;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	
	/**
	 * 与业务无关的显示容器类
	 */ 
	public class MainDisplayBase extends CasaSprite{
		
		
		protected var _initialized:Boolean;
		
		protected var drawStartX:Number;
		protected var drawStartY:Number;
		protected var displayAreaWidth:Number;
		protected var displayAreaHeight:Number;						
		
		/**
		 * 使用增强的显示对象CasaSprite，以更好的管理子对象
		 * 画廊图片容器，也是被滚动对象
		 */ 
		protected var _picsContainer:CasaSprite;	
		
		/**
		 * 查询保护装置，2秒内不允许重复查询
		 */ 
		protected var queryAvailableTimer:Timer;
		/**
		 * 查询状态开关，定时器使用
		 */ 
		protected var isRunning:Boolean;
		
		//滚动条
		private var _scrollbar:ScrollBar;
		//画廊遮罩，别动
		private var _clip:CasaShape;	
		//加载进度条
		private var loading:BusyIndicator;					
		//画廊移动速度
		private var _galleryMoveYSpeed:Number = 0;		
		//加速度系数
		private var _acceleration:int = 40;
		//保留上次鼠标位置以判断移动方向
		private var _lastMouseY:Number = 0;		
		
		
		public function MainDisplayBase(){
			super();
			//先确定绘图起始位置
			initDrawPoint();	
			
			//默认舞台背景色
			drawMainDisplayBackground();
			//生成裁剪区域
			createClipMask();								
			//画廊容器
			_picsContainer = new CasaSprite();
			addChild(_picsContainer);
			
			//滚动条			
			_scrollbar = new ScrollBar(_picsContainer,displayAreaHeight);
			_scrollbar.x = drawStartX+displayAreaWidth-_scrollbar.width;
			_scrollbar.y = drawStartY;
			addChild(_scrollbar);
			
			//2秒内运行检查，类型设置时启动
			queryAvailableTimer = new Timer(2000,1);
		
			//滚轮处理画廊移动
			this.addEventListener(MouseEvent.MOUSE_WHEEL,scrollGallery);	
			//监听大图派发的滚动提升图片事件，方便添加评论输入
			this.addEventListener(PintuEvent.SCROLL_UP, raiseUpGallery);
			
		}		
		
		/**
		 * 显示进度条，并打开查询开关
		 * public 是因为：
		 * 点击缩略图，展示图片详情时也用该方法
		 */ 
		public function showMiddleLoading():void{
			var middleX:Number = drawStartX+displayAreaWidth/2;
			var middleY:Number = drawStartY+displayAreaHeight/2;			
			if(!loading)
				loading = new BusyIndicator(32);
			loading.x = middleX-16;
			loading.y = middleY-16;
			if(!this.contains(loading))
				this.addChild(loading);
			//打开查询开关，防止短时间重复查询
			isRunning = true;
		}		
		public function hideMiddleLoading():void{
			if(this.contains(loading)){
				this.removeChild(loading);				
			}
			//查询结束
			isRunning = false;
			//这时查询开关打开
			queryAvailableTimer.stop();
		}
		
		private function initDrawPoint():void{
			drawStartX = InitParams.startDrawingX();				
			drawStartY = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			
			if(InitParams.isStretchHeight()){
				//拉伸高度
				displayAreaHeight = InitParams.appHeight
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.FOOTER_HEIGHT;
			}else{
				//默认高度，也是最小高度
				displayAreaHeight = InitParams.MINAPP_HEIGHT
					-drawStartY-InitParams.FOOTER_HEIGHT-InitParams.TOP_BOTTOM_GAP;
			}
			displayAreaWidth = InitParams.GALLERY_WIDTH;
		}
		
		private function drawMainDisplayBackground():void{						
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);			
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,displayAreaWidth,displayAreaHeight);
			this.graphics.endFill();
		}
		
		private function createClipMask():void{
			_clip = new CasaShape();
			_clip.graphics.beginFill(0x000000);
			_clip.graphics.drawRect(drawStartX,drawStartY,displayAreaWidth+1,displayAreaHeight+1);
			_clip.graphics.endFill();
			this.mask = _clip;
			this.addChild(_clip);
		}
		
		private function scrollGallery(event:MouseEvent):void{
			//向后滚，负值，向前滚，正值
			var moveDirection:int = event.delta;
			_galleryMoveYSpeed = moveDirection*_acceleration;
			moveGallery();
		}
		
		/**
		 * 鼠标滚轮滚动画廊
		 */ 
		private function moveGallery():void{	
			//画廊默认位置
			var galleryHeight:Number = _picsContainer.height;
			var galleryMoveStartY:Number = 0;			
			var galleryMoveEndY:Number = displayAreaHeight-galleryHeight;
			//如果是负数表示超过了展示高度，则滚动，如果不是，则不滚动
			if(galleryMoveEndY>=0)
				return;			
			
			//按照计算好的速度移动
			if(_galleryMoveYSpeed!=0)				
				TweenLite.to(_picsContainer,0.6,{y:(_picsContainer.y + _galleryMoveYSpeed), ease:Strong.easeOut});
			
			//位置复原
			if(_picsContainer.y>galleryMoveStartY){
				//缓动效果
				TweenLite.to(_picsContainer,0.4,{y:galleryMoveStartY,ease:Strong.easeOut});				
			}
			if(_picsContainer.y<galleryMoveEndY){
				TweenLite.to(_picsContainer,0.4,{y:galleryMoveEndY,ease:Strong.easeOut});
			}
		}
		
		/**
		 * 向上滚动，y值减小diff
		 */ 
		private function raiseUpGallery(evt:PintuEvent):void{
			var diff:Number = Number(evt.data);
			var origPicsContainerY:Number = _picsContainer.y;
			var galleryMoveEndY:Number = origPicsContainerY-diff;
			TweenLite.to(_picsContainer,0.4,{y:galleryMoveEndY,ease:Strong.easeOut});
		}
		
		
		override public function destroy():void{
			super.destroy();
			
			if(queryAvailableTimer)
				queryAvailableTimer.stop();
			queryAvailableTimer = null;
			
		}
		
		
		

		/**
		 * @deprecated 先留着，后面用得着
		 * 首先判断画廊的位置，
		 * 如果画廊在起点0，则鼠标在画廊中部以下时开始滚动画廊，
		 * 如果画廊在终点，则鼠标在画廊中部以上时开始滚动画廊，
		 * 根据鼠标在展示区域的上下位置，决定了画廊移动速度
		 */ 
		private function calculateMoveSpeed(event:MouseEvent):void{											
			var galleryHeight:Number = _picsContainer.height;
			//画廊默认位置
			var galleryMoveStartY:Number = 0;			
			var galleryMoveEndY:Number = displayAreaHeight-galleryHeight;
			//如果是负数表示超过了展示高度，则滚动，如果不是，则不滚动
			if(galleryMoveEndY>=0){
				_galleryMoveYSpeed = 0;
				return;
			}
			//摩擦力系数，越小移动越快
			var frictionFactor:int = 15;
			var relativeMouseY:Number = event.stageY - drawStartY;
			var isMoveDown:Boolean = (relativeMouseY-_lastMouseY)>0?true:false;			
			if(isMoveDown){				
				var isInLowerHalf:Boolean = (relativeMouseY-displayAreaHeight/2)>0?true:false;				
				//画廊在起始位置以下，该往上移动
				if(isInLowerHalf){
					if(_picsContainer.y>galleryMoveEndY && _picsContainer.y<=galleryMoveStartY){
						//与底部越近，速度越快，这个速度是负值，以使画廊向上移动
						//中部时，速度为0
						_galleryMoveYSpeed = (-relativeMouseY+displayAreaHeight/2)/frictionFactor;						
					}
				}
			}else{//Move up				
				var isInHigherHalf:Boolean = (relativeMouseY-displayAreaHeight/2)<0?true:false;				
				if(isInHigherHalf){
					//画廊在终点位置以下，该往下移动
					if(_picsContainer.y>=galleryMoveEndY && _picsContainer.y<galleryMoveStartY){
						//越与顶部接近，速度越快，这个速度是正值，以使画廊向下移动
						//中部时，速度为0
						_galleryMoveYSpeed = (-relativeMouseY+displayAreaHeight/2)/frictionFactor;						
					}
				}
			}
			//取整
			_galleryMoveYSpeed = int(_galleryMoveYSpeed);			
			
			//保留上次的鼠标位置
			_lastMouseY = relativeMouseY;
		}
		
		
	} //end of class
}