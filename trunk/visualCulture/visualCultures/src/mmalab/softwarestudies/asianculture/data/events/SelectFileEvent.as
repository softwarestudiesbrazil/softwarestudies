package mmalab.softwarestudies.asianculture.data.events
{
	import flash.events.Event;
	
	public class SelectFileEvent extends Event
	{
		public static const DATABASE_FILE: String = "databaseFile";
		public static const IMAGE_FOLDER: String = "imageFolder";
		
		public var nativePath:Boolean;
		public var path:String;
		
		public function SelectFileEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}