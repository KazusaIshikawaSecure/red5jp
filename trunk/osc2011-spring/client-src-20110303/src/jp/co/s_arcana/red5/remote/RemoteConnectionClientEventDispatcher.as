package jp.co.s_arcana.red5.remote
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.events.DynamicEvent;
	
	public class RemoteConnectionClientEventDispatcher extends EventDispatcher
	{
		private static var _instance:RemoteConnectionClientEventDispatcher;
		
		public static var UPDATE_CLIENT_LIST:String = "updateClientList";
		public static var UPDATE_ROOM_COUNT:String = "updateRoomCount";
		
		public function RemoteConnectionClientEventDispatcher(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function getInstance():RemoteConnectionClientEventDispatcher{
			if(_instance == null){
				_instance = new RemoteConnectionClientEventDispatcher();
			}
			return _instance;
		}
		
		public function dispatchUpdateClientList(clientList:Array):void {
			var event:DynamicEvent = new DynamicEvent(UPDATE_CLIENT_LIST);
			event.data = clientList;
			
			dispatchEvent(event);
		}
		
		public function dispatchUpdatRoomCount(roomCount:Array):void {
			var event:DynamicEvent = new DynamicEvent(UPDATE_ROOM_COUNT);
			event.data = roomCount;
			
			dispatchEvent(event);
		}
		
	}
}