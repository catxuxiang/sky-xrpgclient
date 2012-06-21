package
{
	import com.D5Power.ui.LogInWin;
	import com.D5Power.ui.RegisterWin;
	import com.D5Power.utils.CharacterData;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[SWF(width="760",height="600",frameRate="30",backgroundColor="#000000")]
	public class Main extends MovieClip
	{
		
		public var nc:MySocket;
		public static var my:Main;
		
		public function Main()
		{
			my = this;
			Global.userdata = new CharacterData();
			addEventListener(Event.ADDED_TO_STAGE, init);
			super();
		}
		
		public function register():void
		{
			var win:RegisterWin = new RegisterWin();
			win.x = int((stage.stageWidth-win.width)*.5);
			win.y = int((stage.stageHeight-win.height)*.5);
			addChild(win);	
		}
		
		public function logIn():void
		{
			var win:LogInWin = new LogInWin();
			win.x = int((stage.stageWidth-win.width)*.5);
			win.y = int((stage.stageHeight-win.height)*.5);
			addChild(win);			
		}
		
		public function start():void
		{
			var main:Wulin = new Wulin(stage);
			addChild(main);
		}
		
		private function init(event:Event):void
		{
			nc = new MySocket("localhost", 5098);
			nc.addEventListener(DataReceiveEvent.Type, onStats);
			nc.connect(onStats);
		}
		
		private function onStats(e:DataReceiveEvent):void
		{
			if (e.Data["IsSuccess"] == "True")
				logIn();
			else
				trace("Server connection error!");
		}
	}
}