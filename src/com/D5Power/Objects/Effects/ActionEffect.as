package com.D5Power.Objects.Effects
{
	import com.D5Power.scene.BaseScene;
	
	import flash.display.BlendMode;
	import flash.geom.Rectangle;
	
	/**
	 * 动画效果
	 */ 
	public class ActionEffect extends EffectObject
	{
		public function ActionEffect(scene:BaseScene)
		{
			super(scene);
			
			_renderPos = CENTER;
			blendMode = BlendMode.ADD;
		}
		
		/**
		 * 渲染自己在屏幕上输出
		 */
		override public function renderMe():void
		{
			enterFrame();
			
			if(_currentFrame==0 && _lastFrame!=0)
			{
				_scene.removeObject(this);
				return;
			}
			
			super.renderMe();		
		}
	}
}