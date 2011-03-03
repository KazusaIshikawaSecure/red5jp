package jp.co.s_arcana.red5.pages.lobby
{
	import flash.events.MouseEvent;
	
	import jp.co.s_arcana.red5.pages.lobby.model.LobbyModel;
	import jp.co.s_arcana.red5.pages.lobby.view.LobbyView;
	import jp.co.s_arcana.red5.remote.RemoteConnection;
	import jp.co.s_arcana.red5.remote.RemoteConnectionClientEventDispatcher;
	import jp.co.s_arcana.red5.utils.StateManager;
	import jp.co.s_arcana.red5.utils.StateManagerEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;

	public class Lobby extends LobbyView
	{
		
		private var model:LobbyModel = LobbyModel.getInstance();
		
		//--------------------------------------
		// Constructor
		//--------------------------------------
		public function Lobby()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,	this.creationCompleteHandler);
		}

		//--------------------------------------
		// Initialization
		//--------------------------------------
		private function creationCompleteHandler(event:FlexEvent):void
		{
			btnJoinRoom.addEventListener(MouseEvent.CLICK,	btnJoinRoom_clickHandler);
			
			// 会議室一覧を取得
			this.listRoom.dataProvider = this.model.getRoomList();
			
			// クライアントリスト更新時のイベントをListen
			RemoteConnectionClientEventDispatcher.getInstance().addEventListener(
				RemoteConnectionClientEventDispatcher.UPDATE_ROOM_COUNT, this.updateRoomCountHandler);
			
			// 画面遷移イベントをListen
			StateManagerEventDispatcher.getInstance().addEventListener(
				StateManagerEventDispatcher.STATE_CONFERENCE, this.onState);
			
		}
		//--------------------------------------
		// UI Event Handler
		//--------------------------------------
		
		/**
		 * お部屋に入る
		 */ 
		private function btnJoinRoom_clickHandler(event:MouseEvent):void
		{
			trace("event.target.id : " + event.target.id);
			
			if (!listRoom.selectedItem) return;
			
			if (6 <= listRoom.selectedItem.count)
			{
				Alert.show("この部屋は満員です。");
				return;
			}
			
			// 会議室画面へ遷移
			StateManager.setStateTo("stateConference");
		}
		
		private function onState(event:DynamicEvent):void
		{
			var room_name:String = listRoom.selectedItem.roomName;
			this.model.joinRoom(room_name);
		}
		
		private function updateRoomCountHandler(event:DynamicEvent):void
		{
			var roomCountList:Array = event.data;
			
			
			for each (var obj:Object in roomCountList)
			{
				trace("Lobby.updateRoomCountHandler()");
				trace("    roomCount.roomName: " + obj.roomName);
				trace("    roomCount.count: " + obj.count);
			}
			
			var definedRoomList:IList = this.model.getRoomList();
			
			var updatedRoomList:IList = new ArrayCollection();
			
			for each (var room:Object in definedRoomList)
			{
				for each (var roomCount:Object in roomCountList)
				{
				
					if(room.roomName == roomCount.roomName)
					{
						room.count = roomCount.count;
					}
				}
				updatedRoomList.addItem(room);
			}
			
			
			this.listRoom.dataProvider = updatedRoomList;
		}
	}
}