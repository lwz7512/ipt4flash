package com.pintu.widgets
{
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.InitParams;
	import com.pintu.config.StyleParams;
	import com.pintu.controller.*;
	import com.pintu.events.PTErrorEvent;
	import com.pintu.events.PintuEvent;
	import com.pintu.events.ResponseEvent;
	import com.pintu.utils.Logger;
		
	
	import com.sibirjak.asdpc.button.Button;
	import com.sibirjak.asdpc.button.ButtonEvent;
	import com.sibirjak.asdpc.button.skins.ButtonSkin;
	import com.sibirjak.asdpc.textfield.Label;
	import com.sibirjak.asdpc.textfield.TextInput;
	import com.sibirjak.asdpc.textfield.TextInputEvent;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import org.casalib.util.StringUtil;
	
	public class LoginBlock extends Sprite{
		
		// permissive, will allow quite a few non matching email addresses
		private static const EMAIL_REGEX : RegExp = /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i;
		private static const USERNOTEXIST:String = "-1";
		private static const PASSWORDERROR:String = "0";
		
		private var _model:IPintu;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var account:TextInput;
		private var pswd:TextInput;
		private var submit:Button;

		private var inputHint:SimpleText;
		private var loading:BusyIndicator;
		
		private var emailValid:Boolean = false;
		
		public function LoginBlock(model:IPintu){
			super();
			_model = model;
			PintuImpl(_model).addEventListener(ApiMethods.LOGON, logonSuccess);
			
			drawLoginBackGround();
			
			createFormInputs();
						
		}
		
		private function logonSuccess(event:ResponseEvent):void{
			if(event is ResponseEvent){
				var result:String = ResponseEvent(event).data;
				//去除尾部的换行符号
				result = StringUtil.trim(result);
				
				Logger.debug("user: "+result);
				
				if(result == USERNOTEXIST){
					inputHint.text = "用户不存在!";
				}else if(result == PASSWORDERROR){
					inputHint.text = "密码错误!";
				}else{
					//登录成功了
					if(result.indexOf("@")>-1){
						var role:String = result.split("@")[0];
						var userId:String = result.split("@")[1];
						//记下来
						GlobalController.rememberUser(userId,role);
						//派发时间通知主应用导航到主页
						dispatchEvent(new PintuEvent(PintuEvent.NAVIGATE,GlobalNavigator.HOMPAGE));
					}else{
						inputHint.text = "非用户标识!";						
					}
				}
			}
			
			if(event is PTErrorEvent){
				inputHint.text = "登录失败!";
			}
			
			//移除进度条
			this.removeChild(loading);
		}
		
		private function createFormInputs():void{			
			var padding:Number = 10;	
			var verticalGap:Number = 2;
			//账号名称
			var actField:SimpleText = new SimpleText("账号：", 0, StyleParams.TEXTINPUT_FONTSIZE);
			actField.x = drawStartX+padding;
			actField.y = drawStartY+padding;
			this.addChild(actField);
			
			//账号输入
			account = new TextInput();
			account.defaultText = "Email ...";
			account.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			account.setSize(InitParams.LOGIN_FORM_WIDTH-2*padding,28);
			account.setStyle(TextInput.style.size,StyleParams.TEXTINPUT_FONTSIZE);
			account.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);			
			account.x = drawStartX+padding;
			account.y = actField.y+actField.height+verticalGap;
			account.addEventListener(TextInputEvent.FOCUS_OUT, checkEmail);
			this.addChild(account);
			
			//密码名称
			var pwdField:SimpleText = new SimpleText("密码：", 0, StyleParams.TEXTINPUT_FONTSIZE);
			pwdField.x = drawStartX+padding;
			pwdField.y = account.y+account.height+verticalGap;
			this.addChild(pwdField);
			
			//密码输入
			pswd = new PswdInput();			
			pswd.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			pswd.setSize(InitParams.LOGIN_FORM_WIDTH-2*padding,28);
			pswd.setStyle(TextInput.style.size,StyleParams.TEXTINPUT_FONTSIZE);
			pswd.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);			
			pswd.x = drawStartX+padding;
			pswd.y = pwdField.y+pwdField.height+verticalGap;
			pswd.addEventListener(TextInputEvent.SUBMIT, checkToLogin);
			pswd.addEventListener(TextInputEvent.CHANGED, clearInput);
			this.addChild(pswd);
			
			//提交
			submit = new Button();
			submit.label = "登录";
			//这个尺寸差不多吧
			submit.setSize(60, 28);
			
			submit.setStyle(ButtonSkin.style_backgroundColors, 
				[StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN, StyleParams.HEADERBAR_BOTTOM_LIGHTGREEN]);
			submit.setStyle(ButtonSkin.style_overBackgroundColors, 
				[StyleParams.HEADERBAR_TOP_LIGHTGREEN, StyleParams.HEADERBAR_NEARBOTTOM_LIGHTGREEN]);
			submit.setStyle(ButtonSkin.style_borderColors, [0x999999, 0x000000]);
			
			submit.setStyle(Button.style.labelStyles, [
				Label.style.color, 0xEEEEEE,				
				Label.style.size, 14
			]);
			submit.setStyle(Button.style.overLabelStyles, [
				Label.style.color, 0xEEEEEE,				
				Label.style.size, 14
			]);
			submit.setStyle(Button.style.selectedLabelStyles, [
				Label.style.color, 0xEEEEEE,				
				Label.style.size, 14
			]);
			submit.x = drawStartX+InitParams.LOGIN_FORM_WIDTH-70;
			submit.y = pswd.y+pswd.height+verticalGap+padding;
			submit.addEventListener(ButtonEvent.CLICK, checkToLogin);
			this.addChild(submit);
			//重置			
			
			//提示
			inputHint = new SimpleText("",StyleParams.DEFAULT_ERROR_RED);
			inputHint.x = drawStartX+padding;
			inputHint.y = submit.y+verticalGap;
			this.addChild(inputHint);
		}
		
		private function checkToLogin(evt:Event):void{
			var email:String = account.text;
			var password:String = pswd.text;
			if(email.length==0 || password.length==0){
				inputHint.text = "账号和密码不能为空!";
				return;
			}
			
			if(emailValid){
				//logon to server...
				inputHint.text = "";
				//登录验证
				_model.logon(email,password);
				showLoading();
			}
			
		}
		
		private function showLoading():void{
			//图片查到后回删掉所有，包括这个进度条
			loading = new BusyIndicator(24);
			loading.x = inputHint.x;
			loading.y = inputHint.y;	
			this.addChild(loading);
		}
		
		private function checkEmail(evt:TextInputEvent):void{
			if(account.text.length>0){
				if(isValidEmail(account.text)){
					emailValid = true;
				}else{
					emailValid = false;
					inputHint.text = "非法邮箱格式";
				}
			}
		}
		
		private function clearInput(evt:Event):void{
			if(pswd.text.length==0)
				inputHint.text = "";
		}
		
		private function drawLoginBackGround():void{
			drawStartX = InitParams.startDrawingX()
								+InitParams.MAINMENUBAR_WIDTH
								+InitParams.DEFAULT_GAP;
			drawStartY = InitParams.HEADER_HEIGHT+InitParams.TOP_BOTTOM_GAP;
			this.graphics.clear();
			this.graphics.lineStyle(1,StyleParams.DEFAULT_BORDER_COLOR);
			this.graphics.beginFill(StyleParams.DEFAULT_FILL_COLOR);
			this.graphics.drawRect(drawStartX,drawStartY,
								InitParams.LOGIN_FORM_WIDTH,InitParams.LOGIN_FORM_HEIGHT);
			this.graphics.endFill();
		}
		
		private function isValidEmail(email : String) : Boolean{
			return Boolean(email.match(EMAIL_REGEX));
		}
		
	} //end of class
}