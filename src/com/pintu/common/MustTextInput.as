package com.pintu.common{
	
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpc.textfield.TextInput;
	import com.sibirjak.asdpc.textfield.TextInputStyles;
	
	public class MustTextInput extends TextInput{
		
		private var redStar:Label;
		
		public function MustTextInput()
		{
			super();
		}
		
		public function showWarningBorder():void{
			this.setStyle(TextInput.style.borderLightColor, 0xFF0000);
			this.setStyle(TextInput.style.borderDarkColor, 0xFF0000);
			this.invalidateProperty(TextInput.style.borderLightColor);
			this.invalidateProperty(TextInput.style.borderDarkColor);
		}
		
		public function resetToNormal():void{
			this.setStyle(TextInput.style.borderLightColor, 0xCCCCCC);
			this.setStyle(TextInput.style.borderDarkColor, 0x333333);
			this.invalidateProperty(TextInput.style.borderLightColor);			
			this.invalidateProperty(TextInput.style.borderDarkColor);			
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