package
{
	public class WulinGlobal
	{
		public static var username:String='D5Power';
		public function WulinGlobal()
		{
		}
		public static function GetReturnJsonString(command:String, arg0:Object = "", arg1:Object = "", arg2:Object = "", arg3:Object = "", arg4:Object = "", arg5:Object = ""):String
		{
			var obj:Object = new Object();
			obj.Command = command;
			obj.Arg0 = arg0;
			obj.Arg1 = arg1;
			obj.Arg2 = arg2;
			obj.Arg3 = arg3;
			obj.Arg4 = arg4;
			obj.Arg5 = arg5;
			return JSON.stringify(obj);
		}
	}
}