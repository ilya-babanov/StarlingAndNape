package 
{
	import Engines.BodyEngine;
	
	import GameObjects.BodyExt;
	
	import com.greensock.TweenLite;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.space.Broadphase;
	import nape.space.Space;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.Color;
	import starling.utils.rad2deg;
	
	public class AppMain extends Sprite
	{
		public var space:Space;
		
		public var hand:PivotJoint;
		
		public var waveTimer:Timer;
		public var waveCount:int;
		
		private var bodyEngine:BodyEngine;
		
		public function AppMain()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			waveCount = 0;
			configureSpace();
			configureEngines();
			configureListeners();
			configureGameTimer();
		}
		
		private function configureSpace():void
		{
			space = new Space(new Vec2(0,-600), Broadphase.SWEEP_AND_PRUNE);
			/*
			space.worldLinearDrag = 0.3;
			space.worldAngularDrag = 0.9;
			*/
			
			hand = new PivotJoint(space.world,space.world,new Vec2(),new Vec2());
			hand.active = false;
			hand.stiff = false;
			hand.space = space;
		}
		
		private function configureEngines():void{
			bodyEngine = new BodyEngine(stage, space, hand);
			bodyEngine.addBorders();
		}
		
		private function configureListeners():void{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		
		private function configureGameTimer():void{
			waveTimer = new Timer(900);
			waveTimer.addEventListener(TimerEvent.TIMER, onWaveTimer);
			waveTimer.start();
		}
		
		protected function onWaveTimer(event:TimerEvent):void{
			waveCount++;
			trace("waveCount = "+waveCount);
			if(waveCount == 1){
				configureFirstWave();
			}else if(waveCount == 2){
				//configureSecondWave();
			}
			else if(waveCount == 3){
				//waveCount = 0;
				//configureThirdWave();
			}
		}
		
		private function configureThirdWave():void{
			var aimBox:BodyExt = null;
			for (var x:int = 20; x < stage.stageWidth - 555; x+=24){
				for(var y:int = -100; y < 0; y+=24){
					bodyEngine.addSimpleAim(x,y);
				}
			}
		}
		
		private function configureSecondWave():void{
			var aimBox:BodyExt = null;
			for (var x:int = 400; x < stage.stageWidth - 100; x+=24){
				for(var y:int = -70; y < 0; y+=24){
					bodyEngine.addSimpleAim(x,y);
				}
			}
		}
		
		private function configureFirstWave():void{
			var aimBox:BodyExt = null;
			/*for (var x:int = 70; x < stage.stageWidth - 70; x+=24){
				for(var y:int = -60; y < 0; y+=24){
					bodyEngine.addSimpleAim(x,y);
				}
			}*/
			for (var x:int = 0; x < stage.stageWidth; x+=24){
				for(var y:int = 0; y < 333; y+=24){
					bodyEngine.addSimpleAim(x,y);
				}
			}
		}
		
		private function onTouch(event:TouchEvent):void{
			var touch:Touch = event.getTouch(this.stage);
			if (touch){
				//addSimpleBall(touch.globalX, touch.globalY);
				switch(touch.phase){
					//down
					case TouchPhase.BEGAN:
						if(event.ctrlKey)
							bodyEngine.addSimpleDisk(touch.globalX,touch.globalY);
						if(event.shiftKey){
							for(var j:uint = 0; j < 20; j++)
								bodyEngine.addSimpleAim(touch.globalX,touch.globalY);
						}
						/*if(shiftKey)
						addSimpleBall(touch.globalX,touch.globalY);*/
						onTouchDownDrag(touch);
						break;
					//move
					case TouchPhase.MOVED:
						//onTouchDownDrag(touch);
						onTouchMove(touch);
						break;
					//up
					case TouchPhase.ENDED:
						hand.active = false;
						break;
				}
			}
		}
		
		private function onTouchDownDrag(touch:Touch):void
		{
			
			hand.anchor1.setxy(touch.globalX, touch.globalY);
			var coordinates:Vec2 = new Vec2(touch.globalX,touch.globalY);
			var bodies:BodyList = space.bodiesUnderPoint(coordinates);
			for(var i:int = 0; i<bodies.length; i++) {
				var b:Body = bodies.at(i);
				if(!b.isDynamic()) 
					continue;
				hand.body2 = b;
				hand.anchor2 = b.worldToLocal(coordinates);
				hand.active = true;
				break;
			}
		}
		
		private function onTouchMove(touch:Touch):void
		{
			hand.anchor1.setxy(touch.globalX, touch.globalY);
		}
		
		private function onEnterFrame():void
		{
			space.step(1/60);
			bodyEngine.removeDeletedBodies();
		}
	}
}