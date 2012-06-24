package com.D5Power
{
	import com.D5Power.Controler.ControllerCenter;
	import com.D5Power.Objects.BuildingObject;
	import com.D5Power.Objects.Effects.RoadPoint;
	import com.D5Power.Objects.NCharacterObject;
	import com.D5Power.events.ChangeMapEvent;
	import com.D5Power.loader.MutiLoader;
	import com.D5Power.map.WorldMap;
	import com.D5Power.ns.NSCamera;
	import com.D5Power.ns.NSD5Power;
	import com.D5Power.scene.D5Scene;
	import com.D5Power.simulator.Simulator;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	use namespace NSCamera;
	use namespace NSD5Power;
	
	public class D5Game extends Sprite
	{
		
		public static var configPath:String = 'config/';
		
		private var loader:URLLoader;
		
		/**
		 * 模拟器
		 */ 
		private var sim:Simulator;
		
		/**
		 * 主游戏场景
		 */ 
		protected var _scene:D5Scene;
		
		protected var _camera:D5Camera;
		
		protected var _config:String;
		
		protected var _stg:Stage;
		
		protected var _loadData:Array=[];
		
		protected var _mtLoader:MutiLoader;
		
		protected var _data:XML;
		
		/**
		 * 角色出现的起始位置X
		 */ 
		protected var _startX:uint;
		
		/**
		 * 角色出现的起始位置Y
		 */ 
		protected var _startY:uint;
		
		protected var _nextStep:Function;
		
		/**
		 * @param	config	配置文件地址
		 */ 
		public function D5Game(config:String,stg:Stage)
		{
			super();
			
			_config = config;
			_stg = stg;
			
			Global.W = _stg.stageWidth;
			Global.H = _stg.stageHeight;
			
			addEventListener(Event.ADDED_TO_STAGE,install);
			
		}
		
		protected function install(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,install);
			
			
			if(_config!='') loadConfig();
			
			addEventListener(Event.DEACTIVATE,onDeactivete);
			_stg.addEventListener(ChangeMapEvent.CHANGE,onChangeMap);
		}
		
		public function get camera():D5Camera
		{
			return _camera;
		}
		
		/**
		 * 加载配置文件
		 */ 
		protected function loadConfig():void
		{
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(new URLRequest(Global.httpServer+configPath+_config+'.d5'));
			loader.addEventListener(IOErrorEvent.IO_ERROR,onConfigIO);
			loader.addEventListener(Event.COMPLETE,parseData);
			
		}
		
		protected function onChangeMap(e:ChangeMapEvent):void
		{
			clear();
			_config = 'map'+e.toMap;
			_startX = e.toX;
			_startY = e.toY;
			_nextStep =  loadConfig;
			if(_scene.Player) _scene.Player.visible=false;
		}
		
		/**
		 * 当FP失去焦点时候的处理函数
		 */ 
		protected function onDeactivete(e:Event):void
		{
			
		}
		
		protected function onConfigIO(e:IOErrorEvent):void
		{
			trace("D5Game load config io error");	
		}
		
		/**
		 * 创建游戏场景
		 */ 
		protected function buildScene():void
		{
			_scene = new D5Scene(_stg,this);
		}
		
		/**
		 * 解析配置文件
		 */ 
		protected function parseData(e:Event):void
		{
			loader.removeEventListener(Event.COMPLETE,parseData);
			var by:ByteArray = loader.data as ByteArray;
			by.uncompress();
			var configXML:String = by.readUTFBytes(by.bytesAvailable);
			setup(configXML);
		}
		/**
		 * 根据配置文件进行场景的数据初始化
		 */ 
		protected function setup(s:String):void
		{
			_data = new XML(s);

			Global.TILE_SIZE.x = _data.tileX;
			Global.TILE_SIZE.y = _data.tileY;
			Global.MAPSIZE.x = _data.mapW;
			Global.MAPSIZE.y = _data.mapH;

			var loadArr:Array = [];
			var libArr:Array = [];
			
			if(Global.characterLib==null && Global.LIBNAME!='')
			{
				loadArr.push(Global.LIBNAME);
				libArr.push('characterLib');
			}
			buildScene();
			_scene.Map.mapid = _data.id;
			_scene.Map.hasTile = _data.hasTile;
			_scene.Map.install(); // 初始化地图
			_scene.Map.tileFormat = _data.tileFormat;
			
			if(loadArr.length>0)
			{
				configMLoader(loadArr,libArr);
			}else{
				start();
			}
			
		}
		
		protected function configMLoader(loadArr:Array,libArr:Array):void
		{
			// 自动加载资源库
			_mtLoader = new MutiLoader(_loadData);
			_mtLoader.addEventListener(Event.COMPLETE,onLoadComplate);
			addChild(_mtLoader);
			_mtLoader.load(loadArr,libArr);
			
		}
		
		/**
		 * 资源库加载完成后进行素材处理
		 */ 
		protected function onLoadComplate(e:Event):void
		{
			_mtLoader.clear();
			_mtLoader.removeEventListener(Event.COMPLETE,onLoadComplate);
			
			if(_mtLoader.libList==null)
			{
				if(_loadData.length==1)
				{
					Global.mapLib = _loadData[1] as ApplicationDomain;
				}else{
					Global.characterLib = _loadData[0] as ApplicationDomain;
					Global.mapLib = _loadData[1] as ApplicationDomain;
				}
			}else{
				for(var i:uint = 0;i<_mtLoader.libList.length;i++)
				{
					Global[_mtLoader.libList[i]] = _loadData[i];
				}
			}

			removeChild(_mtLoader);
			_mtLoader=null;
			start();
		}
		
		/**
		 * 开始运行
		 */ 
		protected function start():void
		{
			if(_scene.Map.smallMap==null)
			{
				_scene.Map.addEventListener(Event.COMPLETE,init);
			}else{
				init();
			}
		}
		
		protected function init(e:Event=null):void
		{
			if(e!=null) _scene.Map.removeEventListener(Event.COMPLETE,init);
			
			sim = new Simulator(_scene);
			_camera = new D5Camera(_scene);
			
			buildObjects();
			buildPlayer();
			
			play();
			
			Global.GC();
			
			if(_scene.Player)
			{
				_scene.Player.setPos(_startX,_startY);
			}
		}
		
		protected function buildPlayer():void
		{
			
		}
		
		/**
		 * 根据配置文件构建场景所有游戏对象
		 */ 
		protected function buildObjects():void
		{
			if(_data!=null)
			{
				if(_data.music!=null) Global.bgMusic.play(_data.music);
				
				for each(var npclist:* in _data.npc.obj)
				{
					var obj:NCharacterObject = _scene.createNPC(npclist.res,_scene.Map.mapid+"_"+npclist.res,npclist.name,new Point(npclist.posx,npclist.posy));
					obj.uid = npclist.uid;
					obj.loadMissionScript();
				}
				
				for each(var buildList:* in _data.build.obj)
				{
					if(buildList.res=='') continue;
					var bld:BuildingObject = _scene.createBuilding(Global.httpServer+WorldMap.LIB_DIR+'map/map'+_scene.Map.mapid+'/'+buildList.res,_scene.Map.mapid+"_"+buildList.res,new Point(buildList.posx,buildList.posy));
					bld.zero=new Point(buildList.centerx,buildList.centery);
					bld.canBeAtk = buildList.canBeAtk=='true' ? true : false;
					bld.zOrderF = buildList.zorder;
				}
				
				for each(var roadList:* in _data.roadpoint.obj)
				{
					if(roadList.posx=='') continue;
					var road:RoadPoint = _scene.createRoad(roadList.posx,roadList.posy);
					road.toMap = roadList.toMap;
					road.toX = roadList.toX;
					road.toY = roadList.toY;
					road.canBeAtk=false;
				}
				
				
				if(_data.loopbg!='') _scene.Map.loopBG = _data.loopbg;
				
				_scene.Map.loadAlphaMap();
				_scene.Map.loadRoadMap();
			}
		}
		
		/**
		 * 控制中心
		 */ 
		public function get ctrlCenter():ControllerCenter
		{
			return _scene.ctrlCenter;
		}
		
		public function clear():void
		{
			stop();
			
			var timer:Timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER,autoUnsetup);
			timer.start();
		}
		
		protected function autoUnsetup(e:Event):void
		{
			var timer:Timer = e.target as Timer;
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER,autoUnsetup);
			
			_scene.clear();
			_scene = null;
			
			if(_nextStep!=null) _nextStep();
			_nextStep=null;
		}
		
		/**
		 * 停止运行
		 */ 
		public function stop():void
		{
			removeEventListener(Event.ENTER_FRAME,render);
			removeEventListener(Event.DEACTIVATE,onDeactivete);
			if(_scene.Player!=null) _scene.Player.controler.unsetupListener();
		}
		
		public function play():void
		{
			if(hasEventListener(Event.ENTER_FRAME)) return;
			addEventListener(Event.ENTER_FRAME,render);
			if(_scene.Player!=null) _scene.Player.controler.setupListener();
		}
		
		/**
		 * 渲染
		 */ 
		protected function render(e:Event):void
		{
			if(_scene.isReady) sim.run();
		}
	}
}