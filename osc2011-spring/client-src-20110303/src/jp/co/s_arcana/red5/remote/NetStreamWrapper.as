package jp.co.s_arcana.red5.remote
{
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class NetStreamWrapper extends NetStream
	{
		public function NetStreamWrapper(connection:NetConnection, peerID:String="connectToFMS")
		{
			super(connection, peerID);
			this.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			this.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			this.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function netStatusHandler( event:NetStatusEvent ):void
		{
			// See: http://help.adobe.com/ja_JP/AS3LCR/Flex_4.0/flash/events/NetStatusEvent.html
			trace( "NetStreamWrapper.netStatusHandler():code: " + event.info.code );
		}
		
		private function asyncErrorHandler( event:AsyncErrorEvent ):void 
		{
			trace( "NetStreamWrapper.asyncErrorHandler(): " + event.type + " - " + event.error );
		}	
		
		private function ioErrorHandler( event:IOErrorEvent ):void 
		{
			trace( "NetStreamWrapper.ioErrorHandler(): " + event.type + " - " + event.text );
		}
		
	}
}