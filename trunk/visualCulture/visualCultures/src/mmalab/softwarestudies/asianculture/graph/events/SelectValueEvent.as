package mmalab.softwarestudies.asianculture.graph.events
{
	import flash.events.Event;
	
	public class SelectValueEvent extends Event
	{
		public static const VALUE_SELECTED: String = "selectValueEvent";
        
        
        public var selectedValues : Array;
        
		public function SelectValueEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}