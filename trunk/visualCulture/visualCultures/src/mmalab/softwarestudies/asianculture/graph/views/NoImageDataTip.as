package mmalab.softwarestudies.asianculture.graph.views
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mmalab.softwarestudies.asianculture.Constants;
	
	import mx.charts.chartClasses.DataTip;
	
	public class NoImageDataTip extends DataTip
	{
		private var numLines:int;
		
		public function NoImageDataTip()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);
			this.setStyle("textAlign","left");
			this.setStyle("color", "0xCECFD1");0xCCCCCC
			
			if (this.numChildren > 1)
				this.removeChildAt(1);
			
			numLines = (data.displayText as String).split("<br").length;
			
			var g:Graphics = graphics;
			g.clear();

			g.beginFill(0x212121);
			g.drawRect(0,0,w,numLines*15+10);
			g.endFill();

		}
	}
}