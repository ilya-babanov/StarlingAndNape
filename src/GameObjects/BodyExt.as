package GameObjects
{
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	
	import starling.extensions.PDParticleSystem;
	
	public class BodyExt extends Body
	{
		public var particles:PDParticleSystem;
		public var numberOfCollisions:int;
		
		private var _circleShape:Circle;
		public function get circleShape():Circle{
			return _circleShape;
		}
		public function set circleShape(value:Circle):void{
			_circleShape = value;
			_circleShape.body = this;
		}
		
		
		override public function BodyExt(type:BodyType=null, position:Vec2=null)
		{
			super(type, position);
		}


	}
}