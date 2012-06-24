package com.D5Power.Objects
{
	import com.D5Power.Controler.BaseControler;
	import com.D5Power.basic.ResourcePool;
	import com.D5Power.mission.NPCMissionConfig;
	import com.D5Power.ns.NSD5Power;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	use namespace NSD5Power;
	
	/**
	 * 由电脑控制的玩家对象
	 */
	
	public class NCharacterObject extends CharacterObject implements IPoolObject
	{
		/**
		 * 用户ID，如果为0则为NPC
		 */ 
		protected var _uid:uint=0;
		
		protected var _misConf:NPCMissionConfig;

		public function set uid(val:uint):void
		{
			canBeAtk=val>0;
			_uid=val;
		}
		
		public function get uid():uint
		{
			return _uid;
		}
		
		public function NCharacterObject(ctrl:BaseControler=null)
		{
			super(ctrl);
			objectName = 'NCharacterObject';
		}
		
		/**
		 * 读取任务配置文件
		 * 本方法只能由D5Game主动触发
		 */ 
		NSD5Power function loadMissionScript():void
		{
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE,parseNpcMission);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onNpcMissionError);
			urlLoader.load(new URLRequest('asset/mission/'+_uid+'.xml'));
		}
		
		public function get missionConfig():NPCMissionConfig
		{
			return _misConf;
		}
		
		protected function parseNpcMission(e:Event):void
		{
			var loader:URLLoader = e.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE,parseNpcMission);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,onNpcMissionError);
			
			var xml:XML = new XML(loader.data);
			
			_misConf = new NPCMissionConfig();
			_misConf._say = xml.nomission.info;
			_misConf._npcname = xml.npcname;
			if(xml.nomission.event)
			{
				_misConf._setEvent(xml.nomission.event.attribute('type'),xml.nomission.event.attribute('value'));
			}
			
			for each(var data:* in xml.mission)
			{
				_misConf.addMission(data.id,data);
			}
		}
		
		protected function onNpcMissionError(e:IOErrorEvent):void
		{
			var loader:URLLoader = e.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE,parseNpcMission);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,onNpcMissionError);
		}
		
		public function close():void
		{
			if(!inuse) return;
			_controler.perception.Scene.removeObject(this);
			inuse = false;
			_graphics = null;
			render = null;
			canBeAtk = false;
			_qTree = null;
			_controler = null;
		}
		
		public function open(_controller:BaseControler):void
		{
			if(inuse)
			{
				trace("This object is in use,can not be reopen.");
				return;
			}
			inuse = true;
			_controler = _controller;
			_controler.perception.Scene.addObject(this);
		}
	}
}