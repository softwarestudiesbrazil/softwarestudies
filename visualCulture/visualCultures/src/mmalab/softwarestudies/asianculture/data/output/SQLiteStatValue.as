package mmalab.softwarestudies.asianculture.data.output
{
	public class SQLiteStatValue
	{
		private var _statId:int;
		private var _objId:int;
		private var _type:String;
		private var _value;
		
		public function SQLiteStatValue(statId:int, objId:int, type:String, value)
		{
			_statId = statId;
			_objId = objId;
			_type = type;
			_value = value;
		}

		public function get statId():int
		{
			return _statId;
		}

		public function set statId(value:int):void
		{
			_statId = value;
		}

		public function get objId():int
		{
			return _objId;
		}

		public function set objId(value:int):void
		{
			_objId = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get value()
		{
			return _value;
		}

		public function set value(value):void
		{
			_value = value;
		}



	}
}