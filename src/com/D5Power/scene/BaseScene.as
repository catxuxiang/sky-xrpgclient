/**
 * D5Power Studio FPower 2D MMORPG Engine
 * 第五动力FPower 2D 多人在线角色扮演类网页游戏引擎
 * 
 * copyright [c] 2010 by D5Power.com Allrights Reserved.
 */ 
package com.D5Power.scene
{
	import com.D5Power.Controler.CharacterControler;
	import com.D5Power.Controler.ControllerCenter;
	import com.D5Power.Controler.NCharacterControler;
	import com.D5Power.Controler.Perception;
	import com.D5Power.D5Camera;
	import com.D5Power.GMath.data.qTree.QTree;
	import com.D5Power.Objects.CharacterObject;
	import com.D5Power.Objects.GameObject;
	import com.D5Power.events.ChangeMapEvent;
	import com.D5Power.map.WorldMap;
	import com.D5Power.ns.NSCamera;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	
	use namespace NSCamera;

	public class BaseScene
	{
		/**
		 * 感知器
		 */
		public var perc:Perception;
		
		/**
		 * 游戏内的显示对象
		 */
		protected var objects:Array;
		/**
		 * 地图
		 */ 
		protected var map:WorldMap;

		/**
		 * 渲染列表
		 */ 
		protected var _renderList:Array;
		
		/**
		 * 双缓冲区
		 */ 
		//public var doubleBuffer:BitmapData;
		
		protected var _mapGround:Shape;
		
		/**
		 * 游戏对象四叉树
		 */ 
		protected var qTree:QTree;
		
		/**
		 * 效果缓冲区，本缓冲区位于最上层
		 */ 
		//public var effectBuffer:BitmapData;		
		
		protected var _stage:Stage;
		
		protected var _isReady:Boolean=false;
		
		/**
		 * 主角
		 */ 
		protected static var player:CharacterObject;
		
		/**
		 * 控制器中心
		 */ 
		protected var _ctrlCenter:ControllerCenter;
		
		protected var _container:DisplayObjectContainer;
		
		protected var _layer_object:Sprite;
		
		protected var _layer_background:Sprite;
		
		protected var _layer_effect:Sprite;
		
		/**
		 * @param	stg			舞台
		 * @param	container	渲染容器，若为NULL则指定为舞台
		 */ 
		public function BaseScene(stg:Stage,container:DisplayObjectContainer)
		{
			
			perc = new Perception(this);
			_stage=stg;
			_container = container;
			
			objects = new Array();
			_renderList = new Array();
			
			_layer_object = new Sprite();
			_layer_background = new Sprite();
			_layer_effect = new Sprite();
			
			_container.addChild(_layer_background);
			_container.addChild(_layer_object);
			_container.addChild(_layer_effect);
			
			
			buildBuffer();
			
			// 定义控制器中心
			_ctrlCenter = new ControllerCenter();
		}
		
		public function buildQtree():void
		{
			qTree = new QTree(new Rectangle(0,0,Global.MAPSIZE.x,Global.MAPSIZE.y),4);
			_renderList = new Array();
		}
		
		/**
		 * 重新裁剪
		 * 更新目前屏幕内的游戏对象
		 * 
		 * @param	update		是否更新摄像头可视区域
		 */ 
		NSCamera function ReCut(update:Boolean=true):void
		{
			if(update) D5Camera.cameraView = Map.cameraView;
			for each(var obj:GameObject in objects)
			{
				if(obj==player) continue;
				if(D5Camera.cameraView.containsPoint(obj._POS))
				{
					pushRenderList(obj);
				}else{
					(obj.controler==null || obj is CharacterObject) ? pullRenderList(obj) : obj.isOuting();
				}
			}
		}
		
		/**
		 * 控制中心
		 */ 
		public function get ctrlCenter():ControllerCenter
		{
			return _ctrlCenter;
		}
		
		/**
		 * 渲染列表（只有在四叉树渲染优化的前提下才不为NULL）
		 */ 
		public function get renderList():Array
		{
			return _renderList;
		}
		
		public function get Player():CharacterObject
		{
			return player;
		}
		
		/**
		 * 初始化缓冲区
		 */ 
		public function buildBuffer():void
		{
			//doubleBuffer = new BitmapData(Global.W,Global.H,false,0);
			//effectBuffer = new BitmapData(Global.W,Global.H,false,0);
			
			_mapGround = new Shape();
			//_mapGround.cacheAsBitmap=true;
		}
		
		/**
		 * 确认某指定目标是否在当前的镜头视野中
		 */ 
		public function inScene(obj:GameObject):Boolean
		{
			if(qTree==null) return true;
			return qTree.isIn(obj.PosX,obj.PosY);
		}
		
		/**
		 * 初始化地图
		 */ 
		protected function setMap():void
		{
			map = new WorldMap();
			map.dbuffer = _mapGround;
			_layer_background.addChild(_mapGround);
			
			D5Camera.needReCut=true;
		}
		
		/**
		 * 向场景中添加游戏对象
		 */ 
		public function addObject(o:GameObject):void
		{
			if(objects.indexOf(o)!=-1) return;
			objects.push(o);
			if(qTree!=null)
			{
				o.qTree = qTree.add(o,o.PosX,o.PosY);
			}
			if(Map.cameraCutView.containsPoint(o._POS)) pushRenderList(o);
		}
		/**
		 * 
		 */ 
		public function removeObject(o:GameObject):void
		{
			var i:int = objects.indexOf(o);
			
			if(i!=-1) objects.splice(i,1);
			
			if(qTree!=null)
			{
				qTree.remove(o);
			}
			
			pullRenderList(o);
			
			o.clear();
			o=null;
		}
		
		/**
		 * 将游戏对象加入渲染列表
		 */ 
		public function pushRenderList(o:GameObject):void
		{
			if(_renderList.indexOf(o)!=-1) return;
			_renderList.push(o);
			_layer_object.addChild(o);
			o.inuse=true;
			o.isIning();
		}
		
		/**
		 * 将游戏对象移出渲染列表
		 */ 
		public function pullRenderList(o:GameObject):void
		{
			var id:int = _renderList.indexOf(o);
			if(id!=-1)
			{
				_layer_object.removeChild(o);
				_renderList.splice(id,1);
				o.inuse=false;
				o.alpha=0;
			}
		}
		
		/**
		 * 获得特定的游戏对象
		 * @param	i	索引
		 */ 
		public function getObject(i:uint):GameObject
		{
			if(i>ObjectsNumber)
				return null;
			else
				return objects[i] as GameObject;	
		}
		
		/**
		 * 获得特定的角色对象
		 * 
		 * @param	i	索引
		 */ 
		public function getCharacter(i:uint):CharacterObject
		{
			if(i>ObjectsNumber)
				return null;
			else
				return objects[i] as CharacterObject;
		}
		
		/**
		 * 得到所有游戏对象
		 */
		public function getAllObjects():Array
		{
			return objects;
		}
		
		/**
		 * 获得目前舞台中的
		 * 
		 */ 
		public function get ObjectsNumber():uint
		{
			return objects.length;
		}
		
		/**
		 * 记忆工作区
		 */ 
		public function set stage(s:Stage):void
		{
			_stage=s;
		}
		
		/**
		 * 获取工作区
		 */ 
		public function get stage():Stage
		{
			return _stage;
		}
		
		/**
		 * 当前场景的地图
		 */ 
		public function get Map():WorldMap
		{
			return map;
		}
		/**
		 * 是否加载完成
		 */ 
		public function get isReady():Boolean
		{
			return _isReady;
		}
		
		/**
		 * 更换场景
		 * @param	id		目的场景ID
		 * @param	startx	起始坐标X
		 * @param	starty	起始坐标Y
		 */ 
		public function changeScene(id:uint,startx:uint,starty:uint):void
		{
			_stage.dispatchEvent(new ChangeMapEvent(id,startx,starty));
		}
		
		/**
		 * 渲染输出
		 * 
		 */ 
		public function render():void
		{
			updateTime();
			
			//doubleBuffer.fillRect(doubleBuffer.rect,0x000000);
			//effectBuffer.fillRect(effectBuffer.rect,0x000000);
			
			draw();
			
			//doubleBuffer.draw(effectBuffer,new Matrix(),new ColorTransform(),BlendMode.ADD);
		}
		
		/**
		 * 设置用户控制器
		 * @param	ctrl 用户控制器
		 */ 
		protected function setPlayerCtrl(ctrl:CharacterControler):void
		{
			_ctrlCenter.PlayerController = ctrl;
		}
		
		/**
		 * 添加NPC控制器
		 * @param	ctrl	NPC控制器
		 * @param	uid		用户ID
		 */ 
		protected function addNCtrl(ctrl:NCharacterControler,key:*):void
		{
			_ctrlCenter.addNController(ctrl,key);
		}
		
		protected function updateTime():void
		{
			Global.Timer = getTimer();
		}
		
		protected function draw():void
		{
			map.render();
			
			if(_renderList.length==0) return;
			var item:GameObject; // 循环对象
			var child:GameObject;	// 场景对象
			
			var max:uint = _renderList.length;
			
			_renderList.sortOn("zOrder",Array.NUMERIC);
			
			D5Camera.needReCut=false;
			
			while(max--)
			{
				item = _renderList[max];

				child = _layer_object.getChildAt(max) as GameObject;
				if(child!=item)
				{
					_layer_object.setChildIndex(item,max);
				}
				item.renderMe();
			}
			
			if(D5Camera.needReCut) ReCut();
		}
		
		public function clear():void
		{
			objects.splice(0,objects.length);
			_renderList.splice(0,_renderList.length);
			
			while(_layer_object.numChildren) _layer_object.removeChildAt(0);
			while(_layer_background.numChildren) _layer_background.removeChildAt(0);
			while(_layer_effect.numChildren) _layer_effect.removeChildAt(0);
			while(_container.numChildren) _container.removeChildAt(0);
			
			_mapGround.graphics.clear();
			_mapGround = null;
			
			//doubleBuffer.dispose();
		}
	}
}