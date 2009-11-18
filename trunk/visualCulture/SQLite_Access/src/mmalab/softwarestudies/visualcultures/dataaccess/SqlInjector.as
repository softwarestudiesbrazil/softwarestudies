package mmalab.softwarestudies.visualcultures.dataaccess
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	public class SqlInjector
	{
		private var sqlFilePath:String;
		private var conn:SQLConnection = new SQLConnection();
		
		public function SqlInjector(file:String) {
			this.sqlFilePath = file;
			
			connect();
		}

		public function connect():void {
			//add an event handeler for the open event
			conn.addEventListener(SQLEvent.OPEN, createTables);
			//create the database if it doesn't exist, otherwise just opens it
			var dbFile:File = File.applicationDirectory.resolvePath (this.sqlFilePath);
			conn.openAsync(dbFile);
		}
		
		private function createTables(event:SQLEvent):void {
			//create a new sql statement
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
			
			// begin transaction
			trace("beginning table creation");
			conn.begin();
			
			sql.sqlConnection = conn;
			//parse the sql command that creates the IMAGE table if it doesn't exist
			sql.text= "﻿create table if not exists image ("+
				"id INTEGER primary key autoincrement,"+
				"name TEXT,"+
				"path TEXT,"+
				"format TEXT,"+
				"width INTEGER,"+
				"height INTEGER,"+
				"description TEXT)";
			sql.execute();
			trace("table image created");
			
			sql = new SQLStatement();
			sql.sqlConnection = conn;
			//parse the sql command that creates the STATISTICS table if it doesn't exist
			sql.text= "﻿create table if not exists statistic ("+
				"id INTEGER primary key autoincrement,"+
				"name TEXT,"+
				"type TEXT,"+
				"description TEXT)";
			sql.execute();			
			trace("table statistic created");

			sql = new SQLStatement();
			sql.sqlConnection = conn;
			//parse the sql command that creates the STAT_INT table if it doesn't exist
			sql.text= "﻿create table if not exists stat_int ("+
				"stat_id INTEGER,"+
				"img_id INTEGER,"+
				"value INTEGER)";
			sql.execute();			
			trace("table stat_int created");

			sql = new SQLStatement();
			sql.sqlConnection = conn;
			//parse the sql command that creates the STAT_FLOAT table if it doesn't exist
			sql.text= "﻿create table if not exists stat_float ("+
				"stat_id INTEGER,"+
				"img_id INTEGER,"+
				"value REAL)";
			sql.execute();			
			trace("table stat_float created");
			
			sql = new SQLStatement();
			sql.sqlConnection = conn;
			//parse the sql command that creates the STAT_STRING table if it doesn't exist
			sql.text= "﻿create table if not exists stat_string ("+
				"stat_id INTEGER,"+
				"img_id INTEGER,"+
				"value TEXT)";
			sql.execute();			
			trace("table stat_string created");

			//add a new event listener to the sql when it completes creating the table
			conn.addEventListener(SQLEvent.COMMIT, creationDone);

			//commit the transaction
			conn.commit();
		}
		
		private function creationDone(evt:SQLEvent):void {
			
		}
		
		/**
		 * Inserts values into the specified table (all columns)
		 * @param tableName
		 * @param values
		 * 
		 */
		public function fillTable(tableName:String, values:Array):void {
			var sql:SQLStatement = new SQLStatement();
			//set the statement to connect to our database
		
			sql.sqlConnection = conn;
			//parse the sql command that creates the IMAGE table if it doesn't exist
			sql.text = "﻿INSERT INTO ?tablename VALUES (?values)";
			sql.parameters["?tablename"] = tableName;
			sql.parameters["?values"] = values.join();
			sql.execute();			
		}
	}
}