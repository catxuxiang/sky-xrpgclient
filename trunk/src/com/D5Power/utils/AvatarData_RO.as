package com.D5Power.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * 角色素材数据(RO类)
	 * 头部与身体分开，不存在裸模，换装则整个身体更换
	 */ 
	public class AvatarData_RO extends AvatarData
	{
		/**
		 * 头像素材
		 */ 
		protected var _head:BitmapData;
		
		
		/**
		 *	头素材中，与身体连接位置的高度
		 */ 
		protected var _nicky:uint;
		/**
		 * 头像素材的方向配置
		 */ 
		protected var _headDir:Object;
		
		/**
		 * 头像素材所包含的总帧数
		 */ 
		protected var _headFrame:uint = 0;
		/**
		 * 头像位置配置
		 */ 
		protected var _headPos:Object;
		/**
		 * 头像与身体的排序配置
		 */ 
		protected var _zorder:Object;
		
		
		
		
		/**
		 * @param frame		身体素材所包含的最大帧数(列)
		 * @param action	身体素材所包含的最大动作数（行）
		 */ 
		public function AvatarData_RO(frame:uint,action:uint)
		{
			_headPos = new Object();
			_zorder = new Object();
			_headDir = new Object();
			
			super(frame,action);
		}
		
		/**
		 * 头像帧数
		 */ 
		public function set headFrame(v:uint):void
		{
			_headFrame = v;	
		}
		
		/**
		 * 设置某一行所有帧的头像偏移
		 * 注意，此偏移是在_nicky的基础上进行的
		 * @param	action	设置的动作行
		 * @param	pos		本行内所有动作的头像偏移
		 */ 
		public function headPos(action:uint,pos:Array):void
		{
			if(_lineFrame[action]!=pos.length)
			{
				trace('设置头像偏移的个数与实际帧数不符！');
				return;
			}
			
			_headPos['_'+action] = pos;
		}
		
		/**
		 * 反转某一动作帧的排序
		 * @param	action	要反转的动作行
		 * @param	frame	要反转的帧列
		 */ 
		public function changeZorder(action:uint,frame:uint):void
		{
			_zorder['_'+action+'_'+frame] = 1;
		}
		
		
		/**
		 * 设置不同动作中头的位置
		 * 如果为-1，则为旋转循环
		 * @param	dir		头像的方向配置，若action为0，则为整行统一方向，此时数组长度需与总的方向行数相符。如果action为1，则为整行逐帧设置。此时数组长度需与当前方向的帧数相符
		 * @param	action	配置的身体方向行，为0则为整行统一设置
		 */ 
		public function headDir(dir:Array,action:uint=0):void
		{
			if(action==0)
			{
				if(dir.length!=_action)
				{
					trace('无效的全局头像方向配置数组！');
					return;
				}
				for(var i:uint = 0;i<_action;i++)
				{
					for(var m:uint = 0;m<_lineFrame[action];m++)
					{
						_headDir[i+'_'+m] = dir[i];
					}
				}
			}else{
				if(action>_action)
				{
					trace('无效的动作行数');
					return;
				}
				if(dir.length!=_lineFrame[action])
				{
					trace('配置单行头像反向的个数与当前行的帧数不符',dir.length,_lineFrame[action]);
					return;
				}
				for(var k:uint = 0;k<_lineFrame[action];k++)
				{
					_headDir[action+'_'+k] = dir[k];
				}
			}
		}
		
		/**
		 *	头素材中，与身体连接位置的高度
		 */ 
		public function set nicky(val:uint):void
		{
			_nicky = val;
		}
		
		/**
		 * 头像
		 */ 
		public function set head(b:BitmapData):void
		{
			_head = b;
			_nicky = int(b.height/2);
		}
		
		override public function get data():Bitmap
		{
			if(_headFrame==0)
			{
				trace('尚未指定头像总帧数');
				return null;
			}
			var buffer:BitmapData = new BitmapData(_body.width,_body.height+_head.height*_action,true,0x00000000);
			var blockheight:uint = int(_body.height/_action);
			var blockwidth:uint =int(_body.width/_frame);
			var headwidth:uint = int(_head.width/_headFrame);
			for(var i:uint=0;i<_action;i++)
			{
				var flyY:Number = _lineYFly['_'+i]==null ? 0 : _lineYFly['_'+i];
				
				
				for(var m:uint=0;m<_frame;m++)
				{
					if(m>=_lineFrame[i]) break;
					var headdir:uint = _headDir[i+'_'+m]==-1 ? m : _headDir[i+'_'+m];	// 判断本行所使用的头部方向
					var headPosx:Number=0;
					var headPosy:Number=0;
					
					if(_headPos['_'+i]!=null)
					{
						headPosx = _headPos['_'+i][m].x;
						headPosy = _headPos['_'+i][m].y;
					}
					
					if(_zorder['_'+i+'_'+m]==null)
					{
						buffer.copyPixels(_body,new Rectangle(blockwidth*m,blockheight*i,blockwidth,blockheight),new Point(m*blockwidth,(_head.height+blockheight)*i+_head.height+flyY),null,null,true);
						buffer.copyPixels(_head,new Rectangle(headdir*headwidth,0,headwidth,_head.height),new Point(m*blockwidth+(blockwidth-headwidth)/2+headPosx,(_head.height+blockheight)*i+_nicky+headPosy+flyY),null,null,true);
					}else{
						buffer.copyPixels(_head,new Rectangle(headdir*headwidth,0,headwidth,_head.height),new Point(m*blockwidth+(blockwidth-headwidth)/2+headPosx,(_head.height+blockheight)*i+_nicky+headPosy+flyY),null,null,true);
						buffer.copyPixels(_body,new Rectangle(blockwidth*m,blockheight*i,blockwidth,blockheight),new Point(m*blockwidth,(_head.height+blockheight)*i+_head.height+flyY),null,null,true);					
					}
				}
			}
			
			var _data:Bitmap = new Bitmap(buffer);
			
			return _data;
		}
	}
}