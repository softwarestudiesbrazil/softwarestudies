package mmalab.softwarestudies.asianculture.data.input
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mmalab.softwarestudies.visualculture.utils.Constants;

	public class CsvReader
	{
		private var datasetRoot:String;

		/**
		 * Constructor
		 * @param datasetRoot
		 * 
		 */
		public function CsvReader(datasetRoot:String = Constants.DATASET_ROOT)
		{
			this.datasetRoot = datasetRoot;
		}
		
		/**
		 * Reads the CSV file and returns the content as a String
		 * @param filename
		 * @return 
		 * 
		 */
		public function csvLoad(filename:String):String {
			return loadFromFilesystem(filename);
		}
		
		/**
		 * Reads the CSV file and returns the content as an Array
		 * of Object using the first line as headings.
		 * @param filename
		 * @return 
		 * 
		 */
		public function csvLoadAsArray(filename:String):Array {
			var contents:String = loadFromFilesystem(filename);

			return parseData(contents);
		}
		
		//////////////////////////////////////////////////////////////////////
		//////////              Private methods                     //////////
		//////////////////////////////////////////////////////////////////////
		/**
		 * Loads a CSV file from the fileSystem with the current datasetRoot;
		 * @param filename
		 * @return 
		 * 
		 */
		private function loadFromFilesystem(filename:String):String {
			var file:File = new File();
			file.nativePath = datasetRoot + File.separator + filename;

			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			
			// Read the entire contents of the file as a string
			var contents:String = stream.readUTFBytes( stream.bytesAvailable );
			stream.close();
			return contents;
		}
		
		/**
		 * Parses the data from an extracted csvData String and converts it
		 * to an array of Objects using the first line of the csvData as
		 * headings
		 *  
		 * @param csvData extracted String
		 * @return Array of Objects
		 * 
		 */
		private function parseData(csvData:String):Array {
			trace("Parsing CSV Data...");
			var properties:Array = new Array();
			var headings:Boolean = false;
			var carriage:Number = new Number();
			var comma:Number = new Number();
			var cursor:Number = new Number();
			var sub:Number = new Number();
			var item:Object = new Object();
			var value:String = new String();
			var line:String = new String();
			var output:Array = new Array();	
			
//			var result:String = csvData;
			
			// loop over lines
			var lastLine:Boolean = false;
			while( csvData.indexOf( "\r", cursor ) != -1 || lastLine) {
				if (lastLine)
					carriage = csvData.length;
				else
					carriage = csvData.indexOf(  "\r", cursor );
				line = csvData.substring( cursor, carriage );
				
				cursor = 0;
				sub = 0;
				
				item = new Object();
				
				// loop over commas in a line
				while( line.indexOf( ",", cursor ) != -1 ) {
					comma = line.indexOf( ",", cursor );
					value = line.substring( cursor, comma );
					
					if( !headings ) {
						properties.push( value );
					} else {
						item[properties[sub]] = value;
					}
					
					cursor = comma + 1;
					sub++;
				}
				
				value = line.substring( cursor, line.length );
				
				if( !headings ) {
					properties.push( value );
					headings = true;
				} else {
					item[properties[sub]] = value;
					output.push( item );
				}
				cursor = carriage + 1;
				
				if (lastLine)
					break;
				if (csvData.indexOf( "\r", cursor ) == -1 && !lastLine) {
					lastLine = true;
					//carriage ++;
				}
			}
			
			trace("Parsing Complete " + output.length + " objects found. \n");
			
			return output;
		}
	}
}