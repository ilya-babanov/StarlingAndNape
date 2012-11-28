package Engines
{
	import GameObjects.BodyExt;
	
	import VisualGameElements.AimSimpleGreenDarkDisk;
	import VisualGameElements.DiskSimpleGrey;
	
	import com.greensock.TweenLite;
	
	import flash.external.ExternalInterface;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	import starling.core.Starling;
	import starling.display.Stage;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;

	public class BodyEngine
	{
		[Embed(source="./Particles/TestParticle4.png")]
		private var ParticleTexture:Class;
		
		[Embed(source="./Particles/TestParticle4.pex", mimeType="application/octet-stream")]
		private var ParticleXML:Class;
		
		private var stage:Stage;
		private var space:Space;
		private var hand:PivotJoint;
		
		public var aimBodies:CbType;
		public var diskBodies:CbType;
		
		public var floor:Body;
		public var borders:Body;
		public var top:Body;
		
		public var aimsToDelete:Vector.<Body>;
		public var explodedDisks:Vector.<BodyExt>;
		public var leavedDisks:Vector.<BodyExt>;

		public function BodyEngine(starlingStage:Stage, napeSpace:Space, handSpace:PivotJoint)
		{
			stage = starlingStage;
			space = napeSpace;
			hand = handSpace;
			
			aimsToDelete = new Vector.<Body>();
			explodedDisks = new Vector.<BodyExt>();
			leavedDisks = new Vector.<BodyExt>();
			
			configureSpaceListenesr();
		}
		
		private function configureSpaceListenesr():void
		{
			aimBodies = new CbType();
			diskBodies = new CbType();
			var beginCollideListener:InteractionListener = 
				new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, aimBodies, diskBodies, onBeginDiskAndAimCollision);
			space.listeners.add(beginCollideListener);
		}
		
		private function onBeginDiskAndAimCollision(cb:InteractionCallback):void
		{
			if(cb.int1 is BodyExt){
				aimsToDelete.push(cb.int1 as BodyExt);
				
			}	
			if(cb.int2 is BodyExt){
				(cb.int2 as BodyExt).numberOfCollisions++;
				if((cb.int2 as BodyExt).numberOfCollisions > 5)
					explodedDisks.push(cb.int2);
			}
		}	
		
		public function addBorders():void{
			borders = new Body(BodyType.STATIC);
			floor = new Body(BodyType.STATIC);
			top = new Body(BodyType.STATIC);
			borders.shapes.add(new Polygon(Polygon.rect(0,stage.stageHeight,stage.stageWidth,100)));
			borders.shapes.add(new Polygon(Polygon.rect(-100,0,100, stage.stageHeight)));
			borders.shapes.add(new Polygon(Polygon.rect(stage.stageWidth,0, 100, stage.stageHeight)));
			top.shapes.add(new Polygon(Polygon.rect(0,-100, stage.stageWidth, 100)));
			floor.cbTypes.add(diskBodies);
			borders.cbTypes.add(diskBodies);
			borders.space = space;
			floor.space = space;
			top.space = space;
		}
		
		public function addSimpleDisk(x:Number, y:Number, type:String = "DiskSimpleGrey"):void
		{
			var bodyForDisk:BodyExt;
			var particleForDisk:PDParticleSystem;
			
			switch(type){
				case "DiskSimpleGrey":
					bodyForDisk = new BodyExt(BodyType.DYNAMIC, new Vec2(x, y));
					var circle:Circle = new Circle(32, null, new Material(1.3));
					bodyForDisk.circleShape = circle;
					bodyForDisk.gravMass = 0;
					bodyForDisk.shapes.add(new Circle(32, null, new Material(1.3)));
					bodyForDisk.graphic = new DiskSimpleGrey();
					bodyForDisk.cbTypes.add(diskBodies);
					particleForDisk = new PDParticleSystem(XML(new ParticleXML()), Texture.fromBitmap(new ParticleTexture()));
					particleForDisk.start();
					break;
				default:
					
					break;
			}
			bodyForDisk.particles = particleForDisk;
			bodyForDisk.graphicUpdate = updateDiskGraphic;
			bodyForDisk.space = space;
			stage.addChild(particleForDisk);
			stage.addChild(bodyForDisk.graphic); 
			Starling.juggler.add(particleForDisk);
		}
		
		public function addSimpleAim(x:Number, y:Number, type:String = "AimSimpleGreenDarkDisk"):void
		{
			var bodyForAim:BodyExt;
			switch(type){
				case "AimSimpleGreenDarkDisk":
					bodyForAim = new BodyExt();
					bodyForAim.position.x = x;
					bodyForAim.position.y = y;
					bodyForAim.cbTypes.add(aimBodies);
					var disk:Circle = new Circle(12,null,Material.rubber());
					disk.body = bodyForAim;
					bodyForAim.graphic = new AimSimpleGreenDarkDisk();
					break;
				default:
					
					break;
			}
		/*	aimBox.shapes.add(new Polygon(Polygon.box(32,32)));
			aimBox.graphic = new LittleBox();*/
			//bodyForAim.graphicUpdate = updateAimGraphic;
			bodyForAim.space = space;
			stage.addChild(bodyForAim.graphic);
		}
		
		private function updateAimGraphic(b:BodyExt):void
		{
			b.graphic.x = b.position.x;
			b.graphic.y = b.position.y;
			b.graphic.rotation = b.rotation;
			
			/*if (b.graphic.y < -100) {
				aimsToDelete.push(b);
			}*/
		}
		
		private function updateDiskGraphic(b:BodyExt):void
		{
			b.graphic.x = b.particles.emitterX = b.position.x;
			b.graphic.y = b.particles.emitterY = b.position.y;
			b.graphic.rotation = b.rotation;
			if (b.graphic.y < -200) {
				leavedDisks.push(b);
			}
		}
		
		private function updateGraphicWithoutRotation(b:BodyExt):void
		{
			b.graphic.x = b.position.x;
			b.graphic.y = b.position.y;
		}
		
		public function deleteAim(b:BodyExt):void{
			stage.removeChild(b.graphic);
			b = null;
		}
		
		public function deleteDisk(b:BodyExt):void{
			trace("deleteStarted");
			space.bodies.remove(b);
			stage.removeChild(b.graphic);
			Starling.juggler.remove(b.particles);
			stage.removeChild(b.particles);
			b = null;
			trace("delete");
		}
		
		public function removeDeletedBodies():void
		{
			for each (var aimBody:BodyExt in aimsToDelete){
				if(hand.body2 == aimBody)
					hand.active = false;
				space.bodies.remove(aimBody);
				TweenLite.to(aimBody.graphic,0.3,{alpha: 0, scaleX: 3, scaleY: 3, onComplete: deleteAim, onCompleteParams: [aimBody]});
			}
			for each (var explodedBody:BodyExt in explodedDisks){
				if(hand.body2 == explodedBody)
					hand.active = false;
				explodedBody.cbTypes.clear();
				TweenLite.to(explodedBody.circleShape, 0.25, {radius: explodedBody.circleShape.radius + 60});
				TweenLite.to(explodedBody.particles, 0.2, {alpha: 0});
				TweenLite.to(explodedBody.graphic,0.3,{alpha: 0,scaleX: 4, scaleY: 4, onComplete:deleteDisk, onCompleteParams: [explodedBody]});
			}
			for each (var leavedBody:BodyExt in leavedDisks){
				if(hand.body2 == leavedBody)
					hand.active = false;
				deleteDisk(leavedBody);
			}
			aimsToDelete.splice(0, aimsToDelete.length);
			explodedDisks.splice(0, explodedDisks.length);
			leavedDisks.splice(0, leavedDisks.length);
		}
	}
	
}