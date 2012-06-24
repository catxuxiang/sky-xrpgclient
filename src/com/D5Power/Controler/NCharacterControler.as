package com.D5Power.Controler
{
	import com.D5Power.GMath.GMath;
	import com.D5Power.Objects.CharacterObject;
	import com.D5Power.map.WorldMap;
	
	import flash.geom.Point;
	
	/**
	 * 由电脑控制的玩家对象的控制器
	 * 
	 */ 
	public class NCharacterControler extends BaseControler
	{
		/**
		 * 移动路径
		 */ 
		protected var _path:Array;
		/**
		 * 移动步骤
		 */ 
		private var _step:uint = 1;
		/**
		 * 是否循环移动
		 */ 
		private var _isloop:Boolean=false;
		
		
		public function NCharacterControler(pec:Perception)
		{
			super(pec);
		}
		
		public function moveTo(x:Number,y:Number):void
		{
			if(x==_me.PosX && y==_me.PosY) return;
			
			var m:WorldMap = _perception.Scene.Map;
			_endTarget = new Point(x,y);
			
			// 计算格子数
			var end:Point = WorldMap.Postion2Tile(_endTarget).clone();
			
			var start:Point = WorldMap.Postion2Tile(_me._POS).clone();
			
			//_me.action = Actions.Stop;
			
			// 得出路径
			//_path = AStar.startSearch(m.roadMap,startX,startY,tileX,tileY);
			_path = new Array(new Array(start.x,start.y),new Array(end.x,end.y));
			_step=1;
		}
		
		/**
		 * 沿某路径移动
		 * @param	args	世界地图的坐标点序列，必须为偶数。以x,y,x1,y1,x2,y2的方式排列
		 */ 
		public function moveInPath(...args):void
		{
			if(args.length%2!=0)
			{
				Global.msg('路径点必须是偶数');
				return;
			}
			
			var nTarget:Point;
			var arr:Point;
			
			_path = new Array();
			
			arr = WorldMap.Postion2Tile(_me._POS);


			for(var i:uint=0;i<args.length;i+=2)
			{
				nTarget = new Point(args[i],args[i+1]);
				arr = WorldMap.Postion2Tile(nTarget);
				_path.push(new Array(arr.x,arr.y));
			}
			_step=0;
		}
		
		/**
		 * 是否循环移动
		 */ 
		public function set loop(b:Boolean):void
		{
			_isloop = b;
		}

		/**
		 * 计算行动
		 */ 
		override public function calcAction():void
		{
			var c:CharacterObject = _me as CharacterObject;
			
			if(c.isFllowing)
			{
				// 跟随类处理
				var cNextTarget:Point = c.fllow.controler.nextTarget;
				if(cNextTarget==null) return;
				

				if(c.fllowDirection!=c.fllow.directionNum)
				{
					//c.fllowDistance.angle = c.fllowDistance.angle+Math.PI;
					c.fllowDistance.x = c.fllowDistance.x*-1;
					c.fllowDirection =c.fllow.directionNum;
				}
				_nextTarget = new Point(cNextTarget.x+c.fllowDistance.x,cNextTarget.y+c.fllowDistance.y);
				
				if(c._POS==_nextTarget) return;
			}else if(_path!=null && _path[_step]!=null){
				// 电脑直接控制类处理
				_nextTarget = _step==_path.length ? _endTarget : WorldMap.tile2WorldPostion(_path[_step][0],_path[_step][1]);
			}
			
			
			//if((_nextTarget!=c.Pos && _nextTarget!=null) || (_path!=null && _path[_step]!=null))
			if(_nextTarget!=null && _nextTarget!=c._POS)
			{
				if(!_me.inuse)
				{
					_step++;
					_me.setPos(_nextTarget.x,_nextTarget.y);
					if(_step>=_path.length)
					{
						if(_isloop)
						{
							// 循环
							_step = 0;
						}else{
							_nextTarget=null;
							c.action=Actions.Stop;
						}
					}
					return;
				}
				
				c.action = Actions.Run;
				var radian:Number = GMath.getPointAngle(_nextTarget.x-c.PosX,_nextTarget.y-c.PosY);
				var angle:int = GMath.R2A(radian)+90;
				
				var xisok:Boolean=false;
				var yisok:Boolean=false;
				
				var xspeed:Number = c.speed*Math.cos(radian);
				var yspeed:Number = c.speed*Math.sin(radian);
				
				
				if(Math.abs(c.PosX-_nextTarget.x)<=xspeed)
				{
					xisok=true;
					xspeed=0;
				}
				
				if(Math.abs(c.PosY-_nextTarget.y)<=yspeed)
				{
					yisok=true;
					yspeed=0;
				}
				c.setPos(c.PosX+xspeed,c.PosY+yspeed);

				if(xisok && yisok)
				{
					_step++;
					c.setPos(_nextTarget.x,_nextTarget.y);
					if(_step>=_path.length)
					{
						if(_isloop)
						{
							// 循环
							_step = 0;
						}else{
							_nextTarget=null;
							_path.splice(0,_path.length);
							_path=null;
						}
					}
					c.action=Actions.Stop;
				}else{
					changeDirectionByAngle(angle);
				}
			}// if
		}// function calcAction
	}
}