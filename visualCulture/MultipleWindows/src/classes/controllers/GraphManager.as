package classes.controllers
{
	import classes.models.Dataset;

	[Bindable]
	public class GraphManager
	{
		public var selectedValue : int;
		public var data:Dataset = new Dataset();
		
		public function GraphManager()
		{
			selectedValue = 0;
			trace("karioca");
		}
		
		public function setSelectedValue(idx:int):void {
			selectedValue = idx;
			trace("tapioca");
		}
	}
}