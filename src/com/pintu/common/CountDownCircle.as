package com.pintu.common{
	
	import flash.events.Event;
	
	import org.casalib.display.CasaShape;
	import org.casalib.display.CasaSprite;
	
	/**
	 * 倒计时进度条，默认显示6秒
	 * 2012/03/11
	 * by lwz7512
	 */ 
	public class CountDownCircle extends CasaSprite{
		
		
		private var radius:Number;
		private var second:Number;
		private var color:Number;
		
		private var _counter:int;		
		private var _totalFrames:int;
		
		private var _section:ArcSection;
		
		public function CountDownCircle(r:Number=10, sec:Number=6, fillColor:uint=0x999999){
			radius = r;
			second = sec;
			color = fillColor;
			
			//每秒24帧
			_totalFrames = second*24;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
		}
		
		private function onStage(evt:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, onStage);
			
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			drawFrame();
						
		}
		
		private function onEnterFrame(evt:Event):void{
			_counter++;
			
			//整秒去画片段
			if((_counter % 24)==0){
				var secElipsed:Number = Math.floor(_counter/24);
				drawSectionByTime(secElipsed);				
			}
			//延迟删除
			if(_counter>_totalFrames+2){				
				if(this.parent){
					this.destroy();
				}
			}
		}
		
		private function drawFrame():void{
			//two circle
			this.graphics.lineStyle(1, 0xCCCCCC);
			this.graphics.drawCircle(0,0,radius);
			this.graphics.drawCircle(0,0, radius*0.6);
						
		}
		
		private function drawSectionByTime(sec:int):void{
			var avgDegree:Number = 360/second;			
			var arc:ArcSection = new ArcSection(radius, 360/second, color);
			arc.rotation = (sec-1)*avgDegree;
			this.addChild(arc);
			
		}
		

		
	} //end of class
	
}//end of package

import org.casalib.display.CasaMovieClip;
import org.casalib.display.CasaShape;

class ArcSection extends CasaShape{
	
	private var smallRadius:Number;
	
	private var deg_to_rad:Number=0.0174532925;
	private var charging:Boolean=false;
	private var power:int=0;
	
	public function  ArcSection(radius:Number, angle:Number, color:uint){
		smallRadius = radius*0.6;
		
		this.graphics.lineStyle(1,color);		
		this.graphics.beginFill(color);		
		//外弧
		drawArc(this, 0, 0, radius, -90, -90+angle);		
		var innerEndX:Number = smallRadius*Math.sin(angle*Math.PI/180);
		var innerEndY:Number = -smallRadius*Math.cos(angle*Math.PI/180);
		this.graphics.lineTo(innerEndX,innerEndY);							
		//内弧
		drawArc(this, 0, 0, smallRadius, -90+angle, -90);		
		this.graphics.lineTo(0,-radius);		
		this.graphics.endFill();
	}
	
	public function drawArc(movieclip:CasaShape,center_x:Number,center_y:Number,radius:Number,angle_from:Number,angle_to:Number,precision:Number=1):void {
		var angle_diff:Number=angle_to-angle_from;
		var steps:Number=Math.round(angle_diff*precision);
		steps = Math.abs(steps);
		var angle:Number=angle_from;
		var px:Number=center_x+radius*Math.cos(angle*deg_to_rad);
		var py:Number=center_y+radius*Math.sin(angle*deg_to_rad);
		movieclip.graphics.moveTo(px,py);
		for (var i:int=1; i<=steps; i++) {
			angle=angle_from+angle_diff/steps*i;
			movieclip.graphics.lineTo(center_x+radius*Math.cos(angle*deg_to_rad),center_y+radius*Math.sin(angle*deg_to_rad));
		}
	}
	
}//end of class
