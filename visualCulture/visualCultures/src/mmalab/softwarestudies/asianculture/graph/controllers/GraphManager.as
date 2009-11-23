package mmalab.softwarestudies.asianculture.graph.controllers
{
	import mmalab.softwarestudies.asianculture.data.input.SQLiteReader;
	import mmalab.softwarestudies.asianculture.data.models.Dataset;

	[Bindable]
	public class GraphManager
	{
		public var selectedValues : Array;

		public var data:Dataset;
		private var dbReader:SQLiteReader;

		
		private var stId:Boolean = false;
		
		public function GraphManager()
		{
			dbReader = new SQLiteReader("visualCultures.db");
			dbReader.connect();
			data = dbReader.getDataset(new Array("Color7_R", "Correlation", "EdgeAmountSobel", "Entropy"));
			selectedValues = null;
			dbReader.closeConnection();
		}
		
		public function setSelectedValue(idx:Array):void {
			selectedValues = idx;
		}
	}
}