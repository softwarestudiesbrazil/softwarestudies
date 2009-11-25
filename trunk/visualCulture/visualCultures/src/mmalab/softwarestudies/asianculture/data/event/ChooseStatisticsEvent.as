package mmalab.softwarestudies.asianculture.data.event
{
	import flash.events.Event;
	
	public class ChooseStatisticsEvent extends Event
	{
		public static const CHOOSE_STATS_EVENT: String = "chooseStatsEvent";
		
		public var numStats:int;
		public var maxNumObjects:int;

		public function ChooseStatisticsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}