/**
 * FlexGame 网页游戏引擎
 * 卡马克地图算法
 * Author:D5Power
 * Ver: 1.0
 */ 
package com.D5Power.map
{
	import com.D5Power.Controler.Actions;
	import com.D5Power.Objects.ActionObject;
	import com.D5Power.core.SilzAstar;
	import com.D5Power.loader.DLoader;
	import com.D5Power.ns.D5Map;
	import com.D5Power.ns.NSCamera;
	import com.D5Power.utils.XYArray;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	use namespace D5Map;
	use namespace NSCamera;
	
	public class WorldMap implements IEventDispatcher
	{
		/**
		 * 地图ID
		 */ 
		public var mapid:uint = 0;
		
		public var hasTile:uint = 0;
		
		public static var LIB_DIR:String = 'asset/';
		
		/**
		 * 常量 寻路格子宽度
		 */
		public static var tileWidth:uint = 20;
		/**
		 * 常量 寻路格子高度
		 */ 
		public static var tileHeight:uint = 20;
		
		/**
		 * 寻路
		 */ 
		private static var _AStar:SilzAstar;
		
		/**
		 * 摄像机范围扩展
		 */ 
		public static var cameraAdd:uint = 100;
		
		/**
		 * 大地图循环块的格式
		 */ 
		private var _tileFormat:String = '';
		
		/**
		 * 是否有新数据
		 */ 
		private var _hasData:Boolean=false;
		/**
		 * 数据资源加载 或者用XML
		 */
		private var _urlLoad:URLLoader;
		
		/**
		 * 地图数组
		 */ 
		private var _arry:Array;
		
		/**
		 * 地图缓冲区（源地图）
		 */
		private var buffer:BitmapData;
		
		/**
		 * 地图绘制区
		 */ 
		private var _dbuffer:Shape;
		
		/**
		 * 偏移量X
		 */ 
		private var _offsetX:int=0;
		
		/**
		 * 偏移量Y
		 */ 
		private var _offsetY:int=0;
		
		/**
		 * 显示区域X数量
		 */
		private var _areaX:uint;
		
		/**
		 *	显示区域Y数量
		 */ 
		private var _areaY:uint;
		
		/**
		 * 缓冲尺寸
		 */ 
		private var buffSize:XYArray;
		
		/**
		 * 角色初始坐标 
		 */
		private var start:XYArray;
		
		/**
		 * 地图的移动目标
		 */ 
		private var target:XYArray;
		
		/**
		 * 地图卷动速度
		 */ 
		private var speed:uint=1;
		
		/**
		 * 当前屏幕正在渲染的坐标记录
		 */ 
		private var posFlush:Array;
		
		/**
		 * 获取透明碰撞位图
		 */ 
		private var _alphaMap:BitmapData;
		
		/**
		 * 镜头注视（跟随）的目标
		 */ 
		private var focus_object:ActionObject;
		
		protected var eventSender:EventDispatcher;
		
		protected var _centerPoint:Point;
		
		
		/**
		 * 循环背景
		 */ 
		protected var _loopbg:String;
		
		/**
		 * 循环背景数据
		 */ 
		protected var _loop_bg_data:BitmapData;
		
		/**
		 * 缓存起始X位置，在makeData中放置多次生成占用过多CPU
		 */ 
		protected var _nowStartX:uint;
		/**
		 * 缓存起始Y位置，在makeData中放置多次生成占用过多CPU
		 */
		protected var _nowStartY:uint;
		
		protected var _smallMap:BitmapData;
		
		protected var _scache:BitmapData
		
		protected var _smallMapCallback:Function;
		
		protected var MapResource:Object = {tiles:new Object()};
		
		/**
		 * 用于返回数据的点对象，已防止转换坐标的时候重复进行new操作
		 */ 
		private static var _turnResult:Point = new Point();
		
		private var _turnRect:Rectangle = new Rectangle();
		
		NSCamera var rendSwitch:Boolean=true;
		
		private var _loadList:Vector.<DLoader> = new Vector.<DLoader>;
		
		public function WorldMap()
		{
			eventSender = new EventDispatcher();
			_centerPoint = new Point(Global.W/2,Global.H/2);
			buffer=new BitmapData(Global.W+Global.TILE_SIZE.x,Global.H+Global.TILE_SIZE.y,false); 
		}
		
		/**
		 * 设置镜头跟随某角色
		 */ 
		public function fllow(o:ActionObject):void
		{
			if(focus_object!=null)
			{
				focus_object.beFocus=false; // 每次只能跟随一个角色
				
				if(o==null)
				{
					_centerPoint.x = Center.x;
					_centerPoint.y = Center.y;
				}
			}
			
			focus_object = o;
			if(o!=null)
			{
				o.beFocus=true;
			}
			
			// 强制刷新
			render(true);
		}
		
		/**
		 * 获取当前跟随目标
		 */ 
		NSCamera function get fllower():ActionObject
		{
			return focus_object;
		}
		
		/**
		 * 获取缩略图
		 */ 
		public function get smallMap():BitmapData
		{
			return _smallMap;
		}
		
		/**
		 * 设置小地图数据加载完成后的响应函数
		 * 
		 */ 
		public function set smallMapCallback(f:Function):void
		{
			_smallMapCallback = f;
		}
		
		/**
		 * 更改地图大循环块格式
		 */ 
		public function set tileFormat(s:String):void
		{
			_tileFormat = s;
		}
		
		public function get tileFormat():String
		{
			return _tileFormat;
		}
		
		/**
		 * 地图最大宽度
		 */ 
		public function get maxX():uint
		{
			return Global.MAPSIZE.x;
		}
		
		/**
		 * 地图最大高度
		 */ 
		public function get maxY():uint
		{
			return Global.MAPSIZE.y;
		}
		
		/**
		 * 当前地图的路径地图数组
		 */ 
		public function get roadMap():Array
		{
			return _arry;
		}
		
		/**
		 * 当前地图的路径地图数组
		 */ 
		public function set roadMap(arr:Array):void
		{
			_arry = arr;	
		}
		
		/**
		 * 获取镜头跟随对象作为中心点
		 */ 
		public function get Center():Point
		{
			if(focus_object!=null)
			{
				_centerPoint.x = focus_object.PosX;
				_centerPoint.y = focus_object.PosY;
			}
			
			return _centerPoint;
		}
		
		public function set Center(p:Point):void
		{
			_centerPoint = p;
		}
		
		public function set loopBG(s:String):void
		{
			_loopbg = String(s);
			if(_loopbg=='null' || _loopbg=='') return;
			var loader:DLoader = new DLoader();
			loader.name = LIB_DIR+_loopbg;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,updateLoopBg);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,error);
			loader.load(new URLRequest(LIB_DIR+_loopbg));
		}
		
		public function get loopBG():String
		{
			return _loopbg;
		}
		
		/**
		 * 镜头视野矩形
		 * 返回镜头在世界地图内测区域
		 */ 
		public function get cameraView():Rectangle
		{
			_turnRect.x = startX>Global.MAPSIZE.x-Global.W ? Global.MAPSIZE.x-Global.W : startX;
			_turnRect.y = startY>Global.MAPSIZE.y-Global.H ? Global.MAPSIZE.y-Global.H : startY;
			
			_turnRect.width = Global.W;
			_turnRect.height = Global.H;
			
			return _turnRect;
		}
		
		/**
		 * 镜头裁剪视野
		 */ 
		public function get cameraCutView():Rectangle
		{
			var zero_x:int = startX>Global.MAPSIZE.x-Global.W ? Global.MAPSIZE.x-Global.W : startX;
			var zero_y:int = startY>Global.MAPSIZE.y-Global.H ? Global.MAPSIZE.y-Global.H : startY;
			
			zero_x = Math.max(0,zero_x-Global.TILE_SIZE.x*2);
			zero_y = Math.max(0,zero_y-Global.TILE_SIZE.y*2);
			
			_turnRect.x = zero_x;
			_turnRect.y = zero_y;
			_turnRect.width = Global.W+Global.TILE_SIZE.x*2;
			_turnRect.height = Global.H+Global.TILE_SIZE.y*2;
			
			return _turnRect;
		}
		
		/**
		 * 获取透明碰撞判断数据
		 */ 
		public function get alphaMap():BitmapData
		{
			return _alphaMap;
		}
		
		/**
		 * 获取寻路对象
		 */ 
		public static function get AStar():SilzAstar
		{
			return _AStar;
		}
		
		public function loadRoadMap():void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,configRoadMap);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,RoadLoadError);
			loader.load(new URLRequest(LIB_DIR+"RoadMap/map"+mapid+".png"));
		}
		
		
		
		/**
		 * 读取透明碰撞判断区域
		 */ 
		public function loadAlphaMap():void
		{
			if(_alphaMap!=null)
			{
				_alphaMap.dispose();
				_alphaMap = null;
			}
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,configAlphaMap);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,alphaLoadError);
			loader.load(new URLRequest(LIB_DIR+"AlphaMap/map"+mapid+".png"));
		}
		
		/**
		 * 判断是否在透明碰撞区域
		 */ 
		public function isInAlphaArea(wx:uint,wy:uint):Boolean
		{
			if(_alphaMap==null) return false;
			return _alphaMap.getPixel32(int(_alphaMap.width/Global.MAPSIZE.x*wx),int(_alphaMap.height/Global.MAPSIZE.y*wy))!=0x00000000;
		}
		
		
		/**
		 * 根据屏幕某点坐标获取其在世界（全地图）内的坐标
		 */ 
		public function getWorldPostion(x:Number,y:Number):Point
		{
			var zero_x:int = Center.x-Global.W/2;
			var zero_y:int = Center.y-Global.H/2;
			
			if(zero_x<0) zero_x=0;
			if(zero_x>Global.MAPSIZE.x-Global.W) zero_x = Global.MAPSIZE.x-Global.W;
			
			if(zero_y<0) zero_y=0;
			if(zero_y>Global.MAPSIZE.y-Global.H) zero_y = Global.MAPSIZE.y-Global.H;
			
			_turnResult.x = zero_x+x;
			_turnResult.y = zero_y+y;
			
			return _turnResult;
		}
		
		/**
		 * 根据世界坐标获取在屏幕内的坐标
		 */ 
		public function getScreenPostion(x:Number,y:Number):Point
		{
			var zero_x:int = Center.x-Global.W/2;
			var zero_y:int = Center.y-Global.H/2;
			
			if(zero_x<0) zero_x=0;
			if(zero_x>Global.MAPSIZE.x-Global.W) zero_x = Global.MAPSIZE.x-Global.W;
			
			if(zero_y<0) zero_y=0;
			if(zero_y>Global.MAPSIZE.y-Global.H) zero_y = Global.MAPSIZE.y-Global.H;
			
			_turnResult.x = x-zero_x;
			_turnResult.y = y-zero_y;
			return _turnResult;
		}
		
		/**
		 * 根据路点获得世界（全地图）内的坐标
		 */ 
		public static function tile2WorldPostion(x:Number,y:Number):Point
		{
			_turnResult.x = x*tileWidth+tileWidth*.5;
			_turnResult.y = y*tileHeight+tileHeight*.5;
			return _turnResult;
		}
		
		/**
		 * 世界地图到路点的转换
		 */ 
		public static function Postion2Tile(p:Point):Point
		{
			_turnResult.x = int(p.x/tileWidth);
			_turnResult.y = int(p.y/tileHeight);
			return _turnResult;
		}
		
		public function set dbuffer(v:Shape):void
		{
			_dbuffer = v;
			_dbuffer.graphics.beginBitmapFill(buffer);
			_dbuffer.graphics.drawRect(0,0,buffer.width,buffer.height);
		}
		
		/**
		 * 渲染
		 */ 
		public function render(mustFlush:Boolean=false):void
		{
			if(_smallMap==null) return;
			if(focus_object!=null && focus_object.action==Actions.Stop && !mustFlush) return;
			//if(focus_object!=null && !rendSwitch) return;
			var startx:int = int(startX/Global.TILE_SIZE.x);
			var starty:int = int(startY/Global.TILE_SIZE.y);
			
			makeData(); // 只有在采用大地图背景的前提下才不断修正数据
			if(_nowStartX==startx && _nowStartY==starty && posFlush!=null)
			{
				var zero_x:int = startX%Global.TILE_SIZE.x;
				var zero_y:int = startY%Global.TILE_SIZE.y;
				_dbuffer.x = -zero_x;
				_dbuffer.y = -zero_y;
			}
			
			rendSwitch = false;
		}
		
		public function reset():void
		{
			clear();
			buffer.fillRect(buffer.rect,0);
		}
		
		/**
		 * 初始化地图
		 */ 
		public function install():void
		{
			setup();
		}
		
		protected function setup():void
		{
			// 根据宽高自动计算所能容纳的最大地图数
			_areaX = Math.ceil(Global.W/Global.TILE_SIZE.x)+1;
			_areaY = Math.ceil(Global.H/Global.TILE_SIZE.y)+1;
			
			
			// 读取地图缩略
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onSmallMapLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioError);
			loader.load(new URLRequest(Global.httpServer+LIB_DIR+'tiles/'+mapid+'/s.jpg'));
			
			
		}
		
		/**
		 * 重置地图数据
		 */ 
		protected function resetRoad():void
		{
			_arry=[];
			// 定义临时地图数据
			var h:int =int(Global.MAPSIZE.y/tileHeight);
			var w:int = int(Global.MAPSIZE.x/tileWidth);
			for(var y:uint = 0;y<h;y++)
			{
				var arr:Array = new Array();
				for(var x:uint = 0;x<w;x++)
				{
					arr.push(0);
				}
				_arry.push(arr);
			}
		}
		
		private function ioError(e:IOErrorEvent):void
		{
			trace("Small map load error.url is "+(e.target as LoaderInfo).loaderURL);
		}
		
		/**
		 * 路点加载完成，更新路点
		 */ 
		private function configRoadMap(e:Event):void
		{
			var loadinfo:LoaderInfo = e.target as LoaderInfo;
			
			loadinfo.removeEventListener(Event.COMPLETE,configRoadMap);
			loadinfo.removeEventListener(IOErrorEvent.IO_ERROR,RoadLoadError);
			
			resetRoad();
			var road:BitmapData = (loadinfo.content as Bitmap).bitmapData;		
			
			var t:uint = Global.Timer;
			
			var k:Number = road.width/Global.MAPSIZE.x;
			var h:int = int(Global.MAPSIZE.y/tileHeight);
			var w:int = int(Global.MAPSIZE.x/tileWidth);
			for(var y:uint = 0;y<h;y++)
			{
				for(var x:uint = 0;x<w;x++)
				{
					_arry[y][x] = road.getPixel32(int(tileWidth*x*k),int(tileHeight*y*k))==0x00000000 ? 1 : 0;
				}
			}
			road.dispose();
			updateAstar()
		}
		
		private function updateAstar():void
		{
			_AStar = new SilzAstar(_arry);
		}
		
		private function RoadLoadError(e:ErrorEvent):void
		{
			resetRoad();
		}
		
		/**
		 * 缩略图加载完成
		 */ 
		private function onSmallMapLoaded(e:Event):void
		{
			var loadinfo:LoaderInfo = e.target as LoaderInfo;
			
			loadinfo.removeEventListener(Event.COMPLETE,onSmallMapLoaded);
			loadinfo.removeEventListener(IOErrorEvent.IO_ERROR,ioError);
			
			_smallMap = (loadinfo.content as Bitmap).bitmapData;
			
			var per:Number = _smallMap.width/Global.MAPSIZE.x;
			_scache = new BitmapData(buffer.width*per,buffer.height*per,false,0);
			
			loadinfo.loader.unload();
			loadinfo = null;
			
			makeData();
			
			eventSender.dispatchEvent(new Event(Event.COMPLETE));
			if(_smallMapCallback!=null) _smallMapCallback();
		}
		
		/**
		 * 更新当前需要读取的地图数据
		 * @param	mustFlush	强制刷新
		 */ 
		protected function makeData(startx:int=-1,starty:int=-1):void
		{
			// 根据00点坐标，计算地图渲染的开始区块坐标
			if(startx==-1)
			{
				startx = int(startX/Global.TILE_SIZE.x);
				starty = int(startY/Global.TILE_SIZE.y);
			}
			
			
			if(_nowStartX==startx && _nowStartY==starty && posFlush!=null) return;
			
			_nowStartX = startx;
			_nowStartY = starty;
			
			if(posFlush!=null) posFlush.splice(0,posFlush.length);
			posFlush = new Array();
			
			fillSmallMap(startx,starty);
			
			var maxY:uint = Math.min(starty+_areaY,int(Global.MAPSIZE.y/Global.TILE_SIZE.y));
			var maxX:uint = Math.min(startx+_areaX,int(Global.MAPSIZE.x/Global.TILE_SIZE.x));
			
			for(var y:int=starty;y<maxY;y++)
			{
				var temp:Array = new Array();
				for(var x:int=startx;x<maxX;x++)
				{
					if(x<0 || y<0)
					{
						temp.push(null);
					}else{
						temp.push(y+'_'+x);
					}
				}
				posFlush.push(temp);
			}
			
			loadTites();
			
		}
		
		protected function fillSmallMap(startx:uint,starty:uint):void
		{
			if(_smallMap==null || _scache==null) return;
			
			// 使用缩略图进行填充
			var per:Number = _smallMap.width/Global.MAPSIZE.x;
			_scache.fillRect(_scache.rect,0);
			_scache.copyPixels(_smallMap,new Rectangle(startx*Global.TILE_SIZE.x*per,starty*Global.TILE_SIZE.y*per,_scache.width,_scache.height),new Point());
			per = Global.MAPSIZE.x/_smallMap.width;
			
			buffer.draw(_scache,new Matrix(per,0,0,per),null,null,null,true);
		}
		
		
		/**
		 * 加载当前需要渲染的地图素材
		 */ 
		protected function loadTites():void
		{
			var arr:Array;
			
			var y:uint = 0;
			
			_dbuffer.cacheAsBitmap=false;
			for(var k:String in posFlush)
			{
				var _data:Array = posFlush[k];
				var x:uint = 0;
				
				for(var m:String in _data)
				{
					try
					{
						// 先复制循环背景图
						arr = _data[m].split('_');
						if(_loop_bg_data!=null)
						{
							buffer.copyPixels(_loop_bg_data,_loop_bg_data.rect,new Point(x*Global.TILE_SIZE.x,y*Global.TILE_SIZE.y));
						}
						
						if(_data[m]==null) continue;
						if(_tileFormat!='' && MapResource.tiles[_data[m]]==null)
						{
							var load:DLoader=new DLoader();
							load.name = Global.httpServer+LIB_DIR+"tiles/"+mapid+"/"+_data[m]+"."+_tileFormat;
							load.data = _data[m];
							_loadList.push(load);
						}else if(MapResource.tiles[_data[m]]!=null){
							buffer.copyPixels(MapResource.tiles[_data[m]],MapResource.tiles[_data[m]].rect,new Point(x*Global.TILE_SIZE.x,y*Global.TILE_SIZE.y));
						}
						
					}catch(e:Error){
						
					}
					x++;
				}
				y++;
			}
			
			startLoad();
		}
		
		private function startLoad():void
		{
			if(_loadList.length==0) return;
			var loader:DLoader = _loadList[0];
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,tilesCompele);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,error);
			loader.load(new URLRequest(loader.name));
			
			_loadList.splice(0,1);
		}
		
		/**
		 * 数据加载结束后入库
		 * 
		 */ 
		private function tilesCompele(e:Event):void
		{
			var l:LoaderInfo=e.target as LoaderInfo;
			var loader:DLoader = l.loader as DLoader;
			
			MapResource.tiles[loader.data]= (l.content as Bitmap).bitmapData;
			
			l.removeEventListener(Event.COMPLETE,tilesCompele);
			l.removeEventListener(IOErrorEvent.IO_ERROR,error);
			loader.unload();
			
			var pos:Array = loader.data.split('_');
			buffer.copyPixels(MapResource.tiles[loader.data],MapResource.tiles[loader.data].rect,new Point(int(pos[1]-_nowStartX)*Global.TILE_SIZE.x,int(pos[0]-_nowStartY)*Global.TILE_SIZE.y));
			
			if(_loadList.length>0)
			{
				startLoad();
			}else{
				_dbuffer.cacheAsBitmap=true;
			}
		}
		
		/**
		 * 以目前角色的位置为中点，屏幕原点（左上角）对应的实际地图坐标X
		 */ 
		protected function get startX():int
		{
			var screen_startx:int = Center.x - int(Global.W/2);
			screen_startx=Math.max(0,screen_startx);
			screen_startx=Math.min(Global.MAPSIZE.x-Global.W,screen_startx);
			
			return screen_startx;
		}
		
		/**
		 * 以目前角色的位置为中点，屏幕原点（左上角）对应的实际地图坐标Y
		 */ 
		protected function get startY():int
		{
			var screen_starty:int = Center.y - int(Global.H/2);
			screen_starty = Math.max(0,screen_starty);
			screen_starty = Math.min(screen_starty,Global.MAPSIZE.y-Global.H);
			
			return screen_starty;
		}
		
		private function updateLoopBg(e:Event):void
		{
			var l:LoaderInfo=e.target as LoaderInfo;
			var loader:DLoader = l.loader as DLoader;
			
			l.removeEventListener(Event.COMPLETE,tilesCompele);
			l.removeEventListener(IOErrorEvent.IO_ERROR,error);
			
			var img:Bitmap = l.content as Bitmap;
			if(_loop_bg_data!=null) _loop_bg_data.dispose();
			_loop_bg_data = new BitmapData(img.width,img.height,false);
			_loop_bg_data.draw(img);
			
			img.bitmapData.dispose();
			img=null;
			loader.unload();
		}
		
		/**
		 * 加载完成
		 */ 
		private function configAlphaMap(e:Event):void
		{
			var loader:Loader = (e.target as LoaderInfo).loader;
			
			_alphaMap = (loader.content as Bitmap).bitmapData;
			
			loader.unload();
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,configAlphaMap);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,alphaLoadError);
			loader = null;
			
		}
		
		private function alphaLoadError(e:IOErrorEvent):void
		{
			var loader:Loader = (e.target as LoaderInfo).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,configAlphaMap);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,alphaLoadError);
			loader = null;
		}
		
		private function error(e:IOErrorEvent):void
		{
			try
			{
				var l:LoaderInfo=e.target as LoaderInfo;
				l.removeEventListener(Event.COMPLETE,tilesCompele);
				l.removeEventListener(IOErrorEvent.IO_ERROR,error);
			}catch(e:Error){
				
			}
			trace("加载出错:"+l.loader.name);
		}
		
		/**
		 * 清空内存
		 */ 
		private function clear():void
		{
			while(posFlush.length) posFlush.shift();
			while(_arry.length) _arry.shift();
			Global.CLEAR();
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			eventSender.addEventListener(type, listener, useCapture, priority);
		}
		
		public function dispatchEvent(evt:Event):Boolean{
			return eventSender.dispatchEvent(evt);
		}
		
		public function hasEventListener(type:String):Boolean{
			return eventSender.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			eventSender.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean {
			return eventSender.willTrigger(type);
		}
	}
}