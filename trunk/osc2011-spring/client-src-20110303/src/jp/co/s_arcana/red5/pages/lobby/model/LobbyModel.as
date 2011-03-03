package jp.co.s_arcana.red5.pages.lobby.model
{
	import flash.net.Responder;
	import flash.utils.getQualifiedClassName;
	
	import jp.co.s_arcana.red5.remote.RemoteConnection;
	import jp.co.s_arcana.red5.utils.MyselfManager;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.utils.ObjectProxy;
	
	import spark.components.List;

	public class LobbyModel
	{
		
		private var remote_model:RemoteConnection;
		
		
		private static var _instance:LobbyModel = null;
		
		public static function getInstance():LobbyModel
		{
			if ( _instance == null ) {
				_instance = new LobbyModel();
			}
			return _instance;
		}
		
		public function LobbyModel()
		{
			this.remote_model = RemoteConnection.getInstance();
		}
		
		public function createRoom(room_name:String):void
		{
			
		}

		public function joinRoom(room_name:String):void
		{
			this.remote_model.joinRoom(room_name);
			
			this.remote_model.getClientId( new Responder(
				function(result:String):void{
					trace( "LobbyModel.joinRoom() -> getClientId() on result" );
					MyselfManager.setMyClientId(result);
				}, 
				function(status:Object):void{
					trace( "LobbyModel.joinRoom() -> getClientId() on status" );
					trace( status.application );
					trace( status.code );
					trace( status.description );
					trace( status.level );
				}
			));
			
			var my_name:String = MyselfManager.getMyName();
			this.remote_model.setClientName( my_name, new Responder(
				function(result:String):void{
					trace( "LobbyModel.joinRoom() -> setClientName() on result" );
				}, 
				function(status:Object):void{
					trace( "LobbyModel.joinRoom() -> setClientName() on status" );
					trace( status.application );
					trace( status.code );
					trace( status.description );
					trace( status.level );
				}
			));
			
		}
		
		
		public function updateRoomCount():void
		{
			this.remote_model.updateRoomCount( new Responder(
				function(result:Object):void{
					trace( "LobbyModel.updateRoomCount() -> updateRoomCount() on result" );
				}, 
				function(status:Object):void{
					trace( "LobbyModel.updateRoomCount() -> updateRoomCount() on status" );
					trace( status.application );
					trace( status.code );
					trace( status.description );
					trace( status.level );
				}));
		}
		
		public function getRoomList():IList
		{
			var list:ArrayCollection = new ArrayCollection([
				new ObjectProxy({label:"ROOM01", roomName:"room1", id:1, count:0, x:350, y:10}),
				new ObjectProxy({label:"ROOM02", roomName:"room2", id:2, count:0, x:112, y:10}),
				new ObjectProxy({label:"ROOM03", roomName:"room3", id:3, count:0, x:350, y:10}),
			]);
			
			return list;
		}
		
		
		//----------------------------------------------------------------
		// push from server
		//----------------------------------------------------------------
		
		
		
	}
}