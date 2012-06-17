package com.D5Power.scene
{
	import com.D5Power.Controler.Actions;
	import com.D5Power.Controler.CharacterControler;
	import com.D5Power.Objects.CharacterObject;
	import com.D5Power.Objects.Effects.ChatPao;
	import com.D5Power.Objects.GameObject;
	import com.D5Power.Objects.NCharacterObject;
	import com.D5Power.Stuff.HSpbar;
	import com.D5Power.controller.MyController;
	import com.D5Power.controller.MyNPCController;
	import com.D5Power.graphicsManager.GraphicsResource;
	import com.D5Power.mission.EventData;
	import com.D5Power.mission.MissionData;
	import com.D5Power.ui.ChatWin;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	
	public class MyScene extends D5Scene
	{		
		public function MyScene(stg:Stage, container:DisplayObjectContainer)
		{
			Main.my.nc.client = this;
			super(stg, container);
		}
		
		/*---------- 响应服务器端程序开始 ----------*/ 
		
		public function move(args:*):void
		{
			updateNpc("游客"+args[0],args[0],args[1],args[2]);
		}
		
		public function come(args:*):void
		{
			var uid:uint = int(args[0]);
			var nickname:String = args[1];
			var x:uint = int(args[2]);
			var y:uint = int(args[3]);
			
			updateNpc(nickname,uid,x,y);
		}
		
		public function leave(args:*):void
		{
			for each(var obj:GameObject in objects)
			{
				if(obj is NCharacterObject && int(args)==obj.ID)
				{
					removeObject(obj);
					return;
				}
			}
		}
		
		public function chat(args:*):void
		{
			ChatWin.my.showchat(args[1]);
		}
		
		/*---------- 响应服务器端程序开始 ----------*/ 
		
		override public function missionCallBack(npcname:String,say:String,event:EventData, miss:Vector.<MissionData>,obj:NCharacterObject):void
		{
			var misid:uint=0;
			var type:uint = 0;
			var complate:Boolean=false;
			if(miss!=null && miss.length!=0)
			{
				if(miss.length==1)
				{
					say = "<font color='#FF9900'>" + miss[0].name + "</font><br><br>"+miss[0].info;
					misid = miss[0].id;
					type = miss[0].type;
					complate = miss[0].isComplate;
				}else{
					for each(var data:MissionData in miss)
					{
						say+= "<br>任务："+data.name+"（完成状态）";
					}
				}
			}else{
				say = "<font color='#FF9900'>" + npcname + "</font><br><br>" + say;
			}
			Wulin.my.npcWindow(say,event,obj,misid,type,complate);
		}
		
		public function buildPlayer(startX:uint,startY:uint):void
		{
			if(player==null)
			{
				player = new CharacterObject(null);
				player.changeController(new MyController(perc,CharacterControler.MOUSE));
				player.ID=Global.userdata.uid;
				
				var g:GraphicsResource = new GraphicsResource('','',1,1,0,true);
				g.addLoadResource(['asset/character/1/body/boy0_stand.png','asset/character/1/body/boy0_stand_head.png'],Actions.Stop,2,5,1);
				g.addLoadResource(['asset/character/1/body/boy0_walk.png','asset/character/1/body/boy0_walk_head.png'],Actions.Run,8,5,12);
				player.graphicsRes = g;
				
				player.render = render_pc;
				player.speed=3.6;
				
				player.setName(WulinGlobal.username);
				
				player.hpMax = 100;
				player.hp = 80;
				player.hpBar = new HSpbar(player,'hp','hpMax');
			}
			
			player.reSetPos(startX,startY);
			createPlayer(player);
		}
		
		
		public function updateNpc(uname:String,uid:uint,sx:uint,sy:uint):void
		{
			for each(var obj:GameObject in _renderList)
			{
				if(obj is NCharacterObject && uid==obj.ID)
				{
					((obj as NCharacterObject).controler as MyNPCController).moveTo(sx,sy);
					return;
				}
			}
			
			for each(obj in objects)
			{
				if(obj is NCharacterObject && uid==obj.ID)
				{
					obj.setPos(sx,sy);
					return;
				}
			}
			
			// 未发现记录，新增角色
			var player:NCharacterObject = new NCharacterObject(new MyNPCController(perc));
			player.ID=uid;
			
			var g:GraphicsResource = new GraphicsResource('','',1,1,0,true);
			g.addLoadResource(['asset/character/1/body/boy0_stand.png','asset/character/1/body/boy0_stand_head.png'],Actions.Stop,2,5,1);
			g.addLoadResource(['asset/character/1/body/boy0_walk.png','asset/character/1/body/boy0_walk_head.png'],Actions.Run,8,5,12);
			player.graphicsRes = g;
			
			player.render = render_npc;
			player.speed=3.6;
			player.setPos(sx,sy);
			
			player.setName(uname);
			
			addObject(player);
		}
		
		override public function changeScene(id:uint, startx:uint, starty:uint):void
		{
			
		}
	}
}