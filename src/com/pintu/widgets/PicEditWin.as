package com.pintu.widgets{
	
	import com.pintu.common.BusyIndicator;
	import com.pintu.common.IconButton;
	import com.pintu.common.MustTextInput;
	import com.pintu.common.SimpleImage;
	import com.pintu.common.SimpleText;
	import com.pintu.common.TextArea;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.controller.FileManager;
	import com.sibirjak.asdpc.button.Button;
	import com.sibirjak.asdpc.button.ButtonEvent;
	import com.sibirjak.asdpc.button.skins.ButtonSkin;
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpc.textfield.TextInput;
	import com.sibirjak.asdpc.textfield.TextInputEvent;
	import com.sibirjak.asdpcbeta.checkbox.CheckBox;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import org.casalib.display.CasaSprite;
	
	
	public class PicEditWin extends CasaSprite{
		
		private var _context:CasaSprite;
		private var _manager:FileManager;
		
		private var _width:Number = 320;
		private var _height:Number = 400;
		private var _headerHeight:Number = 24;
		private var _elementStartX:Number = 6;
		private var _elementStartY:Number = 30;
		private var _elementPadding:Number = 6;
		
		private var _modalOverlay:CasaSprite;
		private var _closemeBtn:SimpleImage;
		private var _title:SimpleText;
		private var _errorHint:SimpleText;
		
		private var _selectLocalImage:IconButton;
		private var _selectWebCamera:IconButton;
		private var _isOriginalCheck:CheckBox;
		private var _tagsInput:MustTextInput;
		private var _descInput:TextArea;
		private var _sendBtn:Button;
		
		private var _loader:Loader;
		private var _loadFileBitmap:Bitmap;
		private var _maxLoadImgWidth:Number = 220;
		private var _maxLoadImgHeight:Number = 160;
		private var _loadImgX:Number = 94;
		private var _loadImgY:Number = 30;
		
		private var _localImagePath:String = "assets/folder32.png";
		private var _cameraImagePath:String = "assets/webcamera32.png";
		
		private var _loading:BusyIndicator;
		private var _loadingX:Number = 210;
		private var _loadingY:Number = 360;
		
		
		
		public function PicEditWin(ctxt:CasaSprite, manager:FileManager){
			super();
			//得到父容器，用来关闭自己
			_context = ctxt;
			_manager = manager;
			//大小固定了，外面就不用设置了
			drawBackground();
			//创建界面元素
			createFormElements();			
			
			_manager.addEventListener(FileManager.IMG_INMEMLOAD, showUploadImg);
			_manager.addEventListener(FileManager.IMG_UPLOAD_SUCCESS, uploadSuccess);
			_manager.addEventListener(FileManager.IMG_UPLOAD_FAILURE, uploadError);			
			//本窗口自主管理遮罩层：
			//稍后创建全局遮罩层
			this.addEventListener(Event.ADDED_TO_STAGE,createModalLayer);
			//隐藏时自动消耗	
			this.addEventListener(Event.REMOVED_FROM_STAGE, removeModalLayer);
		}
		
		private function uploadSuccess(evt:Event):void{
			closeMe(null);
		}
		
		private function uploadError(evt:Event):void{
			_errorHint.text = "上传失败";
		}
		
		private function drawBackground():void{
			//必须要清除绘制内容，否则会重叠显示
			this.graphics.clear();			
					
			//边框清晰模式
			this.graphics.lineStyle(1, 0x666666, 1, true);
			//先画整体区域色，白色的
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.drawRect(0, 0, _width, _height);
			this.graphics.endFill();
			
			//再画标题栏，黯：深黑色、泛指黑色
			this.graphics.beginFill(0x41555D,1);
			this.graphics.drawRect(1, 1, _width-2, _headerHeight);
			this.graphics.endFill();
			
			//画个图片占位框
			this.graphics.lineStyle(1, 0x666666, 1, true);
			this.graphics.drawRect(_elementStartX, _loadImgY, _maxLoadImgWidth, _maxLoadImgHeight);
			
			this.filters = [new DropShadowFilter(4,45,0x666666,0.8)];
		}
		

		private function createFormElements():void{
			createWinTitle();
			createCloseBtn();			
			createLocalImageBtn();
			createWebCameraBtn();
			
			createOriginalCheck();
			createTagsInput();
			createDescriptionInput();
			
			createSubmitBtn();
			
			createErrorHint();
		}
		
		private function createWinTitle():void{
			_title = new SimpleText("编辑贴图",0xFFFFFF);
			_title.x = 6;
			_title.y = 4;
			this.addChild(_title);
		}
		private function createErrorHint():void{			
			_errorHint = new SimpleText("",0xFF0000);
			_errorHint.width = _maxLoadImgWidth;
			_errorHint.x = 6;
			_errorHint.y = _loadingY;
			this.addChild(_errorHint);
		}
		
		private function updateSuggest(hint:String):void{
			_errorHint.text = hint;
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
			_selectLocalImage.label = "本地文件";
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
		
		private function createCloseBtn():void{
			var closeIconPath:String = "assets/closeme.png";
			_closemeBtn = new SimpleImage(closeIconPath);
			_closemeBtn.buttonMode = true;
			_closemeBtn.x = _width-26;
			_closemeBtn.y = 0;
			_closemeBtn.addEventListener(MouseEvent.CLICK, closeMe);
			this.addChild(_closemeBtn);
		}
		
		//处理两个对象的事件：
		//点击关闭按钮，上传成功
		//所以用Event类型事件
		private function closeMe(evt:Event):void{			
			_context.removeChild(this);
			//清除预览图
			if(_loadFileBitmap)
				removeChild(_loadFileBitmap);
			_loadFileBitmap = null;
			//清除发送进度条
			if(_loading && this.contains(_loading))
				this.removeChild(_loading);
			//清除输入框文字
			_isOriginalCheck.selected = false;
			_tagsInput.text = "";
			_descInput.text = "";
			//清除错误提示
			_errorHint.text = "";
			_sendBtn.enabled = true;
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
		
		private function createSubmitBtn():void{
			_sendBtn = new Button();
			_sendBtn.label = "发送";
			//这个尺寸跟登陆按钮大小一致
			_sendBtn.setSize(60, 28);
			
			_sendBtn.setStyle(ButtonSkin.style_backgroundColors, 
				[StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN, StyleParams.HEADERBAR_BOTTOM_LIGHTGREEN]);
			_sendBtn.setStyle(ButtonSkin.style_overBackgroundColors, 
				[StyleParams.HEADERBAR_TOP_LIGHTGREEN, StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN]);
			_sendBtn.setStyle(ButtonSkin.style_borderColors, [0x999999, 0x000000]);
			
			_sendBtn.setStyle(Button.style.labelStyles, [
				Label.style.color, 0xEEEEEE,				
				Label.style.size, 12
			]);
			_sendBtn.setStyle(Button.style.overLabelStyles, [
				Label.style.color, 0xEEEEEE,				
				Label.style.size, 12
			]);
			_sendBtn.setStyle(Button.style.selectedLabelStyles, [
				Label.style.color, 0xEEEEEE,				
				Label.style.size, 12
			]);
			_sendBtn.x = _elementStartX+_maxLoadImgWidth+_elementPadding+14;
			_sendBtn.y = _descInput.y+_descInput.height+_elementPadding;
			_sendBtn.addEventListener(ButtonEvent.CLICK, sendPicture);
			
			this.addChild(_sendBtn);
		}
		
		private function sendPicture(evt:Event):void{
			
			if(!_manager.availableImgData){
				updateSuggest("先选择图像");
				return;
			}
			
			if(_tagsInput.text.length==0 || _descInput.text.length==0){
				updateSuggest("标签和描述不能为空");
				return;
			}
			
			if(!_loading) _loading = new BusyIndicator(24);
			_loading.x = _loadingX;
			_loading.y = _loadingY;
			this.addChild(_loading);
			//清除错误提示
			_errorHint.text = "";
			_sendBtn.enabled = false;
			
			//提交图片
			_manager.uploadPicture(_isOriginalCheck.selected, _tagsInput.text, _descInput.text);
		}
		
		private function createModalLayer(evt:Event):void{
			if(!_modalOverlay)
				_modalOverlay = new CasaSprite();
			
			_modalOverlay.graphics.beginFill(0x999999,0.1);
			_modalOverlay.graphics.drawRect(0,0,InitParams.appWidth,InitParams.appHeight);
			_modalOverlay.graphics.endFill();
			_context.addChild(_modalOverlay);
			//注意：置于窗口的下面
			_context.swapChildren(_modalOverlay,this);
			
		}		
		private function removeModalLayer(evt:Event):void{
			_context.removeChild(_modalOverlay);
		}
		
		private function showUploadImg(evt:Event):void{
			if(!_loader)
				_loader=new Loader() ;
			//载入文件对象的字节数据，牛啊
			_loader.loadBytes(_manager.availableImgData);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadCompleteHandle);
		}
		
		private function onLoadCompleteHandle(evt:Event):void {
			//先移除上一个图片
			if(_loadFileBitmap && this.contains(_loadFileBitmap))
				this.removeChild(_loadFileBitmap);
			//获得新图
			_loadFileBitmap =evt.target.content as Bitmap;
			//稍微做个偏移，好让底框露出来
			_loadFileBitmap.x = _elementStartX+1;
			_loadFileBitmap.y = _loadImgY+1;
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
			_errorHint.text = "";
		}
		
		public override function set width(w:Number):void{
			_width = w;
		}
		
		public override function set height(h:Number):void{
			_height = h;
		}
		
		public override function get width():Number{
			return _width;
		}
		
		public override function get height():Number{
			return _height;
		}
		
		
	} //end of class
}