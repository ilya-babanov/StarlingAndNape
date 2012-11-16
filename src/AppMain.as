package 
{
	import GameObjects.BodyExt;
	
	import VisualGameElements.SimpleBall;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	
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
		
		[Embed(source="./EmbedElements/SimpleBall.png")]
		private var SimpleBallImage:Class;
		
		[Embed(source="./Particles/TestParticle4.png")]
		private var ParticleTexture:Class;
		
		[Embed(source="./Particles/TestParticle4.pex", mimeType="application/octet-stream")]
		private var ParticleXML:Class;
		
		public function AppMain()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			space = new Space(new Vec2(0,3000));
			
			var borders:Body = new Body(BodyType.STATIC);
			borders.shapes.add(new Polygon(Polygon.rect(0,800,1280,50)));
			borders.shapes.add(new Polygon(Polygon.rect(0,0,100, 800)));
			borders.shapes.add(new Polygon(Polygon.rect(1270,0, 150, 800)));
			borders.space = space;
			
			/*	
			var wall:Body = new Body(BodyType.STATIC);
			wall.shapes.add(new Polygon(Polygon.rect(0,0,100, 800)));
			wall.shapes.add(new Polygon(Polygon.rect(1270,0, 150, 800)));
			wall.space = space;
			*/
			
			hand = new PivotJoint(space.world,space.world,new Vec2(),new Vec2());
			hand.active = false;
			hand.stiff = false;
			hand.space = space;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.stage.addEventListener(TouchEvent.TOUCH, onTouch);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyU);
		}
		
		private function onKeyU(e:KeyboardEvent):void
		{
			shiftKey = false;
		}
		
		private var shiftKey:Boolean = false;
		private function onKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode==Keyboard.SHIFT){
				shiftKey = true;
			}
		}
		
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
						if(shiftKey)
							addSimpleBall(touch.globalX,touch.globalY);
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
			
			/*var ball:SpriteEx = touch.target.parent as SpriteEx;
			if(ball){
				ball.x = touch.globalX - (ball.width>>1);
				ball.y = touch.globalY - (ball.height>>1);
				ball.particles.emitterX = ball.x + 50;
				ball.particles.emitterY = ball.y + 50;
			}*/
		}
		
		
		private function onTouchMove(touch:Touch):void
		{
			hand.anchor1.setxy(touch.globalX, touch.globalY);
		}
		
		private function addSimpleBallWithParticles(x:Number, y:Number):void
		{
			var bodyForSimpleBall:BodyExt = new BodyExt(BodyType.DYNAMIC, new Vec2(x, y));
			bodyForSimpleBall.shapes.add(new Circle(48, null, new Material(1.3)));
			bodyForSimpleBall.graphic = new SimpleBall();
			
			var particle:PDParticleSystem = new PDParticleSystem(XML(new ParticleXML()), Texture.fromBitmap(new ParticleTexture()));
			particle.start();
			addChild(particle);
			Starling.juggler.add(particle);
			
			bodyForSimpleBall.particles = particle;
			bodyForSimpleBall.graphicUpdate = updateGraphicsWithParticles;
			bodyForSimpleBall.space = space;
			
			addChild(bodyForSimpleBall.graphic); 
			
			/*var ballImage:SpriteEx = new SpriteEx();//Image.fromBitmap(new SimpleBallImage());  //new SimpleBallImage();]
			addChild(ballImage);
			ballImage.addChild(Image.fromBitmap(new SimpleBallImage()));
			ballImage.x = x - (ballImage.width>>1);
			ballImage.y = y - (ballImage.height>>1);
			
				
			var particle:PDParticleSystem = new PDParticleSystem(XML(new ParticleXML()), Texture.fromBitmap(new ParticleTexture()));
			particle.start();
			particle.emitterX = ballImage.x + 50;
			particle.emitterY = ballImage.y + 50;
			addChildAt(particle,0);
			Starling.juggler.add(particle);
			ballImage.particles = particle;
			ballImage.addEventListener(TouchEvent.TOUCH, onTouch);*/
		}
		private function addSimpleBall(x:Number, y:Number):void
		{
			var bodyForSimpleBall:BodyExt = new BodyExt(BodyType.DYNAMIC, new Vec2(x, y));
			bodyForSimpleBall.shapes.add(new Circle(48, null, new Material(1.3)));
			bodyForSimpleBall.graphic = new SimpleBall();
			
			bodyForSimpleBall.graphicUpdate = updateGraphics;
			bodyForSimpleBall.space = space;
			
			addChild(bodyForSimpleBall.graphic); 
		}
		
		private function updateGraphics(b:BodyExt):void
		{
			b.graphic.x = b.position.x;
			b.graphic.y = b.position.y;
			b.graphic.rotation = b.rotation;
		}
		
		private function updateGraphicsWithParticles(b:BodyExt):void
		{
			b.graphic.x = b.particles.emitterX = b.position.x;
			b.graphic.y = b.particles.emitterY = b.position.y;
			b.graphic.rotation = b.rotation;
		}
		
		
		private function onEnterFrame():void
		{
			space.step(1/60);
		}
	}
}