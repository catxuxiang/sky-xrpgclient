package com.D5Power.Stuff
{
	import com.D5Power.Objects.GameObject;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	/**
	 * Hp/Sp 条
	 */ 
	public class HSpbar extends CharacterStuff
	{
		/**
		 * 当前值
		 */ 
		private var _nowVal:uint;
		private var _ytype:uint;
		
		public static const UP:uint = 0;
		public static const DOWN:uint = 1;
		
		
		/**
		 * @param		target		跟踪目标
		 * @param		attName		跟踪属性名
		 * @param		attMaxName	最大值跟踪
		 * @param		ytype		Y轴位置，若大于1则使用该值进行定位
		 * @param		resource	使用素材
		 */ 
		public function HSpbar(target:GameObject,attName:String,attMaxName:String,ytype:uint = 1,resource:BitmapData=null)
		{
			if(resource == null)
			{
				var temp:Sprite = new Sprite();
				temp.graphics.lineStyle(1);
				temp.graphics.drawRect(0,0,39,3);
				temp.graphics.endFill();
				temp.graphics.beginFill(0x990000);
				temp.graphics.drawRect(0,4,40,4);
				
				
				resource = new BitmapData(temp.width,temp.height,true,0x00000000);
				resource.draw(temp);
				temp.graphics.clear();
				temp = null;
			}
			
			_ytype = ytype;
			
			super(target,resource,attName,attMaxName);
			
			bitmapData = new BitmapData(resource.width,int(resource.height*.5),true,0x00000000);
			update();
			
			var timer:Timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER,waitForFly);
			timer.start();
		}
		
		private function waitForFly(e:TimerEvent):void
		{
			if(_target.graphicsRes.frameWidth>0)
			{
				var t:Timer = e.target as Timer;
				t.removeEventListener(TimerEvent.TIMER,waitForFly);
				t.stop();
				t = null;
				
				x = -_target.graphicsRes.frameWidth*.5+int((_target.graphicsRes.frameWidth-width)/2);
				if(_ytype==0)
				{
					y = -_target.graphicsRes.frameHeight;
				}else if(_ytype>1){
					y = _ytype;
				}
			}
		}
		
		/**
		 * 渲染
		 * @param		buffer		缓冲区
		 * @param		p			角色的标准渲染坐标
		 */ 
		public function update():void
		{
			if(bitmapData==null) return;
			if(_resource==null) return;
			if(_nowVal == _target[_attName]) return;
			
			_nowVal = _target[_attName];
			bitmapData.fillRect(bitmapData.rect,0x00000000);
			bitmapData.copyPixels(_resource,numRect,new Point(),null,null,true);
			bitmapData.copyPixels(_resource,lineRect,new Point(),null,null,true);
		}
		
		/**
		 * 获取线框所在矩形
		 */ 
		protected function get lineRect():Rectangle
		{
			return new Rectangle(0,0,_resource.width,int(_resource.height*0.5));
		}
		
		/**
		 * 获取数据所在矩形
		 */ 
		protected function get numRect():Rectangle
		{
			return new Rectangle(0,int(_resource.height*0.5),int(_resource.width*_target[_attName]/_target[_attMaxName]),int(_resource.height*0.5));
		}
	}
}