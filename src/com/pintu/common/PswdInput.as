package com.pintu.common{
	
	import com.sibirjak.asdpc.textfield.TextInput;
	
	
	public class PswdInput extends TextInput{
		
		public function PswdInput()
		{
			super();
		}
		
		protected override function draw():void{
			super.draw();
			this._tf.displayAsPassword = true;
		}
		
	} //end of class
}