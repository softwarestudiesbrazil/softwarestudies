package mmalab.softwarestudies.asianculture.data.events
{
	import flash.events.Event;
	
	public class ChangeDatabaseEvent extends Event
	{
		public static const CHANGE_DB_EVENT: String = "changeDatabaseEvent";
		
		public var dbPath:String;
		
		public function ChangeDatabaseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}