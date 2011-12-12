package com.pintu.utils{
	
	
	public class PintuUtils{
		
		public static function getRelativeTimeFromNow(simpleFormat:String):String{
			//yyyy-MM-dd HH:mm:ss			
			var dayAndTime:Array = simpleFormat.split(" ");
			var ymd:String = dayAndTime[0];
			var hms:String = dayAndTime[1];
			
			var dateArray:Array = ymd.split("-");
			
			var year:Number = Number(dateArray[0]);
			var month:Number = Number(dateArray[1]);
			var day:Number = Number(dateArray[2]);
			
			var timeArray:Array = hms.split(":");
			
			var hour:Number = Number(timeArray[0]);
			var min:Number = Number(timeArray[1]);
			var sec:Number = Number(timeArray[2]);
			
			var pubDate:Date = new Date(year,month-1,day,hour,min,sec);
			
			var secsByNow:Number = ((new Date()).getTime()-pubDate.getTime())/1000;								
			
			var secUnit:String = "秒";
			var minUnit:String = "分钟";
			var hourUnit:String = "小时";
			var dayUnit:String = "天";
			var suffix:String = "前";
			
			if(secsByNow<0){
				secsByNow = 0;
			}
			
			//小于1分钟
			if(secsByNow<60){
				return int(secsByNow)+secUnit+suffix;
			}			
			// 算分钟数
			secsByNow /= 60;
			
			if(secsByNow<60){
				return int(secsByNow)+minUnit+suffix;
			}
			
			// 用分钟数算小时数
			secsByNow /= 60;
			
			if(secsByNow<24){
				return int(secsByNow)+hourUnit+suffix;
			}
			
			//用小时数算天数
			secsByNow /= 24;	
			
			return int(secsByNow)+dayUnit+suffix;
		}
		
		
		public static function getRelativeTimeByMiliSeconds(milisecond:int):String{
			var pubTime:Date = new Date();
			pubTime.setTime(milisecond);			
			var simpleTime:String = pubTime.fullYear+"-"+(pubTime.month+1)+"-"+pubTime.date;
			simpleTime += " "+pubTime.hours+":"+pubTime.minutes+":"+pubTime.seconds;
			
			return getRelativeTimeFromNow(simpleTime);
		}
		
		
		
	} //end of class
}