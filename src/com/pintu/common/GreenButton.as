package com.pintu.common
{
	
	import com.pintu.config.StyleParams;
	
	import com.sibirjak.asdpc.button.Button;
	import com.sibirjak.asdpc.button.skins.ButtonSkin;
	import com.sibirjak.asdpc.core.constants.Position;
	import com.sibirjak.asdpc.textfield.Label;
	
	public class GreenButton extends Button{
		
		public function GreenButton(){
			super();
			
			this.setStyle(ButtonSkin.style_backgroundColors, 
				[StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN, StyleParams.HEADERBAR_BOTTOM_LIGHTGREEN]);
			this.setStyle(ButtonSkin.style_overBackgroundColors, 
				[StyleParams.HEADERBAR_TOP_LIGHTGREEN, StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN]);
			this.setStyle(ButtonSkin.style_borderColors, [0x999999, 0x000000]);
			
			this.setStyle(Button.style.labelStyles, [
				Label.style.color, 0xEEEEEE,				
				Label.style.size, 12,
				Label.style.verticalAlign, Position.MIDDLE
			]);
			this.setStyle(Button.style.overLabelStyles, [
				Label.style.color, 0xEEEEEE,				
				Label.style.size, 12,
				Label.style.verticalAlign, Position.MIDDLE
			]);
			this.setStyle(Button.style.selectedLabelStyles, [
				Label.style.color, 0xEEEEEE,				
				Label.style.size, 12,
				Label.style.verticalAlign, Position.MIDDLE
			]);
			
			
		}
		
	} //end of class
}