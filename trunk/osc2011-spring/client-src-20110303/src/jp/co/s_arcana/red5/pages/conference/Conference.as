package jp.co.s_arcana.red5.pages.conference
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Video;
	
	import jp.co.s_arcana.red5.pages.conference.components.VideoWindow;
	import jp.co.s_arcana.red5.pages.conference.model.ConferenceModel;
	import jp.co.s_arcana.red5.pages.conference.model.LocalCameraModel;
	import jp.co.s_arcana.red5.pages.conference.view.ConferenceView;
	import jp.co.s_arcana.red5.remote.RemoteConnectionClientEventDispatcher;
	import jp.co.s_arcana.red5.utils.MyselfManager;
	import jp.co.s_arcana.red5.utils.StateManager;
	import jp.co.s_arcana.red5.utils.StateManagerEventDispatcher;
	
	import mx.collections.IList;
	import mx.controls.SWFLoader;
	import mx.core.FlexGlobals;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Application;
	import spark.components.VideoDisplay;

	public class Conference extends ConferenceView
	{
		private var model:ConferenceModel = ConferenceModel.getInstance();
		private var camera_model:LocalCameraModel = LocalCameraModel.getInstance();
		
		//--------------------------------------
		// Constructor
		//--------------------------------------
		public function Conference()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,	this.creationCompleteHandler);
		}
		
		//--------------------------------------
		// Initialization
		//--------------------------------------
		private function creationCompleteHandler(event:FlexEvent):void
		{
			// オマケ(A)
			this.addEventListener(Event.ENTER_FRAME, function(event:Event):void{
				var mx:Number = (FlexGlobals.topLevelApplication as Application).mouseX;
				if(event.target is Conference){
					with(event.target.swfBase){
						if(x!=mx){
							if(x<mx){ x = x+0.5; scaleX = -1; }
							else    { x = x-0.5; scaleX = 1;}
						}
					} 
				}
			});
			// オマケ(A)ここまで
			
			this.btnUpdate.addEventListener(MouseEvent.CLICK, this.btnUpdate_clickHandler);
			this.btnBack.addEventListener(MouseEvent.CLICK, this.btnBack_clickHandler);
			
			// クライアントリスト更新時のイベントをListen
			RemoteConnectionClientEventDispatcher.getInstance().addEventListener(
				RemoteConnectionClientEventDispatcher.UPDATE_CLIENT_LIST, this.updateClientListHandler);
			
			// 画面遷移イベントをListen
			StateManagerEventDispatcher.getInstance().addEventListener(
				StateManagerEventDispatcher.STATE_LOBBY, this.onState);
			
			// Videoの初期化
			for each(var vw:VideoWindow in this.videoPlayerList() )
			{
				var video:Video = new Video();
				video.name = "video";
				video.x=0;
				video.y=0;
				video.height = 120;
				video.width  = 160;
				vw.videoDisplay.height = 120;
				vw.videoDisplay.width  = 160;
				
				vw.videoDisplay.addChild(video);
				vw.clear();
			}
			
		}
		
		public function clearVideoWindows():void
		{
			for each(var vw:VideoWindow in this.videoPlayerList() )
			{
				vw.videoDisplay.visible = false;
				vw.clear();
			}
		}
		
		//--------------------------------------
		// UI Event Handler
		//--------------------------------------
		private function btnUpdate_clickHandler(event:MouseEvent):void
		{
			this.model.updateClientList();
		}
		
		private function btnBack_clickHandler(event:MouseEvent):void
		{
			
			// ロビー画面へ遷移
			StateManager.setStateTo("stateLobby");
		}
		
		private function onState(event:DynamicEvent):void
		{
			this.clearVideoWindows();
			this.camera_model.clearNetStream();
			this.model.clearNetStreams();
			
		}
		
		
		//--------------------------------------
		// Server Event Handler
		//--------------------------------------
		
		private function updateClientListHandler(event:DynamicEvent):void
		{
			var clientList:Array = event.data;
			
			
			for each (var client:Object in clientList)
			{
				trace("Conference.updateClientListHandler()");
				trace("    client.id: " + client.id);
				trace("    client.name: " + client.name);
				trace("    client.published: " + client.published);
				trace("    client.isJoinedRoom: " + client.isJoinedRoom);
				
				var vw:VideoWindow;
				
				var vw_matched:Boolean = false;
				
				// 既に入室している人の場合は表示を更新
				for each(vw in this.videoPlayerList())
				{
					if( vw.client_id == client.id ){
						vw_matched = true;
						
						// ライブ配信の状態が変更になった場合、ビデオ画面の表示を切り替える
						if(vw.client_published != client.published){
							if(client.published){
								this.model.subscribeStart(client.id, (vw.videoDisplay.getChildByName("video") as Video) );
								vw.videoDisplay.visible = true;
								vw.volumeSlider.dispatchEvent( new Event(Event.CHANGE) );
								trace("[Conference.updateClientListHandler] set videoDisplay.visible to true... client: " + client.name);
							}else{
								this.model.subscribeStop(client.id, (vw.videoDisplay.getChildByName("video") as Video));
								vw.videoDisplay.visible = false;
								trace("[Conference.updateClientListHandler] set videoDisplay.visible to false... client: " + client.name);
							}
						}
						
						vw.client_name = client.name;
						vw.client_published = client.published;
						
						
						// 部屋から出た場合は、除外する
						if (!client.isJoinedRoom){
							vw.clear(false);
							trace("[Conference.updateClientListHandler] vw.clear()... client: " + client.name);
							vw.videoDisplay.visible = false;
							trace("[Conference.updateClientListHandler] set videoDisplay.visible to false... client: " + client.name);
							vw.stopNoise();
							trace("[Conference.updateClientListHandler] stopNoise... client: " + client.name);
						}

						vw.client_is_joined_room = client.isJoinedRoom;
						
					}
				}
				
				// 新しく入室した人の場合は追加
				if( !vw_matched )
				{
					for each(var vw_new:VideoWindow in this.videoPlayerList())
					{
						if( !vw_new.client_id ){
							
							if(client.published){
								this.model.subscribeStart(client.id, (vw_new.videoDisplay.getChildByName("video") as Video) );
								vw_new.volumeSlider.dispatchEvent( new Event(Event.CHANGE) );
//								this.model.setSoundTransform(client.id, vw2.volumeSlider.value/100);
								vw_new.videoDisplay.visible = true;
							}
							
							vw_new.client_id = client.id;
							vw_new.client_name = client.name;
							vw_new.client_published = client.published;
							
							// 自分のウィンドウは音量ゼロにする
							if (client.id == MyselfManager.getMyClientId()) {
								vw_new.volumeSlider.value = 0;
								vw_new.volumeSlider.dispatchEvent( new Event(Event.CHANGE) );
							}
							
							vw_new.startNoise();
							trace("[Conference.updateClientListHandler] startNoise... client: " + client.name);
							
							break;
						}
					}
				} // if( !vw_matched )
			}
		}
		
		
		private function videoPlayerList():Array
		{
			return [vw01,vw02,vw03,vw04,vw05,vw06];
		}
		
		
		public function setSoundTransform(client_id:String, vol:Number):void
		{
			this.model.setSoundTransform(client_id, vol);
		}
		
	}
}