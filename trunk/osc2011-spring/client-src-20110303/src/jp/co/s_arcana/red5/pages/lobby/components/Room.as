package jp.co.s_arcana.red5.pages.lobby.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import jp.co.s_arcana.red5.pages.lobby.Lobby;
	
	import mx.events.FlexEvent;

	public class Room extends RoomView
	{
		
		private var _lobby:Lobby;
		
		private var _glowingUp:Boolean = true;
		
		//--------------------------------------
		// Constructor
		//--------------------------------------
		public function Room()
		{
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE,	this.creationCompleteHandler);
			
		}
		
		
		//--------------------------------------
		// Initialization
		//--------------------------------------
		private function creationCompleteHandler(event:FlexEvent):void
		{
			this.btnJoin.addEventListener(MouseEvent.CLICK, btnJoin_clickHandler);
			
			// じわじわ点滅させる
			var timer:Timer = new Timer(50, 0);
			timer.addEventListener(TimerEvent.TIMER, timer_Handler);
			timer.start();
		}
		
		private function timer_Handler(event:TimerEvent):void{
			this.glowFilter.alpha = this._glowingUp ? this.glowFilter.alpha + 0.05 : this.glowFilter.alpha - 0.05;
			if(this.glowFilter.alpha <= 0){
				this._glowingUp = true;
			}else if(this.glowFilter.alpha >= 1){
				this._glowingUp = false;
			}
		}
		
		//--------------------------------------
		// UI Event Handler
		//--------------------------------------
		private function btnJoin_clickHandler(event:MouseEvent):void
		{
			var e:MouseEvent = new MouseEvent(MouseEvent.CLICK);
			
			var parent:Object = this.parent;
			while (parent = parent.parent) {
				if (parent is Lobby) {
					(parent as Lobby).btnJoinRoom.dispatchEvent( e );
					break;
				}
			}
		}
		
		
		public function set lobby(lobby:Lobby):void{
			this._lobby = lobby;
		}
		
		public function set room_name(s:String):void{
			this.txtName.text = s;
		}
		
		public function set room_count(s:String):void{
			this.txtCount.text = "（" + s + " / 6人）";
		}
		
	}
}