package VisualGameElements
{
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.extensions.Particle;
	import starling.textures.Texture;
	
	public class SimpleBall extends Sprite
	{
		[Embed(source="./EmbedElements/SimpleBall.png")]
		private var SimpleBallImage:Class;
		
		[Embed(source="./Particles/TestParticle.png")]
		private var ParticleTexture:Class;
		
		[Embed(source="./Particles/TestParticle.pex", mimeType="application/octet-stream")]
		private var ParticleXML:Class;
		
		
		private var particle:PDParticleSystem;
		
		public function SimpleBall()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addChild(Image.fromBitmap(new SimpleBallImage()));
			pivotX = width >> 1;
			pivotY = height >> 1;
		}
	}
}