package com.D5Power.net
{
	import flash.display.Loader;
	
	/**
	 * 携带回叫函数数据的Loader
	 */ 
	public class CallbackLoader extends Loader
	{
		public var callback:Function;
		public var workType:uint;
		
		public function CallbackLoader()
		{
			super();
		}
	}
}