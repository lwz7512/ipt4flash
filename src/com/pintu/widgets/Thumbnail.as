package com.pintu.widgets{
	
	import com.pintu.vos.TPicDesc;
	
	import org.casalib.display.CasaSprite;
	import org.casalib.load.CasaLoader;
	
	public class Thumbnail extends CasaSprite{
		
		private var _csloader:CasaLoader;
		private var _data:TPicDesc;
		
		public function Thumbnail(data:TPicDesc){
			_data = data;
			//TODO, LOAD PIC BY URL...
			
			drawBackground();
		}
		
		private function drawBackground():void{
			this.graphics.beginFill(0xCCCCCC);
			this.graphics.drawRect(0,0,100,100);
			this.graphics.endFill();
		}
		
	} //end of class
}