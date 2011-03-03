package jp.co.s_arcana.red5.pages.conference.components
{
	import mx.events.FlexEvent;

	public class Tweet extends TweetWindow
	{
		public function Tweet()
		{
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE,	this.creationCompleteHandler);
			
		}
		
		private function creationCompleteHandler(event:FlexEvent):void
		{
			
		}
		
		
	}
}