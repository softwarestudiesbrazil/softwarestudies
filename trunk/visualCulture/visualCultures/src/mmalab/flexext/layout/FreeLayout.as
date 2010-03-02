/*

@Author Bertrand Grandgeorge 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Example of possible layout determined only by the component sizes:

+------------------+-----------------+
|        1         |       2         |
+-----------+------+----------+------+
|     3     |        4        |
+-----------+-----------------+---+
|                                 |
|                5                |
|                                 |
+-----------+-----------------+---+
|     6     |        7        |
|           +-----------------+
+-----------+

*/
package mmalab.flexext.layout
{
	import mx.core.ILayoutElement;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	/**
	 * This class extends LayoutBase which sizes and positions the target's elements. <br>
	 * This layout is a flexible layout manager that aligns components vertically and
	 * horizontally, without requiring that the components be of the same size. <br>
	 * The components are arranged in a grid with their native size, with no
	 * overlapping and fitting the parent component in width. The row height is
	 * calculated to be the max height of the components in the row.
	 * 
	 * @author bertrand grandgeorge b.grandgeorge&#64;gmail.com
	 * 
	 */	
	public class FreeLayout extends LayoutBase
	{
		/**
		 * Overrides LayoutBase class updateDisplayList
		 * Sizes and positions the target's elements
		 * @param width:Number Specifies the width of the target, in pixels, in the targets's coordinates
		 * @param height:Number Specifies the height of the component, in pixels, in the target's coordinates.
		 * 
		 */
		override public function updateDisplayList(width:Number, height:Number):void
		{
			super.updateDisplayList(width, height);
			
			if (!target)
				return;
			
			var currentElement:ILayoutElement;
			var nextElement:ILayoutElement;
			var count:uint = target.numElements;
			
			var _x : Number = 0;
			var _y : Number = 0;
			
			var nextElemWidth : Number = 0;
			
			var maxHeight:Number = 0;
			
			// cycle through all the elements
			for (var i:int = 0; i < count; i++)
			{
				// get the current element being layed out
				currentElement = target.getElementAt(i);
				
				// get the required width to display next element
				if (i<count-1) {
					nextElement = target.getElementAt(i+1);
					// (re)size the element to its preferred size
					// necessary to use getLayoutBounds methods
					nextElement.setLayoutBoundsSize(NaN, NaN);
					nextElemWidth = nextElement.getLayoutBoundsWidth();
				}
				
				if (!currentElement || !currentElement.includeInLayout)
					continue;
				
				// (re)size the element to its preferred size
				// necessary to use getLayoutBounds methods
				currentElement.setLayoutBoundsSize(NaN, NaN);
				
				// position the current element in the grid
				currentElement.setLayoutBoundsPosition(_x, _y);

				// initialize maxHeight to first element's height
				if (i==0)
					maxHeight = currentElement.getLayoutBoundsHeight();
				
				// if current element fits in the row, increment the x coordinate
				if (_x + currentElement.getLayoutBoundsWidth() + nextElemWidth  < target.width)
					_x += currentElement.getLayoutBoundsWidth();
				// else start a new line and reinitialize x coordinate
				else {
					_x = 0;
					_y += maxHeight;
					maxHeight = 0;
				}

				// update the maxHeight with next element
				if (nextElement)
					maxHeight = Math.max(nextElement.getLayoutBoundsHeight(), maxHeight);
			} 
		}
	}
}
