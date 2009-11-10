package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.System;
	
	import mx.events.FlexEvent;
	
	import spark.primitives.BitmapImage;
	
	public class ImageLoader extends EventDispatcher
	{
		
		private var files:Array;

		private var _images: Array = new Array;

		private var offset:int = 0;
		private var batchCounter:int = 0;
		private var imgFilesCounter:int = 0;
		private var finished:int = 0;
		private var batchSize:int = 0;

		public const DEFAULT_BATCH_SIZE:int = 10;
		
/*		private var myFile:File;
		private var myStream:FileStream = new FileStream ();
*/		

		/**
		 * Default Constructor 
		 * 
		 */
		public function ImageLoader(batchSize:int = DEFAULT_BATCH_SIZE)
		{
			this.batchSize = batchSize;
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
		/**
		 * Load all images from the specified path 
		 * @param path
		 * 
		 */		
		public function Load( path: String ):void
		{
			batchCounter = 0;
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
				
				for each (var file:File in files) {
					if ( ! file.isDirectory && file.extension == "jpeg" || file.extension == "jpg" || file.extension == "png" ) {
						imgFilesCounter++;
					}
				}

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
				batchLoad();
				

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
		
		private function batchLoad():void {
			var file:File;
			var urlLoader: URLLoader;
			for (var i:int=offset; i<offset+batchSize && i<files.length; i++)  {
				//				for each( var file: File in files ) {
				file = files[i]; 
				if ( ! file.isDirectory && file.extension == "jpeg" || file.extension == "jpg" || file.extension == "png" ) {
					urlLoader = new URLLoader( );
					urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
					urlLoader.addEventListener(Event.COMPLETE, onLoadingComplete );
					urlLoader.load( new URLRequest(file.url) );
					batchCounter++;
				}
			//trace ("i: "+i);
			}
			trace ("counter: "+batchCounter);
			offset += batchSize;
		}

		private function sequentialLoad():Boolean {
			var file:File;
			var urlLoader: URLLoader;
			//for (var i:int=offset; i<offset+BATCH && i<files.length; i++)  {
				//				for each( var file: File in files ) {
			var i:int = batchCounter;
				file = files[i]; 
				if ( ! file.isDirectory && file.extension == "jpeg" || file.extension == "jpg" || file.extension == "png" ) {
					urlLoader = new URLLoader( );
					urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
					urlLoader.addEventListener(Event.COMPLETE, onLoadingComplete );
					urlLoader.load( new URLRequest(file.url) );
					trace("load "+i);
					batchCounter++;
				//}
				//trace ("i: "+i);
			}
			trace ("counter: "+batchCounter);
			offset += batchSize;
			if (i >= files.length)
				return true; // loading finished
			return false;
		}
		
//****************************
// Internal logic
//****************************
		
		private function onLoadingComplete( e: Event ):void
		{
			var dispLoader: Loader = new Loader( );
			
			dispLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onParsingComplete);
			dispLoader.loadBytes( e.currentTarget.data );
			//trace("loadingComplete");
		}
		private function onParsingComplete( e: Event ):void
		{
			//img:Image = new Image();
			var img: BitmapImage = new BitmapImage( );
			img.source = (e.currentTarget.content as Bitmap).bitmapData;
			_images.push( img );
			finished++;
			trace("finished1 "+finished);
//			if(finished <= batchCounter)
//			{
				trace("finished2 "+finished);
				if (finished%batchSize == 0) {
					batchLoad();
					trace("counter"+batchCounter);
					trace("finished3 "+finished);
				}
//			}
			
				dispatchEvent(new FlexEvent(FlexEvent.UPDATE_COMPLETE));
			
			if (finished >= imgFilesCounter)
				dispatchEvent(new Event(Event.COMPLETE));
		}
		
/*		
		private function onImageLoaded( e:Event ):void
		{
			var img: Image = e.target as Image;			
			img.removeEventListener( Event.COMPLETE, onImageLoaded );
			
			_images.push( img );
		}
*/		
	}
}