package mmalab.softwarestudies.asianculture.data.input
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import mmalab.softwarestudies.asianculture.data.models.Dataset;
	
	public class SQLiteReader
	{
		private var sqlFilePath:String;
		private var conn:SQLConnection = new SQLConnection();
		
		public function SQLiteReader(sqlFilePath:String)
		{
			this.sqlFilePath = sqlFilePath;
		}
		
		public function connect():void {
			//add an event handeler for the open event
			//			conn.addEventListener(SQLEvent.OPEN, fillData);
			//create the database if it doesn't exist, otherwise just opens it
			var dbFile:File = File.applicationDirectory.resolvePath (this.sqlFilePath);
			conn.open(dbFile); // using synchronous connection
		}
		
		public function getData(colname:String, min, max):Array {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			sql.sqlConnection = conn;
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			//parse the sql command that creates the IMAGE table if it doesn't exist
			/*			sql.text = "﻿SELECT o.name, r.val FROM object_ o " +
			"JOIN stat_real r ON r.obj_id = o.id " +
			"JOIN statistic s ON r.stat_id = s.id " +
			"WHERE s.name= :statName";
			sql.parameters[":statName"] = colname;
			*/		
			sql.text = "select o.name as name, r.val as x, r2.val as y from object_ o " +
				"join stat_real r on r.obj_id = o.id " +
				"join statistic s on r.stat_id = s.id " +
				"join stat_real r2 on r2.obj_id = o.id " +
				"join statistic s2 on r2.stat_id = s2.id " +
				"where s.name= 'Color7_R' and s2.name='Color5_V' " +
				"group by o.name order by o.name";
			
			if (min != null) {
				sql.text += " AND r.val >= :min";
				sql.parameters[":min"] = min;
			}
			
			if (max != null) {
				sql.text += " AND r.val <= :max";
				sql.parameters[":max"] = max;
			}
			sql.execute();
			
			var result:SQLResult = sql.getResult();
			if (result != null && result.data.length > 0)
			{
				//trace("id:", row.id, ", name:", row.name, ", type:", row.type);
				return result.data;
			}
			trace("result length:" + result.data.length);
			return null;
		}
		
		/**
		 * Returns a Dataset object containing the specified statistic categories and values for each object of the database 
		 * @param colnames the statistical categories
		 * @param size the max number of objects wanted in the Dataset (0 for all objects)
		 * @param batchSize controls the number of objects to be treated for each query (default 100, must be <= size)
		 * @return Dataset
		 */
		public function getStatObjects(colnames:Array, size:int = 0, batchSize:int = 100):Dataset {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			sql.sqlConnection = conn;
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			
			if (colnames == null)
				return null;
			if (size < 0)
				size = 0;
			if (batchSize < 0)
				batchSize = 100;

			// filter colnames array to remove duplicates
			var tempCols:Dictionary = new Dictionary();
			for each (var obj:Object in colnames) {
				tempCols[obj.id] = obj;
			}
			
			// using dictionary or associative array prevents from having dupplicates
			var whereClauseINT	:String = "";
			var whereClauseREAL	:String = "";
			var whereClauseTEXT	:String = "";
			var temp:String;
			var nbCols:int = 0;
			for each (var stat:Object in tempCols) {
				nbCols++;
				temp = stat.id + ",";
					switch (stat.type) {
						case 'int':
							whereClauseINT += temp;
							break;
						case 'float':
							whereClauseREAL += temp;
							break;
						case 'text':
							whereClauseTEXT += temp;
							break;
						default:
							whereClauseINT += temp;
				}
			}

			var limit		:int = batchSize * nbCols;
			var offset		:int = 0;
			var objectCounter:int = 0;

			var dataset:Array = new Array();
			temp = "";
			if (whereClauseINT.length>0)
				temp += "select o.name as 'obj_name', s.name as 'stat', i.val from stat_int i " +
					"join object_ o on i.obj_id = o.id " +
					"join statistic s on i.stat_id = s.id " +
					"where s.id IN (" +  whereClauseINT.substr(0, whereClauseINT.length-1) + ") UNION "
			if (whereClauseREAL.length>0)
				temp += "select o.name as 'obj_name', s.name as 'stat', r.val from stat_real r " +
					"join object_ o on r.obj_id = o.id " +
					"join statistic s on r.stat_id = s.id " +
					"where s.id IN (" + whereClauseREAL.substr(0, whereClauseREAL.length-1) + ") UNION "
			if (whereClauseTEXT.length>0)
				temp += "select o.name as 'obj_name', s.name as 'stat', t.val from stat_text t " +
					"join object_ o on t.obj_id = o.id " +
					"join statistic s on t.stat_id = s.id " +
					"where s.id IN (" + whereClauseTEXT.substr(0, whereClauseTEXT.length-1) + ") UNION "
			
			sql.text = temp.slice(0, temp.lastIndexOf("UNION")) +
				"order by o.name, s.name " +
				"limit :limit offset :offset";

			while (true) {
				sql.parameters[":limit"] = size>0 ? Math.min(limit, (size - objectCounter)*nbCols) : limit;
				sql.parameters[":offset"] = offset;
				sql.execute();
				
				// get SQL result
				var resultSet:SQLResult = sql.getResult();
				
				if (resultSet != null && resultSet.data != null && resultSet.data.length > 0
					&& (objectCounter < size || size == 0))
				{
					var nameCary:String;
					
					// first object
					var statObject:Object = new Object();
					statObject.name = resultSet.data[0].obj_name;
					
					// loop over each object stats
					for each (var row:Object in resultSet.data) {
						
						// detect break in name
						if (nameCary != null && nameCary != row.obj_name) {
							dataset.push(statObject);
							objectCounter++;
							statObject = new Object();
							statObject.name = row.obj_name;
						}
						statObject[row.stat] = row.val;
						nameCary = row.obj_name;
					}
					
					// push last object of the resultSet
					dataset.push(statObject);
					objectCounter++;
					offset += limit-nbCols;
					
				}
				else {
					// count Last object
					trace ("Last obj: " + objectCounter + ", max size: " + size);
					return new Dataset(dataset);
				}
			}
			return null;
		}
		
		/**
		 * Returns an array of Objects(id, name) matching the names of the stat columns specified 
		 * @param colnames
		 * @return Array
		 * 
		 */
		public function getStatsList(colnames:Array):Array {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			sql.sqlConnection = conn;
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			
			var whereString:String = "";
			if (colnames != null && colnames.length > 0)
				whereString = " where ";
			for (var i:int=0; colnames != null && i<colnames.length; i++) {
				whereString += "s.name = '" + colnames[i] + "' OR ";
			}
			sql.text = "select s.id as id, s.name as name, s.type as type from statistic s "+
				whereString.slice(0, whereString.lastIndexOf("OR")) +
				" order by s.name";
			
			sql.execute();
			
			var result:SQLResult = sql.getResult();
			if (result != null && result.data.length > 0)
			{
				//trace("id:", row.id, ", name:", row.name, ", type:", row.type);
				trace("result length: " + result.data.length);
				return result.data;
			}
			return null;
		}
		
		
		
		private function errorHandler(event:SQLErrorEvent):void {
			trace("An error occured while executing the statement.");
		}
		
		public function closeConnection():void {
			conn.close();
		}
	}
}