package com.pintu.widgets
{
	import com.pintu.api.*;
	import com.pintu.common.*;
	import com.pintu.config.*;
	import com.pintu.controller.*;
	import com.pintu.events.*;
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
	
	import org.casalib.display.CasaSprite;
	import org.casalib.util.StringUtil;
	
	public class LoginBlock extends CasaSprite{
		
		// permissive, will allow quite a few non matching email addresses
		private static const EMAIL_REGEX : RegExp = /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i;
		private static const USERNOTEXIST:String = "-1";
		private static const PASSWORDERROR:String = "0";
		
		private var _model:IPintu;
		
		private var drawStartX:Number;
		private var drawStartY:Number;
		
		private var account:MustTextInput;
		private var pswd:PswdInput;
		private var submit:Button;

		private var inputHint:SimpleText;
		private var loading:BusyIndicator;
		//邮箱验证结果
		private var emailValid:Boolean = false;
		
		//登录成功开关值，真崩溃，事件监听到两次
		//2011/11/24
		private var logonSuccessFlag:Boolean = false;
		
		public function LoginBlock(model:IPintu){
			super();			
//			Logger.debug("Create LoginBlock once...");	
			
			_model = model;			
			//计算位置，画背景
			drawLoginBackGround();			
			createFormInputs();
			
			this.addEventListener(Event.ADDED_TO_STAGE, initLogin);
			this.addEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
		}
		
		private function initLogin(evt:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, initLogin);
			
			PintuImpl(_model).addEventListener(ApiMethods.LOGON, logonHandler);
		}
		private function cleanUp(evt:Event):void{
			PintuImpl(_model).removeEventListener(ApiMethods.LOGON, logonHandler);			
		}
		
		private function logonHandler(event:Event):void{
			
			if(event is ResponseEvent){
				var result:String = ResponseEvent(event).data;
				//如果登录过了就别再进入了	
				//否则会引起_model空对象异常
				//很怪异啊
				//2011/11/24
				if(logonSuccessFlag) return;
				
				//去除尾部的换行符号
				result = StringUtil.trim(result);				
//				Logger.debug("user: "+result);
				
				if(result == USERNOTEXIST){
					inputHint.text = "用户不存在!";
				}else if(result == PASSWORDERROR){
					inputHint.text = "密码错误!";
				}else{										
					//登录成功了
					logonSuccess(result);
				}
			}
			
			if(event is PTErrorEvent){
				inputHint.text = "服务异常!";
			}
			
			//移除进度条
			if(this.contains(loading)) this.removeChild(loading);
			//不管怎样都该恢复提交按钮状态
			submit.enabled = true;
		}
		
		private function logonSuccess(result:String):void{
			if(result.indexOf("@")>-1){
				var role:String = result.split("@")[0];
				var userId:String = result.split("@")[1];
				//缓存下来
				GlobalController.rememberUser(userId,role);
				//更新用户信息到模型中
				_model.updateUser(userId);
				//派发时间通知主应用导航到主页
				dispatchEvent(new PintuEvent(PintuEvent.NAVIGATE,GlobalNavigator.HOMPAGE));
				//标记登录成功
				logonSuccessFlag = true;
			}else{
				inputHint.text = "非用户标识!";						
			}
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
			account = new MustTextInput();
			account.defaultText = "Email ...";
			account.setStyle(TextInput.style.font, StyleParams.DEFAULT_TEXT_FONTNAME);
			account.setSize(InitParams.LOGIN_FORM_WIDTH-2*padding,28);
			account.setStyle(TextInput.style.size,StyleParams.TEXTINPUT_FONTSIZE);
			account.setStyle(TextInput.style.borderDarkColor,StyleParams.DARKER_BORDER_COLOR);			
			account.x = drawStartX+padding;
			account.y = actField.y+actField.height+verticalGap;
			account.addEventListener(TextInputEvent.FOCUS_OUT, checkEmailFormat);
			this.addChild(account);
			//FIXME, 先写死省的老输入
//			account.text = "lwz7512@gmail.com";
			account.text = "guest@ipintu.com";
			
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
			//支持密码输入框上使用回车键提交
			pswd.addEventListener(TextInputEvent.SUBMIT, checkToLogin);
			pswd.addEventListener(TextInputEvent.CHANGED, clearInput);
			this.addChild(pswd);
			//FIXME, 先写死省的老输入
//			pswd.text = "123";
			pswd.text = "guest";
			
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
			inputHint.width = 120;
			this.addChild(inputHint);
		}
		
		private function checkToLogin(evt:Event):void{			
			
			var email:String = account.text;
			var password:String = pswd.text;
			if(email.length==0 || password.length==0){
				inputHint.text = "账号和密码不能为空!";
				return;
			}
			//测试时账号和密码直接填进去了
			//输入框不能触发失去焦点事件
			//所以，这里再检查一次
			checkEmailFormat(null);
			
			if(emailValid){
				//logon to server...
				inputHint.text = "";
				//登录验证
				_model.logon(email,password);
				
				showLoading();
				
				//禁用
				submit.enabled = false;
			}
						
		}
		
		private function showLoading():void{
			//图片查到后回删掉所有，包括这个进度条
			loading = new BusyIndicator(24);
			loading.x = inputHint.x;
			loading.y = inputHint.y;	
			this.addChild(loading);
		}
		
		private function checkEmailFormat(evt:TextInputEvent):void{
			if(account.text.length>0){
				if(isValidEmail(account.text)){
					emailValid = true;
					account.resetToNormal();
				}else{
					emailValid = false;
					account.showWarningBorder();
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
		
		//重写销毁函数
		//凡是在本类中，对_model加过事件监听的都要在这里置空
		override public  function destroy():void{
			super.destroy();
			_model = null;			
		}
		
	} //end of class
}