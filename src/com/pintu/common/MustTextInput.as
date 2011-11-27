package com.pintu.common{
	
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpc.textfield.TextInput;
	
	
	public class MustTextInput extends TextInput{
		
		private var redStar:Label;
		
		public function MustTextInput()
		{
			super();
		}
		
		override protected function draw():void{
			super.draw();
			redStar = new Label();
			//红色星号
			redStar.setStyle(Label.style.color, 0xFF0000);
			redStar.setStyle(Label.style.size, 14);
			redStar.text = "*";
			redStar.x = this._width+2;
			redStar.y = 4;
			this.addChild(redStar);
		}
		
	} //end of class
}