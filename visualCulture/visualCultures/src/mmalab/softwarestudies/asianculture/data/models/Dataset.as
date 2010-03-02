package mmalab.softwarestudies.asianculture.data.models
{
	

	[Bindable]
	public class Dataset
	{
		public var values:Array;
		public var number:int;
		
		public function Dataset(values:Array) {
			if (!values)
				values = new Array();
			this.values = values;
			if (values)
				this.number = values.length;
		}
		
		public function addValue(value:Object):void {
			this.values.push(value);
			this.number++;
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