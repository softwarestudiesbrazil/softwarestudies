package mmalab.softwarestudies.asianculture.data.models
{
	public class selectedRanges
	{
		private var _statName:String;
		private var _statId:int;
		private var _min;
		private var _max;
		
		public function selectedRanges()
		{
		}

		public function get statName():String
		{
			return _statName;
		}

		public function set statName(value:String):void
		{
			_statName = value;
		}

		public function get statId():int
		{
			return _statId;
		}

		public function set statId(value:int):void
		{
			_statId = value;
		}

		public function get min()
		{
			return _min;
		}

		public function set min(value):void
		{
			_min = value;
		}

		public function get max()
		{
			return _max;
		}

		public function set max(value):void
		{
			_max = value;
		}


	}
}