package 
{
	import GameObjects.BodyExt;
	
	import VisualGameElements.SimpleBall;
	import VisualGameElements.SmallBox;
	import VisualGameElements.SmallDisk;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	import org.osmf.events.TimeEvent;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	
	public class AppMain extends Sprite
	{
		private var space:Space;
		
		private var hand:PivotJoint;
		
		[Embed(source="./Particles/TestParticle4.png")]
		private var ParticleTexture:Class;
		
		[Embed(source="./Particles/TestParticle4.pex", mimeType="application/octet-stream")]
		private var ParticleXML:Class;
		
		private var shiftKey:Boolean = false;
		
		protected var waveTimer:Timer;
		protected var waveCount:int;
		
		public var vectorBodyToDelete:Vector.<Body>;

		private var floor:Body;
		private var borders:Body;
		
		public function AppMain()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			waveCount = 0;
			vectorBodyToDelete = new Vector.<Body>();
			configureSpace();
			configureListeners();
			//configureLevelAims();
			configureGameTimer();
		}
		
		private function configureGameTimer():void
		{
			waveTimer = new Timer(5000);
			waveTimer.addEventListener(TimerEvent.TIMER, onWaveTimer);
			waveTimer.start();
		}
		
		protected function onWaveTimer(event:TimerEvent):void
		{
			waveCount++;
			trace("waveCount = "+waveCount);
			if(waveCount == 1){
				configureFirstWave();
			}else if(waveCount == 2){
				configureSecondWave();
			}
			else if(waveCount == 3){
				waveCount = 0;
				configureThirdWave();
			}
		}
		
		private function configureThirdWave():void
		{
			var aimBox:BodyExt = null;
			for (var x:int = 20; x < stage.stageWidth - 600; x+=24){
				for(var y:int = -250; y < 0; y+=24){
					addSmallDisk(x,y);
				}
			}
		}
		
		private function configureSecondWave():void
		{
			var aimBox:BodyExt = null;
			for (var x:int = 400; x < stage.stageWidth - 200; x+=24){
				for(var y:int = -150; y < 0; y+=24){
					addSmallDisk(x,y);
				}
			}
		}
		
		private function configureFirstWave():void
		{
			var aimBox:BodyExt = null;
			for (var x:int = 50; x < stage.stageWidth - 50; x+=24){
				for(var y:int = -50; y < 0; y+=24){
					addSmallDisk(x,y);
				}
			}
		}
		
		private function configureListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(TouchEvent.TOUCH, onTouch);
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function configureSpace():void
		{
			space = new Space(new Vec2(0,150));
			
			borders = new Body(BodyType.STATIC);
			floor = new Body(BodyType.STATIC);
			floor.shapes.add(new Polygon(Polygon.rect(0,stage.stageHeight,stage.stageWidth,100)));
			borders.shapes.add(new Polygon(Polygon.rect(-100,0,100, stage.stageHeight)));
			borders.shapes.add(new Polygon(Polygon.rect(stage.stageWidth,0, 100, stage.stageHeight)));
			//borders.shapes.add(new Polygon(Polygon.rect(0,-100, stage.stageWidth, 100)));
			borders.space = space;
			//floor.space = space;
			hand = new PivotJoint(space.world,space.world,new Vec2(),new Vec2());
			hand.active = false;
			hand.stiff = false;
			hand.space = space;
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			shiftKey = false;
		}
		
		/*private function onKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode==Keyboard.SHIFT){
				shiftKey = true;
			}
		}*/
		
		private function onTouch(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this.stage);
			if (touch){
				//addSimpleBall(touch.globalX, touch.globalY);
				switch(touch.phase){
					//down
					case TouchPhase.BEGAN:
						if(event.ctrlKey)
							addSimpleBallWithParticles(touch.globalX,touch.globalY);
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
		
		private function addSimpleBallWithParticles(x:Number, y:Number):void
		{
			var bodyForSimpleBall:BodyExt = new BodyExt(BodyType.DYNAMIC, new Vec2(x, y));
			bodyForSimpleBall.shapes.add(new Circle(32, null, new Material(1.3)));
			bodyForSimpleBall.graphic = new SimpleBall();
			//bodyForSimpleBall.allowRotation = false;
			var particle:PDParticleSystem = new PDParticleSystem(XML(new ParticleXML()), Texture.fromBitmap(new ParticleTexture()));
			particle.start();
			addChild(particle);
			Starling.juggler.add(particle);
			
			bodyForSimpleBall.particles = particle;
			bodyForSimpleBall.graphicUpdate = updateGraphicsWithParticles;
			bodyForSimpleBall.space = space;
			
			addChild(bodyForSimpleBall.graphic); 
		}
		
		private function addSimpleBall(x:Number, y:Number):void
		{
			var bodyForSimpleBall:BodyExt = new BodyExt(BodyType.DYNAMIC, new Vec2(x, y));
			bodyForSimpleBall.shapes.add(new Circle(32, null, Material.rubber()));
			bodyForSimpleBall.graphic = new SimpleBall();
			//bodyForSimpleBall.allowRotation = false;
			bodyForSimpleBall.graphicUpdate = updateGraphics;
			bodyForSimpleBall.space = space;
			
			addChild(bodyForSimpleBall.graphic); 
		}
		
		private function addSmallDisk(x:Number, y:Number):void
		{
			var aimBox:BodyExt = null;
			aimBox = new BodyExt();
			aimBox.position.x = x;
			aimBox.position.y = y;
			/*aimBox.shapes.add(new Polygon(Polygon.box(32,32)));
			aimBox.graphic = new LittleBox();*/
			var disk:Circle = new Circle(12);
			disk.body = aimBox;
			aimBox.graphic = new SmallDisk();
			aimBox.graphicUpdate = updateGraphics;
			aimBox.space = space;
			addChild(aimBox.graphic);
		}
		
		private function updateGraphics(b:BodyExt):void
		{
			b.graphic.x = b.position.x;
			b.graphic.y = b.position.y;
			b.graphic.rotation = b.rotation;
			
			if (b.graphic.y > 1024) {
				vectorBodyToDelete.push(b);
			}
		}
		
		private function updateGraphicsWithoutRotation(b:BodyExt):void
		{
			b.graphic.x = b.position.x;
			b.graphic.y = b.position.y;
		}
		
		private function updateGraphicsWithParticles(b:BodyExt):void
		{
			b.graphic.x = b.particles.emitterX = b.position.x;
			b.graphic.y = b.particles.emitterY = b.position.y;
			b.graphic.rotation = b.rotation;
		}
		
		
		private function onEnterFrame():void
		{
			space.step(1/60,1,1);
			for each (var b:BodyExt in vectorBodyToDelete) 
			{
				b.graphicUpdate = null;
				removeChild(b.graphic);
				space.bodies.remove(b);
				b = null;
			}
			
		}
	}
}