package mmalab.softwarestudies.asianculture.graph.events
{
	import flash.events.Event;
	
	public class HistoFilterEvent extends Event
	{
		public static const HISTO_FILTER_EVENT:String = "histoFilterEvent";
		
		public function HistoFilterEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}