package com.pintu.widgets{
	
	import com.greensock.TweenLite;
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.events.*;
	import com.pintu.utils.*;
	import com.pintu.vos.*;
	
	import flash.display.JointStyle;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	import org.casalib.display.CasaTextField;
	
	/**
	 * 只有基本信息的手机图片
	 * 图片、时间、是否原创、浏览次数
	 */ 
	public class PicItemView extends CasaSprite{
		
		private var _data:TPicItem;
				
		//图片加载结束标志
		private var imgLoadedFlag:Boolean;	
		//详情内容
		private var mobImage:SimpleImage;
		//图片未展示前出现
		private var mobImgPlaceHolder:CasaShape;
		private var imgLoading:CasaTextField;	
		private var imgInfoHolder:CasaSprite;
		
		//左边空点距离
		private var _xStartOffset:Number = 2;
		//上面有工具栏，给工具栏让位
		private var _yStartOffset:Number = 2;	
		//默认图片大小，图片加载结束时改变
		private var _mobImgDefaultSize:Number = 440;
		private var _mobImgWidth:Number = _mobImgDefaultSize;
		private var _mobImgHeight:Number = _mobImgDefaultSize;
		
		public function PicItemView(data:TPicItem){
			super();
			_data = data;
			
			//draw: mobImgPlaceHolder
			drawImgePlaceHolder();			
			//draw: imgLoading
			drawLoadingText();
			
			//先生成图片，等图片加载完成后，再生成其他内容
			mobImage = new SimpleImage(data.mobImgUrl);
			mobImage.addEventListener(PintuEvent.IMAGE_LOADED,imgLoaded);
			this.addChild(mobImage);		
			
			//点击查看详情
			this.addEventListener(MouseEvent.CLICK, getDetails);
		}
		
		private function imgLoaded(evt:PintuEvent):void{
			//先都移除掉，重新绘制重新排列层级关系
			removeChild(mobImage);
			removeChild(mobImgPlaceHolder);
			removeChild(imgLoading);
			
			//固定图片宽度为默认宽度让文字都能对齐
			//这个数据是绘制其他内容的依据
			_mobImgWidth = InitParams.DEFAULT_BIGPIC_WIDTH;
			_mobImgHeight = mobImage.bitmap.height;
			
			//----------- imgInfoHolder ----------------
			//右侧详情所在背景，先放让它能位于图的底部，使得图片的一部分绘制内容能露出来			
			buildPicInfoBlackBG();
			//图片相关内容：靠右侧放置，只有展开的评论在图片下面显示			
			buildPicRelateInfo();		
			
			//---------------  mobImgPlaceHolder -----------------
			//重绘占位符，因为图片高度改变了，所以占位符也要相应改变				
			drawImgePlaceHolder();
			
			//----------------- mobImage -------------------------
			//白色边框加黑色带三角形边线，指向原创			
			drawImageTriangleBorder();
			//如果图片宽度不够440，让图片靠右与所有的图片对齐
			if(mobImage.bitmap.width<InitParams.DEFAULT_BIGPIC_WIDTH){
				mobImage.x = (InitParams.DEFAULT_BIGPIC_WIDTH-mobImage.bitmap.width);
			}
			//这回该重新显示图片了
			this.addChild(mobImage);	
			
			imgLoadedFlag = true;
			
			//图片加载结束，第一次通知外围，渲染完成
			rendered();	
			
		}
		
		private function buildPicInfoBlackBG():void{
			imgInfoHolder = new CasaSprite();
			//画背景色
			imgInfoHolder.graphics.beginFill(StyleParams.PICDETAIL_BACKGROUND_THIRD);
			var rightBlackColumnWidth:Number = 
				InitParams.GALLERY_WIDTH - _mobImgWidth;
			imgInfoHolder.graphics.drawRect(_mobImgWidth, _yStartOffset,
				rightBlackColumnWidth,_mobImgHeight);
			imgInfoHolder.graphics.endFill();
			
			//TODO, 画个类似Path的竖线
			//2011/12/08
			var vLineXoffset:Number = 20;
			var vLineThickness:int = 4;
			imgInfoHolder.graphics.lineStyle(vLineThickness,StyleParams.PICDETAIL_BACKGROUND_GRAY, 1, true, "normal", JointStyle.BEVEL);
			imgInfoHolder.graphics.moveTo(_mobImgWidth+vLineXoffset, 3);
			imgInfoHolder.graphics.lineTo(_mobImgWidth+vLineXoffset, _mobImgHeight+1);
			
			
			this.addChild(imgInfoHolder);
			//从右侧划滑出
			TweenLite.from(imgInfoHolder, 0.3, {x: rightBlackColumnWidth});
		}
		
		/**
		 * imgInfoHolder中一行放置三项内容：<br/>
		 * 是否原创、浏览次数、时间
		 */ 
		private function buildPicRelateInfo():void{
			var dark:uint = StyleParams.DEFAULT_TEXT_COLOR;
			var green:uint = StyleParams.GREEN_TEXT_COLOR;
			var normalTXTSize:int = 12;
			var bigTXTSize:int = 16;
			
			var marging:Number = 44;
			var textItemVGap:Number = 24;
			var textItemHGap:Number = 20;
			var startX:Number = _mobImgWidth+marging;			
			var startY:Number = 54;	
			
			//是否原创
			var isOriginalStr:String = _data.isOriginal=="0"?"非原创":"原创";
			var isOriginal:Boolean = _data.isOriginal=="0"?false:true;
			var origColor:uint;
			var origFontSize:int;
			if( !isOriginal){//非原创
				origColor = dark;
				origFontSize = normalTXTSize;
			}else{//原创
				origColor = green;
				origFontSize = bigTXTSize;
			}
			
			var isOriginalTF:SimpleText = new SimpleText(isOriginalStr, origColor, origFontSize, true);
			isOriginalTF.x = startX;
			isOriginalTF.y = startY+textItemVGap;
			imgInfoHolder.addChild(isOriginalTF);
			
			//在原创的旁边竖线上，画个圆圈
			//非原创，用灰色圈，原创，用绿色圈
			var origCircleRadius:Number = 10;
			var vLineXoffset:Number = 20;
			var origCircleX:Number = _mobImgWidth+vLineXoffset;
			var origCircleY:Number = isOriginalTF.y+10;
			//跟竖线一样的颜色
			imgInfoHolder.graphics.lineStyle(2, StyleParams.PICDETAIL_BACKGROUND_GRAY);
			if(isOriginal){//画绿色圈
				imgInfoHolder.graphics.beginFill(green, 1);
			}else{//画与背景色相同颜色圈
				imgInfoHolder.graphics.beginFill(StyleParams.PICDETAIL_BACKGROUND_THIRD, 1);
			}
			imgInfoHolder.graphics.drawCircle(origCircleX, origCircleY, origCircleRadius);
			imgInfoHolder.graphics.endFill();
			//里边再画个白圈
			imgInfoHolder.graphics.lineStyle(2, 0xFFFFFF);
			imgInfoHolder.graphics.drawCircle(origCircleX, origCircleY, origCircleRadius-2);						
			
			//发布时间，靠右边放置，这点跟手机版类似
			var pubTimeStr:String = PintuUtils.getRelativeTimeFromNow(_data.publishTime);
			var pubTimeTF:SimpleText = new SimpleText(pubTimeStr,dark, normalTXTSize);
			pubTimeTF.x = InitParams.GALLERY_WIDTH - pubTimeTF.textWidth-textItemHGap;
			pubTimeTF.y = isOriginalTF.y;
			imgInfoHolder.addChild(pubTimeTF);						
			
			//浏览次数，在发布时间的左边
			var browseCountStr:String = "浏览 "+_data.browseCount;
			var browseCountTF:SimpleText = new SimpleText(browseCountStr,dark, normalTXTSize);
			browseCountTF.x = pubTimeTF.x - browseCountTF.textWidth - textItemHGap;
			browseCountTF.y = isOriginalTF.y;
			imgInfoHolder.addChild(browseCountTF);	
		}
		
		private function drawImageTriangleBorder():void{
			//在图片mobImage中添加个shape，盖住图片
			var frameThickness:int = 4;
			var mobImageMask:CasaShape = new CasaShape();			
			
			var offset:int = 2;
			var originalY:Number = 80;
			var triangleSize:int = 14;
			var imageWidth:Number = mobImage.width;
			var imageHeight:Number = mobImage.height;
			//起点
			var triangleStartX:Number = imageWidth+1;
			var triangleStartY:Number = originalY;
			//三角形顶点
			var triangleVertixX:Number = imageWidth+triangleSize/2;
			var triangleVertixY:Number = originalY+triangleSize/2;
			//终点
			var triangleEndX:Number = imageWidth+1;
			var triangleEndY:Number = originalY+triangleSize;				
			
			//直角白色角边框
			mobImageMask.graphics.lineStyle(frameThickness, 0xFFFFFF, 1, true, "normal", null, JointStyle.MITER);
			mobImageMask.graphics.drawRect(frameThickness, frameThickness, 
				mobImage.width-frameThickness, mobImage.height-frameThickness);
			
			//用白色填充下三角形
			mobImageMask.graphics.beginFill(0xFFFFFF);
			mobImageMask.graphics.moveTo(triangleStartX, triangleStartY+offset);
			mobImageMask.graphics.lineTo(triangleVertixX-offset, triangleVertixY);
			mobImageMask.graphics.lineTo(triangleEndX, triangleEndY-offset);
			mobImageMask.graphics.lineTo(triangleStartX, triangleStartY+offset);
			mobImageMask.graphics.endFill();
			
			//墨绿细边框，在白色边框的外围，有个三角对圆圈
			mobImageMask.graphics.lineStyle(1, StyleParams.DEFAULT_DARK_GREEN, 1,true, "normal", null, JointStyle.MITER);
			//左上角
			mobImageMask.graphics.moveTo(offset,offset);
			//右上角
			mobImageMask.graphics.lineTo(imageWidth+1,offset);
			//右侧三角开始
			mobImageMask.graphics.lineTo(triangleStartX, triangleStartY);
			//右侧三角形顶点
			mobImageMask.graphics.lineTo(triangleVertixX, triangleVertixY);
			//右侧三角结束
			mobImageMask.graphics.lineTo(triangleEndX, triangleEndY);
			//右下角
			mobImageMask.graphics.lineTo(imageWidth+1, imageHeight+1);
			//左下角
			mobImageMask.graphics.lineTo(offset, imageHeight+1);
			//回左上角
			mobImageMask.graphics.lineTo(offset,offset);					
			
			mobImage.addChild(mobImageMask);
		}
		
		private function drawImgePlaceHolder():void{
			//draw mobile image placeholder...			
			mobImgPlaceHolder = new CasaShape();	
			//每次绘制前清空
			mobImgPlaceHolder.graphics.clear();						
			//填充
			mobImgPlaceHolder.graphics.beginFill(StyleParams.PICDETAIL_BACKGROUND_THIRD);
			//矩形，这个高度重绘时，改变，但是宽度保持不变
			mobImgPlaceHolder.graphics.drawRect(_xStartOffset, _yStartOffset, _mobImgDefaultSize, _mobImgHeight);
			mobImgPlaceHolder.graphics.endFill();
			
			this.addChild(mobImgPlaceHolder);			
		}
		
		private function drawLoadingText():void{
			imgLoading = new CasaTextField();			
			imgLoading.autoSize = "left";
			imgLoading.defaultTextFormat = new TextFormat(null,14);
			
			imgLoading.text = "loading...";
			imgLoading.x = _xStartOffset+180;
			imgLoading.y = _yStartOffset+220;
			this.addChild(imgLoading);
		}
		
		private function getDetails(event:MouseEvent):void{
			//如果图片没有加载完成，不允许查看详情
			if(!imgLoadedFlag) return;
			dispatchEvent(new PintuEvent(PintuEvent.GETPICDETAILS,_data.id));
		}
		
		/**
		 * 通知图片容器，重新排列图片位置<br/>
		 * _picBuilder._context负责监听render事件，重新排列图片<br/>
		 * 
		 */ 
		private function rendered():void{
			//派发尺寸改变事件	
			if(this.stage) {
				this.stage.invalidate();	
//				Logger.debug("pic detail view rendered...");
			}else{
				Logger.warn("stage in pic detail view lost!");
			}
		}
		
	} //end of class
}