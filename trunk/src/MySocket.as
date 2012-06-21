package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	
	public class MySocket extends EventDispatcher
	{
		private var socket:Socket; 
		private var address:String;
		private var port:int;
		private var func:Function;
		
		public function MySocket(address:String, port:int)
		{ 
			socket = new Socket(); 
			
			// Listen for when data is received from the socket server 
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData); 
			this.address = address;
			this.port = port;
		} 
		
		public function connect(func:Function):void
		{
			this.func = func;
			this.addEventListener(DataReceiveEvent.Type, this.func);			
			// Connect to the server 
			socket.connect(address, port); 
		}
		
		public function send(str:String, func:Function):void
		{
			this.func = func;
			this.addEventListener(DataReceiveEvent.Type, this.func);
			socket.writeUTF(str + "\n");
			socket.flush();
		}
		
		private function onSocketData(eventprogressEvent:Event):void 
		{ 
			var dre:DataReceiveEvent = new DataReceiveEvent();
			var str:String = socket.readUTFBytes(socket.bytesAvailable);
			try
			{
				dre.Data = JSON.parse(str); 
				this.dispatchEvent(dre);
				this.removeEventListener(DataReceiveEvent.Type, this.func);
			}
			catch (err:Error)
			{
				trace(str)
			}
		} 
		
	}
}