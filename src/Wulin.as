package
{
	import com.D5Power.BitmapUI.D5IVfaceButton;
	import com.D5Power.BitmapUI.D5MirrorBox;
	import com.D5Power.BitmapUI.D5TLFText;
	import com.D5Power.BitmapUI.D5Table;
	import com.D5Power.Controler.Actions;
	import com.D5Power.Controler.CharacterControler;
	import com.D5Power.D5Game;
	import com.D5Power.Objects.CharacterObject;
	import com.D5Power.Objects.GameObject;
	import com.D5Power.Objects.NCharacterObject;
	import com.D5Power.Render.RenderCharacter;
	import com.D5Power.Stuff.HSpbar;
	import com.D5Power.events.ChangeMapEvent;
	import com.D5Power.graphicsManager.GraphicsBasic;
	import com.D5Power.graphicsManager.GraphicsResource;
	import com.D5Power.mission.EventData;
	import com.D5Power.net.CallbackLoader;
	import com.D5Power.ns.NSGraphics;
	import com.D5Power.scene.BaseScene;
	import com.D5Power.scene.D5Scene;
	import com.D5Power.scene.MyScene;
	import com.D5Power.ui.BaseWin;
	import com.D5Power.ui.ChatWin;
	import com.D5Power.ui.ChuansongWin;
	import com.D5Power.ui.NPCWin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.Responder;
	import flash.net.URLRequest;
	
	use namespace NSGraphics;

	public class Wulin extends D5Game
	{
		protected static var soundChannle:SoundChannel;
		protected static var sound:Sound;
		protected var _soundPlayStatus:Boolean=false;
				
		public static var my:Wulin;
		/**
		 * npc对话框
		 */ 
		public static var npcBox:NPCWin;
		/**
		 * 功能窗口
		 */ 
		public static var funWin:BaseWin;
		
		/**
		 * 自动加载外部图片数据到资源池，并自动回叫对应函数
		 * @param	url			外部图片的URL地址
		 * @param	resname		资源池中的资源名
		 * @param	callback	回叫函数
		 */ 
		public static function loadResource2Pool(url:String,resname:String,callback:Function,workType:uint=0):void
		{
			if(Global.resPool.getResource(resname)!=null)
			{
				callback();
				return;
			}
			var loader:CallbackLoader = new CallbackLoader();
			loader.name = resname;
			loader.callback = callback;
			loader.workType = workType;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadResource2PoolComplate);
			loader.load(new URLRequest(url));
		}
		
		/**
		 * 读取完成后的数据处理
		 */ 
		private static function onLoadResource2PoolComplate(e:Event):void
		{
			var loader:CallbackLoader = (e.target as LoaderInfo).loader as CallbackLoader;
			
			if((loader.content as Bitmap)==null) throw new Error("外部加载只支持图片资源！当前加载的文件类型是："+loader.contentLoaderInfo.contentType);
			
			var bitmap:BitmapData = (loader.content as Bitmap).bitmapData.clone();
			
			switch(loader.workType)
			{
				case 0:
					Global.resPool.addResource(loader.name,bitmap);
					loader.callback();
					break;
				case D5IVfaceButton.TYPEID:
					var res:Vector.<BitmapData> = D5IVfaceButton.makeResource(bitmap);
					Global.resPool.addResource(loader.name,res);
					loader.callback();
					break;
				case D5MirrorBox.TYPEID:
					var res0:Vector.<BitmapData> = D5MirrorBox.makeResource(
						bitmap,
						new Rectangle(0,0,15,15),
						new Rectangle(15,0,18,15),
						new Rectangle(0,15,15,34),
						new Rectangle(15,15,18,34));
					Global.resPool.addResource(loader.name,res0);
					loader.callback();
					break;
				case D5Table.TYPEID:
					var res1:Vector.<BitmapData> = D5Table.makeResource(bitmap,10,40);
					Global.resPool.addResource(loader.name,res1);
					loader.callback();
					break
				default:
					throw new Error("未知的资源处理类型！"+loader.workType);
					break;
			}
			
			loader.unload();
			loader.callback=null;
			loader=null;
		}
		
		public function Wulin(stg:Stage)
		{
			_startX = 600;
			_startY = 600;
			Global.LIBNAME='';
			Global.userdata.getCanSeeMission(1);
			my = this;
			
			super('map1',stg);
		}
		
		/**
		 * 显示NPC对话窗口
		 */ 
		public function npcWindow(say:String,event:EventData,npc:NCharacterObject,misid:uint,type:uint=0,complate:Boolean=false):void
		{
			if(npcBox==null)
			{
				npcBox = new NPCWin();
				npcBox.y = 80;
				npcBox.x = Global.W-npcBox.width-50;
			}
			npcBox.npc = npc;
			npcBox.say = say;
			if(misid==0)
			{
				npcBox.event = event;
				// 无任务
				npcBox.btnType = event==null ? 0 : 4;
				
			}else{
				npcBox.btnType = type==0 ? 1 : (complate ? 3 : 2);
			}
			npcBox.missionid = misid;
			if(npcBox.resOK) npcBox.show();
			addChild(npcBox);
		}
		
		/**
		 * 显示其他窗口
		 */ 
		public function showWindow(event:EventData):void
		{
			if(funWin!=null && contains(funWin))
			{
				funWin.close();
			}
			switch(event.type)
			{
				case 'chuansong':
					funWin = new ChuansongWin();
					funWin.x = (Global.W-funWin.width)*.5;
					funWin.y = (Global.H-funWin.height)*.5;
					addChild(funWin);
					break;
				case 'shop':
					
					break;
				case 'baobiao':
					
					break;
				case 'wuxue':
					
					break;
				default:
					break;
			}
		}
		
		public function get scene():D5Scene
		{
			return _scene;
		}
		
		
		override protected function buildScene():void
		{
			_scene = new MyScene(_stg,this);
		}
		
		override protected function init(e:Event=null):void
		{
			super.init();
			
			configDirection();
			
			(_scene as MyScene).buildPlayer(_startX,_startY);
			_camera.focus(_scene.Player);
			
			if(sound==null)
			{
				sound = new Sound(new URLRequest('asset/bg.mp3'));
				soundChannle = sound.play(0);
				try
				{
					soundChannle.addEventListener(Event.SOUND_COMPLETE,restarSound);
					_soundPlayStatus=true;
				}catch(e:Error){}
			}
			
			var chatwin:ChatWin = new ChatWin();
			chatwin.x = 10;
			chatwin.y = stage.stageHeight-chatwin.height;
			_stg.addChild(chatwin);
			
			
			//Main.my.nc.call('getPlayers',new Responder(showList));
		}
		
		private function showList(args:*):void
		{
			for each(var obj:Object in args)
			{
				if(obj.uid==Global.userdata.uid) continue;
				(_scene as MyScene).updateNpc(obj.nickname,obj.uid,obj.x,obj.y);
			}
			//Main.my.nc.call("ready",null);
		}
		
		/**
		 * 循环播放
		 */ 
		private function restarSound(e:Event):void
		{
			sound.play(0);	
		}
		
		private function configDirection():void
		{
			GameObject.DEFAULT_DIRECTION.Down = 4;
			GameObject.DEFAULT_DIRECTION.LeftDown = 3;
			GameObject.DEFAULT_DIRECTION.Left = 2;
			GameObject.DEFAULT_DIRECTION.LeftUp = 1;
			GameObject.DEFAULT_DIRECTION.Up = 0;
			GameObject.DEFAULT_DIRECTION.RightUp = -1;
			GameObject.DEFAULT_DIRECTION.Right = -2;
			GameObject.DEFAULT_DIRECTION.RightDown = -3;
		}
	}
}