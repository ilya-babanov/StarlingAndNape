package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import net.hires.debug.Stats;
	import starling.core.Starling;
	
	[SWF(width="1280", height="800", frameRate="60", backgroundColor="#000000")]
	public class StarlingApp extends Sprite
	{
		private var starlingEngine:Starling;
		
		public function StarlingApp()
		{
			addChild(new Stats());
			
			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			starlingEngine = new Starling(AppMain, stage, null, null);
			
			//starlingEngine.antiAliasing = 1;
			starlingEngine.start();
		}
	}
}