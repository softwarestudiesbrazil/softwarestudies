package mmalab.softwarestudies.asianculture.graph.models
{
	public class GraphType extends Object
	{
		private var _name:String;
		private var _dim:int;
		private var _axisLabels:Array = new Array();
		
		public function GraphType(name:String, dim:int, axisLabels:Array)
		{
			this._name = name;
			this._dim = dim;
						
			var axis:Object;
			for each (var label:String in axisLabels) {
				axis = new Object();
				axis.axisName = label;
				this._axisLabels.push(axis);
			}
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get dim():int
		{
			return _dim;
		}

		public function set dim(value:int):void
		{
			_dim = value;
		}

		public function get axisLabels():Array
		{
			return _axisLabels;
		}

		public function set axisLabels(value:Array):void
		{
			_axisLabels = value;
		}
	}
}