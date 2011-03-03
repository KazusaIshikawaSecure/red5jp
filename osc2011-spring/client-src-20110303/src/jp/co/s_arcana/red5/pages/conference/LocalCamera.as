package jp.co.s_arcana.red5.pages.conference
{
	import flash.events.MouseEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.media.Video;
	
	import jp.co.s_arcana.red5.pages.conference.model.ConferenceModel;
	import jp.co.s_arcana.red5.pages.conference.model.LocalCameraModel;
	import jp.co.s_arcana.red5.pages.conference.view.LocalCameraView;
	import jp.co.s_arcana.red5.utils.MyselfManager;
	import jp.co.s_arcana.red5.utils.StateManagerEventDispatcher;
	
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	
	public class LocalCamera extends LocalCameraView
	{
		
		private var camera:Camera;
		private var mic:Microphone;
		
		private var model:LocalCameraModel = LocalCameraModel.getInstance();
		private var model_conference:ConferenceModel = ConferenceModel.getInstance();
		
		
		public function LocalCamera()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,	this.creationCompleteHandler);
		}
		
		//--------------------------------------
		// Initialization
		//--------------------------------------
		private function creationCompleteHandler(event:FlexEvent):void
		{
			this.camera = Camera.getCamera();
			this.camera.setMode(160, 120, 10);
			this.camera.setQuality(200 * 1000 / 8, 0); // kbyte per sec ( 200Kbyte / 8 => 25Kbps)
			
			this.mic = Microphone.getMicrophone();
			this.mic.setSilenceLevel(0);
			this.mic.setLoopBack(false);
			this.mic.setUseEchoSuppression(false);
			
			//--------------------------------
			// specify the codec (cf. http://askmeflash.com/article/2/speex-vs-nellymoser)
			//--------------------------------
			
			// codec:SPEEX and quality:10 => 42.2 kbit per sec
//			this.mic.codec = SoundCodec.SPEEX;
//			this.mic.encodeQuality = 10;	
			
			// codec:NELLYMOSER and rate:22 => 44.1 kbit per sec
			this.mic.codec = SoundCodec.NELLYMOSER;
			this.mic.rate = 22;
			
			
			var video:Video = new Video();
			
			video.width = this.camera.width;
			video.height = this.camera.height;

			video.attachCamera(this.camera);
			
			this.videoDisplay.addChild(video);
			
			this.togglePublish.addEventListener(MouseEvent.CLICK, this.togglePublish_clickHandler);
			
			
			// 自分の名前を表示
			this.labelName.text = MyselfManager.getMyName();
			
			// 画面遷移イベントをListen
			StateManagerEventDispatcher.getInstance().addEventListener(
				StateManagerEventDispatcher.STATE_CONFERENCE, this.onState);
			
		}
		
		private function onState(event:DynamicEvent):void
		{
			this.togglePublish.selected = false;
		}
		
		private function togglePublish_clickHandler(event:MouseEvent):void
		{
			if (togglePublish.selected)
			{
				
				this.model.publishStart(this.camera, this.mic);
			}
			else
			{
				this.model.publishStop();
			}
				
		}
		
	}
}