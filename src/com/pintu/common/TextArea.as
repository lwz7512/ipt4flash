package com.pintu.common{
	
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpc.textfield.TextInput;
	import com.sibirjak.asdpc.textfield.TextInputEvent;
	
	import flash.events.Event;
	
	public class TextArea extends TextInput{
		
		public static const RESIZED:String = "resized";
		
		private var redStar:Label;
		
		private var _isMust:Boolean;
		private var _autoStretchHeight:Boolean;
		private var _autoFocus:Boolean;
		
		private var _textFieldHeight:Number;
		
		public function TextArea(){
			super();			
			this.setStyle(TextInput.style.size,12);
			this.setStyle(TextInput.style.borderDarkColor,0x333333);	
			//限制字长140
			this.setStyle(TextInput.style.maxChars,140);		
		}
		
		public function set isMust(v:Boolean):void{
			_isMust = v;
		}
		public function set autoStretchHeight(v:Boolean):void{
			_autoStretchHeight = v;
		}
		public function set autoFocus(v:Boolean):void{
			_autoFocus = v;
		}
		
		override protected function draw():void{
			super.draw();
			//保存一个文本高度
			_textFieldHeight = this._tf.textHeight;
			
			if(_isMust){
				redStar = new Label();
				//红色星号
				redStar.setStyle(Label.style.color, 0xFF0000);
				redStar.setStyle(Label.style.size, 14);
				redStar.text = "*";
				redStar.x = this._width+2;
				redStar.y = 4;
				this.addChild(redStar);				
			}
			
			if(_autoStretchHeight){				
				this.addEventListener(TextInputEvent.CHANGED,stretchHeight);			
			}
			
		}
		
		override protected function initialised():void{
			if(_autoFocus) this.setFocus();
		}
		
		private function stretchHeight(evt:TextInputEvent):void{
			if(this._tf.textHeight!=_textFieldHeight){
				//更新文本框高度
				this._height = this._tf.textHeight+12;
				invalidateProperty(UPDATE_PROPERTY_SIZE);
				//保存新的文本框高度
				_textFieldHeight = this._tf.textHeight;
				this.dispatchEvent(new Event(RESIZED));
			}
		}
		
		protected override function setTextFieldProperties():void{	
			super.setTextFieldProperties();
			this._tf.wordWrap = true;
		}
		
		override protected function layoutTextField() : void {
			this._tf.y = 4;
		}
		
	} //end of class
}