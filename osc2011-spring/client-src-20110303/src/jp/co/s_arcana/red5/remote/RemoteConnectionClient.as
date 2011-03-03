package jp.co.s_arcana.red5.remote
{
	import flash.events.EventDispatcher;

	public class RemoteConnectionClient
	{
		
		private static var _instance:RemoteConnectionClient = null;
		
		private var eventdispatcher:EventDispatcher;
		
		public static function getInstance():RemoteConnectionClient
		{
			if ( _instance == null ) {
				_instance = new RemoteConnectionClient();
			}
			return _instance;
		}
		
		public function RemoteConnectionClient()
		{
			this.eventdispatcher = new EventDispatcher();
		}
		
		
		public function onClientListUpdated(clientList:Array):void
		{
			trace("RemoteConnectionClient.updateClientList()");
			trace("    list_size: " + clientList.length);
			
			// イベントの通知
			RemoteConnectionClientEventDispatcher.getInstance().dispatchUpdateClientList(clientList);

		}
		
		public function onRoomCountUpdated(clientRoomCount:Array):void
		{
			trace("RemoteConnectionClient.onRoomCountUpdated()");
			trace("    list_size: " + clientRoomCount.length);
			
			// イベントの通知
			RemoteConnectionClientEventDispatcher.getInstance().dispatchUpdatRoomCount(clientRoomCount);
			
		}
		
		
	}
}