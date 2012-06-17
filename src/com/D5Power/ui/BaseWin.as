package com.D5Power.ui
{
	import com.D5Power.BitmapUI.D5IVfaceButton;
	import com.D5Power.BitmapUI.D5MirrorBox;

	public class BaseWin extends BaseUI
	{
		protected var _box:D5MirrorBox;
		
		/**
		 * 关闭窗口按钮
		 */ 
		protected var _btn:D5IVfaceButton;
		
		protected var _width:uint;
		
		protected var _height:uint;
		
		public function BaseWin(w:uint = 300,h:uint = 300)
		{
			_width = w;
			_height = h;
			super();
			Wulin.loadResource2Pool('resource/ui/win0.png','ui_win0',step0,D5MirrorBox.TYPEID);
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		private function step0():void
		{
			Wulin.loadResource2Pool('resource/ui/btn1.png','ui_btn1',build,D5IVfaceButton.TYPEID);
		}
		
		protected function build():void
		{
			_box = new D5MirrorBox(Global.resPool.getResource('ui_win0'),_width,_height);
			
			
			_btn = new D5IVfaceButton(Global.resPool.getResource('ui_btn1'),onBtn);
			_btn.x = _box.width-15-_btn.width;
			_btn.y = _box.height-15-_btn.height;
			_btn.lable = '离开';
			_btn.id=0;
			
			_box.addChild(_btn);
			addChild(_box);
		}
		
		public function show():void
		{
			
		}
		
		protected function onBtn(id:uint):void
		{
			if(id==0)
			{
				close();
				return;
			}
		}
	}
}