package mmalab.softwarestudies.asianculture.data.event
{
	import flash.events.Event;
	
	public class ChooseStatisticsEvent extends Event
	{
		public static const CHOOSE_STATS_EVENT: String = "chooseStatsEvent";
		public static const CHOOSE_RANDOM_STATS_EVENT: String = "chooseRandomStatsEvent";
		public static const CHOOSE_SEQUENCE_STATS_EVENT: String = "chooseSequentialStatsEvent";
		
		public var page:int;
		public var numStats:int;
		public var maxNumObjects:int;

		public var statsList:Array;

		public function ChooseStatisticsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}