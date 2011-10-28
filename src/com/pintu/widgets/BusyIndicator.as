package com.pintu.widgets
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Transform;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	public class BusyIndicator extends Sprite{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */ 
		static private const DEFAULT_ROTATION_INTERVAL:Number = 50;
		
		/**
		 *  @private
		 */ 
		static private const DEFAULT_MINIMUM_SIZE:Number = 20;
		
		/**
		 *  @private
		 */ 
		static private const RADIANS_PER_DEGREE:Number = Math.PI / 180;
		
		
		private var rotationTimer:Timer;
		
		/**
		 *  @private
		 * 
		 *  Current rotation of this component in degrees.
		 */   
		private var currentRotation:Number = 0;
		
		/**
		 *  @private
		 * 
		 *  Diameter of the spinner for this component.
		 */ 
		private var spinnerDiameter:int = DEFAULT_MINIMUM_SIZE;
		
		/**
		 *  @private
		 * 
		 *  Cached value of the spoke color.
		 */ 
		private var spokeColor:uint = 0x000000;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------	
		public function BusyIndicator(size:Number=20, color:uint=0){
			super();
			
			spinnerDiameter = size;
			spokeColor = color;
			
			alpha = 0.60;       // default alpha
			
			// Listen to added to stage and removed from stage.
			// Start rotating when we are on the stage and stop
			// when we are removed from the stage.
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		/**
		 *  @private
		 */
		private function addedToStageHandler(event:Event):void
		{			
			if (canRotate()) startRotation();					
		}
		
		/**
		 *  @private
		 */
		private function removedFromStageHandler(event:Event):void
		{
			stopRotation();			
		}
		
		/**
		 *  The BusyIndicator can be rotated if it is both on the display list and 
		 *  visible.
		 * 
		 *  @returns true if the BusyIndicator can be rotated, false otherwise.
		 */ 
		private function canRotate():Boolean
		{
			if (stage != null) return true;			
			return false;
		}
		
		private function startRotation():void
		{
			if (!rotationTimer){				
				var rotationInterval:Number = DEFAULT_ROTATION_INTERVAL;
				
				if (rotationInterval < 16.6)
					rotationInterval = 16.6;
				
				rotationTimer = new Timer(rotationInterval);
			}
			
			if (!rotationTimer.hasEventListener(TimerEvent.TIMER)){
				rotationTimer.addEventListener(TimerEvent.TIMER, timerHandler);
				rotationTimer.start();
			}
			
		}
		
		private function stopRotation():void
		{
			if (rotationTimer)
			{
				rotationTimer.removeEventListener(TimerEvent.TIMER, timerHandler);
				rotationTimer.stop();
				rotationTimer = null;
			}
		}
		
		/**
		 *  @private
		 * 
		 *  Rotate the spinner once for each timer event.
		 */
		private function timerHandler(event:TimerEvent):void
		{
			currentRotation += 30;
			if (currentRotation >= 360)
				currentRotation = 0;
			
			drawSpinner();
			event.updateAfterEvent();
		}
		
		/**
		 *  @private
		 * 
		 *  Draw the spinner using the graphics property of this component.
		 */ 
		private function drawSpinner():void 
		{
			var g:Graphics = graphics;
			var spinnerRadius:int = spinnerDiameter / 2;
			var spinnerWidth:int = spinnerDiameter;
			var spokeHeight:Number = spinnerDiameter / 3.7;
			var insideDiameter:Number = spinnerDiameter - (spokeHeight * 2); 
			var spokeWidth:Number = insideDiameter / 5;
			var eHeight:Number = spokeWidth / 2;
			var spinnerPadding:Number = 0;			
			
			g.clear();
			
			// 1
			drawSpoke(0.20, currentRotation + 300, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 2
			drawSpoke(0.25, currentRotation + 330, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 3
			drawSpoke(0.30, currentRotation, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 4
			drawSpoke(0.35, currentRotation + 30, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 5
			drawSpoke(0.40, currentRotation + 60, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 6
			drawSpoke(0.45, currentRotation + 90, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 7
			drawSpoke(0.50, currentRotation + 120, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 8
			drawSpoke(0.60, currentRotation + 150, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 9
			drawSpoke(0.70, currentRotation + 180, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 10
			drawSpoke(0.80, currentRotation + 210, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 11
			drawSpoke(0.90, currentRotation + 240, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
			
			// 12
			drawSpoke(1.0, currentRotation + 270, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
		}
		
		
		/**
		 *  @private
		 * 
		 *  @param spokeAlpha: alpha value of the spoke.
		 *  @param spokeWidth: width of the spoke in points.
		 *  @param spokeHeight: the lenght of the spoke in pixels.
		 *  @param spokeColor: the color of the spoke.
		 *  @param spinnerRadius: radius of the spinner.
		 *  @param eHeight: estimated height of the rounded end of the spinner.
		 *  @param spinnerPadding: number of pixels between the outside
		 *  radius of the spinner and the spokes. This is used to make 
		 *  spinners with skinny spokes look better by moving them
		 *  closer to the center of the spinner.
		 */ 
		private function drawSpoke(spokeAlpha:Number, degrees:int,
								   spokeWidth:Number, 
								   spokeHeight:Number, 
								   spokeColor:uint, 
								   spinnerRadius:Number, 
								   eHeight:Number,
								   spinnerPadding:Number):void
		{
			var g:Graphics = graphics;
			var outsidePoint:Point = new Point();
			var insidePoint:Point = new Point();
			
			g.lineStyle(spokeWidth, spokeColor, spokeAlpha, false, LineScaleMode.NORMAL, CapsStyle.ROUND);
			outsidePoint = calculatePointOnCircle(spinnerRadius, spinnerRadius - eHeight - spinnerPadding, degrees);
			insidePoint = calculatePointOnCircle(spinnerRadius, spinnerRadius - spokeHeight + eHeight - spinnerPadding, degrees);
			g.moveTo(outsidePoint.x, outsidePoint.y);
			g.lineTo(insidePoint.x,  insidePoint.y);
			
		}
		
		/**
		 *  @private
		 */ 
		private function calculatePointOnCircle(center:Number, radius:Number, degrees:Number):Point
		{
			var point:Point = new Point();
			var radians:Number = degrees * RADIANS_PER_DEGREE;
			point.x = center + radius * Math.cos(radians);
			point.y = center + radius * Math.sin(radians);
			
			return point;
		}
		
		
	} //end of class
}