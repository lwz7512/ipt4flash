package com.pintu.common{
	
	import com.sibirjak.asdpc.textfield.TextInput;
	
	import flash.text.TextFieldType;
	
	public class DisableTxtInput extends TextInput{
		
		public function DisableTxtInput()
		{
			super();
		}
		
		override protected function layoutTextField() : void {
			super.layoutTextField();
			//改为不可编辑
			_tf.type = TextFieldType.DYNAMIC;
			_tf.selectable = false;
		}
		
		override protected function initialised():void{
			//去掉事件监听
			cleanUpCalled();
		}
		
	} //end of class
}