package mmalab.softwarestudies.asianculture
{
	import mmalab.softwarestudies.asianculture.graph.models.GraphType;

	public final class Constants
	{
		/**
		 * Assumed resized images directory
		 */
		public static const RESIZED_DIR:String = "resized";
		
		public static const IMAGE_DIR:String = "images/";
		public static const THUMBS_DIR:String = "thumbs/";
		public static const TINY_IMG_DIR:String = "tinys/";
		
		public static const TINY_IMG_PATH:String = IMAGE_DIR + TINY_IMG_DIR;
		public static const THUMBS_PATH:String = IMAGE_DIR + THUMBS_DIR;

		public static const GRAPH_SCATTER:GraphType = new GraphType("Scatter", 2, ["X Axis", "Y Axis"]);
		public static const GRAPH_HISTO:GraphType = new GraphType("Histo", 1, ["X Axis"]);
		public static const GRAPH_BAR:GraphType = new GraphType("Bar", 1, ["X Axis"]);
		public static const GRAPH_BUBBLE:GraphType = new GraphType("Bubble", 3, ["X Axis", "Y Axis", "Radius"]);
		public static const GRAPH_PIE:GraphType = new GraphType("Pie", 1, ["Values"]);

		public static const GRAPH_TYPES:Array = [GRAPH_SCATTER, GRAPH_HISTO, GRAPH_BUBBLE, GRAPH_PIE, GRAPH_BAR];
		
		public static const EMPTY_DB_NAME:String = "emptyDB.db";
		
		// Did this because property injection to custom DataTip doesn't work: --> use static variable
		public static var imagesPath:String;
				
	}
}