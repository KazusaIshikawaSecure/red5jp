package jp.co.s_arcana.red5.utils
{
	/**
	 * 自分自身の情報を管理する
	 * 
	 * ※ほとんどstaticですが、instance化の必要性が生じたら要refactoringで。
	 * 
	 */
	public class MyselfManager
	{
		
		/**
		 * 自分のお名前
		 */
		private static var my_name:String;
		
		/**
		 * サーバから割り振られたID
		 */
		private static var client_id:String;
		
		
		public function MyselfManager()
		{
		}
		
		public static function setMyName(s:String):void
		{
			trace("MyselfManager.setMyName() s: " + s);
			my_name = s;
		}
		
		public static function getMyName():String
		{
			trace("MyselfManager.getMyName() " + my_name);
			return my_name;
		}
		
		public static function setMyClientId(s:String):void
		{
			trace("MyselfManager.setMyClientId() s: " + s);
			client_id = s;
		}
		
		public static function getMyClientId():String
		{
			trace("MyselfManager.getMyClientId() " + client_id);
			return client_id;
		}
	}
}