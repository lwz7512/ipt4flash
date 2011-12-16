package com.pintu.common
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.casalib.display.CasaSprite;
	
	/**
	 * 文字按钮，可作为主菜单项
	 */ 
	public class TextMenu extends CasaSprite{
		
		protected var _width:Number = 40;
		protected var _height:Number = 20;
		
		/**
		 * Name constant for the up state.
		 */
		private static const STATE_UP : String = "up";
		
		/**
		 * Name constant for the down state.
		 */
		private static const STATE_DOWN : String = "down";
		
		/**
		 * Name constant for the over state.
		 */
		private static const STATE_OVER : String = "over";
		
		/**
		 * Name constant for the disabled state.
		 */
		private static const STATE_DISABLED : String = "disabled";
		
		/**
		 * Name constant for the selected up state.
		 */
		private static const STATE_SELECTED_UP : String = "selectedUp";
		
		/**
		 * Name constant for the selected down state.
		 */
		private static const STATE_SELECTED_DOWN : String = "selectedDown";
		
		/**
		 * Name constant for the selected over state.
		 */
		private static const STATE_SELECTED_OVER : String = "selectedOver";
		
		/**
		 * Name constant for the selected disabled state.
		 */
		private static const STATE_SELECTED_DISABLED : String = "selectedDisabled";	
		
		/**
		 * Initialisation flag.
		 * 
		 * <p>This flag is set to true, if the view has finished its
		 * initialisation process. The flag is set after draw() and
		 * before initialised()</p> 
		 */
		protected var _initialised : Boolean = false;
		
		/**
		 * The text displayed on the button.
		 */
		protected var _labelText : String = "";
		
		/**
		 * The text displayed on the button in selected state.
		 */
		private var _selectedLabelText : String = "";
		
		/**
		 * Tool tip.
		 */
		private var _toolTip : String = "";
		
		/**
		 * Tool tip in selected state.
		 */
		private var _selectedToolTip : String = "";
		
		/**
		 * Auto repeat flag.
		 */
		private var _autoRepeat : Boolean = false;
		
		/**
		 * Toggle button flag.
		 */
		private var _toggle : Boolean = false;
		
		/**
		 * Selected flag.
		 */
		private var _selected : Boolean = false;
		
		/**
		 * Enabled flag.
		 */
		private var _enabled : Boolean = true;
		
		/* internals */
		
		/**
		 * The current button state.
		 */
		private var _state : String = STATE_UP;		
		
		/**
		 * Mouse down flag.
		 */
		private var _mouseDown : Boolean = false;
		
		/**
		 * Mouse over flag.
		 */
		private var _over : Boolean = false;		
		
		/*  style */
		private var upSkinColors:Array = [0x666666, 0x666666];
		private var overSkinColors:Array = [0x999999, 0x999999];
		private var downSkinColors:Array = [0x333333, 0x333333];
		
		private var upLabelColor:uint = 0xFFFFFF;
		private var overLabelColor:uint = 0xFFFFFF;
		private var downLabelColor:uint = 0xFFFFFF;
		
		private var defaultFontSize:int = 12;
		private var defaultFontName:String;
		
		/* children */
		
		/**
		 * The currently displayed skin.
		 */
		private var _skin : Sprite; // currently displayed skin
		
		/**
		 * the displayed label
		 */ 
		private var _label:TextField; //currently displayed text
		
		/**
		 * up状态的皮肤透明度
		 */ 
		private var _upSkinAlpha:Number = 0;
		
		/**
		 *********** Construction **********************************************
		 */ 
		public function TextMenu(w:Number=40, h:Number=20){			
			_width = w;
			_height = h;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			
		}
		
		/**
		 * Handler for the ADDED_TO_STAGE event.
		 */
		private function addedToStageHandler(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			_initialised = true;
			init();			
		}
		
		private function init() : void {
			
			drawBackground();
			
			_skin = new Sprite();//create skin
			this.addChild(_skin);
			
			setLabelText(); // creates a new label if necessary			
			
			setState();// show init appearance
			
			showIcon();// for subclass to add icon
			
		}		
		
		
		/**
		 * Calculates the current state and sets skin, icon and label.
		 */
		private function setState() : void {
			//先校验
			if (!_initialised) return;
			
			var state : String;
			//从表达式外围开始取值
			if (_selected) {
				state =_enabled ? _over ? _mouseDown? STATE_SELECTED_DOWN
					: STATE_SELECTED_OVER : STATE_SELECTED_UP : STATE_SELECTED_DISABLED;				
			} else { // up, down, over, disabled
				state =_enabled ? _over ? _mouseDown ? STATE_DOWN
					: STATE_OVER : STATE_UP : STATE_DISABLED;				
			}
			
			//这里表示不画初始状态皮肤
//			if (state == _state) return;		
			
			_state = state;
						
			//draw component appearance at runtime...
			showSkin();			
		}
		
		/**
		 * Shows the skin depending on the current state.
		 * 
		 * <p>Sub classes may perform additional layout operations.</p>
		 */
		private function showSkin() : void {
			switch(_state){
				case STATE_SELECTED_UP:
				case STATE_SELECTED_DOWN:
				case STATE_SELECTED_OVER:
					drawDownSkin();
					
					break;
				case STATE_SELECTED_DISABLED:
					//do nothing...
					break;
				
				case STATE_UP:
					drawUpSkin()
					break;
				
				case STATE_DOWN:
					drawDownSkin();
					break;
				
				case STATE_OVER:
					drawOverSkin();
					break;
				
				case STATE_DISABLED:
					drawDisabledSkin();
					break;
				
			}
		}
		
		private function drawUpSkin():void{			
			//默认都是透明的
			drawGradientRec(this.upSkinColors,_upSkinAlpha);
			updateLabelColor(this.upLabelColor);
		}
		private function drawDownSkin():void{
			drawGradientRec(this.downSkinColors);			
			updateLabelColor(this.downLabelColor);
		}
		private function drawOverSkin():void{
			drawGradientRec(this.overSkinColors);
			updateLabelColor(this.overLabelColor);
		}
		
		private function drawDisabledSkin():void{
			drawGradientRec(this.upSkinColors,0);
			updateLabelColor(0x666666);
		}
		
		private function drawGradientRec(colors:Array, alpha:Number=1):void{
			_skin.graphics.clear();			
			var alphas:Array = [alpha,alpha];
			var ratios:Array = [0,255];
			var matrix:Matrix = new Matrix();
			//需要旋转90度，垂直渐变
			matrix.createGradientBox(this._width,this._height,Math.PI/2);
			_skin.graphics.beginGradientFill(GradientType.LINEAR,colors,alphas,ratios,matrix);
			_skin.graphics.drawRect(0,0,this._width,this._height);
			_skin.graphics.endFill();			
		}
		
		
		/**
		 * Shows the icon depending on the current state.
		 * 
		 * <p>Sub classes may perform additional layout operations.</p>
		 */
		protected function showIcon() : void {
			
		}
		
		/**
		 * Mouse down handler
		 */
		private function mouseDownHandler(event : MouseEvent) : void {
			if (!_enabled) return;
			
			// mouse up listener
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			// mouse down
			_mouseDown = true;
			
			setState();
		}
		
		/**
		 * Mouse over handler
		 */
		private function mouseOverHandler(event : MouseEvent) : void {
			_over = true;
			
			showToolTip();
			
			if (!_enabled) return;
			
			dispatchRollOver();
			
			setState();
		}
		
		
		public function setSize(w:Number, h:Number):void
		{
			_width = w;
			_height = h;
		}
		
		/**
		 * Mouse out handler
		 */
		private function mouseOutHandler(event : MouseEvent) : void {
			_over = false;
			
			hideToolTip();
			
			if (!_enabled) return;
			
			dispatchRollOut();
			
			setState();
		}
		
		/**
		 * Mouse up handler
		 */
		private function mouseUpHandler(event : MouseEvent) : void {
			// mouse up listener
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			// mouse up
			_mouseDown = false;
			
			if (_over) {
				if (_toggle) {
					
					_selected = !_selected;
					
					setLabelText();
					
					showToolTip(); // tooltip may change
										
				}
				dispatchClick();
			} else {
				dispatchMouseUpOutside();
			}			
			
			setState();
		}
		
		/**
		 * Sets the label text depending on the current state.
		 */
		private function setLabelText() : void {
			_label = new TextField();
			_label.autoSize = TextFieldAutoSize.LEFT;
			_label.selectable = false;
			_label.mouseEnabled = false;
			
			var labelFormat:TextFormat = new TextFormat();			
			labelFormat.size = defaultFontSize;
			labelFormat.color = upLabelColor;
			if(defaultFontName) 
				labelFormat.font = defaultFontName;
			
			_label.defaultTextFormat = labelFormat;			
			_label.text = _labelText;
			this.addChild(_label);
			
			//repostion label in center of button
			var visualTFwidth:Number = _label.textWidth;
			var visualTFheight:Number = _label.textHeight;
			
			//FIXME, For some reason to offset the label, so as to center it rightly...
			var labelPositionOffset:int = 3;
			_label.x = _width/2 - visualTFwidth/2 -labelPositionOffset;
			_label.y = _height/2 - visualTFheight/2 -labelPositionOffset;			
			
		}
		
		private function updateLabelColor(color:uint):void{
			var labelFormat:TextFormat = _label.defaultTextFormat;
			labelFormat.size = defaultFontSize;
			labelFormat.color = color;				
			_label.defaultTextFormat = labelFormat;	
			//按照新的样式重新渲染文字
			_label.text = _labelText;			
		}
		
		//for subclass to call...
		protected function moveLabelY(y:Number):void{
			_label.y += y;
		}
		//for subclass to call...
		protected function moveLabelX(x:Number):void{
			_label.x = x;
		}
		
		/**
		 * Shows the tool tip.
		 */
		private function showToolTip() : void {
			
		}
		
		/**
		 * Hides the tool tip.
		 */
		private function hideToolTip() : void {
			
		}
		
		/**
		 * Dispatchs ButtonEvent.MOUSE_UP_OUTSIDE
		 */
		private function dispatchMouseUpOutside() : void {
			onMouseUpOutside();
			//			dispatchEvent(new ButtonEvent(ButtonEvent.MOUSE_UP_OUTSIDE));
		}
		
		/**
		 * Dispatchs ButtonEvent.CLICK
		 */
		private function dispatchClick() : void {
			onClick();
			//			dispatchEvent(new ButtonEvent(ButtonEvent.CLICK));
		}
		
		/**
		 * Dispatchs ButtonEvent.ROLL_OVER
		 */
		private function dispatchRollOver() : void {
			onRollOver();
			//			dispatchEvent(new ButtonEvent(ButtonEvent.ROLL_OVER));
		}
		
		/**
		 * Template method for the roll over event. 
		 */
		protected function onRollOver() : void {
		}
		
		/**
		 * Dispatchs ButtonEvent.ROLL_OUT
		 */
		private function dispatchRollOut() : void {
			onRollOut();
			//			dispatchEvent(new ButtonEvent(ButtonEvent.ROLL_OUT));
		}
		
		
		
		/**
		 * Template method for the roll out event. 
		 */
		protected function onRollOut() : void {
		}
		
		/**
		 * Template method for the mouse down event. 
		 */
		protected function onMouseDown() : void {
		}
		
		/**
		 * Template method for the mouse up outside event. 
		 */
		protected function onMouseUpOutside() : void {
		}
		
		/**
		 * Template method for the click event. 
		 */
		protected function onClick() : void{
		}
		
		
		/**
		 * Draws a transparent background, which makes the button interactiv
		 * within the entire button area.
		 */
		private function drawBackground() : void {
			graphics.clear();
			graphics.beginFill(0xFFFFFF, 0.01);
			graphics.drawRect(0, 0, _width, _height);
		}
		
		
		/*  *********************  public settings  ******************************************** */
		/**
		 * @inheritDoc
		 */
		public function set label(label : String) : void {
			if (_labelText == label) return;
			
			_labelText = label;
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function get label() : String {
			return _labelText;
		}
	
		
		/**
		 * @inheritDoc
		 */
		public function set enabled(enabled : Boolean) : void {
			if (_enabled == enabled) return;
			
			_enabled = enabled;
			
			setState();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get enabled() : Boolean {
			return _enabled;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set toggle(toggle : Boolean) : void {	
			// cannot be set at runtime
			if (_initialised) return;
			
			_toggle = toggle;
			
			if (_toggle) _autoRepeat = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get toggle() : Boolean {
			return _toggle;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set selected(selected : Boolean) : void {					
			
			if (!_initialised) {
				_selected = selected;
				return;
			}
			
			if (_selected == selected) return;
			
			_selected = selected;
			
			setState();
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function get selected() : Boolean {
			return _selected;
		}
		
		
		/**
		 * set style colors
		 */ 
		public function setSkinStyle(upColors:Array, overColors:Array, downColors:Array):void{
			
			if(upColors) this.upSkinColors = upColors;
			
			if(overColors) this.overSkinColors = overColors;
			
			if(downColors) this.downSkinColors = downColors;
			
		}
		
		/**
		 * set label styles
		 */
		public function setLabelStyle(fontName:String, fontSize:int, upColor:uint, overColor:uint, downColor:uint):void{
			
			if(fontName) this.defaultFontName = fontName;
			if(fontSize) this.defaultFontSize = fontSize;
			
			this.upLabelColor = upColor;
			
			this.overLabelColor = overColor;
			
			this.downLabelColor = downColor;
			
		}
		
		public function set upAlpha(v:Number):void{
			_upSkinAlpha = v;
		}
		
		override public function get width():Number{
			return this._width;
		}
		
		override public function get height():Number{
			return this._height;
		}
		
	}
}