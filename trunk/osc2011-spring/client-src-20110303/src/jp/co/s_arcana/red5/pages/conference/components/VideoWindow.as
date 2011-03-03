package jp.co.s_arcana.red5.pages.conference.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	
	import jp.co.s_arcana.red5.pages.conference.Conference;
	
	import mx.core.IVisualElementContainer;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.HSlider;
	import spark.components.Label;
	import spark.filters.DropShadowFilter;
	import spark.primitives.BitmapImage;

	public class VideoWindow extends VideoWindowView
	{
		
		private const ENABLE_DRAG_AREA_X_MIN:int = 10;
		private const ENABLE_DRAG_AREA_Y_MIN:int = 10;
		private const ENABLE_DRAG_AREA_X_MAX:int = 800 - 10;
		private const ENABLE_DRAG_AREA_Y_MAX:int = 432 - 10;
		
		private var _client_id:String;
		private var _client_name:String;
		private var _client_published:Boolean;
		private var _client_is_joined_room:Boolean;
		
		private var is_dragging:Boolean = false;
		private var shadow:DropShadowFilter = new DropShadowFilter(4, 45, 0, 0.5);

		private var current_volume:Number;
		private var is_muted:Boolean;
		
		private var show_noise:Boolean;
		
		public function VideoWindow()
		{
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE,	this.creationCompleteHandler);
			
		}
		
		private function creationCompleteHandler(event:FlexEvent):void
		{
			//--------------------------------
			// ノイズ画像の生成
			//--------------------------------
			var bitmapData:BitmapData = new BitmapData(160, 120, false, 0xff000000); 
			bitmapData.noise(Math.random() * 1000, 0, 128, 7 ,true); 
			var image:Bitmap = new Bitmap(bitmapData); 
			this.imageNoise.source = image;
			
			/* クリックで砂嵐エフェクト
			this.imageNoise.addEventListener(MouseEvent.CLICK, noise_clickHandler);
			*/
			
			/* 砂嵐エフェクトは目に優しくないので廃止
			this.addEventListener(Event.ENTER_FRAME, function(event:Event):void{
				if(event.target is VideoWindow){
					var bitmapData:BitmapData = new BitmapData(160, 120, false, 0xff000000); 
					bitmapData.noise(Math.random() * 1000, 0, 255, 7 ,true); 
					var image:Bitmap = new Bitmap(bitmapData); 
					event.target.imageNoise.source = image;
				}
			});
			*/
			
			
			//--------------------------------
			// ドラッグの制御
			//--------------------------------
			this.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void{
				if(event.target is VideoWindow || event.target is Label){
					var window:Object = event.target;
					if(event.target is Label) window = event.target.parent;
					// ドラッグ開始
					window._dragStart();
				}
			});
			
			this.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void{
				var parent:Object = event.target;
				while ( !(parent is VideoWindow) && parent != null ){
					parent = parent.parent;
				}
				if(parent is VideoWindow) parent._dragStop();
				/*
				if(event.target is VideoWindow || event.target is Label){
					var window:Object = event.target;
					if(event.target is Label) window = event.target.parent;
					// ドラッグ停止
					window._dragStop();
				}
				*/
			});
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void{
				if(event.target is VideoWindow || event.target is Label){
					var window:Object = event.target;
					if(event.target is Label) window = event.target.parent;
					// ドラッグ時に領域外へ移動できないようにする
					if(window.is_dragging) window._checkPosition();
				}
			});
			
			//--------------------------------
			// ボリュームコントロール制御
			//--------------------------------
			this.volumeSlider.addEventListener(Event.CHANGE, function(event:Event):void{
				var parent:Object = event.target;
				while (parent = parent.parent){
					if(parent is VideoWindow) break;
				}
				var client_id:String = (parent as VideoWindow).client_id;
				var vol:Number = event.target.value;
				
				while (parent = parent.parent){
					if(parent is Conference) break;
				}
				(parent as Conference).setSoundTransform(client_id, (vol/100));
				
				// ボリュームアイコン表示
				var sliderSkin:Object = event.target.skin;
				if(vol <= 0){
					sliderSkin.slider_icon_on.visible = false;
					sliderSkin.slider_icon_off.visible = true;
					is_muted = false;
				} else {
					sliderSkin.slider_icon_on.visible = true;
					sliderSkin.slider_icon_off.visible = false;
				}
				// トラックバー表示
				var trackSkin:Object = sliderSkin.track.skin;
				trackSkin.track_over.width = (trackSkin.track_off.width-3) * (vol/100);
				//trackSkin.track_over.alpha = (vol/500)+0.8;
				//trackSkin.track_over_left.alpha = (vol/500)+0.8;
				
			});
			// ミュート
			if(this.volumeSlider.skin["slider_icon_on"]){
				this.volumeSlider.skin["slider_icon_on"].addEventListener(MouseEvent.CLICK, function(event:Event):void{
					var parent:Object = event.target;
					while (parent = parent.parent){
						if(parent is HSlider) break;
					}
					with(parent as HSlider){
						if( 0 < value ){
							current_volume = value;
							value = 0;
							dispatchEvent( new Event(Event.CHANGE) );
							is_muted = true;
						}
					}
				});
			}
			// ミュート解除
			if(this.volumeSlider.skin["slider_icon_off"]){
				this.volumeSlider.skin["slider_icon_off"].addEventListener(MouseEvent.CLICK, function(event:Event):void{
					var parent:Object = event.target;
					while (parent = parent.parent){
						if(parent is HSlider) break;
					}
					var trackSkin:Object;
					with(parent as HSlider){
						if( is_muted ){
							value = current_volume;
							dispatchEvent( new Event(Event.CHANGE) );
							is_muted = false;
						}
					}
				});
			}
			
		}
		
		private function noise_clickHandler(event:MouseEvent):void{
			if(this.show_noise) {
				this.removeEventListener(Event.ENTER_FRAME, noise_enterFrameHandler);
				this.show_noise = false;
			}
			else {
				this.addEventListener(Event.ENTER_FRAME, noise_enterFrameHandler);
				this.show_noise = true;
			}
		}
		
		public function startNoise():void{
			this.addEventListener(Event.ENTER_FRAME, noise_enterFrameHandler);
			this.show_noise = true;
		}
		
		public function stopNoise():void{
			this.removeEventListener(Event.ENTER_FRAME, noise_enterFrameHandler);
			this.show_noise = false;
		}
		
		private function noise_enterFrameHandler(event:Event):void{
			if(event.target is VideoWindow){
				var bitmapData:BitmapData = new BitmapData(160, 120, false, 0xff000000); 
				bitmapData.noise(Math.random() * 1000, 0, 128, 7 ,true); 
				var image:Bitmap = new Bitmap(bitmapData); 
				event.target.imageNoise.source = image;
			}
		}
		
		
		private function _dragStart():void{
			// 最前面に移動
			var m:int = this.parent.numChildren - 1;
			(this.parent as IVisualElementContainer).setElementIndex(this, m);
			
			this.startDrag();
			this.filters = [shadow];
			this.is_dragging = true;
		}
		
		private function _dragStop():void{
			this.stopDrag();
			this.filters = [];
			this.is_dragging = false;
		}
		
		private function _checkPosition():void{
			
			if(this.mouseX < 2) { this.x = ENABLE_DRAG_AREA_X_MIN; this._dragStop(); }
			if(this.mouseY < 2) { this.y = ENABLE_DRAG_AREA_Y_MIN; this._dragStop(); }
			if(this.mouseX > this.width - 2)  { this.x = ENABLE_DRAG_AREA_X_MAX - this.width; this._dragStop(); }
			if(this.mouseY > this.height - 2) { this.y = ENABLE_DRAG_AREA_Y_MAX - this.height; this._dragStop(); }
			
			/*
			if(this.mouseX <= 0) this._dragStop();
			if(this.mouseY <= 0) this._dragStop();
			if(this.mouseX >= this.width)  this._dragStop();
			if(this.mouseY >= this.height) this._dragStop();
			*/
			
			if(this.parentApplication.stage.mouseX < ENABLE_DRAG_AREA_X_MIN) this._dragStop();
			if(this.parentApplication.stage.mouseY < ENABLE_DRAG_AREA_Y_MIN) this._dragStop();
			if(this.parentApplication.stage.mouseX > ENABLE_DRAG_AREA_X_MAX) this._dragStop();
			if(this.parentApplication.stage.mouseY > ENABLE_DRAG_AREA_Y_MAX) this._dragStop();
			
			
			if(this.x < ENABLE_DRAG_AREA_X_MIN) { this.x = ENABLE_DRAG_AREA_X_MIN; }
			if(this.y < ENABLE_DRAG_AREA_Y_MIN) { this.y = ENABLE_DRAG_AREA_Y_MIN; }
			if(this.x > ENABLE_DRAG_AREA_X_MAX - this.width)  { this.x = ENABLE_DRAG_AREA_X_MAX - this.width; }
			if(this.y > ENABLE_DRAG_AREA_Y_MAX - this.height) { this.y = ENABLE_DRAG_AREA_Y_MAX - this.height; }
			
		}
		
		
		public function set client_id(s:String):void{
			_client_id = s;
		}
		public function get client_id():String{
			return _client_id;
		}
		
		public function set client_name(s:String):void{
			_client_name = s;
			labelClientName.text = s;
		}
		public function get client_name():String{
			return _client_name;
		}
		
		public function set client_published(b:Boolean):void{
			_client_published = b;
		}
		
		public function get client_published():Boolean{
			return _client_published;
		}
		
		
		public function set client_is_joined_room(b:Boolean):void{
			_client_is_joined_room = b;
		}
		
		public function get client_is_joined_room():Boolean{
			return _client_is_joined_room;
		}
		
		
		public function clear(withVolume:Boolean = true):void{
			this.client_id = null;
			this.client_name = "----";
			this.client_published = false;
			this.client_is_joined_room = false;
			this.stopNoise();
			
			try {
				// ボリュームコントロール制御
				if(withVolume){
					this.volumeSlider.skin["slider_icon_on"].visible = true;
					this.volumeSlider.skin["slider_icon_off"].visible = false;
					this.volumeSlider.value = 30;
					this.volumeSlider.skin["track"].skin.track_over.width = 
						(this.volumeSlider.skin["track"].skin.track_off.width-3) * (this.volumeSlider.value/100);
					//this.volumeSlider.skin["track"].skin.track_over.alpha = (this.volumeSlider.value/500)+0.8;
					//this.volumeSlider.skin["track"].skin.track_over_left.alpha = (this.volumeSlider.value/500)+0.8;
				}
			} catch (e:Error) {
				trace(e.message); 
			}
		}
		
	}
}