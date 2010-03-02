package 
{
	import mx.charts.AxisLabel;
	import mx.controls.Label;
		
	public class InnerlabelRenderer extends Label
	{
		private var _data:AxisLabel;
		
		override public function get data():Object
		{       	
			return _data;
		}
		
		override public function set data(value:Object):void
		{
			if(value != null)
			{ 
				this.text =value.text.toString();				
				this._data = value as AxisLabel; 
				this.setStyle("color", "0xCECFD1");
				this.setStyle("fontSize", 11);
			}
		}
	}
}