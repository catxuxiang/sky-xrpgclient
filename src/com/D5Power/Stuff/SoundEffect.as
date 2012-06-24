package com.D5Power.Stuff
{
	import flash.media.Sound;

	/**
	 * 声音效果控制器
	 */ 
	public class SoundEffect
	{
		public function SoundEffect()
		{
			
		}
		
		public function play(id:uint):void
		{
			var clas:Class = this['_'+id];
			var sound:Sound = new clas() as Sound;
			sound.play();
		}
	}
}