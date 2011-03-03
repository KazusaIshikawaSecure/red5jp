package jp.co.s_arcana.red5.pages.conference.model
{
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.net.Responder;
	
	import jp.co.s_arcana.red5.remote.RemoteConnection;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;

	public class ConferenceModel
	{
		private var remote_model:RemoteConnection;
		
		private var subscribe_ns_list:Object = new Object();
		
		private static var _instance:ConferenceModel = null;
		
		public static function getInstance():ConferenceModel
		{
			if ( _instance == null ) {
				_instance = new ConferenceModel();
			}
			return _instance;
		}
		
		public function ConferenceModel()
		{
			this.remote_model = RemoteConnection.getInstance();
		}
		
		
		public function getClientList():IList
		{
			
			var clientList:IList = new ArrayCollection();
			
			this.remote_model.getClientList( new Responder(
				function(result:Array):void{
					trace( "ConferenceModel.getClientList() -> getClientList() on result" );
					clientList = new ArrayCollection(result);
				}, 
				function(status:Object):void{
					trace( "ConferenceModel.getClientList() -> getClientList() on status" );
					trace( status.application );
					trace( status.code );
					trace( status.description );
					trace( status.level );
				}
			));
			
			return clientList;
		}
		
		
		public function joinLobby():void
		{
			this.remote_model.joinLobby();
		}
		
		public function getRoomCount():void
		{
			this.remote_model.getRoomCount( new Responder(
				function(result:Object):void{
					trace( "ConferenceModel.getRoomCount() -> getRoomCount() on result" );
				}, 
				function(status:Object):void{
					trace( "ConferenceModel.getRoomCount() -> getRoomCount() on status" );
					trace( status.application );
					trace( status.code );
					trace( status.description );
					trace( status.level );
				}));
		}
		
		public function updateClientList():void
		{
			this.remote_model.updateClientList( new Responder(
				function(result:Object):void{
					trace( "ConferenceModel.updateClientList() -> updateClientList() on result" );
				}, 
				function(status:Object):void{
					trace( "ConferenceModel.updateClientList() -> updateClientList() on status" );
					trace( status.application );
					trace( status.code );
					trace( status.description );
					trace( status.level );
				}));
		}
		
		public function clearNetStreams():void
		{
			this.subscribe_ns_list = new Object();
		}
		
		public function setSoundTransform(client_id:String, vol:Number):void
		{
			if( this.subscribe_ns_list[client_id] ){
				(this.subscribe_ns_list[client_id] as NetStream).soundTransform = new SoundTransform(vol);
			}
		}
		
		public function subscribeStart(client_id:String, video:Video):void
		{
			if( !this.subscribe_ns_list[client_id] ){
				this.subscribe_ns_list[client_id] = this.remote_model.createNetStream();
				
				var obj:Object = new Object();
				obj.onMetaData = function(info:Object):void{
					video.width = info.width;
					trace("info.width : "+info.width);
					video.height = info.height;
					trace("info.height : "+info.height);
				}
				this.subscribe_ns_list[client_id].client = obj;
				
			}
			
			video.attachNetStream(this.subscribe_ns_list[client_id]);
			
			(this.subscribe_ns_list[client_id] as NetStream).play("publish:"+client_id);
		}
		
		
		public function subscribeStop(client_id:String, video:Video):void
		{
			
			video.attachNetStream(null);
			video.clear();
			
			if( this.subscribe_ns_list[client_id] ){
				(this.subscribe_ns_list[client_id] as NetStream).close();
			}
		}
		
		
	}
}