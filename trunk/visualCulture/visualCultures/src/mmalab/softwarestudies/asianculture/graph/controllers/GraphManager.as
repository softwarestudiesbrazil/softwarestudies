package mmalab.softwarestudies.asianculture.graph.controllers
{
	import flash.filesystem.File;
	
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

		/**
		 * The list of statistics selected for display
		 */
		public var statsList:Array;
		
		/**
		 * The full list of statistics 
		 */		
		public var fullStatsList:Array;
		
		/**
		 * The collection of stats organized by set of graphs (objectProxys) 
		 */
		public var graphs:ArrayCollection;
		
		/**
		 * The graph type (histo, scatter, bubble...) to use 
		 */
		public var graphStyle:String;

		private var dbReader:SQLiteReader;
		private var stId:Boolean = false;
		private var _numCols:int;
		
		public function GraphManager() {
			selectedValues = null;
			_numCols = 10;
		}
		
		/**
		 * Stores an array of selected values to dispatch over all graphs 
		 * @param idx Array of ids
		 * 
		 */
		public function setSelectedValue(idx:Array):void {
			selectedValues = idx;
		}
		
		public function setGraphStyle(value:String):void
		{
			graphStyle = value;
			
			// clear current statistic list
			for (var i:int=0; statsList != null && i<statsList.length; i++) {
				statsList[i] = null;
				delete statsList[i]
			}
			
			// clear current graphs
			if (graphs!=null)
				graphs.removeAll();
		}

		/**
		 * Close existing connection and connects to the specified database
		 * @param databasePath
		 */
		public function setDatabase(databasePath:String):void {
			this.databasePath = databasePath;

			// Close previous connection
			if (dbReader != null)
				dbReader.closeConnection();

			dbReader = new SQLiteReader(this.databasePath);
			dbReader.connect();

			fullStatsList = dbReader.getStatsList(null);
			
			var imagePath:String = databasePath.substring(0, databasePath.lastIndexOf("/"));
			var original:File = new File(imagePath+"/"+Constant.RESIZED_DIR);
			var newFile:File = File.applicationStorageDirectory.resolvePath(Constant.TINY_IMG_PATH);
			original.copyTo(newFile, true);
		}
		
		/**
		 * Updates the list of selected statistics
		 * @param _statsList
		 * 
		 */
		public function setSelectedStatSet(_statsList:Array, maxNumObjects:int, dim:int):void {
			if (dbReader == null) {
				dbReader = new SQLiteReader(this.databasePath);
				dbReader.connect();
			}
			
			this.statsList = _statsList;
			
			// retrieve dataset of specified statistics
			if (this.statsList != null && this.statsList.length > 0)
				this.data = dbReader.getStatObjects(statsList, maxNumObjects);
			else
				this.data = null;
			
			// Using ObjectProxy instead of plain Object prevents to have the warning:
			// unable to bind to property ‘XXX’ on class ‘Object’ (class is not an IEventDispatcher)
			var graph:ObjectProxy;
			graphs = new ArrayCollection();
			var statNames:Array;
			
			for (var i:int=0; i<_statsList.length && _statsList.length>1; i += dim) {
				graph = new ObjectProxy();
				statNames = new Array();
				for (var j:int=0; j<dim; j++) {
					statNames[j] = (statsList[i+j] as Object).name;
				}
				graph.statNames = new ArrayCollection(statNames);
				graphs.addItem(graph);
				graph = null;
				
				// discard last stat(s) if not enough to build a tuple
				if (i == _statsList.length-dim-1 && dim > 1)
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
				statItem = new Statistic(fullStatsList[randomStat].id, fullStatsList[randomStat].name, fullStatsList[i].type);
				statsList.push(statItem);
			}
		}
				
		/**
		 * Connect to the specified database and creates a Dataset of all statistics chosen sequentially.
		 * @param numStats number of Statistics to choose
		 * @param databasePath path to the database
		 * 
		 */
		public function setSequentialSet(numGraphs:int, page:int):void {
			
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
						
			var graphCounter:int = 0;
			var pageCounter:int = 0;
			
			// create page of sequential statistics of length numGraphs x 2
			statsList = new Array();
			for (i=0; i<fullStatsList.length - 1; i++) {
				for (var j:int=i+1; j<fullStatsList.length; j++) {
					if ((graphCounter < numGraphs && pageCounter == page-1) || page == 0) {
						statItem = new Statistic(fullStatsList[i].id, fullStatsList[i].name, fullStatsList[i].type);
						statsList.push(statItem);
						statItem = new Statistic(fullStatsList[j].id, fullStatsList[j].name, fullStatsList[i].type);
						statsList.push(statItem);
					}
					graphCounter++;
					if (graphCounter == numGraphs) {
						pageCounter++;
						graphCounter = 0;
					}
				}
			}
		}
		
		public function histoSelectSubset(statName:String, array:Array):void {
			trace("histoSelectSubset");
		}
		
		/////////////////////
		// private methods
		/////////////////////
		
		private function computeHisto(array:Array, col:int):Array {
			array.sort();
			var histo:Array =  new Array();
			var max:int = Number.MIN_VALUE;
			
			// comput max value
			for (var i:int=0; i< array.length; i++) {
				max = Math.max(array[i], max);
			}
			
			// fill histo with zeros
			for (var j:int=0; j<col; j++)
				histo.push(0);
			
			for (i=0; i< array.length; i++) {
				for (j=0; j<col; j++) {
					if (array[i] >= max/col*j && array[i] <= max/col*(j+1) ) {
						histo[j]++;
						break;
					}
				}
			}
			
			return histo;
		}
		
/*		private function mixArray(array:Array):Array {
			var _length:Number = array.length, mixed:Array = array.slice(), rn:Number, it:Number, el:Object;
			for (it=0; it<_length; it++) {
				el = mixed[it];
				mixed[it] = mixed[rn = Math.floor(Math.random() * _length)];
				mixed[rn] = el;
			}
			return mixed;
		}*/
	}
}