package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 显示在应用右上角的个人详情部分
	 */ 
	public class UserDetailsBlock extends CasaSprite{
		
		private var _model:IPintu;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		private var userDetailFetched:Boolean;
		
		private var headerHeight:Number = 24;
		
		public function UserDetailsBlock(model:IPintu){
			super();
			_model = model;
			PintuImpl(_model).addEventListener(ApiMethods.GETUSERDETAIL, userDetailHandler);
			
			drawLoginBackGround();			
			
			this.addEventListener(Event.ADDED_TO_STAGE, queryUserInfo);
		}
		
		private function queryUserInfo(evt:Event):void{
			//获取个人信息			
//			_model.getUserDetail(PintuImpl(_model).currentUser);
		}
		
		private function userDetailHandler(evt:Event):void{	
			
			if(userDetailFetched) return;
			
			if(evt is ResponseEvent){
				var jsUser:String = ResponseEvent(evt).data;
				Logger.debug("user info: \n"+jsUser);
				
				var objUser:Object = JSON.decode(jsUser);
				buildUserDetails(objUser);
				//查询完成
				userDetailFetched = true;
			}
			
			if(evt is PTErrorEvent){
				Logger.error("get user details error!!!");
			}
		}
		
		private function buildUserDetails(userObj:Object):void{
			
		}
		
		private function drawLoginBackGround():void{
			drawStartX = InitParams.startDrawingX()
				+InitParams.MAINMENUBAR_WIDTH
				+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			blockWidth = InitParams.USER_DETAIL_WIDTH;
			blockHeight = InitParams.USER_DETAIL_HEIGHT;
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);
			this.graphics.endFill();
			
			
		}
		
		
	} //end of class
}