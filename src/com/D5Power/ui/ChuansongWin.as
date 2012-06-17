package com.D5Power.ui
{
	import com.D5Power.BitmapUI.D5TLFText;

	public class ChuansongWin extends BaseWin
	{
		private static var _content:D5TLFText;
		
		public function ChuansongWin()
		{
			super(500, 300);
		}
		
		override protected function build():void
		{
			super.build();
			
			if(_content==null)
			{
				_content = new D5TLFText('副本传送',0xffffff);
				_content.fontSize=14;
				_content.fontBorder = 0x000000;
				_content.width = _box.width-30;
				_content.height = 25;
				_content.x = _content.y = 15;
			}
			
			addChild(_content);
			
		}
	}
}