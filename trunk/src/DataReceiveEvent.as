package
{
	import flash.events.Event;
		
	public class DataReceiveEvent extends Event
	{
		public static const Type = "DataReceive";
		private var data:Object;
		public function DataReceiveEvent()
		{
			super(Type);
		}
		public function get Data():Object
		{
			return this.data;
		}
		public function set Data(d:Object):void
		{
			this.data = d;
		}
	}
}