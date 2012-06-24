/**
 * D5Power Studio FPower 2D MMORPG Engine
 * 第五动力FPower 2D 多人在线角色扮演类网页游戏引擎
 * 
 * copyright [c] 2010 by D5Power.com Allrights Reserved.
 */ 
package com.D5Power.Objects
{
	
	import com.D5Power.Controler.BaseControler;
	import com.D5Power.Stuff.HSpbar;
	import com.D5Power.display.D5TextField;
	import com.D5Power.graphicsManager.GraphicsResource;
	import com.D5Power.ns.NSGraphics;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	use namespace NSGraphics;
	
	/**
	 * 游戏角色类对象基类
	 * 游戏中全部角色类（包括NPC）的根类
	 */
	
	public class CharacterObject extends ControlActionObject
	{
		/**
		 * HP最大值
		 */ 
		public var hpMax:uint;
		
		/**
		 * SP最大值
		 */ 
		public var spMax:uint;
		
		/**
		 * 角色名称
		 */ 
		protected var _nameBox:Bitmap;
		
		protected var _hpBar:HSpbar;
		
		/**
		 * HP值
		 */ 
		protected var _hp:uint;
		/**
		 * SP值
		 */ 
		protected var _sp:uint;
		
		NSGraphics var alphaCheck:Boolean=false;
		
		
		public function CharacterObject(ctrl:BaseControler=null)
		{
			//TODO: implement function
			super(ctrl);
			objectName = 'CharacterObject';
		}
		
		public function set hp(val:int):void
		{
			_hp = val>0 ? val : 0;
			if(_hpBar!=null)
			{
				_hpBar.update();
			}
		}
		
		public function get hp():int
		{
			return _hp;
		}
		
		/**
		 * 设置名字
		 * @param	_name	角色名
		 * @param	color	字体颜色	，若为-1则自动根据Global的阵营设置进行判断
		 * @param	bordercolor	描边颜色
		 */ 
		public function setName(_name:String,color:int=-1,bordercolor:int=0):void
		{
			var text:D5TextField = new D5TextField('',0xFFFFFF);
			
			text.text = _name;
			text.autoGrow();
			
			if(color==-1)
			{
				text.textColor = Global.userdata.camp==camp ? 0x99ff00 : 0xff0000;
				text.fontBorder = Global.userdata.camp==camp ? 0x003300 : 0x390000;
			}else{
				text.textColor = color;
				text.fontBorder = bordercolor;
			}
			text.align=D5TextField.CENTER;
			
			if(_nameBox!=null)
			{
				_nameBox.bitmapData.dispose();
			}else{
				_nameBox = new Bitmap();
			}

			var bd:BitmapData = new BitmapData(text.width,text.height,true,0x00000000);
			bd.draw(text);
			
			_nameBox.bitmapData = bd;
			
			flyName();
			addStuff(_nameBox);
			
			text = null;
		}
		
		/**
		 * 设置HP条
		 */ 
		public function set hpBar(bar:HSpbar):void
		{
			_hpBar = bar;
			addStuff(_hpBar);
		}
		
		/**
		 * 调整角色名称位置
		 */ 
		protected function flyName():void
		{
			_nameBox.x = -int(_nameBox.width/2);
		}
		
		override protected function enterFrame():Boolean
		{
			if(!super.enterFrame()) return false;
			_renderBuffer.alpha = controler.perception.Scene.Map.isInAlphaArea(pos.x,pos.y) ? .5 : 1;
			return true;
		}
		
		override protected function build():void
		{
			super.build();
			if(_nameBox!=null) flyName(); // 重新调整名字坐标
		}
		
		override protected function setupBuffer():void
		{
			_renderBuffer = new Bitmap(GraphicsResource.DEFAULT_BD);
			addChild(_renderBuffer);
			flyPos(GraphicsResource.DEFAULT_BD.width/2,GraphicsResource.DEFAULT_BD.height);
			
		}
		
	}
	
}