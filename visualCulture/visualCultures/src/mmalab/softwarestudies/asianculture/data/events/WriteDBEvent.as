package mmalab.softwarestudies.asianculture.data.events
{
	import flash.events.Event;
	
	public class WriteDBEvent extends Event
	{
		public static const WRITE_DB_EVENT:String = "writeDBEvent";
		public static const WRITE_DB_COMPLETE_EVENT:String = "writeDBCompleteEvent"
		
		public var filePath:String;
		public var data:Array;
		
		public function WriteDBEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}