package com.pintu.widgets{
	
	import com.pintu.common.*;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.controller.FileManager;
	import com.pintu.events.PintuEvent;
	import com.sibirjak.asdpc.button.Button;
	import com.sibirjak.asdpc.button.ButtonEvent;
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpc.textfield.TextInput;
	import com.sibirjak.asdpc.textfield.TextInputEvent;
	import com.sibirjak.asdpcbeta.checkbox.CheckBox;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearInterval;
	
	/**
	 * 窗口类，只初始化一个实例，并缓存
	 */ 
	public class PicEditWin extends EditWinBase{
				
		private var _manager:FileManager;		
		
		private var _loader:Loader;
		private var _selectLocalImage:IconButton;
		private var _selectWebCamera:IconButton;
		private var _isOriginalCheck:CheckBox;
		private var _tagsInput:MustTextInput;
		private var _descInput:TextArea;
		
		private var _maxLoadImgWidth:Number = 220;
		private var _maxLoadImgHeight:Number = 160;
		
		
		private var _loadFileBitmap:Bitmap;
		
		private var _localImagePath:String = "assets/folder32.png";
		private var _cameraImagePath:String = "assets/webcamera32.png";
				
		
		public function PicEditWin(ctxt:Stage, manager:FileManager){
			super(ctxt, 320, 400, "编辑图片");
			
			_manager = manager;					
			_manager.addEventListener(FileManager.IMG_INMEMLOAD, showUploadImg);
			_manager.addEventListener(FileManager.IMG_UPLOAD_SUCCESS, uploadSuccess);
			_manager.addEventListener(FileManager.IMG_UPLOAD_FAILURE, uploadError);			

			//创建界面元素
			createFormElements();
		}
		
		override protected function drawBackground():void{
			super.drawBackground();
			
			//画个图片占位框
			this.graphics.lineStyle(1, 0x666666, 1, true);
			this.graphics.drawRect(_elementStartX, _elementStartY, _maxLoadImgWidth, _maxLoadImgHeight);
			
		}		
		
		//点击提交触发
		override protected function submit(evt:ButtonEvent):void{			
			//先检查内容是否合法
			if(!_manager.availableImgData){
				updateSuggest("先选择图像");
				return;
			}
			
			if(_tagsInput.text.length==0 || _descInput.text.length==0){
				updateSuggest("标签和描述不能为空");
				return;
			}
			
			//然后执行父类方法
			super.submit(evt);
			
			//提交图片
			_manager.uploadPicture(_isOriginalCheck.selected, _tagsInput.text, _descInput.text);
		}
		
		override protected function reset():void{
			super.reset();
			//清除预览图
			if(_loadFileBitmap)
				removeChild(_loadFileBitmap);
			_loadFileBitmap = null;
			
			//清除输入框文字
			_isOriginalCheck.selected = false;
			_tagsInput.text = "";
			_descInput.text = "";
		}
		
		private function showUploadImg(evt:Event):void{
			if(!shouldDo()) return;
			
			if(!_loader)
				_loader=new Loader() ;
			//载入文件对象的字节数据，牛啊
			_loader.loadBytes(_manager.availableImgData);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadCompleteHandle);
		}
		
		private function uploadSuccess(evt:Event):void{
			if(!shouldDo()) return;
			closeMe(null);			
		}
		
		
		private function uploadError(evt:Event):void{
			if(!shouldDo()) return;
			updateSuggest("上传失败");
		}
		

		private function createFormElements():void{			
				
			createLocalImageBtn();
			createWebCameraBtn();
			
			createOriginalCheck();
			createTagsInput();
			createDescriptionInput();
			
		}
			
		
		private function createLocalImageBtn():void{
			//icon button colors
			var upColors:Array = [0xFFFFFF,0xFFFFFF];
			var overColors:Array = [StyleParams.ICONMENU_MOUSEOVER_TOP,
				StyleParams.ICONMENU_MOUSEOVER_BOTTOM];
			var downColors:Array = [StyleParams.ICONMENU_SELECTED_TOP,
				StyleParams.ICONMENU_SELECTED_BOTTOM];
			
			_selectLocalImage = new IconButton(
				InitParams.MAINMENUBAR_HEIGHT,
				InitParams.MAINMENUBAR_HEIGHT-2);			
			_selectLocalImage.setSkinStyle(upColors,overColors,downColors);
			_selectLocalImage.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);
			_selectLocalImage.label = "选择图片";
			_selectLocalImage.x = _elementStartX+_maxLoadImgWidth+_elementPadding+10;
			_selectLocalImage.y = _selectLocalImage.y+30;	
			//图标路径
			_selectLocalImage.iconPath = _localImagePath;
			_selectLocalImage.addEventListener(MouseEvent.CLICK, function():void{				
				_manager.browse();
			});
			this.addChild(_selectLocalImage);
		}
		
		private function createWebCameraBtn():void{
			//icon button colors
			var upColors:Array = [0xFFFFFF,0xFFFFFF];
			var overColors:Array = [StyleParams.ICONMENU_MOUSEOVER_TOP,
				StyleParams.ICONMENU_MOUSEOVER_BOTTOM];
			var downColors:Array = [StyleParams.ICONMENU_SELECTED_TOP,
				StyleParams.ICONMENU_SELECTED_BOTTOM];
			
			_selectWebCamera = new IconButton(
				InitParams.MAINMENUBAR_HEIGHT,
				InitParams.MAINMENUBAR_HEIGHT-2);			
			_selectWebCamera.setSkinStyle(upColors,overColors,downColors);
			_selectWebCamera.setLabelStyle(StyleParams.DEFAULT_TEXT_FONTNAME,
				StyleParams.DEFAULT_TEXT_FONTSIZE,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR,
				StyleParams.DEFAULT_TEXT_COLOR);
			_selectWebCamera.label = "摄像头";
			_selectWebCamera.x = _elementStartX+_maxLoadImgWidth+_elementPadding+10;
			_selectWebCamera.y = _selectLocalImage.y+60;	
			//图标路径
			_selectWebCamera.iconPath = _cameraImagePath;
			_selectWebCamera.addEventListener(MouseEvent.CLICK, function():void{				
				//TODO, ...
			});
			//FIXME, TO ENABLED IN FUTURE...
			_selectWebCamera.enabled = false;
			this.addChild(_selectWebCamera);
		}
		

		
		private function createOriginalCheck():void{
			_isOriginalCheck = new CheckBox();
			_isOriginalCheck.label = "是否原创";
			_isOriginalCheck.x = _elementStartX+_maxLoadImgWidth+2*_elementPadding;
			_isOriginalCheck.y = 175;
			_isOriginalCheck.setStyle(Button.style.labelStyles, [
				Label.style.color, StyleParams.DEFAULT_TEXT_COLOR,				
				Label.style.size, 12
			]);
			_isOriginalCheck.setStyle(Button.style.overLabelStyles, [
				Label.style.color, StyleParams.HEADERBAR_TOP_LIGHTGREEN,				
				Label.style.size, 12
			]);
			_isOriginalCheck.setStyle(Button.style.selectedLabelStyles, [
				Label.style.color, StyleParams.DEFAULT_TEXT_COLOR,				
				Label.style.size, 12
			]);
			this.addChild(_isOriginalCheck);
		}
				
		private function createTagsInput():void{
			_tagsInput = new MustTextInput();
			_tagsInput.defaultText = "多个标签用空格隔开";
			_tagsInput.setSize(300,28);
			_tagsInput.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			_tagsInput.setStyle(TextInput.style.size,12);
			_tagsInput.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);			
			_tagsInput.setStyle(TextInput.style.maxChars,12);			
			_tagsInput.x = _elementStartX;
			_tagsInput.y = _elementStartY+_maxLoadImgHeight+_elementPadding+2;
			_tagsInput.addEventListener(TextInputEvent.CHANGED, autoComplete);
			this.addChild(_tagsInput);
		}
		
		private function autoComplete(evt:TextInputEvent):void{
			//TODO, ...后台搜索匹配标签
		}
		
		private function createDescriptionInput():void{
			_descInput = new TextArea();
			_descInput.isMust = true;
			_descInput.defaultText = "图片描述";
			_descInput.setSize(300,120);
			_descInput.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			_descInput.setStyle(TextInput.style.size,12);
			_descInput.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);			
			_descInput.setStyle(TextInput.style.maxChars,140);			
			_descInput.x = _elementStartX;
			_descInput.y =_tagsInput.y+_elementPadding+30;
			this.addChild(_descInput);
		}
			
		
		private function onLoadCompleteHandle(evt:Event):void {
			//先移除上一个图片
			if(_loadFileBitmap && this.contains(_loadFileBitmap))
				this.removeChild(_loadFileBitmap);
			//获得新图
			_loadFileBitmap =evt.target.content as Bitmap;
			//稍微做个偏移，好让底框露出来
			_loadFileBitmap.x = _elementStartX+1;
			_loadFileBitmap.y = _elementStartY+1;
			var ratio:Number = _loadFileBitmap.width/_loadFileBitmap.height;
			if(_loadFileBitmap.width>_maxLoadImgWidth || _loadFileBitmap.height>_maxLoadImgHeight ){
				if(ratio>1){
					_loadFileBitmap.width = _maxLoadImgWidth-1;
					_loadFileBitmap.height = _maxLoadImgWidth/ratio-1;
				}else{
					_loadFileBitmap.height = _maxLoadImgHeight-1;
					_loadFileBitmap.width = _maxLoadImgHeight*ratio-1;
				}
			}
			this.addChild(_loadFileBitmap);
			//清除错误提示
			updateSuggest("");
		}
		
		
	} //end of class
}