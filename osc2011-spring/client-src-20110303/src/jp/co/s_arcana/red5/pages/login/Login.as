package jp.co.s_arcana.red5.pages.login
{
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import jp.co.s_arcana.red5.pages.StateConference;
	import jp.co.s_arcana.red5.pages.login.model.LoginModel;
	import jp.co.s_arcana.red5.pages.login.view.LoginView;
	import jp.co.s_arcana.red5.remote.RemoteConnection;
	import jp.co.s_arcana.red5.utils.MyselfManager;
	import jp.co.s_arcana.red5.utils.StateManager;
	import jp.co.s_arcana.red5.utils.StateManagerEventDispatcher;
	
	import mx.core.FlexGlobals;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Application;

	public class Login extends LoginView
	{
		
		private var model:LoginModel = LoginModel.getInstance();
		
		//--------------------------------------
		// Constructor
		//--------------------------------------
		public function Login()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE,	this.creationCompleteHandler);
		}
		
		//--------------------------------------
		// Initialization
		//--------------------------------------
		private function creationCompleteHandler(event:FlexEvent):void
		{
			btnLogin.addEventListener(MouseEvent.CLICK,	btnLogin_clickHandler);
			
			// 画面遷移イベントをListen
			StateManagerEventDispatcher.getInstance().addEventListener(
				StateManagerEventDispatcher.STATE_LOBBY, this.onState);
			
		}
		
		//--------------------------------------
		// UI Event Handler
		//--------------------------------------
		private function btnLogin_clickHandler(event:MouseEvent):void
		{
			var uname:String = txtName.text;
			
			if(uname.length > 0){
				// お名前を保存
				MyselfManager.setMyName(uname);
				
				// ロビー画面へ遷移
				StateManager.setStateTo("stateLobby");
			}
		}
		
		
		private function onState(event:DynamicEvent):void
		{
			this.model.joinLobby();
			this.model.getRoomCount();
			
		}
		
		
		
	}
}