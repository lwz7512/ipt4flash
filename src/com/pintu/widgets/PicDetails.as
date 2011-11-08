package com.pintu.widgets{
	
	import com.pintu.vos.TPicData;
	
	import org.casalib.display.CasaSprite;
	import org.casalib.load.ImageLoad;
	
	
	public class PicDetails extends CasaSprite{
		
		private var _data:TPicData;
		
		private var _mobImage:SimpleImage;
		
		public function PicDetails(data:TPicData){
			_data = data;
			
			_mobImage = new SimpleImage(data.mobImgUrl);
			this.addChild(_mobImage);
			
		}
		
	} //end of class
}