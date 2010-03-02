package mmalab.softwarestudies.asianculture.data.events
{
	import flash.events.Event;
	
	public class SQLiteFillDataEvent extends Event
	{
		public static const SQLITE_FILLDATA_EVENT:String = "sqliteFillDataEvent";
		
		public var percentFinished:int;
		
		public function SQLiteFillDataEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}