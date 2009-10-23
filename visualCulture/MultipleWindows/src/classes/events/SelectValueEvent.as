package classes.events
{
	import flash.events.Event;
	
	public class SelectValueEvent extends Event
	{
		public static const VALUE_SELECTED: String = "selectValueEvent";
        
        
        public var selectedValue : int;
        
		public function SelectValueEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			trace("toundra");
			super(type, bubbles, cancelable);
		}
	}
}