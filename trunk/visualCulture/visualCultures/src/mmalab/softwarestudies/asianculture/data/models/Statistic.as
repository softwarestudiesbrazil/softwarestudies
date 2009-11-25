package mmalab.softwarestudies.asianculture.data.models
{
	public class Statistic
	{
		
		private var _id:int;
		private var _name:String;

		public function Statistic(id:int, name:String)
		{
			this._id = id;
			this._name = name;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get id():int
		{
			return _id;
		}

		public function set id(value:int):void
		{
			_id = value;
		}

	}
}