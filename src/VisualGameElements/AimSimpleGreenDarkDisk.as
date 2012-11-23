package VisualGameElements
{
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.extensions.Particle;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	public class AimSimpleGreenDarkDisk extends Sprite
	{
		[Embed(source="./EmbedElements/LittleDisk.png")]
		private var LittleDiskImg:Class;
		
		/*	
		[Embed(source="./Particles/TestParticle.png")]
		private var ParticleTexture:Class;
		
		[Embed(source="./Particles/TestParticle.pex", mimeType="application/octet-stream")]
		private var ParticleXML:Class;
		*/
		
		private var particle:PDParticleSystem;
		private var image:Image;
		
		public function set color(value:uint):void
		{
			if(image)
				image.color = value;
		}
		public function get color():uint
		{
			if(image)
				return image.color;
			else 
				return null;
		}
		public function AimSimpleGreenDarkDisk()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			image = Image.fromBitmap(new LittleDiskImg());
			//image.color = Color.GREEN;
			addChild(image);
			pivotX = width >> 1;
			pivotY = height >> 1;
		}
	}
}