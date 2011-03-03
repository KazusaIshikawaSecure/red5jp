package jp.co.s_arcana.red5.pages.conference.model
{
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.net.NetStream;
	
	import jp.co.s_arcana.red5.remote.RemoteConnection;
	import jp.co.s_arcana.red5.utils.MyselfManager;
	
	import mx.collections.IList;

	public class LocalCameraModel
	{
		private var remote_model:RemoteConnection;
		
		private var publish_ns:NetStream;
		
		private static var _instance:LocalCameraModel = null;
		
		public static function getInstance():LocalCameraModel
		{
			if ( _instance == null ) {
				_instance = new LocalCameraModel();
			}
			return _instance;
		}
		
		public function LocalCameraModel()
		{
			this.remote_model = RemoteConnection.getInstance();
		}
		
		
		public function publishStart(camera:Camera, mic:Microphone):void
		{
			if( !this.publish_ns ){
				this.publish_ns = this.remote_model.createNetStream();
			}
			
			this.publish_ns.attachCamera(camera);
			this.publish_ns.attachAudio(mic);
			
			var my_client_id:String = MyselfManager.getMyClientId();
			this.publish_ns.publish("publish:"+my_client_id, "live");
		}

		
		public function publishStop():void{
			
			if( this.publish_ns )
			{
				this.publish_ns.close();
			}
			
		}
		
		public function clearNetStream():void
		{
			this.publish_ns = null;
		}
	}
}