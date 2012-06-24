package com.D5Power.utils
{
	import flash.display.Bitmap;

	/**
	 * 角色数据-完整层次类
	 */ 
	public class AvatarData_Layer extends AvatarData
	{
		/**
		 * 装扮列表
		 */ 
		protected var _avatarList:Array;
		
		protected var drawed:Boolean=false;
		
		public function AvatarData_Layer(frame:uint, action:uint)
		{
			super(frame, action);
			_avatarList = new Array();
		}
		
		/**
		 * 增加新的装扮
		 * 添加越早，渲染层次越靠底层
		 * @param	b	素材
		 */ 
		public function addAvatarPart(b:String):void
		{
			if(_body==null)
			{
				trace('还未定义角色身体');
				return;
			}
			
			_avatarList.push(b);
		}
		
		public function get avatarList():Array
		{
			return _avatarList;
		}

		override public function get data():Bitmap
		{
			if(_body==null)
			{
				trace('还未定义角色身体');
				return null;
			}			
			return new Bitmap(_body);
		}
	}
}