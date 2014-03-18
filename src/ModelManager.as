package  {
	import away3d.containers.ObjectContainer3D;
	import caurina.transitions.Tweener;
	import com.gestureworks.away3d.TouchManager3D;
	import com.gestureworks.cml.core.CMLAway3D;
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.utils.document;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.events.GWGestureEvent;
	import com.greensock.plugins.ShortRotationPlugin;
	import com.greensock.plugins.TweenPlugin;
	import flash.display.Sprite;
	import flash.events.Event;

	public class ModelManager extends Sprite { 	

		private var container:ObjectContainer3D;
		
		private var minScale:Number = .75;
		private var maxScale:Number = 1.5;

		private var maxRotationX:Number = 60;
		private var minRotationX:Number = -maxRotationX;
		
		private var popups:Array;
		
		public function ModelManager() {
			TweenPlugin.activate([ShortRotationPlugin]);
			super();
		}
		
		public function init():void {
			container = document.getElementById("container01");
			
			document.getElementById("cube").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("cube").vto.addEventListener(GWGestureEvent.SCALE, onModelScale);
			
			document.getElementById("hotspot01").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			document.getElementById("hotspot02").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			document.getElementById("hotspot03").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			popups = document.getElementsByTagName(ModelPopup);
		}
		
		private function onModelDrag(e:GWGestureEvent):void {
			
			var val:Number = container.rotationX + e.value.drag_dy * .25;
			
			if (val < minRotationX)
				val = minRotationX;
			else if (val > maxRotationX)
				val = maxRotationX;
				
			container.rotationY -= e.value.drag_dx * .5;
			container.rotationX = val;
		}

		private function onModelScale(e:GWGestureEvent):void {
			var val:Number = container.scaleX + e.value.scale_dsx * .75;
			
			if (val < minScale)
				val = minScale;
			else if (val > maxScale)
				val = maxScale;
				
			container.scaleX = val;
			container.scaleY = val;
			container.scaleZ = val;
		}	

		private function onHotspotTap(e:GWGestureEvent):void {
			trace("model tap", e.target.vto.x, e.target.vto.y, e.target.z);

			var popup:ModelPopup = document.getElementById(e.target.vto.name);
			for (var i:int = 0; i < popups.length; i++) {
				if (popups[i].visible && popups[i] != popup) {
					popups[i].tweenOut();
				}
			}
			if (!popup.visible)
				popup.tweenIn();
			else
				popup.tweenOut();	
		}
	}
}