package com.pintu.window{
	
	import com.adobe.images.JPGEncoder;
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.controller.FileManager;
	import com.pintu.controller.GlobalController;
	import com.pintu.events.PintuEvent;
	import com.sibirjak.asdpc.button.ButtonEvent;
	import com.sibirjak.asdpc.textfield.TextInput;
	import com.sibirjak.asdpcbeta.slider.Slider;
	import com.sibirjak.asdpcbeta.slider.SliderEvent;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	
	public class UserEditWin extends EditWinBase{
		
		private var _manager:FileManager;
		
		private var _maxLoadImgWidth:Number = 300;
		private var _maxLoadImgHeight:Number = 220;
		private var _maxShowBitmapSize:Number = 600;
		//取景窗口大小
		private var vpSize:Number = 100;
		
		private var _loader:Loader;		
		private var _clonedBitmap:Bitmap;
		private var _clonedImage:CasaSprite;
		
		private var _selectLocalImage:IconButton;
		private var _selectWebCamera:IconButton;
		private var _slider:Slider;
		private var _nickName:MustTextInput;
		
		private var _mouseDownInImage:Boolean;
		private var _oldGlobalMouseX:Number;
		private var _oldGlobalMouseY:Number;
		
		private var _localImagePath:String = "assets/folder32.png";
		private var _cameraImagePath:String = "assets/webcamera32.png";
		
		
		public function UserEditWin(ctxt:Stage, manager:FileManager){
			super(ctxt, 400, 350, "编辑头像和昵称");
			
			_manager = manager;
			_manager.addEventListener(FileManager.IMG_INMEMLOAD, showUploadImg);
			_manager.addEventListener(FileManager.IMG_UPLOAD_SUCCESS, uploadSuccess);
			_manager.addEventListener(FileManager.IMG_UPLOAD_FAILURE, uploadError);			
			
			createFormElements();			
			createBitmapAndMask();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onWindowAdded);
		}
		
		private function onWindowAdded(evt:Event):void{
			this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpInImage);
			//填充登陆用户昵称
			_nickName.text = GlobalController.account;
		}
		
		
		/**
		 * 从上到下图层顺序：
		 * ----------- 取景小窗口层 ------------
		 * ----------- 克隆图片层 --------------
		 * ----------- 黑色半透明层 ------------
		 * ----------- 图片遮罩层 --------------
		 * ----------- Loader层 ----------------
		 */ 
		private function createBitmapAndMask():void{
			
			var imgMask:CasaShape = new CasaShape();
			imgMask.x = _elementStartX+1;
			imgMask.y = _elementStartY+1;
			imgMask.graphics.beginFill(0x000000);
			imgMask.graphics.drawRect(0,0,_maxLoadImgWidth-1,_maxLoadImgHeight-1);
			imgMask.graphics.endFill();
			//先放加载器
			_loader=new Loader() ;
			_loader.x = _elementStartX+1;
			_loader.y = _elementStartY+1;
			_loader.mask = imgMask;			
			this.addChild(_loader);
			//图片遮罩在上面
			this.addChild(imgMask);			
			
			//再放黑色半透明层
			var translucent:CasaSprite = new CasaSprite();
			translucent.x = _elementStartX;
			translucent.y = _elementStartY;
			translucent.graphics.beginFill(0x000000, 0.8);
			translucent.graphics.drawRect(0,0,_maxLoadImgWidth,_maxLoadImgHeight);
			translucent.graphics.endFill();
			translucent.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownInImage);
			
			this.addChild(translucent);
			
			//与缩放后的原图一样
			_clonedImage = new CasaSprite();
			_clonedImage.x =  _elementStartX+1;
			_clonedImage.y = _elementStartY+1;
			//屏蔽对下面层的鼠标操作
			_clonedImage.mouseEnabled = false;
			_clonedImage.mouseChildren = false;
			
			
			var viewPort:CasaShape = new CasaShape();
			viewPort.x = _elementStartX+(_maxLoadImgWidth-vpSize)/2;
			viewPort.y = _elementStartY+(_maxLoadImgHeight-vpSize)/2;
			viewPort.graphics.beginFill(0x000000);
			viewPort.graphics.drawRect(0,0,vpSize,vpSize);
			viewPort.graphics.endFill();
			
			_clonedImage.mask = viewPort;
			//可见的图片
			this.addChild(_clonedImage);
			//最后放取景层
			this.addChild(viewPort);
			
		}
		
		private function mouseDownInImage(evt:MouseEvent):void{
			if(!_clonedBitmap) return;
			
			_mouseDownInImage = true;
			
			//记下初始位置
			_oldGlobalMouseX = evt.stageX;
			_oldGlobalMouseY = evt.stageY;	
			
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveImage);
			
		}
		private function mouseUpInImage(evt:MouseEvent):void{
			if(!_clonedBitmap) return;
			
			_mouseDownInImage = false;
			
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveImage);
			
		}
		
		private function moveImage(evt:MouseEvent):void{
			if(!_mouseDownInImage) return;
			
			var mouseGlobalX:Number = evt.stageX;
			var mouseGlobalY:Number = evt.stageY;
			
			var moveDiffX:Number = mouseGlobalX-_oldGlobalMouseX;
			var moveDiffY:Number = mouseGlobalY-_oldGlobalMouseY;
			
			var localsp:Point = new Point(_elementStartX,_elementStartY);
			var imgGlobalStart:Point = this.localToGlobal(localsp);
			var localep:Point = new Point(_elementStartX+_maxLoadImgWidth,_elementStartY+_maxLoadImgHeight);
			var imgGlobalEnd:Point = this.localToGlobal(localep);
			
			var mouseInImage:Boolean = false;
			if(mouseGlobalX>imgGlobalStart.x && mouseGlobalX<imgGlobalEnd.x
				&& mouseGlobalY>imgGlobalStart.y && mouseGlobalY<imgGlobalEnd.y){
				mouseInImage = true;
			}else{
				mouseInImage = false;
			}
			
			if(mouseInImage){
				//移动两张图片
				_loader.content.x += moveDiffX;
				_loader.content.y += moveDiffY;
				_clonedBitmap.x += moveDiffX;
				_clonedBitmap.y += moveDiffY;				
				
				//记下来下次用
				_oldGlobalMouseX = mouseGlobalX;
				_oldGlobalMouseY = mouseGlobalY;				
			}
			
		}
		
		private function showUploadImg(evt:Event):void{
			if(!shouldDo()) return;					
				
			//载入文件对象的字节数据，牛啊
			_loader.loadBytes(_manager.availableImgData);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadCompleteHandle);
			
		}
		
		private function uploadSuccess(evt:Event):void{
			if(!shouldDo()) return;
			closeMe(null);
			//刷新用户资料
			this.dispatchEvent(new PintuEvent(PintuEvent.REFRESH_USER,null));
		}
		
		private function uploadError(evt:Event):void{
			if(!shouldDo()) return;
			updateSuggest("上传失败");
		}	
		
		//克隆一个图放在上面可以取景
		private function onLoadCompleteHandle(evt:Event):void {
			
			//准备工作：先清理上一个
			if(_clonedImage.numChildren)
				_clonedImage.removeChildAt(0);
			//恢复百分比
			_slider.value = 100;
			
			//获得新图
			var rawBitmap:Bitmap =evt.target.content as Bitmap;
			var clonedBD:BitmapData = new BitmapData(rawBitmap.width, rawBitmap.height);
			clonedBD.draw(rawBitmap);
			_clonedBitmap = new Bitmap(clonedBD);			
			_clonedImage.addChild(_clonedBitmap);
			
			
			//清除错误提示
			updateSuggest("");
		}	
		
		
		//点击提交触发
		override protected function submit(evt:ButtonEvent):void{	
			//先校验内容输入
			if(!_clonedBitmap){
				updateSuggest("先选择图像");
				return;
			}
			
			if(_nickName.text.length==0 || _nickName.text.length==0){
				updateSuggest("昵称不能为空");
				return;
			}
			
			super.submit(evt);		
			
			//调用文件管理器方法提交图片和文字
			var avatar:ByteArray = getViewportImageData();
			var nickName:String = _nickName.text;
			_manager.uploadAvatar(avatar,nickName);
			
		}
		
		private function getViewportImageData():ByteArray{
			if(!_clonedBitmap) return null;
			
			var avatarBD:BitmapData = new BitmapData(vpSize, vpSize);
			//取景窗口左上角，相对于图片位置
			var locViewportX:Number = (_maxLoadImgWidth-vpSize)/2;
			var locViewportY:Number = (_maxLoadImgHeight-vpSize)/2;
			
			var scale:Number = _slider.value/100;
			
			var m:Matrix = new Matrix();
			//缩放
			m.scale(scale, scale);
			//将原图取景点，向左上角移动到avatarBD绘制原点
			//所以要偏移locViewportX和locViewportY
			m.translate(_clonedBitmap.x-locViewportX , _clonedBitmap.y-locViewportY);		
			//需要考虑移动和缩放
			avatarBD.draw(_clonedBitmap, m);									
			
			var byteArray : ByteArray = new JPGEncoder(90).encode(avatarBD);
			//FIXME, 必须移动到头部
			byteArray.position = 0;
			
			return byteArray;
		}
		
		//关闭时清理输入框，恢复初始值
		override protected function reset():void{
			super.reset();
			//清除预览图
			_loader.unload();
			//清除取景图
			if(_clonedBitmap) 
				_clonedImage.removeChild(_clonedBitmap);
			_clonedBitmap = null;
						
			_slider.value = 100;
			//清除输入框文字
			_nickName.text = "";
		}		
		
		//移除克隆模型的事件监听，并销毁克隆模型
		//整个HomePage模块被移除时，才调用这个方法
		override public function destroy():void{
			super.destroy();
			
			_manager = null;
			
			//如果没用到模型，就此打住
			if(!cloneModel) return;
			
			//REMOVE MODEL EVENT LISTENER...						
			cloneModel.destory();		
		}
		
		override protected function drawBackground():void{
			super.drawBackground();
			
			//画个图片占位框
			this.graphics.lineStyle(1, 0x666666, 1, true);
			this.graphics.drawRect(_elementStartX, _elementStartY, _maxLoadImgWidth, _maxLoadImgHeight);
			
		}
		
		private function createFormElements():void{
			createLocalImageBtn();
			createWebCameraBtn();
			createSlider();
			createNickName();
		}
		
		private function createSlider():void{
			var sliderStartY:Number = _elementStartY+_maxLoadImgHeight+4;
			
			var zero:SimpleText = new SimpleText("0%");
			zero.x = _elementStartX;
			zero.y = sliderStartY;
			this.addChild(zero);
			
			_slider = new Slider();
			_slider.setSize(_maxLoadImgWidth-50, 16);
			_slider.x = _elementStartX+20;
			_slider.y = sliderStartY;
			_slider.snapInterval = 1;
			_slider.minValue = 0;
			_slider.maxValue = 100;
			_slider.value = 100;
			_slider.addEventListener(SliderEvent.CHANGE, resizeImage);
			this.addChild(_slider);
			
			var hundred:SimpleText = new SimpleText("100%");
			hundred.x = _elementStartX+_maxLoadImgWidth-30;
			hundred.y = sliderStartY;
			this.addChild(hundred);
		}
		
		private function resizeImage(evt:SliderEvent):void{
			var value:Number = evt.value;			
			
			if(_loader.content){
				var m:Matrix =  new Matrix();
				m.scale(value/100,value/100);

				_loader.content.transform.matrix = m;
				_clonedBitmap.transform.matrix = m;
			}
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
			_selectLocalImage.label = "选择照片";
			_selectLocalImage.x = _elementStartX+_maxLoadImgWidth+_elementPadding+14;
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
			_selectWebCamera.x = _elementStartX+_maxLoadImgWidth+_elementPadding+14;
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
		
		private function createNickName():void{
			_nickName = new MustTextInput();
//			_nickName.defaultText = "输入新昵称";			
			_nickName.setSize(300,28);
			_nickName.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			_nickName.setStyle(TextInput.style.size,12);
			_nickName.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);			
			_nickName.setStyle(TextInput.style.maxChars,12);			
			_nickName.x = _elementStartX;
			_nickName.y = _elementStartY+_maxLoadImgHeight+30;			
			this.addChild(_nickName);
		}
		
		
		
	} //end of class
}