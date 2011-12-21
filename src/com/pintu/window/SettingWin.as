package com.pintu.window{
	
	import com.pintu.config.StyleParams;
	import com.pintu.controller.GlobalController;
	
	import com.sibirjak.asdpc.button.Button;
	import com.sibirjak.asdpc.button.ButtonEvent;
	import com.sibirjak.asdpc.button.skins.ButtonSkin;
	import com.sibirjak.asdpc.core.constants.Position;
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpcbeta.radiobutton.RadioButton;
	import com.sibirjak.asdpcbeta.radiobutton.RadioGroup;
	
	import flash.display.Stage;
	
	
	public class SettingWin extends EditWinBase{
		
		private var tbBtn:RadioButton;
		private var rdBtn:RadioButton;
		private var bpBtn:RadioButton;
		private var hotBtn:RadioButton;
		private var favBtn:RadioButton;
		
		private var radioGroup : RadioGroup;
		
		public function SettingWin(ctxt:Stage, w:Number=320, h:Number=350){
			super(ctxt, w, h, "浏览模式设置");
			
			//不是提交数据窗口
			this.showProgressbar = false;
			
			_elementStartX += 10;
			_elementStartY += 10;
			
			buildBrowseTypeSetting();
		}
		
		private function buildBrowseTypeSetting():void{
			tbBtn = new RadioButton();
			tbBtn.label = "最新画廊";
			tbBtn.value = "gallery_tb";
			tbBtn.selected = true;
			tbBtn.x = _elementStartX;
			tbBtn.y = _elementStartY;
			addLabelStyle(tbBtn);
			this.addChild(tbBtn);
			
			rdBtn = new RadioButton();
			rdBtn.label = "随机画廊";
			rdBtn.value = "gallery_rd";			
			rdBtn.x = _elementStartX;
			rdBtn.y = _elementStartY+30;
			addLabelStyle(rdBtn);
			this.addChild(rdBtn);
			
			bpBtn = new RadioButton();
			bpBtn.label = "大图列表";
			bpBtn.value = "gallery_bp";			
			bpBtn.x = _elementStartX;
			bpBtn.y = _elementStartY+60;
			addLabelStyle(bpBtn);
			this.addChild(bpBtn);
			
			hotBtn = new RadioButton();
			hotBtn.label = "最近热图";
			hotBtn.value = "hot";			
			hotBtn.x = _elementStartX;
			hotBtn.y = _elementStartY+90;
			addLabelStyle(hotBtn);
			this.addChild(hotBtn);
			
			favBtn = new RadioButton();
			favBtn.label = "最近收藏";
			favBtn.value = "favored";			
			favBtn.x = _elementStartX;
			favBtn.y = _elementStartY+120;
			addLabelStyle(favBtn);
			this.addChild(favBtn);
			
			radioGroup = new RadioGroup();
			radioGroup.setButtons([tbBtn, rdBtn, bpBtn, hotBtn, favBtn]);
		}
		
		private function addLabelStyle(btn:Button):void{
			btn.setStyle(Button.style.labelStyles, [
				Label.style.color, StyleParams.DEFAULT_TEXT_COLOR,				
				Label.style.size, 12,
				Label.style.verticalAlign, Position.MIDDLE
			]);
			btn.setStyle(Button.style.overLabelStyles, [
				Label.style.color, StyleParams.DEFAULT_TEXT_COLOR,				
				Label.style.size, 12,
				Label.style.verticalAlign, Position.MIDDLE
			]);
			btn.setStyle(Button.style.selectedLabelStyles, [
				Label.style.color, StyleParams.DEFAULT_TEXT_COLOR,				
				Label.style.size, 12,
				Label.style.verticalAlign, Position.MIDDLE
			]);
		}
		
		override protected function submit(evt:ButtonEvent):void{	
			//保存设置
			var type:String = radioGroup.selectedValue;
			GlobalController.rememberBrowseType(type);
			
			super.submit(evt);	
		}
		
		override protected function get submitLabel():String{
			return "确定";
		}
		
	} //end of class
}