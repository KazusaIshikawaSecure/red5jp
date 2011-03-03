package jp.co.s_arcana.red5.pages.login.model
{
	import flash.net.Responder;
	
	import jp.co.s_arcana.red5.remote.RemoteConnection;

	public class LoginModel
	{
		private static var _instance:LoginModel = null;
		
		private var remote_model:RemoteConnection;
		
		public static function getInstance():LoginModel
		{
			if ( _instance == null ) {
				_instance = new LoginModel();
			}
			return _instance;
		}
		
		public function LoginModel()
		{
			this.remote_model = RemoteConnection.getInstance();
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
		
		
	}
}