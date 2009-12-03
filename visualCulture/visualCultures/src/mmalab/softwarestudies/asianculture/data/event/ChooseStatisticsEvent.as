package mmalab.softwarestudies.asianculture.data.event
{
	import flash.events.Event;
	
	public class ChooseStatisticsEvent extends Event
	{
		public static const CHOOSE_STATS_EVENT: String = "chooseStatsEvent";
		public static const CHOOSE_RANDOM_STATS_EVENT: String = "chooseRandomStatsEvent";
		
		public var numStats:int;
		public var maxNumObjects:int;

		public var statsList:Array;

		public function ChooseStatisticsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}