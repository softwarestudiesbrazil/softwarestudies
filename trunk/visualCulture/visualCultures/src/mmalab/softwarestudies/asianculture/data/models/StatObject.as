package mmalab.softwarestudies.asianculture.data.models
{
	public class StatObject
	{
		private var _objID:int;
		private var _objName:String;
		private var stats:Array;
		
		
		public function StatObject(id:int, name:String)
		{
			this._objID = id;
			this._objName = name;
		}
		
		public function addStat(stat:Statistic) {
			stats.push(stat);
		}

		public function get objID():int
		{
			return _objID;
		}

		public function set objID(value:int):void
		{
			_objID = value;
		}

		public function get objName():String
		{
			return _objName;
		}

		public function set objName(value:String):void
		{
			_objName = value;
		}


	}
}