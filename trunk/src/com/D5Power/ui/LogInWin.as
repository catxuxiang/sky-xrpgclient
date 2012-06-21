package com.D5Power.ui
{
	import com.D5Power.BitmapUI.D5IVfaceButton;
	import com.D5Power.BitmapUI.D5MirrorBox;
	import com.D5Power.BitmapUI.D5TLFText;
	
	import flash.events.Event;
	import flash.net.Responder;
	import flash.text.TextFieldType;
	import flash.events.MouseEvent;

	public class LogInWin extends BaseWin
	{
		private var tf:D5TLFText;
		private var uname:D5TLFText;
		private var upassword:D5TLFText;
		private var tf1:D5TLFText;
		
		public function LogInWin()
		{
			super(300, 150);
		}
		
		override protected function build():void
		{
			_box = new D5MirrorBox(Global.resPool.getResource('ui_win0'),_width,_height);
			
			tf1 = new D5TLFText("",0xff0000);
			tf1.fontBorder = 0;
			tf1.width = _width-20;
			tf1.x = 10;
			tf1.y = 10;
			tf1.multiline = false;
			tf1.name = 'tf1';
			
			tf = new D5TLFText("Welcome to XRpg, please enter the account name:",0xffffff);
			tf.fontBorder = 0;
			tf.maxWidth = _width-20;
			tf.x = 10;
			tf.y = tf1.y + tf1.height;
			tf.multiline = true;
			tf.name = 'tf';
			tf.autoGrow();
			
			_btn = new D5IVfaceButton(Global.resPool.getResource('ui_btn1'),logIn);
			_btn.lable = 'Log In';
			_btn.id=0;
			
			var _btn1:D5IVfaceButton = new D5IVfaceButton(Global.resPool.getResource('ui_btn1'),register);
			_btn1.lable = 'Register';
			_btn1.id=1;			
			
			uname = new D5TLFText("sky1",0xffffff);
			uname.type = TextFieldType.INPUT;
			uname.background = true;
			uname.backgroundColor = 0x333333;
			uname.border = true;
			uname.borderColor = 0x000000;
			uname.width = tf.width - 10;
			uname.height = _btn.height;
			uname.name = 'uname';
			
			uname.x = tf.x;
			uname.y = tf.y+tf.height+5;
			
			upassword = new D5TLFText("",0xffffff);
			upassword.type = TextFieldType.INPUT;
			upassword.background = true;
			upassword.backgroundColor = 0x333333;
			upassword.border = true;
			upassword.borderColor = 0x000000;
			upassword.width = tf.width - 10;
			upassword.height = _btn.height;
			upassword.name = 'upassword';
			
			upassword.x = tf.x;
			upassword.y = uname.y+uname.height+5;
			
			_btn.x = tf.x + 50;
			_btn.y = upassword.y+upassword.height+5;
			_btn.width = 80
			
			_btn1.x = tf.x + 150;
			_btn1.y = upassword.y+upassword.height+5;
			_btn1.width = 80
			
			_box.addChild(tf);
			_box.addChild(tf1);
			_box.addChild(_btn);
			_box.addChild(_btn1);
			_box.addChild(uname);
			_box.addChild(upassword);
			
			addChild(_box);
		}
		private function register(id:uint):void
		{
			this.close();
			Main.my.register();			
		}
		private function logIn(id:uint):void
		{
			if(uname.text=="")
			{
				tf1.text = "Account name is empty!";
				return;
			}
			if(upassword.text == "")
			{
				tf1.text = "Account password is empty!";
				return;
			}
			
			WulinGlobal.username = uname.text;
			Main.my.nc.send(WulinGlobal.GetReturnJsonString("LogIn", uname.text, upassword.text), onLogIn);
		}
		private function onLogIn(e:DataReceiveEvent):void
		{
			if (e.Data["IsSuccess"] == "False")
			{
				tf1.text = e.Data["ErrorMsg"];
			}
			else
			{
				Global.userdata.uid = e.Data["Arg0"];
				this.close();
				Main.my.start();
			}
		}
	}
}