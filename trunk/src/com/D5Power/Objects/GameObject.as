/**
 * D5Power Studio FPower 2D MMORPG Engine
 * 第五动力FPower 2D 多人在线角色扮演类网页游戏引擎
 * 
 * copyright [c] 2010 by D5Power.com Allrights Reserved.
 */ 
package com.D5Power.Objects
{
	import com.D5Power.Controler.BaseControler;
	import com.D5Power.GMath.data.qTree.QTree;
	import com.D5Power.Objects.Effects.Shadow;
	import com.D5Power.Render.Render;
	import com.D5Power.graphicsManager.GraphicsResource;
	import com.D5Power.ns.NSCamera;
	import com.D5Power.ns.NSGraphics;
	import com.D5Power.ns.NSRender;
	import com.D5Power.utils.NoEventSprite;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	use namespace NSRender;
	use namespace NSCamera;
	use namespace NSGraphics;

	/**
	 * 游戏对象基类
	 * 游戏中全部对象的根类
	 */ 
	public class GameObject extends NoEventSprite
	{
		/**
		 * 默认方向配置
		 */ 
		public static var DEFAULT_DIRECTION:Direction=new Direction();
		
		/**
		 * 渲染器
		 */ 
		public var render:Render;
		
		/**
		 * 是否可用
		 */ 
		public var inuse:Boolean=false;
		
		/**
		 * 外部引用数
		 */ 
		public var linkNum:int = 0;
		
		/**
		 * 是否可被攻击
		 */ 
		public var canBeAtk:Boolean=false;
		
		/**
		 * 渲染是否更新,若为true则无需渲染,若为false则需要重新渲染
		 */ 
		public var RenderUpdated:Boolean=false;
		
		/**
		 *	是否摄像机跟随的目标 
		 */
		public var beFocus:Boolean=false;
		
		public var ID:uint=0;
		
		/**
		 * 类型名，用于点击区分
		 */ 
		public var objectName:String='GameObject';
		
		/**
		 * 是否正在移出场景
		 */ 
		protected var _isOuting:Boolean=false;
		/**
		 * 是否正在移进场景
		 */ 
		protected var _isIning:Boolean=false;
		/**
		 * 深度排序
		 */ 
		protected var zorder:int = 0;
		
		
		/**
		 * 控制器,每个对象都可以拥有控制器。控制器是进行屏幕裁剪后对不在屏幕内
		 * 的对象进行处理的接口。
		 */ 
		protected var _controler:BaseControler;
		/**
		 * 对象定位
		 */ 
		protected var pos:Point;
		
		/**
		 * 对象的速度
		 */
		protected var _speed:Number=2;
		
		/**
		 * 图形资源
		 */ 
		protected var _graphics:GraphicsResource;
		
		/**
		 * 行动方向  默认为8个方向 配置见Directions对象
		 */			
		protected var _directionNum:int=0;
		
		/**
		 * 排序调整
		 */ 
		protected var _zOrderF:int=0;
		
		/**
		 * 显示阴影
		 */ 
		protected var _shadow:Shadow;
		
		/**
		 * 记录当前对象所在的象限
		 */ 
		protected var _qTree:QTree;
		
		/**
		 * 角色阵营
		 */ 
		protected var _camp:uint=0;
		
		/**
		 * 渲染方式
		 */ 
		protected var _renderPos:uint;
		
		/**
		 * 主渲染
		 */ 
		protected var _renderBuffer:Bitmap;
		
		/**
		 * 是否使用alpha通道
		 */ 
		protected var _allowAlpha:Boolean=true;
		
		/**
		 * 渲染矩阵
		 */ 
		protected var _renderRect:Rectangle;
		
		
		protected var Directions:Direction;
		
		public static const BOTTOM:uint = 1;
		public static const LEFTTOP:uint = 0;
		public static const CENTER:uint = 2;
		
	

		/**
		 * @param	ctrl	控制器
		 */ 
		public function GameObject(ctrl:BaseControler = null,dir:Direction=null)
		{
			Directions = dir==null ? DEFAULT_DIRECTION : dir;
			pos = new Point(0,0);
			_renderPos = LEFTTOP;
			_renderRect = new Rectangle();
			changeController(ctrl);
			setupBuffer();
			
		}
		
		/**
		 * 更换控制器
		 */ 
		public function changeController(ctrl:BaseControler):void
		{
			if(_controler!=null)
			{
				_controler.unsetupListener();
			}
			
			if(ctrl!=null)
			{
				_controler = ctrl;
				_controler.me=this;
				_controler.setupListener();
			}
			
		}
		
		NSGraphics function get renderBuffer():Bitmap
		{
			return _renderBuffer;
		}
		
		/**
		 * 设置对象的坐标定位
		 * @param	p
		 */ 
		public function setPos(px:Number,py:Number):void
		{
			pos.x = px;
			pos.y = py;
			zorder = pos.y;
		}
		
		/**
		 * 将对象移动到某一点，并清除当前正在进行的路径
		 */ 
		public function reSetPos(px:Number,py:Number):void
		{
			setPos(px,py);
			if(controler!=null) controler.clearPath();
		}
		
		/**
		 * 当前对象所在的象限
		 */ 
		public function set qTree(q:QTree):void
		{
			_qTree = q;
		}
		
		/**
		 * 获取对象的坐标定位
		 */ 
		public function get PosX():Number
		{
			return pos.x;
		}
		
		/**
		 * 获取对象的坐标定位
		 */ 
		public function get PosY():Number
		{
			return pos.y;
		}
		
		/**
		 * 本坐标仅可用来获取！！！
		 */ 
		public function get _POS():Point
		{
			return pos;
		}
		
		/**
		 * 影子
		 */ 
		public function get shadow():Shadow
		{
			return _shadow;
		}
		
		/**
		 * 深度排序浮动
		 */ 
		public function set zOrderF(val:int):void
		{
			_zOrderF = val;
		}
		/**
		 * 深度排序浮动
		 */
		public function get zOrderF():int
		{
			return _zOrderF;
		}
		
		/**
		 * 获取坐标的深度排序
		 */ 
		public function get zOrder():int
		{
			//return zorder;
			return pos.y+_zOrderF;
		}
		
		public function set speed(value:Number):void
		{
			_speed = value;
		}
		
		public function get speed():Number
		{
			return _speed;
		}
		
		public function get controler():BaseControler
		{
			return _controler;
		}
		
		/**
		 * 面向角度
		 */ 
		public function get Angle():uint
		{
			switch(_directionNum)
			{
				case Directions.Up:
					return 0;
					break;
				case Directions.LeftUp:
					return 315;
					break;
				case Directions.Left:
					return 270;
					break;
				case Directions.LeftDown:
					return 215;
					break;
				case Directions.Down:
					return 180;
					break;
				case Directions.RightDown:
					return 135;
					break;
				case Directions.Right:
					return 90;
					break;
				case Directions.RightUp:
					return 45;
					break;
				default:
					return 0;
					break;
			}
		}
		
		public function set directions(v:Direction):void
		{
			Directions = v;
			_directionNum = v.Down;
		}
		
		public function get directions():Direction
		{
			return Directions;
		}
		
		/**
		 * 渲染自己在屏幕上输出
		 */
		public function renderMe():void
		{
			if(_renderBuffer!=null && inuse) render.render(this);
		}
		
		/**
		 * 图形资源
		 */ 
		public function get graphicsRes():GraphicsResource
		{
			return _graphics;
		}
		
		/**
		 * 图形资源
		 */ 
		public function set graphicsRes(value:GraphicsResource):void
		{
			_graphics=value;
			if(_graphics.frameWidth==0)
			{
				var timer:Timer = new Timer(500);
				timer.addEventListener(TimerEvent.TIMER,waitResLoad);
				timer.start();
			}else{
				build();
			}
		}
		
		/**
		 * 方向值
		 */ 
		public function get directionNum():int
		{
			return _directionNum;
		}
		
		/**
		 * 方向值
		 */ 
		public function set directionNum(value:int):void
		{
			_directionNum=value;
			RenderUpdated = false;
		}
		
		/**
		 * 角色阵营
		 */ 
		public function get camp():uint
		{
			return _camp;
		}
		
		/**
		 * 角色阵营
		 */ 
		public function set camp(_c:uint):void
		{
			if(_c==0) return;
			_camp=_c;
		}
		
		/**
		 * 是否中央渲染
		 */ 
		public function get renderPos():uint
		{
			return _renderPos;
		}
		
		/**
		 * 渲染矩形
		 */
		public function get renderRect():Rectangle
		{
			_renderRect.x = 0;
			_renderRect.y = 0;
			_renderRect.width = _graphics.frameWidth;
			_renderRect.height = _graphics.frameHeight;
			return _renderRect;
		}
		
		public function get renderLine():uint
		{
			return 0;
		}
		
		public function get renderFrame():uint
		{
			return 0;
		}
		
		NSCamera function isOuting():void
		{
			_isOuting = true;
			_isIning = false;
			
			if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME,goIn);
			if(!hasEventListener(Event.ENTER_FRAME)) addEventListener(Event.ENTER_FRAME,goOut);
		}
		
		NSCamera function isIning():void
		{
			_isIning = true;
			_isOuting = false;
			
			if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME,goOut);
			if(!hasEventListener(Event.ENTER_FRAME)) addEventListener(Event.ENTER_FRAME,goIn);
		}
		
		/**
		 * 当对象超出渲染范围后后逐渐消失的效果实现
		 */ 
		protected function goOut(e:Event):void
		{
			if(alpha>0)
			{
				alpha-=.01;
			}else{
				_controler.perception.Scene.pullRenderList(this);
				removeEventListener(Event.ENTER_FRAME,goOut);
			}
		}
		
		/**
		 * 当对象进入渲染范围后后逐渐出现的效果实现
		 */ 
		protected function goIn(e:Event):void
		{
			if(alpha<1)
			{
				alpha+=.01;
			}else{
				removeEventListener(Event.ENTER_FRAME,goIn);
			}
		}
		
		protected function setupBuffer():void
		{
			_renderBuffer = new Bitmap();
			addChild(_renderBuffer);
		}

		/**
		 * 清除
		 */ 
		public function clear():void
		{
			if(_graphics!=null)
			{
				_graphics.clear();
				_graphics=null;
			}
			
			Global.GC();
		}
		
		protected function waitResLoad(e:TimerEvent):void
		{
			var target:Timer = e.target as Timer;
			if(_graphics!=null && _graphics.frameWidth!=0)
			{
				target.stop();
				target.removeEventListener(TimerEvent.TIMER,waitResLoad);
				target = null;
				
				build();
			}
		}
		
		/**
		 * 创建主渲染缓冲区
		 */ 
		protected function build():void
		{
			RenderUpdated=false;
			flyPos();
		}
		
		/**
		 * 设置相对坐标
		 */ 
		protected function flyPos(px:Number=NaN,py:Number=NaN):void
		{
			if(px && py)
			{
				_renderBuffer.x = -px;
				_renderBuffer.y = -py;
			}
			if(_graphics!=null)
			{
				_renderBuffer.x = -_graphics.frameWidth/2;
				_renderBuffer.y = -_graphics.frameHeight;
			}
		}
	}
}