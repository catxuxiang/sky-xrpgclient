package com.D5Power
{
	import com.D5Power.Objects.ActionObject;
	import com.D5Power.ns.NSCamera;
	import com.D5Power.scene.BaseScene;
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	use namespace NSCamera;
	
	/**
	 * 摄像机控制类
	 */ 
	public class D5Camera
	{
		/**
		 * 摄像机可视区域
		 */ 
		public static var cameraView:Rectangle;
		
		/**
		 * 是否需要重新裁剪
		 */ 
		public static var needReCut:Boolean;
		
		/**
		 * 主场景
		 */ 
		protected var _scene:BaseScene;
		/**
		 * 镜头注视
		 */ 
		protected var _focus:ActionObject;
		
		protected var _timer:Timer;
		
		protected var _moveSpeed:uint;
		
		private var _moveStart:Point;
		private var _moveEnd:Point;
		private var _moveAngle:Number=0;
		private var _moveCallBack:Function;
		
		
		public function D5Camera(scene:BaseScene)
		{
			_scene = scene;
		}
		
		public function get centerX():uint
		{
			return _scene.Map.Center.x;
		}
		
		public function get centerY():uint
		{
			return _scene.Map.Center.y;
		}
		
		public function setCenter(x:uint,y:uint):void
		{
			_scene.Map.Center = new Point(x,y);
			_scene.ReCut();
		}
		
		/**
		 * 镜头注视
		 */ 
		public function focus(o:ActionObject=null):void
		{
			if(o==null)
			{
				if(_scene.Player==null)
				{
					Global.msg("Can not fllow null object.");
					return;
				}else{
					_scene.Map.fllow(_scene.Player);
				}
			}else{
				_scene.Map.fllow(o);
			}
			
			_scene.ReCut();
		}
		
		/**
		 * 镜头移动速度
		 */ 
		public function set moveSpeed(s:uint):void
		{
			_moveSpeed = s;
		}
		
		/**
		 * 镜头观察某点
		 */ 
		public function lookTo(x:uint,y:uint):void
		{
			if(_scene.Map.fllower!=null)
			{
				_focus = _scene.Map.fllower;
			}
			
			
		}
		
		public function flyTo(x:uint,y:uint,callback:Function=null):void
		{
			if(_timer!=null)
			{
				throw new Error("Camera is moving,can not do this operation.");
				return;
			}
			
			_moveCallBack = callback;
			
			_focus = _scene.Map.fllower;
			_moveStart = new Point(_scene.Map.Center.x,_scene.Map.Center.y);
			
			_scene.Map.fllow(null);
			_moveEnd = new Point(x,y);
			
			_timer = new Timer(50);
			_timer.addEventListener(TimerEvent.TIMER,moveCamera);
			_timer.start();
		}
		
		protected function moveCamera(e:TimerEvent):void
		{
			_moveStart.x += int((_moveEnd.x-_moveStart.x)/5);
			_moveStart.y += int((_moveEnd.y-_moveStart.y)/5);
			_scene.Map.Center = _moveStart;
			_scene.ReCut();
			if(Point.distance(_moveStart,_moveEnd)<10)
			{
				_scene.Map.Center = _moveEnd;
				_moveEnd = null;
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER,moveCamera);
				_timer = null;
				if(_moveCallBack!=null) _moveCallBack();
			}
		}
	}
}