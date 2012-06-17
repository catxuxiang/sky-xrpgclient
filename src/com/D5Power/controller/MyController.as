package com.D5Power.controller
{
	import com.D5Power.Controler.CharacterControler;
	import com.D5Power.Controler.Perception;
	
	import flash.geom.Point;
	import flash.net.Responder;
	
	public class MyController extends CharacterControler
	{
		public function MyController(pec:Perception, ctrl:uint=2)
		{
			super(pec, ctrl);
		}
		
		override protected function tellServerMove(p:Point):void
		{
			Main.my.nc.call('move',new Responder(back2),p.x,p.y);
		}
		
		private function back2(data:*):void
		{
			trace("[MyCharacter] Move Success!!");
		}
	}
}