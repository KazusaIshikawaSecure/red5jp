package jp.co.s_arcana.red5.remote
{
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	
	public class NetConnectionWrapper extends NetConnection
	{
		public function NetConnectionWrapper()
		{
			super();
			this.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			this.addEventListener( SecurityErrorEvent.SECURITY_ERROR, netSecurityErrorHandler );
			this.addEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			this.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );	
		}
		
		private function netStatusHandler( event:NetStatusEvent ):void
		{
			// See: http://help.adobe.com/ja_JP/AS3LCR/Flex_4.0/flash/events/NetStatusEvent.html
			trace( "NetConnectionWrapper.netStatusHandler():code: " + event.info.code );
		}
		
		private function netSecurityErrorHandler( event:SecurityErrorEvent ):void {
			trace( "NetConnectionWrapper.netSecurityError(): " + event );
		}		
		
		private function asyncErrorHandler( event:AsyncErrorEvent ):void {
			trace( "NetConnectionWrapper.asyncErrorHandler(): " + event.type + " - " + event.error );
		}	
		
		private function ioErrorHandler( event:IOErrorEvent ):void {
			trace( "NetConnectionWrapper.ioErrorHandler(): " + event.type + " - " + event.text );
		}	
	}
}