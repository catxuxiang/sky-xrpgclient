package com.D5Power.ui
{
	import flash.display.Sprite;
	
	public class BaseUI extends Sprite
	{
		public function BaseUI()
		{
			super();
		}
		
		public function close():void
		{
			if(parent!=null) parent.removeChild(this);
		}
	}
}