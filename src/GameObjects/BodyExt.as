package GameObjects
{
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	
	import starling.extensions.PDParticleSystem;
	
	public class BodyExt extends Body
	{
		public var particles:PDParticleSystem;
		
		override public function BodyExt(type:BodyType=null, position:Vec2=null)
		{
			super(type, position);
		}
	}
}