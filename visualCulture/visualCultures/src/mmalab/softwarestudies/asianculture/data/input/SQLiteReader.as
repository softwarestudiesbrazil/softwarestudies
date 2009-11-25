package mmalab.softwarestudies.asianculture.data.input
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.filesystem.File;
	
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
			trace(result.data.length);
			return null;
		}
		
		/**
		 * Returns a Dataset object containing the specified statistic categories and values for each object of the database 
		 * @param colnames the statistical categories
		 * @param batchSize controls the number of objects to be treated for each query (default 100)
		 * @return Dataset
		 * 
		 */
		public function getStatObjects(colnames:Array, batchSize:int = 100):Dataset {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			sql.sqlConnection = conn;
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			
			var limit		:int = batchSize * colnames.length;
			var offset		:int = 0;
			var whereClause	:String = "";
			for (var i:int=0; colnames != null && i<colnames.length; i++) {
				whereClause += "s.id = "+colnames[i].id+" OR ";
			}
			
			var dataset:Array = new Array();
			while (true) {
				sql.text = "select o.name as 'obj_name', s.name as 'stat', r.val from stat_real r " +
					"join object_ o on r.obj_id = o.id " +
					"join statistic s on r.stat_id = s.id " +
					"where " + whereClause.slice(0, whereClause.lastIndexOf("OR")) +
					" order by o.name, s.name " +
					"limit :limit offset :offset";
				sql.parameters[":limit"] = limit;
				sql.parameters[":offset"] = offset;
				sql.execute();
				
				// get SQL result
				var result:SQLResult = sql.getResult();
				
				if (result != null && result.data != null && result.data.length > 0)
				{
					var nameCary:String;
					
					// first object
					var statObject:Object = new Object();
					statObject.name = result.data[0].obj_name;
					for each (var row:Object in result.data) {
						
						// detect break in name
						if (nameCary != null && nameCary != row.obj_name) {
							dataset.push(statObject);
							statObject = new Object();
							statObject.name = row.obj_name;
						}
						statObject[row.stat] = row.val;
						nameCary = row.obj_name;
					}
					
					// push last object
					dataset.push(statObject);
					offset += limit;
				}
				else
					return new Dataset(dataset);
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
			sql.text = "select s.id as id, s.name as name from statistic s " + whereString.slice(0, whereString.lastIndexOf("OR")) + " order by s.name";
			
			sql.execute();
			
			var result:SQLResult = sql.getResult();
			if (result != null && result.data.length > 0)
			{
				//trace("id:", row.id, ", name:", row.name, ", type:", row.type);
				trace(result.data.length);
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