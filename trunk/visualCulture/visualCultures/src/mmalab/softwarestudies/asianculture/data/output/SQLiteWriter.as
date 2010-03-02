package mmalab.softwarestudies.asianculture.data.output
{	
	import com.asfusion.mate.core.GlobalDispatcher;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	import mmalab.softwarestudies.asianculture.data.events.SQLiteFillDataEvent;
	import mmalab.softwarestudies.asianculture.data.events.WriteDBEvent;

	[Bindable]
	public class SQLiteWriter// extends EventDispatcher
	{
		private var conn:SQLConnection = new SQLConnection();
		
		private var data:Array;
		private var statTypes:Object;
		private var dataLength:int;
		
		public var dispatcher:GlobalDispatcher;
		
		public var percentFinished:int;
		
		public function SQLiteWriter() {
		}
		
		public function connect(filePath:String, data:Array):void {
			this.data = data;
			//add an event handeler for the open event
			conn.addEventListener(SQLEvent.OPEN, fillData);
			//create the database if it doesn't exist, otherwise just opens it
			var dbFile:File = new File(filePath); // File.applicationStorageDirectory.resolvePath (filePath);
			conn.open(dbFile); // using synchronous connection
			trace(dbFile.nativePath);
		}
		
		private function fillData(event:SQLEvent):void {
			conn.removeEventListener(SQLEvent.OPEN, fillData);
			statTypes = data.shift();
			
			// add Statistic descriptions
			for (var statName:String in statTypes)
			{
				addStat(statName, statTypes[statName], null);
			}

			dataLength = data.length;

			// fill the data and objects
			processLine();
		}
		
		public function processLine():void {
			for (var i:int=0; i<1 && data!=null && data.length > 0; i++) {
				var currentLine:Object = data.shift();
				// add objects
				addObject(currentLine.filename, "", (currentLine.filename as String).substr((currentLine.filename as String).lastIndexOf(".")), 0, 0, "");
				fileID = getObjId(currentLine.filename, "");
				
				var fileID:int;
				var statValuesArray:Array;
				
				statValuesArray = new Array();
				for (var j:String in currentLine)
				{
					if (j != "filename") 
						statValuesArray.push(new SQLiteStatValue(getStatId(j, statTypes[j]), fileID, statTypes[j], currentLine[j]));
				}
				
				addValue(statValuesArray);
				
				percentFinished = (dataLength-data.length) / dataLength * 100;
			}
			
			if (data!=null && data.length>=0) {
				var fillDataEvent:SQLiteFillDataEvent = new SQLiteFillDataEvent(SQLiteFillDataEvent.SQLITE_FILLDATA_EVENT);
				fillDataEvent.percentFinished = percentFinished;
				dispatcher.dispatchEvent(fillDataEvent);
			}
			
			// stop criteria
			if (data!=null && data.length<1) {
				conn.close();
				data = null;
				var writeCompleteEvent:WriteDBEvent = new WriteDBEvent(WriteDBEvent.WRITE_DB_COMPLETE_EVENT);
				dispatcher.dispatchEvent(writeCompleteEvent);
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
		private function addValue(statValues:Array):void {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			sql.sqlConnection = conn;
			conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			conn.begin();
			
			try {
				for each (var statValue:SQLiteStatValue in statValues) {
					//parse the sql command that creates the IMAGE table if it doesn't exist
					sql.text = "﻿INSERT INTO stat_int VALUES (:stat_id, :obj_id, :value, :update_date)";
					switch (statValue.type) {
						case "int": // nothing to do...
							break;
						case "float":
							sql.text = sql.text.replace("stat_int", "stat_real");
							break;
						case "string":
							sql.text = sql.text.replace("stat_int", "stat_text");
							break;
					}
					sql.parameters[":stat_id"] = statValue.statId;
					sql.parameters[":obj_id"] = statValue.objId;
					sql.parameters[":value"] = statValue.value;
					sql.parameters[":update_date"] = new Date();
					statValue = null;
					
					sql.execute();
				}
				conn.commit();
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
			if (result != null && result.data != null &&result.data.length > 0)
			{
				var row:Object = result.data[0];
				//trace("id:", row.id, ", name:", row.name, ", type:", row.type);
				return row.id;
			}
			//trace(result.data.length);
			return -1;
		}

		private function errorHandler(event:SQLErrorEvent):void {
			trace("An error occured while executing the statement.");
		}
	}
}