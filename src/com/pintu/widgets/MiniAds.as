package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.greensock.TweenLite;
	import com.pintu.api.*;
	import com.pintu.common.BusyIndicator;
	import com.pintu.common.LazyImage;
	import com.pintu.common.SimpleLinkTxt;
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
	import flash.utils.Timer;
	
	import org.as3commons.collections.utils.NullComparator;
	
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
		private var adStayTime:Number = 3000;
		
		private var rollingTimer:Timer;
		
		public function MiniAds(model:IPintu){
			super(model);
			
			buildUI();
			
			rollingTimer = new Timer(adStayTime);
			rollingTimer.addEventListener(TimerEvent.TIMER, timeToRolling);
			rollingTimer.start();
		}
		
		private function timeToRolling(evt:TimerEvent):void{
			Logger.debug("timeToRolling....");
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
			
//			_loading = new BusyIndicator();
//			this.addChild(_loading);
			
			adObjs = [];
			adObjs.push({id:"aaaa", type:"text", content:"爱品图：随时随地，发现创意。。。", link:"ipintu.com"});
			adObjs.push({id:"bbbb", type:"text", content:"微博：随时随地发现身边的新鲜事儿", link:"weibo.com"});
			adObjs.push({id:"cccc", type:"text", content:"点点：文艺范儿的轻博客社区", link:"diandian.com"});
			adObjs.push({id:"dddd", type:"text", content:"苏打苏塔：设计量贩铺", link:"sudasuta.com"});
			
		}
		
		
		override protected function initModelListener(evt:Event):void{
			super.initModelListener(evt);
			//TODO, 添加模型事件，触发方法
			PintuImpl(_clonedModel).addEventListener(ApiMethods.GETMINIADS, adsDataHandler);
//			_clonedModel.getMiniAds();
		}
		
		private function adsDataHandler(evt:Event):void{
			if(evt is ResponseEvent){
				var adStr:String = ResponseEvent(evt).data;
				adObjs = JSON.decode(adStr);				
				
				if(this.contains(_loading)){
					this.removeChild(_loading);
				}
			}
			if(evt is PTErrorEvent){
				Logger.error("get mini ads error!!!");
			}
			
		}
		
		private function showRollingAds():void{
			if(!adObjs) return;
			
			Logger.debug("showRollingAds....");
			
			//增加数组下标
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
			
			//设置内容和点击事件
			if(tempDO is SimpleLinkTxt){
				SimpleLinkTxt(tempDO).text = newadDat["content"];
				SimpleLinkTxt(tempDO).addEventListener(MouseEvent.CLICK, openBrowse);
			}else if(tempDO is LazyImage){
				//TODO, ADD IMAGE HERE...
				
			}
			//显示
			this.addChild(tempDO);
			
			//落下来，稍微时间长点
			TweenLite.to(tempDO, 0.6, {y : 9, onComplete: rememberAd});
			
			//当前的往下面走并消失
			if(currentAd){
				//落下来
				TweenLite.to(currentAd, 0.5, {y : 36, onComplete: destroyAdItem});
			}
			
		}
		
		private function openBrowse(evt:MouseEvent):void{
			var url:String = adObjs[adItemIndex]["link"];
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
			if(this.contains(currentAd)) this.removeChild(currentAd);
		}
		
		private function createAdItemByType(type:String):DisplayObject{
			if(type=="text"){				
				var liteTxt:SimpleLinkTxt = new SimpleLinkTxt("...", StyleParams.DEFAULT_BLACK_COLOR);
				liteTxt.filters = [new DropShadowFilter(1,45,0xFFFFFF,1,0,0)];
				return liteTxt;
			}else if(type=="image"){
				var image:LazyImage = new LazyImage(null);
				return image;
			}
			return null;
		}
		
		override protected function cleanUpModelListener(evt:Event):void{
			//先移除事件
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.GETMINIADS, adsDataHandler);
			
			rollingTimer.stop();
			
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