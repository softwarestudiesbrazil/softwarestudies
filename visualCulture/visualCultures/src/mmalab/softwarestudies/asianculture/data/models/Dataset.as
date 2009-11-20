package mmalab.softwarestudies.asianculture.data.models
{
	[Bindable]
	public class Dataset
	{
		public var values:Array = new Array();
		
		public var min:Array = new Array();
		public var max:Array = new Array();

		public function Dataset(values:Array) {
			this.values = values;
		}
		
/*		public function Dataset() {
			var obj:Object = new Object();
			obj.stat1 = 10;
			obj.stat2 = 100;
			values.push(obj);
			obj = new Object();
			obj.stat1 = 15;
			obj.stat2 = 150;
			values.push(obj);
			obj = new Object();
			obj.stat1 = 40;
			obj.stat2 = 140;
			values.push(obj);
			obj = new Object();
			obj.stat1 = 30;
			obj.stat2 = 200;
			values.push(obj);
		}*/
	}
}