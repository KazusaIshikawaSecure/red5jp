package jp.co.s_arcana.red5.remote
{
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.profiler.showRedrawRegions;
	
	import mx.collections.IList;
	import mx.controls.Alert;

	public class RemoteConnection
	{
		
		private const REMOTE_HOST:String = "localhost";
		private const REMOTE_APP_NAME:String    = "conference";
		
		private const APP_URL:String   = "rtmp://" + REMOTE_HOST+"/" + REMOTE_APP_NAME;
		private const ROOM_URL:String  = APP_URL + "/room";
		
		private static var _instance:RemoteConnection = null;
		
		private var nc:NetConnectionWrapper;
		
		/**
		 * コンストラクタ
		 */
		public function RemoteConnection()
		{
			if( _instance ){
				throw new ArgumentError("This object must be singleton.");
			}
			this.nc = new NetConnectionWrapper();
		}
		
		/**
		 * インスタンスの取得
		 */
		public static function getInstance():RemoteConnection
		{
			if ( _instance == null ) {
				_instance = new RemoteConnection();
			}
			return _instance;
		}
		
		
		
		//----------------------------------------------------------------
		// Lobby
		//----------------------------------------------------------------
		
		public function joinRoom(room_name:String):void
		{
			var room_url:String = ROOM_URL + "/" + room_name; 
			this.nc.client = RemoteConnectionClient.getInstance();
			if (this.nc.connected) this.nc.close();
			this.nc.connect(room_url);
		}
		
		
		public function getClientId(responder:Responder):void
		{
			this.nc.call("getClientId", responder);
		}

		
		public function setClientName(name:String, responder:Responder):void
		{
			this.nc.call("setClientName", responder, name);
		}
		
		public function updateRoomCount(responder:Responder):void
		{
			this.nc.call("updateRoomCount", responder);
		}
		
		//----------------------------------------------------------------
		// Conference
		//----------------------------------------------------------------
		
		
		public function createNetStream():NetStream
		{
			return new NetStreamWrapper(this.nc);
		}
		
		
		public function getClientList(responder:Responder):void
		{
			this.nc.call("getClientList", responder);
		}
		
		
		public function updateClientList(responder:Responder):void
		{
			this.nc.call("updateClientList", responder);
		}
		
		
		public function getRoomCount(responder:Responder):void
		{
			this.nc.call("getRoomCount", responder);
		}
		
		
		public function joinLobby():void
		{
			this.nc.client = RemoteConnectionClient.getInstance();
			if (this.nc.connected) this.nc.close();
			this.nc.connect(ROOM_URL);
		}
		
	}
}