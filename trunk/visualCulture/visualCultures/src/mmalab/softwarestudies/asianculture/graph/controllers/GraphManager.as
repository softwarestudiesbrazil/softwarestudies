package mmalab.softwarestudies.asianculture.graph.controllers
{
	import com.asfusion.mate.core.GlobalDispatcher;
	
	import flash.filesystem.File;
	
	import mmalab.softwarestudies.asianculture.Constants;
	import mmalab.softwarestudies.asianculture.data.events.WriteDBEvent;
	import mmalab.softwarestudies.asianculture.data.input.CsvReader;
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
		public var imagesPath:String;
		public var dataSize:int = 0;
		public var numStats:int = 0;
		
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
		 * The graph type (histo, scatter, bubble...) to use with the graphChooser
		 */
		public var graphType:String;

		public var dispatcher:GlobalDispatcher;
		
		private var dbReader:SQLiteReader;
		private var stId:Boolean = false;
		private var _numCols:int;
		private var selectedRanges:Array;
		private var nativePath:Boolean;
		private var graph:ObjectProxy;

		
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
		
		public function setImagesPath(path:String):void {
			imagesPath = path;
			Constants.imagesPath = path;
		}
		
		public function setGraphStyle(value:String):void
		{
			graphType = value;
			
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
		 * Close existing connection and connects to the specified database.
		 * Copy files in the 'resized' directory to the application storage directory
		 * @param databasePath
		 */
		public function setDatabase(databasePath:String, nativePath:Boolean):void {
			if (databasePath !=null && databasePath.substr(databasePath.lastIndexOf(".")).toUpperCase() != ".CSV") {
				this.databasePath = databasePath;
				this.nativePath = nativePath;
				readData();
			}
			else {
				var csvReader:CsvReader = new CsvReader();
				var array:Array = csvReader.csvLoadAsArray(databasePath);
				
				var original:File = File.applicationDirectory.resolvePath(Constants.EMPTY_DB_NAME);
				var newFile:File = new File(databasePath+"_.db");
				original.copyTo(newFile, true);

				this.databasePath = databasePath+"_.db";
				
				var writeDBEvent:WriteDBEvent = new WriteDBEvent(WriteDBEvent.WRITE_DB_EVENT);
				writeDBEvent.filePath = newFile.nativePath;
				writeDBEvent.data = array;
				dispatcher.dispatchEvent(writeDBEvent);
			}
		}
		
		public function readData():void {

			// Close previous connection
			if (dbReader != null)
				dbReader.closeConnection();

			trace(this.databasePath);
			dbReader = new SQLiteReader(this.databasePath);
			dbReader.connect(this.nativePath);

			fullStatsList = dbReader.getStatsList(null);
			numStats = fullStatsList.length;
			
			if (false && nativePath) {
				// copy image files in the 'resized' directory to the application storage directory
				var imagePath:String = databasePath.substring(0, databasePath.lastIndexOf("/"));
				var original:File = new File(imagePath+"/"+Constants.RESIZED_DIR);
				var newFile:File = File.applicationStorageDirectory.resolvePath(Constants.TINY_IMG_PATH);
				original.copyTo(newFile, true);
			}
		}
		
		/**
		 * Updates the list of selected statistics 
		 * @param _statsList
		 * @param maxNumObjects
		 * @param dim
		 * 
		 */
		public function setSelectedStatSet(_statsList:Array, maxNumObjects:int, dim:int):void {
			if (dbReader == null) {
				dbReader = new SQLiteReader(this.databasePath);
				dbReader.connect(this.nativePath);
			}
			
			this.statsList = _statsList;
			
			// retrieve dataset of specified statistics
			if (this.statsList != null && this.statsList.length > 0) {
				this.data = dbReader.getStatObjects(statsList, maxNumObjects);
				dataSize = data.number;
			}
			else {
				this.data = null;
				dataSize = 0;
			}
			
			// Erase current graphs
			graphs.removeAll();
			
			// Using ObjectProxy instead of plain Object prevents to have the warning:
			// unable to bind to property ‘XXX’ on class ‘Object’ (class is not an IEventDispatcher)
			graphs = new ArrayCollection();
			var statNames:Array;
			
			for (var i:int=0; i<_statsList.length && _statsList.length>1; i += dim) {
				graph = new ObjectProxy();
				statNames = new Array();
				for (var j:int=0; j<dim; j++) {
					statNames[j] = (statsList[i+j] as Object).name;
				}
				graph.graphType = graphType;
				graph.statNames = new ArrayCollection(statNames);
				graphs.addItem(graph);
				graph = null;
				
				// discard last stat(s) if not enough to build a tuple
				if (i == _statsList.length-dim-1 && dim > 1)
					break;
			}
		}
				
		/**
		 * Creates and displays a list of graphs of different types
		 * @param graphList
		 * 
		 */
		public function addGraphs(graphList:Array):void {
			if (dbReader == null) {
				dbReader = new SQLiteReader(this.databasePath);
				dbReader.connect(this.nativePath);
			}
			
			var _statsList:Array = new Array();
			var tempName:Object;
			for (var i:int=0; i< graphList.length; i++) {
				for (var j:int=0; j<graphList[i].statNames.length; j++) {
					tempName = graphList[i].statNames[j].statName;
					_statsList[tempName.name] = tempName;
				}
			}
			
			if (statsList)
				this.statsList.splice();
			this.statsList = new Array();

			for each (var statName:Object in _statsList) {
				this.statsList.push(statName);
			}
			_statsList.splice();
			
			var statNames:Array;
			var displayImages:Boolean = false;
			var graphStatNamesDirty:Boolean = false;
			graphs = new ArrayCollection();
			for each(var graphItem:Object in graphList) {
				if (graphItem.graphType && graphItem.active) {
					graph = new ObjectProxy();
					statNames = new Array();
					for (j=0; j<graphItem.statNames.length; j++) {
						statNames[j] = (graphItem.statNames[j] as Object).statName.name;
						// if statName not found => next
						if (!statNames[j]) {
							statNames = null;
							graph = null;
							graphStatNamesDirty = true;
							break;
						}
					}
					// go to next graph if this one is corrupted
					if (graphStatNamesDirty)
						continue;
					graph.graphType = graphItem.graphType.name;
					graph.dims = graphItem.dims;
					graph.displayAxes = graphItem.displayAxes;
					graph.displayImages = graphItem.displayImages; // for scatter & bubble
					graph.displayXLabels = graphItem.xLabels; // for histo and barchart plots
					graph.showDataTips = graphItem.dataTips;
					graph.zoomFactor = graphItem.zoomFactor; // for scatter
					if (!displayImages && graphItem.displayImages)
						displayImages = true;
					graph.numBins = graphItem.numBins; // for histo
					graph.statNames = new ArrayCollection(statNames);
					graphs.addItem(graph);
					graph = null;
					statNames = null;
				}
			}
			
			var numObjLimit:int = 0;
			
			if (displayImages)
				numObjLimit = 500;
			
			// retrieve dataset of specified statistics
			if (this.statsList != null && this.statsList.length > 0) {
				this.data = dbReader.getStatObjects(statsList, numObjLimit, 1000);
				dataSize = data?data.number:0;
			}
			else {
				this.data = null;
				dataSize = 0;
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
				dbReader.connect(this.nativePath);
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
				dbReader.connect(this.nativePath);
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
		
		/**
		 * Update the selected range(s) for a specific Stat 
		 * @param statName
		 * @param array
		 * 
		 */
		public function histoSelectSubset(statName:String, array:Array):void {
			if (selectedRanges == null)
				selectedRanges = new Array();
			var stat:Object = new Object();
			stat.name = statName;
			stat.arr = array;
			selectedRanges[statName] = stat;
		}
		
		public function histoFilter():void {
			if (dbReader == null) {
				dbReader = new SQLiteReader(this.databasePath);
				dbReader.connect(this.nativePath);
			}
			trace(dbReader.createFilter(selectedRanges));
		}
		
		/////////////////////////////////////////
		// private methods
		/////////////////////////////////////////
		
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