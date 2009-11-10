package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.System;
	
	import spark.primitives.BitmapImage;
	
	public class ImageLoader extends EventDispatcher
	{
		
		public var counter:int = 0;
		public var finished:int = 0;
		
		private var files:Array;
		
		private var offset:int = 0;
		private const BATCH:int = 100;
		
/*		private var myFile:File;
		private var myStream:FileStream = new FileStream ();
*/		
		//
		// Construction
		//
		public function ImageLoader()
		{
/*			myStream.open( myFile, FileMode.WRITE);
			
			myFile = new File (File.applicationDirectory.nativePath + File.separator + "config2.txt");
			myStream.writeUTF("if I rule the world...");
			myStream.close();
*/		}
		
		//
		// Properties
		//
		public function get images( ): Array
		{	
			return _images;
		}
		
		
		//
		// Methods
		//
		public function Load( path: String ):void
		{
			counter = 0;
			offset = 0;
			/*
			These consume a lot of memory:
			Image, BitmapImage, Loader, SWFLoader, URLLoader
			Dedicated to the memory of the same size to that required for storing data of pixels
			*/
			var folder: File = new File( path );
			if ( folder.isDirectory )
			{
				files = folder.getDirectoryListing( );

				var loadingFinished:Boolean = false;
				var loadingBegun:Boolean = false;
				/*
				while (true) {
					if ((!loadingFinished && (finished == BATCH)) || ((finished == 0)&& !loadingBegun) ) {
						finished = 0;
						loadingFinished = batchLoad2();
					}
					if (loadingFinished)
						break;
				}
				*/
				batchLoad2();
				

/*				var timer:Timer = new Timer(2000, Math.ceil(files.length/BATCH));
				timer.addEventListener(TimerEvent.TIMER, batchLoad);
				timer.start();
*/			}
		}
		
		
		/**
		 * References
		 * 		http://blog.empiregpservices.com/pos...n-local-images
		 */
		public function Delete( ):void
		{
			_images.splice( 0, _images.length );
			
			System.gc();
		}
		
		private function batchLoad(e:TimerEvent):void {
			var file:File;
			var urlLoader: URLLoader;
			for (var i:int=offset; i<offset+BATCH && i<files.length; i++)  {
				//				for each( var file: File in files ) {
				file = files[i]; 
				if ( ! file.isDirectory && file.extension == "jpeg" || file.extension == "jpg" || file.extension == "png" ) {
					urlLoader = new URLLoader( );
					urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
					urlLoader.addEventListener(Event.COMPLETE, onLoadingComplete );
					urlLoader.load( new URLRequest(file.url) );
					counter++;
				}
			trace ("i: "+i);
			}
			trace ("counter: "+counter);
			offset += BATCH;
		}

		private function batchLoad2():Boolean {
			var file:File;
			var urlLoader: URLLoader;
			//for (var i:int=offset; i<offset+BATCH && i<files.length; i++)  {
				//				for each( var file: File in files ) {
			var i:int = counter;
				file = files[i]; 
				if ( ! file.isDirectory && file.extension == "jpeg" || file.extension == "jpg" || file.extension == "png" ) {
					urlLoader = new URLLoader( );
					urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
					urlLoader.addEventListener(Event.COMPLETE, onLoadingComplete );
					urlLoader.load( new URLRequest(file.url) );
					trace("load "+i);
					counter++;
				//}
				trace ("i: "+i);
			}
			trace ("counter: "+counter);
			offset += BATCH;
			if (i >= files.length)
				return true; // loading finished
			return false;
		}
		//
		// Internal logic
		//		
		private function onLoadingComplete( e: Event ):void
		{
			var dispLoader: Loader = new Loader( );
			
			dispLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onParsingComplete);
			dispLoader.loadBytes( e.currentTarget.data );
			trace("loadingComplete");
		}
		private function onParsingComplete( e: Event ):void
		{
			//img:Image = new Image();
			var img: BitmapImage = new BitmapImage( );
			img.source = (e.currentTarget.content as Bitmap).bitmapData;
			_images.push( img );
			finished++;
			trace("parsingComplete");
			if(counter < files.length)
			{
				batchLoad2();
			}
			else
				dispatchEvent(new Event(Event.COMPLETE));
			
			trace("parsing really Complete");
		}
		
		
/*		private function onImageLoaded( e:Event ):void
		{
			var img: Image = e.target as Image;			
			img.removeEventListener( Event.COMPLETE, onImageLoaded );
			
			_images.push( img );
		}
*/		
		
		//
		// Internal Properties
		//
		private var _images: Array = new Array;
	}
}