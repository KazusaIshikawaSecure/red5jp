package jp.co.s_arcana.red5.utils
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import jp.co.s_arcana.red5.pages.StateTransition;
	import jp.co.s_arcana.red5.utils.StateManagerEventDispatcher;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.states.State;
	
	import spark.components.Application;

	public class StateManager
	{
		private static var next_state:String;
		
		public function StateManager()
		{
		}
		
		public static function setStateTo(strState: String):void {
//			_setStateTo(strState);
//			return;
			
			
			_setStateTo("stateTransition");
			
			var timer:Timer = new Timer(500, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void {
				trace("StateManager.setStateTo() :  TimerEvent.TIMER_COMPLETE");
				timer.stop();

				_setStateTo(strState);
				
				// ページ遷移のイベントを送出
				StateManagerEventDispatcher.getInstance().dispatchState(strState);
				
			});
			
			timer.start();
		}
		
		private static function _setStateTo(s:String):void
		{
			(FlexGlobals.topLevelApplication as Application).currentState = s;
		}
		
		
		
	}
}