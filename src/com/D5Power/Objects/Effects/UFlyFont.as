package com.D5Power.Objects.Effects
{
	import com.D5Power.display.D5TextField;
	import com.D5Power.graphicsManager.GraphicsResource;
	import com.D5Power.scene.BaseScene;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	/**
	 * 向上飞行的文字
	 */ 
	public class UFlyFont extends EffectObject
	{
		protected var _target:Point;
		public var flyY:uint = 50;
		
		/**
		 * @param	scene		场景
		 * @param	skillName	技能名称
		 * @param	color		字体颜色
		 */ 
		public function UFlyFont(scene:BaseScene,skillName:String,color:uint=0xff0000)
		{
			super(scene);
			_zOrderF = 200;
			buildBuffer(skillName,color);
		}
		
		protected function buildBuffer(name:String,color:uint):void
		{
			var textFiled:D5TextField = new D5TextField(name,color);
			textFiled.autoGrow();
			textFiled.fontBorder = 0;
			
			_buffer = new BitmapData(textFiled.width,textFiled.height,true,0x00000000);
			_buffer.draw(textFiled);
			
			var gs:GraphicsResource = new GraphicsResource(null);
			gs.addResource(_buffer);
			graphicsRes = gs;
			
			textFiled.clear();
			textFiled=null;
		}
		
		override public function setPos(px:Number,py:Number):void
		{
			super.setPos(px,py);
			
			_target = new Point(px,py-flyY);
			
		}
		
		override protected function run():void
		{
			pos.y += (_target.y-pos.y)/15;
			if(Point.distance(pos,_target)<5)
			{
				_scene.removeObject(this);
				return;
			}
		}
		
		/**
		 * 渲染自己
		 */ 
		override public function renderMe():void
		{
			if(_buffer==null || _target==null) return;
			RenderUpdated = false;
			super.renderMe();
		}
		
		override public function clear():void
		{
			super.clear();
			_buffer.dispose();
			_buffer=null;
		}
	}
}