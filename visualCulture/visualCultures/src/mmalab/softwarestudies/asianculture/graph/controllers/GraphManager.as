package mmalab.softwarestudies.asianculture.graph.controllers
{
	import mmalab.softwarestudies.asianculture.data.input.SQLiteReader;
	import mmalab.softwarestudies.asianculture.data.models.Dataset;
	import mmalab.softwarestudies.asianculture.data.models.Statistic;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;

	[Bindable]
	public class GraphManager
	{
		/**
		 * The graph values selected by the user 
		 */
		public var selectedValues : Array;

		public var databasePath:String;
		
		public var data:Dataset;

		public var statsList:Array;
		public var fullStatsList:Array;
		
		public var graphs:ArrayCollection;
		
		private var dbReader:SQLiteReader;
		private var stId:Boolean = false;
		
		public function GraphManager() {
			selectedValues = null;
		}
		
		public function setSelectedValue(idx:Array):void {
			selectedValues = idx;
		}
		
		public function setDatabase(databasePath:String):void {
			this.databasePath = databasePath;

			// Close previous connection
			if (dbReader != null)
				dbReader.closeConnection();

			dbReader = new SQLiteReader(this.databasePath);
			dbReader.connect();
			fullStatsList = dbReader.getStatsList(null);
			trace("fullstatslist");
		}
		
		/**
		 * 
		 * @param _statsList
		 * 
		 */
		public function setSelectedStatSet(_statsList:Array, maxNumObjects:int):void {
			if (dbReader == null) {
				dbReader = new SQLiteReader(this.databasePath);
				dbReader.connect();
			}
			
			this.statsList = _statsList;
			
			// retrieve dataset of specified statistics
			this.data = dbReader.getStatObjects(statsList, maxNumObjects);
			
			// Using ObjectProxy instead of plain Object prevents to have the warning:
			// unable to bind to property ‘XXX’ on class ‘Object’ (class is not an IEventDispatcher)
			var graph:ObjectProxy;
			graphs = new ArrayCollection();
			for (var i:int=0; i<_statsList.length && _statsList.length>1; i += 2) {
				graph = new ObjectProxy();
				graph.statIdx = (statsList[i] as Object).name;
				graph.statIdy = (statsList[i+1] as Object).name;
				graphs.addItem(graph);
				graph = null;
				
				// discard last stat if number chosen is impair
				if (i == _statsList.length-3)
					break;
			}
		}
		
		/**
		 * Connect to the specified database and creates a Dataset of a number of statistics chosen randomly.
		 * @param numStats number of Statistics to choose
		 * @param maxNumObjects maximum number of object in the dataset
		 * @param databasePath path to the database
		 * 
		 */
		public function setRandomSet(numStats:int):void {

			if (dbReader == null) {
				dbReader = new SQLiteReader(this.databasePath);
				dbReader.connect();
			}
			
			var randomStat:int;
			
			// clear previous statistic list
			var statItem:Statistic;
			for (var i:int=0; statsList != null && i<statsList.length; i++) {
				statsList[i] = null;
				delete statsList[i]
			}
			
			// create random statistics list of length numStats
			statsList = new Array();
			for (i=0; i<numStats; i++) {
				randomStat = Math.floor( Math.random() * fullStatsList.length);
				statItem = new Statistic(fullStatsList[randomStat].id, fullStatsList[randomStat].name);
				statsList.push(statItem);
			}
/*
			// retrieve dataset of specified statistics
			this.data = dbReader.getStatObjects(statsList, maxNumObjects);
			
			// Using ObjectProxy instead of plain Object prevents to have the warning:
			// unable to bind to property ‘XXX’ on class ‘Object’ (class is not an IEventDispatcher)
			var graph:ObjectProxy;
			graphs = new ArrayCollection();
			for (i=0; i<statsList.length; i += 2) {
				graph = new ObjectProxy();
				graph.statIdx = (statsList[i] as Statistic).name;
				graph.statIdy = (statsList[i+1] as Statistic).name;
				graphs.addItem(graph);
				graph = null;
			}
*/		}
				
		/////////////////////
		// private method
		/////////////////////
		private function mixArray(array:Array):Array {
			var _length:Number = array.length, mixed:Array = array.slice(), rn:Number, it:Number, el:Object;
			for (it=0; it<_length; it++) {
				el = mixed[it];
				mixed[it] = mixed[rn = Math.floor(Math.random() * _length)];
				mixed[rn] = el;
			}
			return mixed;
		}
	}
}