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
	
	public class ImageDataTip extends DataTip
	{
		private var numLines:int;
		
		public function ImageDataTip()
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
			//var m:Matrix = new Matrix();
			//m.createGradientBox(w+60,h+numLines*25,0,0,0);
			g.beginFill(0x212121);
//			g.beginGradientFill(GradientType.LINEAR,[0x00FF00,0xFFFFFF],
//				[.1,1],[0,255],m,null,null,0);
//			g.drawRect(-30,0,w+60,h+numLines*25);
			g.drawRect(0,0,w,numLines*15+10);
			g.endFill();
			
			// load current image
			//var imageFile:File = File.applicationStorageDirectory.resolvePath(Constants.TINY_IMG_PATH + data.item.name);
			var urlLoader:URLLoader = new URLLoader( );
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, onLoadingComplete );
			urlLoader.load( new URLRequest("file://" + Constants.imagesPath + "/" + data.item.name) );
		}
		
		private function onLoadingComplete( e: Event ):void
		{
			var dispLoader: Loader = new Loader( );
			
			dispLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onParsingComplete);
			dispLoader.loadBytes( e.currentTarget.data );
		}
		
		private function onParsingComplete(e:Event):void {
			
			var container:Sprite = new Sprite();
			this.addChild(container);
			container.y = numLines*15+10; //*15+10
			
			var _bitmap:Bitmap = new Bitmap((e.currentTarget.content as Bitmap).bitmapData);
			container.graphics.beginBitmapFill(_bitmap.bitmapData, null, false, true);
			container.graphics.drawRect(0, 0, _bitmap.width, _bitmap.height);
			container.graphics.endFill();
		}
	}
}