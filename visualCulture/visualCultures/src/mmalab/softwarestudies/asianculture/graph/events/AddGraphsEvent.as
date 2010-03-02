package mmalab.softwarestudies.asianculture.graph.events
{
	import flash.events.Event;
	
	public class AddGraphsEvent extends Event
	{
		public static const ADD_GRAPHS_EVENT:String = "addGraphsEvent";

		public var graphList:Array;
		
		public function AddGraphsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}