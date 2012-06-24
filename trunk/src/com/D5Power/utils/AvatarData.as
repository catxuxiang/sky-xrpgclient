package com.D5Power.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	/**
	 * 角色素材数据
	 */ 
	public class AvatarData
	{
		/**
		 * 资源名
		 */ 
		public var resName:String;
		
		/**
		 * 身体素材
		 */ 
		protected var _body:BitmapData;
		
		/**
		 * 身体素材所包含的最大帧数(列)
		 */ 
		protected var _frame:uint;
		/**
		 * 身体素材所包含的最大动作数（行）
		 */ 
		protected var _action:uint;
		
		/**
		 * 每行所包含的最大帧数的配置
		 */ 
		protected var _lineFrame:Array;
		/**
		 * 每行的整体浮动配置
		 */ 
		protected var _lineYFly:Object;
		
		/**
		 * 最终要返回的结果
		 */ 
		protected var buffer:BitmapData;
		
		/**
		 * @param frame		身体素材所包含的最大帧数(列)
		 * @param action	身体素材所包含的最大动作数（行）
		 */
		public function AvatarData(frame:uint,action:uint)
		{
			_frame = frame;
			_action=action;
			
			_lineFrame = new Array();
			_lineYFly = new Object();
			
			for(var i:uint=0;i<_action;i++) _lineFrame.push(_frame);
		}
		
		/**
		 * 设置整体浮动
		 */ 
		public function lineYFly(action:uint,fly:Number):void
		{
			_lineYFly['_'+action] = fly;
		}
		
		/**
		 * 设置某行所包含的帧数
		 */ 
		public function setLineFrame(line:uint,frame:uint):void
		{
			_lineFrame[line] = frame;
		}
		
		public function get lineFrame():Array
		{
			return _lineFrame;
		}
		
		/**
		 * 身体
		 */ 
		public function set body(b:BitmapData):void
		{
			_body = b;
		}
		
		public function get data():Bitmap
		{
			return null;
		}
		/**
		 * 帧数（列数）
		 */ 
		public function get Frame():uint
		{
			return _frame;
		}
		
		/**
		 * 动作数（行数）
		 */ 
		public function get Action():uint
		{
			return _action;
		}
		
		/**
		 * 释放
		 */ 
		public function clear():void
		{
			
		}
	}
}