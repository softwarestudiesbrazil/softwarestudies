package mmalab.softwarestudies.asianculture.graph.events
{
	import flash.events.Event;
	
	public class HistoSelectionEvent extends Event
	{
		public static const HISTO_SELECTION_EVENT: String = "histoSelectionEvent";
		
		public var statName:String;
		public var selectedRanges:Array;
		
		public function HistoSelectionEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}