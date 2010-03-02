package mmalab.softwarestudies.asianculture.data.events
{
	import flash.events.Event;
	
	public class NextIterationEvent extends Event
	{
		public static const NEXT_ITERATION_EVENT:String = "nextIterationEvent";
		
		public function NextIterationEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}