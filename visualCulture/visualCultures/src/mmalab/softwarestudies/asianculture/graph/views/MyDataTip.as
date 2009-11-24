package mmalab.softwarestudies.asianculture.graph.views
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import mx.charts.chartClasses.DataTip;
	
	public class MyDataTip extends DataTip
	{
		public function MyDataTip()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);
			
			this.setStyle("textAlign","left");
			this.setStyle("color", "0xCCCCCC");
			var g:Graphics = graphics; 
			g.clear();  
			var m:Matrix = new Matrix();
			m.createGradientBox(w+60,h,0,0,0);
			g.beginGradientFill(GradientType.LINEAR,[0x00FF00,0xFFFFFF],
				[.1,1],[0,255],m,null,null,0);
			g.drawRect(-30,0,w+60,h);
			g.endFill(); 
		}
	}
}