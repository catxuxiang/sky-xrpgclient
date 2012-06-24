package com.D5Power.Objects
{
	import com.D5Power.Controler.BaseControler;
	import com.D5Power.ns.NSCamera;
	import com.D5Power.ns.NSRender;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	use namespace NSCamera;
	
	public class MovieObject extends GameObject implements IFrameRender
	{
		/**
		 * 当前帧数
		 */ 
		protected var _currentFrame:uint=0;
		
		/**
		 * 上一帧数
		 */ 
		protected var _lastFrame:uint=0;
		
		/**
		 * 动画最大帧数
		 */ 
		protected var _FrameTotal:uint = 0;
		
		/**
		 * 是否循环
		 */ 
		protected var _loop:Boolean = true;
		
		/**
		 * 非循环动作是否播放完毕
		 */ 
		protected var loopPlayEnd:Boolean=false;
		
		/**
		 * 播放时间间隔
		 */ 
		protected var _playTime:uint;
				
		/**
		 * 上一帧的播放时间，用于计算两帧间的时间差
		 */ 
		private var _lastFrameTime:uint;
		
		private var _needChangeFrame:Boolean=false;
		
		public function MovieObject(ctrl:BaseControler=null)
		{
			_lastFrameTime = Global.Timer;
			super(ctrl);
		}
		
		public function set currentFrame(value:int):void
		{
			_currentFrame=value;
		}
		
		public function get currentFrame():int
		{
			return _currentFrame;
		}
		
		
		public function get lastFrame():int
		{
			return _lastFrame;
		}
		
		public function set Loop(b:Boolean):void
		{
			_loop = b;
			loopPlayEnd = false;
		}
		
		public function get isKeepStatic():Boolean
		{
			return !_loop && loopPlayEnd;
		}
		
		public function get needChangeFrame():Boolean
		{
			return _needChangeFrame;
		}
		
		public function set needChangeFrame(v:Boolean):void
		{
			_needChangeFrame = v;
		}
		
		/**
		 * 渲染矩形
		 */
		override public function get renderRect():Rectangle
		{
			if(_graphics.framesTotal==1)
			{
				return super.renderRect;
			}
			_renderRect.x = currentFrame*_graphics.frameWidth;
			_renderRect.y = Math.abs(directionNum)*_graphics.frameHeight;
			_renderRect.width = _graphics.frameWidth;
			_renderRect.height = _graphics.frameHeight;
			return _renderRect;
		}
		
		override public function get renderLine():uint
		{
			return Math.abs(_directionNum);
		}
		
		override public function get renderFrame():uint
		{
			return _currentFrame;
		}
		
		override protected function build():void
		{
			super.build();
			updateFPS()
		}
		
		protected function updateFPS():void
		{
			_FrameTotal = _graphics.getFrameTotal();
			_playTime = 1000/_graphics.fps;
		}
		
		protected function enterFrame():Boolean
		{
			if(_graphics==null || _graphics.fps==0) return false;
			if(Global.Timer-_lastFrameTime>=_playTime && !loopPlayEnd)
			{
				_lastFrameTime = Global.Timer;
				_lastFrame = _currentFrame;
				
				if(_currentFrame>=_FrameTotal-1)
				{
					_loop ? _currentFrame=0 : loopPlayEnd=true;
				}else{
					_currentFrame++;
				}
				
				_needChangeFrame = true;
			}
			return true;
		}
		
		override public function renderMe():void
		{
			enterFrame();
			
			super.renderMe();
		}
	}
}