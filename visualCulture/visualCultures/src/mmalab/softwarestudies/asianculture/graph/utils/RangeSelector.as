package mmalab.softwarestudies.asianculture.graph.utils
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import mx.charts.chartClasses.*;
	import mx.controls.*;
	
	public class RangeSelector extends ChartElement {
		
		private var startX:Number = 0;
		private var startY:Number = 0;
		
		public var rectX:Number = 0;
		public var rectY:Number = 0;
		public var rectWidth:Number = 0;
		public var rectHeight:Number = 0;
		
		private var bSet:Boolean = false;
		
		private var bTracking:Boolean = false;
		
		private var _crosshairs:Point;
		
		public function RangeSelector():void
		{
			super();
			addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,startTracking);
			
			addEventListener(MouseEvent.MOUSE_MOVE,updateCrosshairs);
			addEventListener(MouseEvent.ROLL_OUT,removeCrosshairs);
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			
			var g:Graphics = graphics;
			g.clear();
			
			g.moveTo(0,0);
			g.lineStyle(0,0,0);
			g.beginFill(0,0);
			g.drawRect(0,0,unscaledWidth,unscaledHeight);
			g.endFill();
			
			if(_crosshairs != null)
			{
				g.lineStyle(1,0x005364,.5);
				
				g.moveTo(0,_crosshairs.y);
				g.lineTo(unscaledWidth,_crosshairs.y);
				
				g.moveTo(_crosshairs.x,0);
				g.lineTo(_crosshairs.x,unscaledHeight);                
			}
			
			if(bSet)
			{
				g.moveTo(rectX,rectY);                
				g.beginFill(0xEEEE22,.2);
				g.lineStyle(1,0xBBBB22);

				//g.drawRect(rectX, 0, rectWidth, unscaledHeight);
				
				// uncomment this and comment the above line to draw a rectangle.
				g.drawRect(rectX, rectY, rectWidth, rectHeight);
				
				g.endFill();
				
			}
		}
		
		
		
		override public function mappingChanged():void
		{
			invalidateDisplayList();
		}
		
		private function startTracking(e:MouseEvent) :void
		{
			bTracking = true;
			parent.addEventListener(MouseEvent.RIGHT_MOUSE_UP,endTracking,true);
			parent.addEventListener(MouseEvent.MOUSE_MOVE,track,true);
			
			startX = mouseX;
			startY = mouseY;
			bSet = false;
		}
		
		private function track(e:MouseEvent):void {
			if(bTracking == false)
				return;
			bSet = true;
			updateTrackBounds();
			e.stopPropagation();
		}
		
		private function endTracking(e:MouseEvent):void
		{
			bTracking = false;
			parent.removeEventListener(MouseEvent.RIGHT_MOUSE_UP,endTracking,true);
			parent.removeEventListener(MouseEvent.MOUSE_MOVE,track,true);
			e.stopPropagation();
			updateTrackBounds();
		}
		
		private function updateCrosshairs(e:MouseEvent):void
		{
			_crosshairs = new Point(mouseX,mouseY);
			invalidateDisplayList();
		}
		private function removeCrosshairs(e:MouseEvent):void
		{
			_crosshairs = null;
			invalidateDisplayList();
		}
		private function updateTrackBounds():void
		{
			rectX = Math.min(startX, mouseX);
			
			// replace with commented code to draw a rectangle.
			rectY = Math.min(startY, mouseY);//0;
			
			rectWidth = Math.abs(startX-mouseX);
			
			// replace with commented code to draw a rectangle.
			rectHeight = Math.abs(startY-mouseY);//unscaledHeight;
			
			invalidateProperties();
			invalidateDisplayList();
			
		}
		
	}
}
