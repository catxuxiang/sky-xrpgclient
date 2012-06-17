package com.D5Power.ui
{
	import com.D5Power.BitmapUI.D5IVfaceButton;
	import com.D5Power.BitmapUI.D5MirrorBox;
	import com.D5Power.BitmapUI.D5TLFText;
	import com.D5Power.Objects.Effects.ChatPao;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.Responder;
	import flash.text.TextFieldType;
	import flash.utils.getTimer;

	public class ChatWin extends BaseWin
	{
		private var lastSend:uint = 0;
		private var shower:D5TLFText;
		
		
		public static var my:ChatWin;
		
		public function ChatWin()
		{
			my = this;
			super(200, 40);
		}
		
		public function showchat(msg:String):void
		{
			shower.appendText(msg+"\n");
			shower.scrollV = shower.maxScrollV;
		}
		
		override protected function build():void
		{
			_box = new D5MirrorBox(Global.resPool.getResource('ui_win0'),_width,_height);
			
			_btn = new D5IVfaceButton(Global.resPool.getResource('ui_btn1'),send);
			_btn.lable = '发送';
			_btn.id=0;
			
			var uname:D5TLFText = new D5TLFText("游客"+Global.userdata.uid,0xffffff);
			addEventListener(MouseEvent.CLICK,onClick);
			uname.type = TextFieldType.INPUT;
			uname.background = true;
			uname.backgroundColor = 0x333333;
			uname.border = true;
			uname.borderColor = 0x000000;
			uname.width = _box.width-_btn.width - 30;
			uname.height = _btn.height;
			uname.name = 'uname';
			uname.addEventListener(KeyboardEvent.KEY_DOWN,onKey);
			
			uname.x = 10;
			uname.y = 10;
			
			_btn.x = _box.width-_btn.width-10;
			_btn.y = uname.y;
			

			_box.addChild(_btn);
			_box.addChild(uname);
			
			addChild(_box);
			
			shower = new D5TLFText('',0xffffff);
			shower.width = _width;
			shower.height = 200;
			shower.fontBorder = 0x333333;
			shower.multiline = true;
			shower.y = -shower.height;
			addChild(shower);
		}
		
		private function onKey(e:KeyboardEvent):void
		{
			if(e.keyCode==13)
			{
				send();
			}
		}
		
		private function onClick(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
		}
		
		
		private function send(id:uint=0):void
		{
			if(getTimer()-lastSend<3000) return;
			lastSend = getTimer();
			var uname:D5TLFText = _box.getChildByName('uname') as D5TLFText;
			if(uname.text=='') return;
			
			var s:String = uname.text;
			if(s.length>50) s=s.substr(0,50);
			showchat("我说："+s);
			Main.my.nc.call('chat',null,0,s);
			uname.text='';
			
			var say:ChatPao = new ChatPao(Wulin.my.scene,Wulin.my.scene.Player,s);
			Wulin.my.scene.createEffect(say);
		}
	}
}