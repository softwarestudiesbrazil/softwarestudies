package mmalab.softwarestudies.asianculture.graph.utils
{
	import mx.formatters.NumberFormatter;
	
/**
 * This class holds the logic to temper with histogram, bar or pie charts.
 */
	public class HistoPieUtil
	{
		/**
		 * Stores the position in of the objects in the dataset, organized by the columns/sectors displayed
		 */
		public var chartIDs:Array = new Array();
		
		/**
		 * Stores the values of the chart to be displayed as a Pie or histogram (bar chart)
		 */
		public var chartValues:Array;
		
		private var numberFormatter:NumberFormatter = new NumberFormatter();
		
		/**
		 * Constructor
		 */
		public function HistoPieUtil()
		{
			// setup numberFormatter for later use
			numberFormatter.precision = 2;
			numberFormatter.useThousandsSeparator = true;
			numberFormatter.useNegativeSign = true;
		}
		
		public function computeChartElements(array:Array, statIdy:String, bins:int, labels:Boolean):void {
//			array.sort();
			chartValues =  new Array();
			var min:Number = Number.MAX_VALUE;
			var max:Number = -Number.MIN_VALUE;

			// compute max value
			for (var i:int=0; i< array.length; i++) {
				if (array[i][statIdy] != null) {
					min = Math.min(array[i][statIdy], min);
					max = Math.max(array[i][statIdy], max);
				}
			}
			
			// calculate max of an array of numbers
			//trace(Math.max.apply(null, [1,2,2,3,4,5,2,3]));

			var range:Number = (max-min)/bins;
			
			// fill chart with empty values
			for (var j:int=0; j<bins; j++) {
				var chartValue:Object = new Object();
				chartValue.value = 0;
				if (labels)
					chartValue.label = "["+numberFormatter.format(min+j*range)+" "+numberFormatter.format(min+(j+1)*range)+"]";
				chartValues.push(chartValue);
			}
			
			for (i=0; i< array.length; i++) {
				for (j=0; j<bins; j++) {
					if (chartIDs[j] == null || chartIDs.length < 0)
						chartIDs[j] = new Array();
					// if value is inside range
					if (array[i][statIdy] >= min+range*j && array[i][statIdy] <= min+(j+1)*range) {
						chartValues[j].value++;
						
						// add chart column/sector info
						chartIDs[j].push(i);
						break;
					}
				}
			}
		}
		
		public function computeBarchartElements(array:Array, statIdx:String, labels:Boolean):void {
			chartValues =  new Array();
			var tempArray:Array = new Array();
			
			chartIDs = new Array();
			
			var tempStrValue:String;
			var chartValue:Object;
			var barNum:int = 0;
			// calculate bar height & add ids (in the dataset) of related objects
			for (var i:int=0; i< array.length; i++) {
				tempStrValue = array[i][statIdx];
				if (tempArray[tempStrValue]) {
					tempArray[tempStrValue].ids.push(i); // add id to array of ids in the bar
				}
				else {
					chartValue = new Object();
					chartValue.label = tempStrValue;
					chartValue.barNum = barNum;
					chartValue.ids = [i];
					tempArray[tempStrValue] = chartValue;
					barNum++;
				}
			}
			
			// populate values and ids for use in the chart
			for each (var cValue:Object in tempArray) {
				cValue.value = cValue.ids.length;
				chartValues[cValue.barNum] = cValue;
				chartIDs[cValue.barNum] = cValue.ids;
			}
		}
		
	}
}