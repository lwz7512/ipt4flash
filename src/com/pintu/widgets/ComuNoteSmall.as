package com.pintu.widgets{
	
	import com.pintu.common.LazyImage;
	import com.pintu.common.SimpleText;
	import com.pintu.config.StyleParams;
	import com.pintu.events.PintuEvent;
	import com.pintu.utils.PintuUtils;
	import com.pintu.vos.Note;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 社区条子，九宫格内显示，大小固定，不自适应
	 */ 
	public class ComuNoteSmall extends CasaSprite{
		
		[Embed(source="assets/community/note_bg.png")]
		private var NoteBG:Class;
		
		//宽高都固定的
		//2012/05/17
		private var _width:Number = 204;
		private var _height:Number = 177;
		
		private var _data:Note;
		
		public function ComuNoteSmall(data:Note){		
			if(data) _data = data;
			
			createSkin();
			
			createTextContent();
			
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOut);
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
		private function createTextContent():void{
			if(!_data) return;
			
			var titleWidth:Number = _width-50;
			//TODO, 这块需要知道发布者的昵称，目前数据库返回是否已经转换？
			var titleStr:String = _data.publiserName+"张贴于"+_data.publishTime.split(" ")[0];
			//FIXME, 标题长度做限制
			titleStr = PintuUtils.truncateStr(titleStr,16);
			var titleTxt:SimpleText = new SimpleText(titleStr,0,14,true,false);
			titleTxt.width = 100;
			titleTxt.height = 16;
			titleTxt.x = 20;
			titleTxt.y = 10;
			this.addChild(titleTxt);
			
			var topic:SimpleText = new SimpleText(_data.title,0,12,true,false);
			topic.width = 150;
			topic.height = 16;
			topic.x = 50;
			topic.y = 40;
			this.addChild(topic);
			
			var contentWidth:Number = _width-20;
			var contentHeight:Number = 30;
			var contentStr:String = _data.content;
			//限制可展示字符串长度80
			contentStr = PintuUtils.truncateStr(contentStr,80);
			var contentTxt:SimpleText = new SimpleText(contentStr,0,12,false,true,false,true);
			contentTxt.width = contentWidth;
			contentTxt.height = 30;
			contentTxt.x = 10;
			contentTxt.y = 60;
			this.addChild(contentTxt);
		}
		
		private function createSkin():void{
			var bg:Bitmap = new NoteBG() as Bitmap;
			this.addChild(bg);
			
			var stickPath:String = "assets/community/sticker_"+Math.floor(Math.random()*6)+".png";
			var sticker:LazyImage = new LazyImage(stickPath);
			sticker.x = -20;
			sticker.y = -20;
			this.addChild(sticker);
		}
		
		private function onMouseOver(evt:MouseEvent):void{
			
		}
		private function onMouseOut(evt:MouseEvent):void{
			
		}
		private function onMouseClick(evt:MouseEvent):void{
			if(!_data) return;
			var view:PintuEvent = new PintuEvent(PintuEvent.VIEW_NOTE,_data.id);
			this.dispatchEvent(view);
		}
		
		override public function get width():Number{
			return _width;
		}
		
		override public function get height():Number{
			return _height;
		}
		
		private function drawFrame():void{
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.drawRect(0,0,_width,_height);			
		}
		
	} //end of class
}