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
	
	import mx.controls.Image;
	
	import spark.primitives.BitmapImage;
	
	public class ImageLoader extends EventDispatcher
	{

		public var counter:int = 0;
		
		//
		// Construction
		//
		public function ImageLoader()
		{
		}
		
		
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
			
			/*
			These consume a lot of memory:
			Image, BitmapImage, Loader, SWFLoader, URLLoader
			Dedicated to the memory of the same size to that required for storing data of pixels
			*/
			var folder: File = new File( path );
			if ( folder.isDirectory )
			{
				var files: Array = folder.getDirectoryListing( );
//				for (var i:int=0; i<800; i++) {
				for each( var file: File in files ) {
//					var file:File = files[1]; {
					if ( ! file.isDirectory && file.extension == "jpeg" || file.extension == "jpg" || file.extension == "png" ) {
						var urlLoader: URLLoader = new URLLoader( );
						urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
						urlLoader.addEventListener(Event.COMPLETE, onLoadingComplete );
						urlLoader.load( new URLRequest(file.url) );
					}
				}
			} //}}
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
		
		
		//
		// Internal logic
		//		
		private function onLoadingComplete( e: Event ):void
		{
			var dispLoader: Loader = new Loader( );

			dispLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onParsingComplete );
			dispLoader.loadBytes( e.target.data );
		}
		private function onParsingComplete( e: Event ):void
		{
			var img: BitmapImage = new BitmapImage( );
			img.source = (e.target.content as Bitmap).bitmapData;
			_images.push( img );
			counter++;
		}
		
		
		private function onImageLoaded( e:Event ):void
		{
			var img: Image = e.target as Image;			
			img.removeEventListener( Event.COMPLETE, onImageLoaded );
			
			_images.push( img );
		}
		
		
		//
		// Internal Properties
		//
		private var _images: Array = new Array;
	}
}