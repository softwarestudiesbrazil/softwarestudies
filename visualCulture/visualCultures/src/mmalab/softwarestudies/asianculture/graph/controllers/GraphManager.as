package mmalab.softwarestudies.asianculture.graph.controllers
{
	import mmalab.softwarestudies.asianculture.data.input.SQLiteReader;
	import mmalab.softwarestudies.asianculture.data.models.Dataset;
	import mmalab.softwarestudies.asianculture.data.models.Statistic;

	[Bindable]
	public class GraphManager
	{
		public var selectedValues : Array;

		public var data:Dataset;
		public var statsList:Array;		
		private var dbReader:SQLiteReader;

		private var stId:Boolean = false;
		
		public function GraphManager()
		{
			dbReader = new SQLiteReader("visualCultures.db");
			dbReader.connect();
			
			selectedValues = null;
//			dbReader.closeConnection();
		}
		
		public function setSelectedValue(idx:Array):void {
			selectedValues = idx;
		}
		
		public function setRandomSet(numStats:int, maxNumObjects:int):void {

			var fullStatsList:Array = dbReader.getStatsList(null);
			var randomStat:int;
			
			// clear previous statistic list
			var statItem:Statistic;
			for (var j:int=0; statsList != null && j<statsList.length; j++) {
				statsList[j] = null;
				delete statsList[j]
			}
			
			// create random statistics list of length numStats
			statsList = new Array();
			for (var i:int=0; i<numStats; i++) {
				randomStat = Math.floor( Math.random() * fullStatsList.length);
				statItem = new Statistic(fullStatsList[randomStat].id, fullStatsList[randomStat].name);
				statsList.push(statItem);
			}

			// retrieve dataset of specified statistics
			this.data = dbReader.getStatObjects(statsList, maxNumObjects);
		}
	}
}