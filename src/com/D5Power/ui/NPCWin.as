package com.D5Power.ui
{
	import com.D5Power.BitmapUI.D5IVfaceButton;
	import com.D5Power.BitmapUI.D5MirrorBox;
	import com.D5Power.BitmapUI.D5TLFText;
	import com.D5Power.Objects.NCharacterObject;
	import com.D5Power.mission.EventData;

	public class NPCWin extends BaseWin
	{
		public var npc:NCharacterObject;
		public var say:String;
		public var missionid:uint;
		/**
		 * 非任务事件，用于触发NPC对应事件，如打开商店等
		 */ 
		public var event:EventData;
		/**
		 * 按钮类型 0 关闭 1 接受 2 灰色完成 3 完成
		 **/
		public var btnType:uint;
		/**
		 * 资源是否准备完成
		 */ 
		private var _resOK:Boolean=false;
		
		private var _content:D5TLFText;
		
		private var _btn_do:D5IVfaceButton;
		
		public function NPCWin()
		{
			super(300,300);
		}
		
		/**
		 * 资源是否准备完成
		 */ 
		public function get resOK():Boolean
		{
			return _resOK;
		}
		
		override protected function build():void
		{
			super.build();

			_content = new D5TLFText('',0xffffff);
			_content.fontSize=14;
			_content.multiline=true;
			_content.fontBorder = 0x000000;
			_content.width = _box.width-30;
			_content.height = 200;
			_content.x = _content.y = 15;

			_btn_do = new D5IVfaceButton(Global.resPool.getResource('ui_btn1'),onBtn);
			_btn_do.x = _btn.x - _btn_do.width - 5;
			_btn_do.y = _btn.y;
			_btn_do.id=1;
			
			_box.addChild(_content);
			_box.addChild(_btn_do);
			
			_resOK=true;
			show();
		}
		
		override public  function show():void
		{
			_content.htmlText = say;
			
			_btn_do.visible=true;
			switch(btnType)
			{
				case 0:
					_btn_do.visible=false;
					break;
				case 1:
					_btn_do.lable='接受';
					break;
				case 2:
				case 3:
					_btn_do.lable='完成';
					if(btnType==2) _btn_do.enabled=false;
					break;
				case 4:
					_btn_do.lable = '确定';
					break;
				default:
					_btn_do.visible=false;
					break;
			}
		}
		
		override protected  function onBtn(id:uint):void
		{
			super.onBtn(id);
			if(id==0) return;
			
			switch(btnType)
			{
				case 0:
					close();
					break;
				case 1:
				case 3:
					// 完成任务
					npc.missionConfig.complateMission(missionid,Global.userdata);
					close();
					break;
				case 2:
					// 未完成
					return;
					break;
				case 4:
					// 打开其他界面
					Wulin.my.showWindow(event);
					close();
					break;
				
			}
		}
	}
}