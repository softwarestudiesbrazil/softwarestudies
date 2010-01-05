package mmalab.softwarestudies.asianculture.graph.events
{
	import flash.events.Event;
	
	public class ChangePlotItemsEvent extends Event
	{
		public static const CHANGE_PLOT_ITEMS_EVENT: String = "changePlotItemsEvent";
		
		public var renderer:String;
		
		public function ChangePlotItemsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}