/**
 * D5Power Studio FPower 2D MMORPG Engine
 * 第五动力FPower 2D 多人在线角色扮演类网页游戏引擎
 * 
 * copyright [c] 2010 by D5Power.com Allrights Reserved.
 */ 
package com.D5Power.Controler
{
	import com.D5Power.Objects.GameObject;
	import com.D5Power.ns.ControllerAndTarget;
	
	import flash.geom.Point;
	
	use namespace ControllerAndTarget;
	
	/**
	 *	控制器根类 
	 */
	public class BaseControler
	{
		/**
		 * 感知器
		 */ 
		protected var _perception:Perception;
		
		/**
		 * 计算出来的目标点
		 */ 
		protected var _point:Point;
		
		/**
		 * 
		 */ 
		protected var _actionType:uint;
		
		/**
		 * 结束坐标
		 */ 
		protected var _endTarget:Point;
		
		/**
		 * 下一坐标
		 */ 
		protected var _nextTarget:Point;
		
		/**
		 * 控制器的控制对象
		 */ 
		protected var _me:GameObject;
		
		
		public function BaseControler(pec:Perception)
		{
			_perception = pec;
			_point = new Point();
		}
		
		public function clearPath():void{}
		
		/**
		 * 设置侦听器
		 */ 
		public function setupListener():void{}
		/**
		 * 卸载侦听器
		 */ 
		public function unsetupListener():void{}
		
		/**
		 * 计算行动
		 */ 
		public function calcAction():void
		{
			
		}
		
		public function updateRenderList():void
		{	
		}
		
		public function get point():Point
		{
			return _point;
		}
		
		public function set point(p:Point):void
		{
			_point = p;
		}
		
		public function get actionType():uint
		{
			return _actionType;
		}
		
		public function set actionType(i:uint):void
		{
			_actionType=i;
		}
		
		public function get perception():Perception
		{
			return _perception;
		}
		
		public function set perception(p:Perception):void
		{
			_perception=p;
		}
		
		/**
		 * 下一目标点
		 */ 
		public function get nextTarget():Point
		{
			return _nextTarget;
		}
		/**
		 * 结束目标点
		 */ 
		public function get endTarget():Point
		{
			return _endTarget;
		}

		/**
		 * 控制对象
		 */ 
		public function set me(nc:GameObject):void
		{
			_me=nc;
		}
		/**
		 * 根据角度值修改角色的方向
		 */ 
		protected function changeDirectionByAngle(angle:int):void
		{
			if(_me==null) return;
			if(angle<-22.5) angle+=360;
			
			//_me.Angle = angle;
			
			if(angle>=-22.5 && angle<22.5){
				_me.directionNum = _me.directions.Up;
			}else if(angle>=22.5 && angle<67.5){
				_me.directionNum = _me.directions.RightUp;
			}else if(angle>=67.5 && angle<112.5){
				_me.directionNum = _me.directions.Right;
			}else if(angle>=112.5 && angle<157.5){
				_me.directionNum = _me.directions.RightDown;
			}else if(angle>=157.5 && angle<202.5){
				_me.directionNum = _me.directions.Down;
			}else if(angle>=202.5 && angle<247.5){
				_me.directionNum = _me.directions.LeftDown;
			}else if(angle>=247.5 && angle<292.5){
				_me.directionNum = _me.directions.Left;
			}else{
				_me.directionNum = _me.directions.LeftUp;
			}
		}
	}
}