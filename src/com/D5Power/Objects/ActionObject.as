/**
 * D5Power Studio FPower 2D MMORPG Engine
 * 第五动力FPower 2D 多人在线角色扮演类网页游戏引擎
 * 
 * copyright [c] 2010 by D5Power.com Allrights Reserved.
 */ 
package com.D5Power.Objects
{
	import com.D5Power.Controler.Actions;
	import com.D5Power.Controler.BaseControler;
	import com.D5Power.D5Camera;
	import com.D5Power.basic.ResourcePool;
	import com.D5Power.core.Vector2D;
	import com.D5Power.ns.NSCamera;
	import com.D5Power.ns.NSGraphics;
	
	use namespace NSCamera;
	use namespace NSGraphics;
	/**
	 * 游戏中可以活动的对象
	 */ 
	public class ActionObject extends MovieObject
	{
		/**
		 * 动作状态
		 */ 
		protected var _action:uint = Actions.Stop;
		
		/**
		 * 跟随对象
		 */ 
		private var _fllow:ControlActionObject;
		
		/**
		 * 跟随距离
		 */ 
		private var _fllow_distance:Vector2D;
		
		/**
		 * 跟随方向
		 */ 
		private var _fllow_direction:uint;
		
		/**
		 * 是否反向行走
		 */ 
		protected var _isBackWalk:Boolean=false;
		
		
		
		/**
		 * 构造函数
		 */ 
		public function ActionObject(ctrl:BaseControler=null)
		{
			super(ctrl);
			objectName = 'ActionObject';
		}
		
		/**
		 * 在onEnterFrame中计算当前动画应该播放的帧
		 * 
		 * @param	t	时间间隔
		 */ 
		override protected function enterFrame():Boolean
		{
			if(!super.enterFrame()) return false;

			//if(_action==Actions.Stop) _currentFrame=0;
			
			if(_action==Actions.Sit) _currentFrame = directionNum-Directions.Down;
			
			if(_action==Actions.Run)
			{
				D5Camera.needReCut = D5Camera.needReCut || true;
			}
			return true;
			
		}
		
		public function set isBackWalk(b:Boolean):void
		{
			_isBackWalk = b;
		}
		
		public function get isBackWalk():Boolean
		{
			return _isBackWalk;
		}
		
//		override public function get directionNum():int
//		{
//			switch(_action)
//			{
//				case Actions.Sit:
//					return Directions.Sit;
//					break;
//				case Actions.Attack:
//					switch(_4dir)
//					{
//						case Directions.Down:
//							return Directions.ATK_LD;
//							break;
//						case Directions.Left:
//							return Directions.ATK_LU;
//							break;
//						case Directions.Up:
//							return Directions.ATK_RU;
//							break;
//						default:
//							return Directions.ATK_RD;
//					}
//					break;
//				case Actions.BeAtk:
//					switch(_4dir)
//					{
//						case Directions.Down:
//							return Directions.BE_ATK_LD;
//							break;
//						case Directions.Left:
//							return Directions.BE_ATK_LU;
//							break;
//						case Directions.Up:
//							return Directions.BE_ATK_RU;
//							break;
//						default:
//							return Directions.BE_ATK_RD;
//					}
//					break;
//				case Actions.Wait:
//					switch(_4dir)
//					{
//						case Directions.Down:
//							return Directions.WAIT_LD;
//							break;
//						case Directions.Left:
//							return Directions.WAIT_LU;
//							break;
//						case Directions.Up:
//							return Directions.WAIT_RU;
//							break;
//						default:
//							return Directions.WAIT_RD;
//					}
//					break;
//				case Actions.Die:
//					switch(_4dir)
//					{
//						case Directions.Down:
//							return Directions.DIE_LD;
//							break;
//						case Directions.Left:
//							return Directions.DIE_LU;
//							break;
//						case Directions.Up:
//							return Directions.DIE_RU;
//							break;
//						default:
//							return Directions.DIE_RD;
//					}
//					break;
//					break;
//				default:
//					return _directionNum;
//					break;
//			}
//		}
		
		/**
		 * 动作状态
		 */ 
		public function set action(flag:int):void
		{
			if(_action==flag) return;
			if(_action==Actions.Die && flag!=Actions.RELIVE) return;
			if(flag==Actions.RELIVE) flag = Actions.Stop;
			if(flag==Actions.Die)
			{
				canBeAtk=false;
			}else{
				canBeAtk=true;
			}
			if(_action!=flag) _currentFrame=0;
			_action=flag;
			_graphics.nowAction = _action;
			
			RenderUpdated = false;
			
			loopSeter();
			
			updateFPS();
		}
		
		/**
		 * 动作状态
		 */ 
		public function get action():int
		{
			return _action;
		}
		
		
		
		/**
		 * 跟随对象
		 */ 
		public function set fllow(target:ControlActionObject):void
		{
			_fllow=target;
			
			// 计算距离
			var xdistance:Number = pos.x-target.PosX;
			var ydistance:Number = pos.y-target.PosY;
			
			_fllow_distance = new Vector2D(xdistance,ydistance);
			_fllow_direction = target.directionNum;
			directionNum = target.directionNum;
		}
		
		/**
		 * 跟随对象
		 */ 
		public function get fllow():ControlActionObject
		{
			return _fllow;
		}
		
		/**
		 * 跟随方向
		 */ 
		public function get fllowDirection():uint
		{
			return _fllow_direction;
		}
		
		/**
		 * 跟随方向
		 */ 
		public function set fllowDirection(dir:uint):void
		{
			_fllow_direction = dir;	
		}
		
		
		/**
		 * 确认是否在跟随
		 */ 
		public function get isFllowing():Boolean
		{
			return (_fllow!=null);
		}
		
		/**
		 * 跟随距离
		 */ 
		public function set fllowDistance(v:Vector2D):void
		{
			_fllow_distance = v;
		}
		
		
		/**
		 * 跟随距离
		 */ 
		public function get fllowDistance():Vector2D
		{
			return _fllow_distance;
		}

		override public function get currentFrame():int
		{
			if(_action==Actions.Stop) return 0;
			if(isOneline)
			{
				return (_directionNum>0 ? _directionNum : (Directions.Up*2+_directionNum))-Directions.Down;
			}else{
				if(directionNum>=0)
				{
					return _isBackWalk && _action==Actions.Run ? _graphics.framesTotal-_currentFrame-1 : _currentFrame;
				}else{
					if(_action==Actions.Run)
					{
						return _isBackWalk ? _currentFrame : _graphics.framesTotal-_currentFrame-1;
					}else{
						return _graphics.framesTotal-_currentFrame-1;
					}
				}
			}
		}
		
		/**
		 * 当前渲染所需素材的行数
		 * @return	int	若为正数，则为正常素材，若为负数，则为其绝对值行数取镜像
		 */ 
		public function get currentLine():int
		{
			var _y:int = _directionNum;
			if(_action==Actions.Attack) _y+=2;
			if(_graphics.mirrorBitmapData!=null)
			{
				if(_y>4)
				{
					_y=(8-_y)*-1;
				}
			}
			return _y;
		}
		
		/**
		 * 当前所使用的素材是否一行多面
		 */ 
		protected function get isOneline():Boolean
		{
			if(_action==Actions.Sit) return true;
			if(_action==Actions.Stop) return true;
			return false;
		}
		
		/**
		 * 根据不同的动作确定当前动作是否循环
		 */ 
		protected function loopSeter():void
		{
			switch(_action)
			{
				case Actions.Die:
					Loop = false;
					break;
				
				default:
					Loop = true;
					break;
			}
		}
		
		/**
		 * 8方向转4方向
		 */ 
		protected function get _4dir():int
		{
			if(_directionNum==Directions.Down || _directionNum==Directions.LeftDown) return Directions.Down;
			if(_directionNum==Directions.Left || _directionNum==Directions.LeftUp) return Directions.Left;
			if(_directionNum==Directions.Up || _directionNum==Directions.RightUp) return Directions.Up;
			return Directions.Right;
		}
		
		/**
		 * 8方向转2方向
		 */ 
		protected function get _2dir():int
		{
			if(_directionNum==Directions.Down || _directionNum==Directions.LeftDown || _directionNum==Directions.Left || _directionNum==Directions.LeftUp) return Directions.Left;
			return Directions.Right;
		}
	}
}