package com.pintu.widgets{
	
	import com.pintu.api.IPintu;
	import com.pintu.common.IconButton;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PintuEvent;
	
	import flash.events.MouseEvent;
	
	/**
	 * 社区贴条子，以及用户资料
	 * 
	 * 2012/05/14
	 */ 
	public class ComuPostBlock extends AbstractWidget{
		
		private var titleBackgroudColor:uint = StyleParams.PICDETAIL_BACKGROUND_THIRD;
		private var titleBackgroudHeight:int = InitParams.MAINMENUBAR_HEIGHT;

		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		
		public function ComuPostBlock(model:IPintu){
			super(model);
			
			initDrawPoint();			
			
			drawBackGround();	
			drawTitleBar();
						
		}
		
		override protected function safeAddModelListener():void{
			
		}
		
		override protected function safeClearModelListener():void{
			
		}
		
		private function drawTitleBar():void{
			this.graphics.lineStyle(1, titleBackgroudColor);
			this.graphics.beginFill(titleBackgroudColor, 1);
			this.graphics.drawRect(drawStartX+1,drawStartY+1,InitParams.ANDI_ASSETS_WIDTH-2,titleBackgroudHeight);
			this.graphics.endFill();
			
			//icon button colors
			var upColors:Array = [0xFFFFFF,0xFFFFFF];
			var overColors:Array = [StyleParams.ICONMENU_MOUSEOVER_TOP,
				StyleParams.ICONMENU_MOUSEOVER_BOTTOM];
			var downColors:Array = [StyleParams.ICONMENU_SELECTED_TOP,
				StyleParams.ICONMENU_SELECTED_BOTTOM];
			
			var buttonGap:Number = 2;
			var buttonXoffset:Number = 4;
			
			//贴条子
			var post:IconButton = new IconButton(InitParams.MAINMENUBAR_HEIGHT,InitParams.MAINMENUBAR_HEIGHT-buttonGap);
			post.iconPath = "assets/community/notes.png";
			post.addEventListener(MouseEvent.CLICK, postNote);
			post.x = drawStartX+buttonXoffset;
			post.y = drawStartY;			
			post.label = "贴条子";			
			post.setSkinStyle(upColors,overColors,downColors);
			post.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);	
			this.addChild(post);			
		}
		
		private function postNote(evt:MouseEvent):void{
			//HomPage监听该事件
			dispatchEvent(new PintuEvent(PintuEvent.POST_NOTE,null));
		}
		
		
		private function initDrawPoint():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			blockWidth = InitParams.USER_DETAIL_WIDTH;
			blockHeight = InitParams.USER_DETAIL_HEIGHT;
		}
		
		private function drawBackGround():void{
			
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);			
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);
			this.graphics.endFill();
			
		}
		
	} //end of class
}