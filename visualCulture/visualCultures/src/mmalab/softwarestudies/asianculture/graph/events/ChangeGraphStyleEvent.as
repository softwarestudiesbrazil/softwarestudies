package mmalab.softwarestudies.asianculture.graph.events
{
	import flash.events.Event;

	public class ChangeGraphStyleEvent extends Event
	{
		public static const CHANGE_GRAPH_STYLE_EVENT:String = "changeGraphStyleEvent";
		public var graphStyle:String;
		
		public function ChangeGraphStyleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}