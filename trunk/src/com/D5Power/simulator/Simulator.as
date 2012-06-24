package com.D5Power.simulator
{
	import com.D5Power.Objects.GameObject;
	import com.D5Power.scene.BaseScene;


	public class Simulator extends BasicSimulator
	{
		public function Simulator(gs:BaseScene)
		{
			super(gs);
		}
		
		public function run():void
		{
			generateActions();
			_gs.render();
		}
		
		private function generateActions():void
		{
			for each(var c:GameObject in _gs.getAllObjects()) if(c.controler!=null) c.controler.calcAction();
		}
		
		private function updateScene():void
		{
		}
	}
}