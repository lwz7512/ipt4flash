package com.pintu.widgets{
	
	import com.adobe.crypto.MD5;
	import com.adobe.serialization.json.JSON;
	import com.greensock.TweenLite;
	import com.hurlant.crypto.hash.MD2;
	import com.hurlant.crypto.hash.MD5;
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.StyleParams;
	import com.pintu.events.*;
	import com.pintu.utils.Logger;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * 迷你广告，也叫微广告
	 * 以滚动的方式显示文字或者图片
	 * 
	 * 2012/03/02
	 */ 
	public class MiniAds extends AbstractWidget{
		
		private var _width:Number = 254;
		private var _height:Number = 36;
		
		private var _mask:Shape;
		private var _loading:BusyIndicator;
		
		//保存取回的广告数据
		private var adObjs:Array;
		//刚开始没进入数组
		private var adItemIndex:int = -1;
		
		private var currentAd:DisplayObject;
		private var tempDO:DisplayObject;
		
		//单条广告停留时间，毫秒
		private var adStayTime:Number = 6000;
		
		private var rollingTimer:Timer;
		
		private var defaultAds:String = "精彩马上呈现...";
		private var defaultAdTF:SimpleText;
		
		//新增图片缓存处理，节省服务器资源
		//2012/03/09
		private var imageCache:Dictionary;
		
		public function MiniAds(model:IPintu){
			super(model);
			
			buildUI();
			
			imageCache = new Dictionary();
			
			rollingTimer = new Timer(adStayTime);
			rollingTimer.addEventListener(TimerEvent.TIMER, timeToRolling);
			rollingTimer.start();
		}
		
		private function timeToRolling(evt:TimerEvent):void{
			if(this.contains(defaultAdTF)){
				this.removeChild(defaultAdTF);
			}
			showRollingAds();
		}
		
		private function buildUI():void{
			_mask = new Shape();
			_mask.graphics.beginFill(0xCCCCCC);
			_mask.graphics.drawRect(0,0,_width,_height);
			_mask.graphics.endFill();			
			this.addChild(_mask);
			//设置广告条的遮罩
			this.mask = _mask;					
			
			defaultAdTF = new SimpleText(defaultAds, 0xFFFFFF);
			defaultAdTF.x = 30;
			defaultAdTF.y = 7;
			defaultAdTF.width = _width;
			this.addChild(defaultAdTF);
			
			var countDown:CountDownCircle = new CountDownCircle(10,5,0xCCCCCC);
			countDown.x = _width-30;
			//放到标题栏一半的高度
			countDown.y = 18;
			this.addChild(countDown);
		}
				
		
		private function showRollingAds():void{
			if(!adObjs) return;
					
			//播放下一条广告
			adItemIndex ++;
			if(adItemIndex>(adObjs.length-1)){
				adItemIndex = 0;
			}
			
			//新广告数据
			var newadDat:Object = adObjs[adItemIndex];
			//新的从顶部落下
			tempDO = createAdItemByType(newadDat["type"]);
			//先放在外面
			tempDO.y = -36;
			tempDO.x = 0;
			//图片要循环使用，隐藏时透明度变为0了，这里恢复
			tempDO.alpha = 1;
			
			//设置内容和点击事件
			if(tempDO is HandCursorLink){
				HandCursorLink(tempDO).text = newadDat["content"];				
			}else if(tempDO is LazyImage){
				//ADD IMAGE HERE...
				LazyImage(tempDO).imgPath = newadDat["imgPath"];				
			}
			//添加交互
			tempDO.addEventListener(MouseEvent.CLICK, openBrowse);	
			//显示
			this.addChild(tempDO);
			
			//落下来，稍微时间长点，图片和文字位置稍微不同
			if(tempDO is HandCursorLink){
				TweenLite.to(tempDO, 0.6, {y : 7, onComplete: rememberAd});				
			}else if(tempDO is LazyImage){
				TweenLite.to(tempDO, 0.6, {y : -2, onComplete: rememberAd});
			}
			
			//当前的往下面走并迅速消失
			if(currentAd){
				//落下来
				TweenLite.to(currentAd, 0.3, {y : _height, alpha : 0, onComplete: destroyAdItem});
			}
			
		}
		
		private function openBrowse(evt:MouseEvent):void{
			var url:String = adObjs[adItemIndex]["link"];
			//没有链接内容，不弹出窗口
			if(!url || url.length==0) return;
			
			if(url.indexOf("http")==-1){
				url = "http://"+url;
			}
			var address:URLRequest = new URLRequest(url);
			navigateToURL(address, "_blank");
		}
		
		private function rememberAd():void{
			currentAd = tempDO;			
		}
		
		private function destroyAdItem():void{
			if(this.contains(currentAd)) {
				this.removeChild(currentAd);
				currentAd.removeEventListener(MouseEvent.CLICK, openBrowse);
				currentAd = null;
			}
		}
		
		private function createAdItemByType(type:String):DisplayObject{
			if(type=="text"){				
				var liteTxt:HandCursorLink = new HandCursorLink("...", StyleParams.MENUBAR_TOP_ICE);
				liteTxt.filters = [new DropShadowFilter(1,45,0x333333,1,0,0)];
				return liteTxt;
			}else if(type=="image"){
				//先看缓存中有没有
				var imgURL:String = adObjs[adItemIndex]["imgPath"];
				var imgKey:String = com.adobe.crypto.MD5.hash(imgURL);
				var result:LazyImage = imageCache[imgKey];
				if(result){
					return result;
				}
				//没有就创建一个
				var image:LazyImage = new LazyImage(null);
				image.visibleWidth = _width;
				image.visibleHeight = _height;
				image.buttonMode = true;
				image.useHandCursor = true;
				image.mouseChildren = false;
				//放入缓存
				imageCache[imgKey] = image;
				
				return image;
			}
			return null;
		}
		
		override protected function initModelListener(evt:Event):void{
			super.initModelListener(evt);
			//添加模型事件，触发方法
			PintuImpl(_clonedModel).addEventListener(ApiMethods.GETMINIADS, adsDataHandler);
			//FIXME, TO GET ADS DATA...
			_clonedModel.getMiniAds();
			
			_loading = new BusyIndicator();
			_loading.y = 6;
			this.addChild(_loading);
		}
		
		private function adsDataHandler(evt:Event):void{
			if(evt is ResponseEvent){
				var adStr:String = ResponseEvent(evt).data;
				adObjs = JSON.decode(adStr);				
				for each(var obj:Object in adObjs){
					//如果是图片广告
					if(obj["type"]=="image")
						//将文件路径转换为URL
						obj["imgPath"] = _clonedModel.composeImgUrlByRelativePath(obj["imgPath"]);
				}
				if(this.contains(_loading)){
					this.removeChild(_loading);
				}
			}
			if(evt is PTErrorEvent){
				Logger.error("get mini ads error!!!");
			}
			
		}
		
		override protected function cleanUpModelListener(evt:Event):void{
			//先移除事件
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.GETMINIADS, adsDataHandler);
			
			rollingTimer.stop();
			rollingTimer.removeEventListener(TimerEvent.TIMER,timeToRolling);
			rollingTimer = null;
			
			//后清空模型
			super.cleanUpModelListener(evt);	
		}
		
		override public function get width():Number{
			return _width;
		}
		override public function get height():Number{
			return _height;
		}
		
	} //end of class
}