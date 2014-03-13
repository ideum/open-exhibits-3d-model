package  {
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.lights.DirectionalLight;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.MaterialBase;
	import com.gestureworks.away3d.*;
	import com.gestureworks.away3d.TouchManager3D;
	import com.gestureworks.away3d.utils.*;
	import com.gestureworks.away3d.utils.Math3DUtils;
	import com.gestureworks.cml.away3d.geometries.CubeGeometry;
	import com.gestureworks.cml.utils.document;
	import com.gestureworks.core.TouchSprite;
	import com.gestureworks.events.GWGestureEvent;
	import com.greensock.plugins.ShortRotationPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	

	public class Model extends Sprite { 	

		private var hitMeshAlpha:Number = 0;
		
		private var minScale:Number = .75;
		private var maxScale:Number = 1.5;
		
		private var maxRotationX = 60;
		private var minRotationX = -maxRotationX;
		
		private var models:Array = [];
		private var modelNames:Array = [];
		private var modelIndex:Number = 1;
		private var modelButtons:Array = [];	
		private var modelPositions:Array = [];
		private var modelScales:Array = [];
		private var modelScaleMap:Dictionary = new Dictionary;
		private var modelY:Array = [];
		private var modelRotationsX:Array = [];
		private var modelRotationsY:Array = [];

		private var touchSprites:Array = [];
		private var view:View3D;
		private var container:ObjectContainer3D;
		private var cameraController:HoverController;
		private var touchView:TouchSprite;
		private var loadCnt:uint = 0;
		private var fileList:Array = [];
		private var dragRight:Boolean = false;
		private var initialized:Boolean = false;
		
		private var hitGeometry:CubeGeometry;
		
		private var light:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		
		public function Model() {
			TweenPlugin.activate([ShortRotationPlugin]);
			super();
		}
		
		public function init():void {
			
			fileList  = ["library/assets/theModel.awd",];
			
			modelNames = ['a'];
			
			modelPositions = [0];
			
			modelRotationsX = [0];
			
			modelRotationsY = [0];
			
			view = new View3D();
			view.backgroundColor = 0x000000;
			view.width  = 1920;
			view.height = 1080;
			view.antiAlias = 4;
			view.camera.lens.far = 15000;
			addChild(view);
			
			cameraController = new HoverController(view.camera, null, 180, 0, 150);
			
			
			cameraController.yFactor = 1;
			cameraController.wrapPanAngle = true;
			cameraController.minTiltAngle = -30;
			cameraController.maxTiltAngle = 0;
			
			container = new ObjectContainer3D;
			container.rotationX = 0;
			container.rotationY = 0;
			container.rotationZ = 0;
			view.scene.addChild(container);
				
			addEventListener( Event.ENTER_FRAME, update );				
			
			Parsers.enableAllBundled();		
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, resourceComplete);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, assetComplete);	
			AssetLibrary.load(new URLRequest(fileList[loadCnt]));
			
			hitGeometry = new CubeGeometry(100, 100, 100, 1, 1, 1);
			
			TouchManager3D.onlyTouchEnabled = false;
			
			light = new DirectionalLight;
			lightPicker = new StaticLightPicker([light]);
		}

		private function assetComplete(e:AssetEvent):void {
			if (e.asset is ObjectContainer3D && ObjectContainer3D(e.asset).parent == null) {
				models.push(e.asset);
				e.asset.name = modelNames[loadCnt];
			}		
			else if (e.asset is MaterialBase) {
				MaterialBase(e.asset).lightPicker = lightPicker;
			}
		}
		
		private function resourceComplete(e:LoaderEvent):void {				
			loadCnt++;			
			if (fileList.length == loadCnt) {
				initObjects();
			}
			else {
				AssetLibrary.load(new URLRequest(fileList[loadCnt]));
			}
		}
		
		private function initObjects():void {
			var t:TouchSprite;
			var p:Vector3D;
			for (var i:int = 0; i < models.length; i++) {				
			
				p = Math3DUtils.sphericalToCartesian(new Vector3D( (modelPositions[i] ) , 0, 300));		
				
				var hitMesh:Mesh = new Mesh(hitGeometry);
				hitMesh.material = new ColorMaterial(0xFFFFFF, hitMeshAlpha);
				hitMesh.addChild(models[i]);
				container.addChild(hitMesh);
				
				hitMesh.x = p.x;
				models[i].y = 0
				hitMesh.z = p.z;
				models[i].rotationX = modelRotationsX[i];
				models[i].rotationY = modelRotationsY[i];
				hitMesh.name = models[i].name;
				hitMesh.rotationY = modelRotationsY[i];
				
				// REGISTER THE ACTUAL 3D OBJECT TO THE MANAGER. WHAT RETURNS IS A TOUCH OBJECT THAT HOLDS THE TRANSFORMATION OF THAT OBJECT
				t = TouchSprite(TouchManager3D.registerTouchObject(hitMesh, false));
					t.view = view;
					t.mouseEnabled = true; // ENSURES THAT THE 3D OBJECT CAN PROCESS TOUCH AND MOTION POINTS 
					t.nativeTransform = false; // MUST BE MANUALLY SET TO FALSE
					t.affineTransform = false; // MUST BE MANULALLY SET TO FALSE
					
					t.motionEnabled = true; // ENSURES THAT MOTION GESTURES ARE PROCESSED ON THE TOUCHSPRITE
					t.transform3d = false;  // ENSURES THAT THE 3D MOTION INTERACTION POINTS ARE PROJECTED INTO THE 2D STAGE
					t.gestureEvents = true; // ENABLES GESTURE EVENT DISPATCHING ON THE TOUCHSPRITE
					
					// CONFIGURES THE TOUCH SPRITE TO COLLECT ONLY 3D MOTION INTERACTION POINTS FROM THE SKELETAL MODEL 
					// THAT COLLIDE WITH THE 3D MODEL/OBJECT WHEN INITIALIZED (INTERACTIONPOINT_BEGIN)
					t.motionClusterMode = "local_strong";
					
					//CONFIGURES THE 3D MODEL TO PROCESS 3 STANDARD TOUCH GESTURES AND 2 3D MOTION GESTURES
					// 1. A TRIGGER HOLD GESTURE THAT REQUIRES A TRIGGER POSTURE (WITH BENT THUMB) HELD IN PLACE FOR HALF A SECOND 
					// 2. A PINCH DRAG/ROTATE GESTURE THAT REQUIRES THAT TWO FINGERS OR A FINGER AND A THUMB ARE CLOSE BUT NOT TOUCHING
					t.gestureList = { 	"n-tap":true, "n-drag":true, "n-scale":true };
					
					// SIMPLE TOUCH GESTURE LISTENERS
					t.addEventListener(GWGestureEvent.DRAG, onModelDrag);
					t.addEventListener(GWGestureEvent.TAP, onModelTap);
					t.addEventListener(GWGestureEvent.SCALE, onModelScale);	
				
				touchSprites.push(t);				
			}
			initialized = true;
		}
		
		private function update(e:Event = null):void {
			if (initialized) {
				view.render();
			}
		}			
		
		// THE TARGET'S VTO (VIRTUAL TRANSFORM OBJECT) IS THE OBJECT SHOULD RECEIVED THE VIRTUAL TRANSFORMATIONS. IN THIS CASE IT HOLDS THE ACTUAL 3D OBJECT OR MESH
		private function onModelDrag(e:GWGestureEvent):void {
			e.target.vto.rotationY -= e.value.drag_dx * .5;
			
			var val:Number = e.target.vto.rotationX - e.value.drag_dy * .5;
			
			if (val < minRotationX)
				val = minRotationX;
			else if (val > maxRotationX)
				val = maxRotationX;
				
			e.target.vto.rotationX = val;	
		}

		private function onModelScale(e:GWGestureEvent):void {
			var val:Number = e.target.vto.scaleX + e.value.scale_dsx * .75;
			
			if (val < minScale)
				val = minScale;
			else if (val > maxScale)
				val = maxScale;
				
			e.target.vto.scaleX = val;
			e.target.vto.scaleY = val;
			e.target.vto.scaleZ = val;
		}	

		private function onModelTap(e:GWGestureEvent):void {
			trace("model tap");
		}		
	}
}