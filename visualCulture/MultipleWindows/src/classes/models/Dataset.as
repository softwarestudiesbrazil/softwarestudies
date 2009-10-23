package classes.models
{
	[Bindable]
	public class Dataset
	{
		public var values:Array = new Array();
		
		public function Dataset()
		{
			values.push(10);
			values.push(15);
			values.push(45);
			values.push(30);
		}
	}
}