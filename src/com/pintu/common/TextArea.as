package com.pintu.common{
	
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpc.textfield.TextInput;
	
	
	public class TextArea extends TextInput{
		
		private var redStar:Label;
		
		private var _isMust:Boolean;
		
		public function TextArea(){
			super();
		}
		
		public function set isMust(v:Boolean):void{
			_isMust = v;
		}
		
		override protected function draw():void{
			super.draw();
			
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