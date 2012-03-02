package com.pintu.window{
	
	import com.greensock.TweenLite;
	import com.pintu.api.IPintu;
	import com.pintu.api.PintuImpl;
	import com.pintu.common.BusyIndicator;
	import com.pintu.common.GreenButton;
	import com.pintu.common.LazyImage;
	import com.pintu.common.SimpleText;
	import com.pintu.config.*;
	import com.pintu.controller.FileManager;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.Logger;
	import com.sibirjak.asdpc.button.Button;
	import com.sibirjak.asdpc.button.ButtonEvent;
	import com.sibirjak.asdpc.button.skins.ButtonSkin;
	import com.sibirjak.asdpc.core.constants.Position;
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpc.textfield.TextInput;
	import com.sibirjak.asdpc.textfield.TextInputEvent;
	import com.sibirjak.asdpcbeta.checkbox.CheckBox;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 所有对话窗口的父类
	 * 负责生成窗口轮廓，和全局遮罩层，以及关闭按钮
	 * 并负责关闭时回收全局遮罩层
	 * 
	 * 该类的典型用法参见：MsgEditWin
	 */ 
	public class EditWinBase extends CasaSprite{
		
		/**
		 * 通过克隆方法得到的模型，这样避免模型干扰
		 * 在窗体销毁时，务必在子类的destroy方法中销毁这个实例
		 */ 
		private var _clonedModel:PintuImpl;
		/**
		 * 默认都是提交动作，所以这个都是true <br/>
		 * 如果只是普通的确定关闭，这个为false
		 */ 
		private var _showProgressbar:Boolean = true;
		
		
		protected var _elementStartX:Number = 6;
		protected var _elementStartY:Number = 30;
		protected var _elementPadding:Number = 6;		
		
		private var _context:Stage;
		private var _title:SimpleText;
		private var _errorHint:SimpleText;
		private var _sendBtn:Button;		
		private var _loading:BusyIndicator;
		private var _modalOverlay:CasaSprite;
		private var _closemeBtn:LazyImage;
		
		private var _loadingX:Number = 0;
		private var _loadingY:Number = 0;		
		
		private var _width:Number = 320;
		private var _height:Number = 400;				
		
		private var _headerHeight:Number = 24;
		

		
		public function EditWinBase(ctxt:Stage, w:Number=320, h:Number=400, title:String=""){
			super();
			//得到父容器，用来关闭自己
			_context = ctxt;
			if(w) _width = w;
			if(h) _height = h;
			
			_loadingX = _width-110;
			_loadingY = _height-36;
			
			//大小固定了，子类就不用设置了
			drawBackground();
			
			createWinTitle(title);
			createCloseBtn();		
			createSubmitBtn();			
			createErrorHint();
			
			//本窗口自主管理遮罩层：
			//稍后创建全局遮罩层
			this.addEventListener(Event.ADDED_TO_STAGE,createModalLayer);
			//隐藏时自动销毁	
			this.addEventListener(Event.REMOVED_FROM_STAGE, removeModalLayer);
		}
		
		protected function drawBackground():void{
			//必须要清除绘制内容，否则会重叠显示
			this.graphics.clear();			
			
			//边框清晰模式
			this.graphics.lineStyle(1, 0x666666, 1, true);
			//先画整体区域色，白色的
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.drawRect(0, 0, _width, _height);
			this.graphics.endFill();
			
			//再画标题栏，黯：深黑色、泛指黑色
			this.graphics.beginFill(0x41555D,1);
			this.graphics.drawRect(1, 1, _width-2, _headerHeight);
			this.graphics.endFill();			
			
			this.filters = [new DropShadowFilter(4,45,0x666666,0.8)];
		}
		
		private function createWinTitle(title:String):void{
			_title = new SimpleText(title, 0xFFFFFF);
			_title.x = 6;
			_title.y = 4;
			this.addChild(_title);
		}	
		
		private function createCloseBtn():void{
			var closeIconPath:String = "assets/closeme.png";
			_closemeBtn = new LazyImage(closeIconPath);
			_closemeBtn.buttonMode = true;
			_closemeBtn.x = _width-26;
			_closemeBtn.y = 0;
			_closemeBtn.addEventListener(MouseEvent.CLICK, closeMe);
			this.addChild(_closemeBtn);
		}
		
		//处理两个对象的事件：
		//点击关闭按钮，上传成功
		//所以用Event类型事件
		protected function closeMe(evt:Event):void{
			//清除发送进度条
			if(_loading && this.contains(_loading))
				this.removeChild(_loading);
			//滑出舞台
			var initY:Number = -_height;
			TweenLite.to(this, 0.4, {y:initY, onComplete:reset});
		}
		
		/**
		 * 关闭时执行，移除窗口，并启用按钮，消除错误内容
		 * 子类也需要重载这个方法，来恢复初始状态
		 */ 
		protected function reset():void{
			_context.removeChild(this);
			
			//清除错误提示
			_errorHint.text = "";
			_sendBtn.enabled = true;			
		}
		
		private function createErrorHint():void{			
			_errorHint = new SimpleText("",0xFF0000);
			_errorHint.width = 200;
			_errorHint.x = 6;
			_errorHint.y = _loadingY;
			this.addChild(_errorHint);
		}
		
		private function createSubmitBtn():void{
			_sendBtn = new GreenButton();
			_sendBtn.label = submitLabel;
			//这个尺寸跟登陆按钮大小一致
			_sendBtn.setSize(60, 28);
			
			_sendBtn.x = _elementStartX+_width-76;
			_sendBtn.y = _elementStartX+_height-50+_elementPadding;
			_sendBtn.addEventListener(ButtonEvent.CLICK, submit);
			
			this.addChild(_sendBtn);
		}
		
		protected function get submitLabel():String{
			return "发送";
		}
		
		/**
		 * 清除进度条和错误提示，禁用提交按钮
		 * 子类需要重载这个方法来提交内容
		 * 
		 * 如果是普通的窗口，则不显示进度条
		 * 2011/12/21
		 */ 
		protected function submit(evt:ButtonEvent):void{
			
			if(!_showProgressbar){
				closeMe(null);
				return;
			}
			
			if(!_loading) _loading = new BusyIndicator(24);
			_loading.x = _loadingX;
			_loading.y = _loadingY;
			this.addChild(_loading);
			//清除错误提示
			_errorHint.text = "";
			_sendBtn.enabled = false;
		}
		
		private function createModalLayer(evt:Event):void{
			if(!_modalOverlay)
				_modalOverlay = new CasaSprite();
			
			_modalOverlay.graphics.beginFill(0x999999,0.1);			
			_modalOverlay.graphics.drawRect(0,0,InitParams.appWidth,InitParams.appHeight);
			_modalOverlay.graphics.endFill();
			_context.addChild(_modalOverlay);
			//注意：置于窗口的下面
			_context.swapChildren(_modalOverlay,this);
			
		}		
		private function removeModalLayer(evt:Event):void{
			_context.removeChild(_modalOverlay);
		}
		
		protected function updateSuggest(hint:String):void{
			_errorHint.text = hint;
		}
		
		protected function hintToUser(info:String):void{
			var hint:PintuEvent = new PintuEvent(PintuEvent.HINT_USER, info);
			this.dispatchEvent(hint);
		}
		
		/**
		 * 多个窗口可能会用FileManager，这里检查下
		 * 只有活动窗口才执行事件
		 */ 
		protected function shouldDo():Boolean{
			if(!_context.contains(this)){				
				return false;
			}else{
				return true;
			}
		}
		
		public function set sourceModel(model:IPintu):void{
			_clonedModel = PintuImpl(model.clone());
		}
		public function get cloneModel():PintuImpl{
			return _clonedModel;
		}
		
		public function set showProgressbar(s:Boolean):void{
			_showProgressbar = s;
		}
		
		public override function set width(w:Number):void{
			_width = w;
		}
		
		public override function set height(h:Number):void{
			_height = h;
		}
		
		public override function get width():Number{
			return _width;
		}
		
		public override function get height():Number{
			return _height;
		}
				
		
	} //end of class
}