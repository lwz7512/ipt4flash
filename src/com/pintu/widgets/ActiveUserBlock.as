package com.pintu.widgets{
	
	import com.adobe.serialization.json.JSON;
	import com.pintu.api.*;
	import com.pintu.common.LinkRow;
	import com.pintu.common.SimpleText;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.events.*;
	import com.pintu.utils.Logger;
	import com.pintu.utils.PintuUtils;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import org.casalib.display.CasaSprite;
	
	public class ActiveUserBlock extends AbstractWidget{
				
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var blockWidth:Number;
		private var blockHeight:Number;
		
		private var headerHeight:Number = InitParams.ANDI_TITLE_HEIGHT;
		
		private var titleBackgroudColor:uint = StyleParams.COLUMN_TITLE_BACKGROUND;
		
		private var userContainer:CasaSprite;
		
		private var userObjs:Array;
		
		public function ActiveUserBlock(model:IPintu){
			super(model);
			
			drawActiveUserBackground();
			
			buildTitle();
			
			userContainer = new CasaSprite();
			userContainer.x = drawStartX;
			userContainer.y = drawStartY+headerHeight;
			this.addChild(userContainer);
		}
		
		override protected function initModelListener(evt:Event):void{
			PintuImpl(_clonedModel).addEventListener(ApiMethods.ACTIVEUSERRANKING, activeUserHandler);
			_clonedModel.getActiveUserRanking();
		}
		
		override protected function cleanUpModelListener(evt:Event):void{
			//先移除事件
			PintuImpl(_clonedModel).removeEventListener(ApiMethods.ACTIVEUSERRANKING, activeUserHandler);
			//后清空模型
			super.cleanUpModelListener(evt);
		}
		
		private function activeUserHandler(evt:Event):void{
			if(evt is ResponseEvent){
				var users:String = ResponseEvent(evt).data;
				if(!users) return;
				
//				Logger.debug(".... active user: \n"+users);
				
				userObjs = JSON.decode(users);
				if(userObjs.length==0) return;
				
				buildActiveUsers();
				
			}
			if(evt is PTErrorEvent){
				Logger.error("get active users error!!!");
			}
		}
		
		private function buildActiveUsers():void{
			var userStartX:Number = 4;
			var userStartY:Number = 4;
			var userVGap:Number = 26;
			
			userContainer.removeChildren();
			
			for(var i:int=0; i<userObjs.length; i++){
				var user:Object = userObjs[i];
				if(user==null) continue;
				
				var nickName:String = user["nickName"];
				if(nickName==""){
					nickName = PintuUtils.getShowUserName(user["account"]);
				}
				nickName += "  ("+user["score"]+"分)";
				var userId:String = user["id"];
				var userView:LinkRow = new LinkRow(nickName, userId);
				userView.x = 1;
				userView.y = i*userVGap+userStartY;
				userView.width = blockWidth-1;
				userView.height = userVGap;
				//偶数行放背景
				if(i%2==0){
					userView.backgroundColor = StyleParams.PICDETAIL_BACKGROUND_THIRD;							
				}
				//指定派发事件，点击获取该用户图片
				userView.eventType = PintuEvent.GETPICS_BYUSER;
				userContainer.addChild(userView);
			}
		}
		
		private function buildTitle():void{
			//标题
			var title:SimpleText = new SimpleText("活跃用户排行榜",0xFFFFFF,12);
			//居中
			title.x = drawStartX+InitParams.LOGIN_FORM_WIDTH/2-title.textWidth/2;
			title.y = drawStartY+2;
			this.addChild(title);
		}
		
		private function drawActiveUserBackground():void{
			drawStartX = InitParams.startDrawingX()
								+InitParams.MAINMENUBAR_WIDTH
								+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT
								+InitParams.TOP_BOTTOM_GAP
								+InitParams.LOGIN_FORM_HEIGHT
								+InitParams.DEFAULT_GAP;			
			blockWidth = InitParams.LOGIN_FORM_WIDTH;
			
			if(InitParams.isStretchHeight()){
				blockHeight = InitParams.appHeight
									-drawStartY
									-InitParams.TOP_BOTTOM_GAP
									-InitParams.FOOTER_HEIGHT;				
			}else{
				blockHeight = InitParams.MINAPP_HEIGHT
					-drawStartY
					-InitParams.TOP_BOTTOM_GAP
					-InitParams.FOOTER_HEIGHT;
			}
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR, 1);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,blockHeight);
			this.graphics.endFill();
			
			//标题背景条
			this.graphics.lineStyle(1, titleBackgroudColor);
			this.graphics.beginFill(StyleParams.COLUMN_TITLE_BACKGROUND);
			this.graphics.drawRect(drawStartX,drawStartY,blockWidth,headerHeight);
			this.graphics.endFill();
		}
		
		
	}
}