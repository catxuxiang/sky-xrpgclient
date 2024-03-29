/**
 * D5Power Studio FPower 2D MMORPG Engine
 * 第五动力FPower 2D 多人在线角色扮演类网页游戏引擎
 * 
 * copyright [c] 2010 by D5Power.com Allrights Reserved.
 */ 
package com.D5Power.Controler
{
	import com.D5Power.Objects.ActionObject;
	import com.D5Power.Objects.CharacterObject;
	import com.D5Power.Objects.GameObject;
	import com.D5Power.scene.BaseScene;
	
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * 感知器
	 * 
	 */ 
	public class Perception
	{
		/**
		 * 游戏主场景
		 */
		private var _gameScene:BaseScene;
		/**
		 * 我自己
		 */
		private var _me:GameObject;
		/**
		 * 攻击目标
		 */
		private var _attackTarget:GameObject;
		
		/**
		 * 碰撞检测精度
		 */ 
		private var _hitChecker:uint = 4;
		
		/**
		 * 
		 */
		private var _mouseEvent:MouseEvent;
		
		
		public function Perception(gs:BaseScene)
		{
			_gameScene=gs;
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			
		}
		
		private function onMove(e:MouseEvent):void
		{
			
		}
		
		private function keykown(e:KeyboardEvent):void
		{
			
		}
		
		private function keyUP(e:KeyboardEvent):void
		{
			
		}
		
		
		public function set me(value:GameObject):void
		{
			_me=value;
		}		
		public function get me():GameObject
		{
			return _me;
		}
		
		public function set Scene(value:BaseScene):void
		{
			_gameScene=value;
		}
		public function get Scene():BaseScene
		{
			return _gameScene;
		}
		
		/**
		 * 设置我的攻击目标
		 */ 
		public function set AttackTarget(value:GameObject):void
		{
			_attackTarget=value;
		}
		public function get AttackTarget():GameObject
		{
			return _attackTarget;
		}
		
		/**
		 * 计算我与当前对像的距离
		 */
		public function calcMyDistanceToCharacter(who:GameObject):Number
		{
			return Point.distance(me._POS,who._POS);
		}
		
		/**
		 * 计算最近角色的距离
		 */
		public function calcMyDistanceToNearestCharacter():CharacterObject
		{
			return  _gameScene.getCharacter(0);
		}
		
		/**
		 * 获取点击目标
		 * @param	p	屏幕坐标
		 */ 
		public function getClicker(px:Number,py:uint):GameObject
		{
			var tpos:Point = _gameScene.Map.getWorldPostion(px,py);
			return getObjectByGraphics(tpos);
		}
		/**
		 * 根据某坐标及对象坐标来判断是否发生碰撞
		 * @param	tpos			获取点
		 * @param	checkAtkStatus	是否区分能否被攻击，若为true，则只查找可被攻击的目标。如果为false,则查找全部
		 * @param	checkDistance	攻击精确判断距离
		 * @param	checkCamp		是否检测阵营
		 */ 
		public function getObjectByPos(tpos:Point,checkAtkStatus:Boolean=false,checkDistance:uint=15,checkCamp:Boolean=false):GameObject
		{
			var arr:Array = _gameScene.renderList==null ? getAll() : _gameScene.renderList;
			var tx:int;
			var ty:int;
			var c:ActionObject;
			
			/**
			 * 碰撞列表
			 */ 
			var atkList:Array = new Array();
			for each(var d:GameObject in arr)
			{
				if(d==Scene.Player || !d.inuse) continue;
				if(checkAtkStatus && d.canBeAtk==false) continue;
				if(checkCamp && Global.userdata.camp!=0 && d.camp==Global.userdata.camp) continue;
				if(Point.distance(tpos,d._POS)<checkDistance)
				{
					atkList.push(d);
				}
			}
			
			if(atkList.length==0) return null;
			atkList.sortOn('zOrder',Array.DESCENDING);
			return atkList[0];
		}
		
		/**
		 * 根据某坐标及对象的图形外框获取发生碰撞的物体
		 * @param	tpos			获取点(屏幕坐标)
		 * @param	checkAtkStatus	是否区分能否被攻击，若为true，则只查找可被攻击的目标。如果为false,则查找全部
		 * @param	checkCamp		是否区分阵营不同，如果为true，则只查找不同阵营的目标
		 * @param	notMe			是否把自己计算在内，如果为true，则不计算自己
		 */ 
		public function getObjectByRect(tpos:Point,checkAtkStatus:Boolean=false,checkCamp:Boolean=false,notMe:Boolean=true):GameObject
		{
			var arr:Array = _gameScene.renderList==null ? getAll() : _gameScene.renderList;
			var c:ActionObject;
			
			var atkList:Array = new Array();

			for each(var d:GameObject in arr)
			{
				if(notMe && d==Scene.Player) continue;

				if(!d.inuse) continue;

				if(checkAtkStatus && d.canBeAtk==false) continue;

				//trace(d,d.camp,_gameScene.Player.camp,checkCamp,(checkCamp && _gameScene.Player!=null && d.camp==_gameScene.Player.camp));
				if(checkCamp && Global.userdata.camp!=0 && d.camp==Global.userdata.camp) continue;
				
				// 若相对坐标在图像范围内，则列入碰撞范围
				if(d.hitTestPoint(tpos.x,tpos.y,false))
				{
					atkList.push(d);
				}

			}
			if(atkList.length==0) return null;
			atkList.sortOn('zOrder',Array.DESCENDING);
			return atkList[0];
		}
		
		/**
		 * 根据某坐标及图形获取发生碰撞的物体
		 * @param	tpos			获取点
		 * @param	checkAtkStatus	是否区分能否被攻击，若为true，则只查找可被攻击的目标。如果为false,则查找全部
		 * @param	checkCamp		是否区分阵营不同，如果为true，则只查找不同阵营的目标
		 * @param	notMe			是否把自己计算在内，如果为true，则不计算自己
		 */ 
		public function getObjectByGraphics(tpos:Point,checkAtkStatus:Boolean=false,checkCamp:Boolean=false,notMe:Boolean=true):GameObject
		{
			var arr:Array = _gameScene.renderList==null ? getAll() : _gameScene.renderList;
			var tx:int;
			var ty:int;

			var tester:BitmapData;
			for each(var d:GameObject in arr)
			{
				if(notMe && d==Scene.Player) continue;
				if(!d.inuse) continue;
				if(checkAtkStatus && d.canBeAtk==false) continue;
				if(checkCamp && Global.userdata.camp!=0 && d.camp==Global.userdata.camp) continue;
				tx = int(tpos.x-(d.PosX-d.graphicsRes.frameWidth/2));		// 由于在渲染的时候，将角色素材硬性移动到了鼠标脚下，因此在检测时候也需要调整
				ty = int(tpos.y-(d.PosY-d.graphicsRes.frameHeight));
				
				// 若相对坐标超出图像范围，则跳过
				if(tx>d.graphicsRes.frameWidth || tx<0) continue;
				if(ty>d.graphicsRes.frameHeight || ty<0) continue;
				

				if(d.directionNum>=0)
				{
					tester = d.graphicsRes.bitmap[d.renderLine][d.renderFrame];
				}else{
					tester = d.graphicsRes.mirrorBitmapData[d.renderLine][d.renderFrame];
				}
				
				if(tester.hitTest(new Point(),255,new Point(tx,ty)))
				{
					return d;
					break;
				}
			}
			
			return null;
		}
		
		/**
		 * 获取全部渲染对象
		 */
		public function getAll():Array
		{
			return _gameScene.getAllObjects();
		}
	}
}