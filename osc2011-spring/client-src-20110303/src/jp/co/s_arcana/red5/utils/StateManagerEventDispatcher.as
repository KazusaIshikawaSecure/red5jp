package jp.co.s_arcana.red5.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.events.DynamicEvent;
	
	public class StateManagerEventDispatcher extends EventDispatcher
	{
		private static var _instance:StateManagerEventDispatcher;
		
		public static var STATE_CONFERENCE:String = "state_conference";
		public static var STATE_LOBBY:String = "state_lobby";
		public static var STATE_LOGIN:String = "state_login";
		
		public function StateManagerEventDispatcher(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function getInstance():StateManagerEventDispatcher{
			if(_instance == null){
				_instance = new StateManagerEventDispatcher();
			}
			return _instance;
		}
		
		public function dispatchState(strState:String):void {
			var event:DynamicEvent = new DynamicEvent(resolveEventName(strState));
			
			dispatchEvent(event);
		}
		
		private function resolveEventName(s:String):String {
			return {stateLobby: STATE_LOBBY, 
				stateLogin: STATE_LOGIN, 
				stateConference: STATE_CONFERENCE}[s];
		}
		
	}
}