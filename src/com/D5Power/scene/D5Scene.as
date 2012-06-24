package com.D5Power.scene
{
	import com.D5Power.Controler.BaseControler;
	import com.D5Power.Controler.NCharacterControler;
	import com.D5Power.Objects.BuildingObject;
	import com.D5Power.Objects.CharacterObject;
	import com.D5Power.Objects.Effects.BulletObject;
	import com.D5Power.Objects.Effects.RoadPoint;
	import com.D5Power.Objects.GameObject;
	import com.D5Power.Objects.NCharacterObject;
	import com.D5Power.Render.RenderCharacter;
	import com.D5Power.Render.RenderEffect;
	import com.D5Power.Render.RenderNCharacter;
	import com.D5Power.Render.RenderStatic;
	import com.D5Power.graphicsManager.GraphicsResource;
	import com.D5Power.map.WorldMap;
	import com.D5Power.mission.EventData;
	import com.D5Power.mission.MissionData;
	import com.D5Power.ns.NSGraphics;
	import com.D5Power.utils.AvatarData;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Point;
	
	use namespace NSGraphics;
	
	public class D5Scene extends BaseScene
	{
		/**
		 * 建筑渲染器
		 */ 
		protected var render_building:RenderStatic;
		/**
		 * NPC渲染器
		 */ 
		protected var render_npc:RenderNCharacter;
		/**
		 * 角色渲染器
		 */
		protected var render_pc:RenderCharacter;
		/**
		 * 效果渲染器
		 */ 
		protected var render_effect:RenderEffect;

		/**
		 * 
		 * @param	stg				主场景引用
		 * @param	startQuadTree	是否启用四叉树优化
		 */ 
		public function D5Scene(stg:Stage,container:DisplayObjectContainer)
		{
			super(stg,container);
			
			setMap();
			
			render_effect = new RenderEffect();
			
			render_npc = new RenderNCharacter();
			
			render_pc = new RenderCharacter();
			
			render_building = new RenderStatic();
			
			_isReady=true;
		}
		
		/**
		 * 点击了有任务的NPC后的处理
		 * @param	say		NPC默认说的话
		 * @param	miss	可见任务列表
		 */ 
		public function missionCallBack(name:String,say:String,event:EventData,miss:Vector.<MissionData>,obj:NCharacterObject):void
		{
			
		}
		
		/**
		 * 创建NPC
		 * @param	s			位图资源名
		 * @param	resname		缓冲池资源名
		 * @param	name		NPC姓名
		 * @param	pos			目前所在位置
		 * @param	dirConfig	方向配置参数，若为NULL，则为静态1帧
		 */
		public function createNPC(s:String,resname:String,name:String='',pos:Point=null,dirConfig:Object=null):NCharacterObject
		{
			
			var res:GraphicsResource;
			if(dirConfig==null)
			{
				res = new GraphicsResource(null,resname);
			}else{
				res = new GraphicsResource(null,resname,dirConfig.frameTotal,dirConfig.frameLayer,dirConfig.fps,dirConfig.mirror);
			}

			res.addLoadResource([WorldMap.LIB_DIR+'map/map'+Map.mapid+'/npc/'+s]);
			
			var ctrl:NCharacterControler = new NCharacterControler(perc);
			var npc:NCharacterObject = new NCharacterObject(ctrl);
			npc.render = render_npc;
			npc.graphicsRes=res;
			npc.setName(name);
			
			if(pos!=null) npc.setPos(pos.x,pos.y);
			
			addNCtrl(ctrl,npc.uid);
			addObject(npc);
			
			return npc;
		}
		/**
		 * 创建路点
		 * @param	s		资源路径
		 * @param	frame	路点素材帧数
		 * @param	pos		坐标
		 */ 
		public function createRoad(posx:uint=0,posy:uint=0):RoadPoint
		{
			var g:GraphicsResource = new GraphicsResource(null);
			g.addLoadResource([WorldMap.LIB_DIR+'Road.png'],0,5,1,15);
			var obj:RoadPoint = new RoadPoint(this);
			obj.graphicsRes = g;
			obj.setPos(posx,posy);
			
			createEffect(obj,true);
			return obj;
		}
		
		/**
		 * 创建其他用户
		 * 由于不具备通用性。本方法需要在实际的项目中自行实现
		 */ 
		public function createOtherPlayer(s:AvatarData,name:String='',uid:uint = 0,pos:Point=null):NCharacterObject
		{
			return null;
		}
		
		/**
		 * 创建建筑
		 * @param	resList
		 * @param	pos		目前所在位置
		 */ 
		public function createBuilding(resource:String,resname:String,pos:Point=null):BuildingObject
		{
			var res:GraphicsResource = new GraphicsResource(null,resname);
			res.addLoadResource([resource]);
			
			var ctrl:BaseControler = new BaseControler(perc);
			var house:BuildingObject = new BuildingObject(this,ctrl);
			house.graphicsRes = res;
			house.render = render_building;
			
			if(pos!=null) house.setPos(pos.x,pos.y);
			
			addObject(house);
			
			return house;
		}
		
		/**
		 * 创建玩家
		 * @param	s		位图资源
		 * @param	name	玩家姓名
		 * @param	pos		目前所在位置
		 * @param	ctrl	专用控制器，如果为空，则使用默认的角色控制器
		 */ 
		public function createPlayer(p:CharacterObject):void
		{
			if(player==null) player = p;
			
			// 更新感知器为当前场景的感知器。由于player为静态变量，因此当场景重建后，其感知器依然指向已不存在的旧感知器
			p.controler.perception = perc; 
			player.alphaCheck=true;
			addObject(player);
			pushRenderList(player);
		}
		
		/**
		 * 向场景中增加子弹
		 * @param	bitmap	子弹素材
		 * @param	b		子弹对象
		 */ 
		public function createBullet(bitmap:BitmapData,b:BulletObject,resname:String,totalFrame:uint=1):void
		{
			b.graphicsRes = new GraphicsResource(bitmap,resname,totalFrame,1,totalFrame==1 ? 0 : 10);
			createEffect(b,true);
		}
		
		/**
		 * 创建效果
		 * @param	b					要创建的效果
		 * @param	checkView			创建时是否检测视口，若为false，则无条件添加。否则，物品必须在视野范围内才会添加
		 * @param	userEffectBuffer	是否使用EFFECT缓存
		 */ 
		public function createEffect(b:GameObject,useEffectBuffer:Boolean=false):void
		{			
			b.render=useEffectBuffer ? render_effect : render_building;
			addObject(b);
		}
	}
}