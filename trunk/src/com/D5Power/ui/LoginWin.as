package com.D5Power.ui
{
	import com.D5Power.BitmapUI.D5IVfaceButton;
	import com.D5Power.BitmapUI.D5MirrorBox;
	import com.D5Power.BitmapUI.D5TLFText;
	
	import flash.events.Event;
	import flash.net.Responder;
	import flash.text.TextFieldType;

	public class LoginWin extends BaseWin
	{
		public function LoginWin()
		{
			super(300, 90);
		}
		
		override protected function build():void
		{
			_box = new D5MirrorBox(Global.resPool.getResource('ui_win0'),_width,_height);
			
			var tf:D5TLFText = new D5TLFText("欢迎试用OpenRTMFP 配合 D5Rpg V2.1 范例演示程序。请输入一个您喜欢的昵称进入游戏场景。",0xffffff);
			tf.fontBorder = 0;
			tf.maxWidth = _width-20;
			tf.x = 10;
			tf.y = 10;
			tf.multiline = true;
			tf.name = 'tf';
			tf.autoGrow();
			
			_btn = new D5IVfaceButton(Global.resPool.getResource('ui_btn1'),checkIn);
			_btn.lable = '登入';
			_btn.id=0;
			
			
			
			
			var uname:D5TLFText = new D5TLFText("游客"+Global.userdata.uid,0xffffff);
			uname.type = TextFieldType.INPUT;
			uname.background = true;
			uname.backgroundColor = 0x333333;
			uname.border = true;
			uname.borderColor = 0x000000;
			uname.width = tf.width-_btn.width - 10;
			uname.height = _btn.height;
			uname.name = 'uname';
			
			uname.x = tf.x;
			uname.y = tf.y+tf.height+10;
			
			_btn.x = tf.width+tf.x-_btn.width;
			_btn.y = uname.y;
			
			_box.addChild(tf);
			_box.addChild(_btn);
			_box.addChild(uname);
			
			addChild(_box);
		}
		
		private function checkIn(id:uint):void
		{
			var uname:D5TLFText = _box.getChildByName('uname') as D5TLFText;
			if(uname.text=='') return;
			
			WulinGlobal.username = uname.text;
			Main.my.nc.call('checkIn',new Responder(back),Global.userdata.uid,600,600,uname.text);
		}
		
		private function back(data:*):void
		{
			if(data==1)
			{
				onBtn(0);
				Main.my.start();
			}else{
				(_box.getChildByName('uname') as D5TLFText).text = '服务器错误，请稍后再试。';
			}
		}
	}
}