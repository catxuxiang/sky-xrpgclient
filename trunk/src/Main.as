package
{
	import com.D5Power.ui.LoginWin;
	import com.D5Power.utils.CharacterData;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.utils.Timer;
	
	[SWF(width="760",height="600",frameRate="30",backgroundColor="#000000")]
	public class Main extends MovieClip
	{
		
		public var nc:NetConnection;
		public static var my:Main;
		
		public function Main()
		{
			my = this;
			Global.userdata = new CharacterData();
			addEventListener(Event.ADDED_TO_STAGE, init);
			super();
		}
		
		public function start():void
		{
			var main:Wulin = new Wulin(stage);
			addChild(main);
		}
		
		private function init(event:Event):void
		{
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS,onStats);
			nc.connect("rtmfp://127.0.0.1");
		}
		
		private function onStats(e:NetStatusEvent):void
		{
			if(e.info.code=="NetConnection.Connect.Success")
			{
				Global.userdata.uid = int(Math.random()*65000);
				var win:LoginWin = new LoginWin();
				win.x = int((stage.stageWidth-win.width)*.5);
				win.y = int((stage.stageHeight-win.height)*.5);
				addChild(win);
			}else{
				trace(e.info.code);
			}
		}
	}
}