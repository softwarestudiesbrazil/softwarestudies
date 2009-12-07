package mmalab.softwarestudies.visualcultures.dataaccess
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;

	public class SQLiteWriter
	{
		private var sqlFilePath:String;
		private var conn:SQLConnection = new SQLConnection();
		

		private var data:Array;
		
		public function SQLiteWriter(file:String) {
			this.sqlFilePath = file;
			
//			connect();
		}
		
		public function connect(data:Array):void {
			this.data = data;
			//add an event handeler for the open event
			conn.addEventListener(SQLEvent.OPEN, fillData);
			//create the database if it doesn't exist, otherwise just opens it
			var dbFile:File = File.applicationDirectory.resolvePath (this.sqlFilePath);
			conn.open(dbFile); // using synchronous connection
		}
		
		private function fillData(event:SQLEvent):void {
			var line1:Object = data.shift();
			
			// add Statistic descriptions
			for (var statName:String in line1)
			{
				addStat(statName, line1[statName], null);
			}

			var line:Object;
			var fileID:int;

			// fill the data and objects
			while (data.length > 0) {
				line = data.shift();
				
				// add objects
				addObject(line.filename, "", "jpg", 0, 0, "");
				fileID = getObjId(line.filename, "");
				
				// add stat values for each object
				for (var j:String in line)
				{
					if (j != "filename") 
						addValue(getStatId(j, line1[j]), fileID, line1[j], line[j]);
				}
			}
		}
				
		private function addStat(name:String, type:String, description:String):void {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			sql.sqlConnection = conn;
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);

			//parse the sql command that creates the IMAGE table if it doesn't exist
			sql.text = "﻿INSERT INTO statistic VALUES (null, :name, :type, :description, :update_date)";
			sql.parameters[":name"] = name;
			sql.parameters[":type"] = type;
			sql.parameters[":description"] = description;
			sql.parameters[":update_date"] = new Date();
			try {
				sql.execute();
			}
			catch (err:SQLError) {
				if (err.errorID != 3131) // ignore error due to constraint violation
					trace ("addStat:"+err.details);
			}
		}
		
		private function addObject(name:String, path:String, format:String, width:int, height:int, description:String):void {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			sql.sqlConnection = conn;
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			
			//parse the sql command that creates the IMAGE table if it doesn't exist
			sql.text = "﻿INSERT INTO object_ VALUES (null, :set_id, :name, :description, :path, :width, :height, :format, :obj_date, :update_date)";
			sql.parameters[":set_id"] = 1;
			sql.parameters[":name"] = name;
			sql.parameters[":description"] = description;
			sql.parameters[":path"] = path;
			sql.parameters[":width"] = width;
			sql.parameters[":height"] = height;
			sql.parameters[":format"] = 1;//format;
			sql.parameters[":obj_date"] = new Date();
			sql.parameters[":update_date"] = new Date();
			try {
				sql.execute();
			}
			catch (err:SQLError) {
				if (err.errorID != 3131) // ignore error due to constraint violation
					trace ("addObj:"+err.message);
			}
		}
		
		/**
		 * Adds a value to the right statistic table depending on the time.
		 * value has any type, this is thus specific to flex.
		 * @param statId the ID of the statistic
		 * @param objId the ID of the object
		 * @param type the type of the statistic (int, float, string)
		 * @param value the value of the statistic
		 * 
		 */
		private function addValue(statId:int, objId:int, type:String, value):void {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			sql.sqlConnection = conn;
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			
			//parse the sql command that creates the IMAGE table if it doesn't exist
			sql.text = "﻿INSERT INTO stat_int VALUES (:stat_id, :obj_id, :value, :update_date)";
			switch (type) {
				case "int": // nothing to do...
					break;
				case "float":
					sql.text.replace("stat_int", "stat_real");
					break;
				case "string":
					sql.text.replace("stat_int", "stat_string");
					break;
			}
			sql.parameters[":stat_id"] = statId;
			sql.parameters[":obj_id"] = objId;
			sql.parameters[":value"] = value;
			sql.parameters[":update_date"] = new Date();
			try {
				sql.execute();
			}
			catch (err:SQLError) {
				if (err.errorID != 3131) // ignore error due to constraint violation
					trace ("addValue:"+err.message);
			}
		}
		
		/**
		 * Gets the statistic ID from the specified name and type
		 * (name, type) is uniquely defined
		 * @param name the name of the statistic
		 * @param type the type of the statistic
		 * @return int
		 * 
		 */
		private function getStatId(name:String, type:String):int {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			sql.sqlConnection = conn;
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			//parse the sql command that creates the IMAGE table if it doesn't exist
			sql.text = "﻿SELECT id FROM statistic WHERE name=:name AND type=:type";
			sql.parameters[":name"] = name;
			sql.parameters[":type"] = type;
			sql.execute();
			
			var result:SQLResult = sql.getResult();
			if (result != null && result.data.length == 1)
			{
				var row:Object = result.data[0];
				//trace("id:", row.id, ", name:", row.name, ", type:", row.type);
				return row.id;
			}
			return -1;
		}
				
		/**
		 * Gets the object ID from the specified name and path
		 * (name, path) is uniquely defined
		 * @param name the filename of the object
		 * @param path the path of the object
		 * @return int
		 * 
		 */
		private function getObjId(name:String, path:String):int {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			sql.sqlConnection = conn;
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			//parse the sql command that creates the IMAGE table if it doesn't exist
			sql.text = "﻿SELECT id FROM object_ WHERE name=:name AND path=:path";
			sql.parameters[":name"] = name;
			sql.parameters[":path"] = path;
			sql.execute();
			
			var result:SQLResult = sql.getResult();
			if (result != null && result.data.length > 0)
			{
				var row:Object = result.data[0];
				//trace("id:", row.id, ", name:", row.name, ", type:", row.type);
				return row.id;
			}
			trace(result.data.length);
			return -1;
		}

		private function errorHandler(event:SQLErrorEvent):void {
			trace("An error occured while executing the statement.");
		}
	}
}