// *****************************************************************************************
// ZBuffer.as
// 
// Copyright (c) 2008 Ryan Taylor | http://www.boostworthy.com
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
// *****************************************************************************************
// 
// +          +          +          +          +          +          +          +          +
// 
// *****************************************************************************************

// PACKAGE /////////////////////////////////////////////////////////////////////////////////

package com.boostworthy.display
{
	// IMPORTS /////////////////////////////////////////////////////////////////////////////
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	// CLASS ///////////////////////////////////////////////////////////////////////////////
	
	/**
	 * This <code>ZBuffer</code> class is responsible for sorting <code>DisplayObject</code>
	 * depths according to their location on the Z axis.
	 * <p>
	 * Two primary methods exist for sorting - <code>sort</code> and 
	 * <code>recursiveSort</code>. The <code>sort</code> method will only sort a given 
	 * <code>DisplayObjectContainer</code>'s children. The <code>recursiveSort</code> method
	 * is the same as the <code>sort</code> method, except it will recursively sort each
	 * child's children if the child is a <code>DisplayObjectContainer</code> as well.
	 * <p>
	 * Usage is simple; simply create a new instance of this class and pass one of the two
	 * sorting methods a <code>DisplayObjectContainer</code> to sort.
	 * <p>
	 * <code>
	 * 		var zBuffer:ZBuffer = new ZBuffer();
	 * 		
	 * 		var plane1:Sprite = new Sprite();
	 * 		var plane2:Sprite = new Sprite();
	 * 		var plane3:Sprite = new Sprite();
	 * 		
	 * 		plane1.graphics.beginFill(0xFF0000);
	 * 		plane1.graphics.drawRect(0, 0, 200, 200);
	 * 		plane1.graphics.endFill();
	 * 		
	 * 		plane2.graphics.beginFill(0x00FF00);
	 * 		plane2.graphics.drawRect(0, 0, 200, 200);
	 * 		plane2.graphics.endFill();
	 * 		
	 * 		plane3.graphics.beginFill(0x0000FF);
	 * 		plane3.graphics.drawRect(0, 0, 200, 200);
	 * 		plane3.graphics.endFill();
	 * 		
	 * 		plane1.x = 80;
	 * 		plane1.y = 50;
	 * 		plane1.z = 100;
	 * 		
	 * 		plane2.x = 150;
	 * 		plane2.y = 100;
	 * 		plane2.z = 200;
	 * 		
	 * 		plane3.x = 220;
	 * 		plane3.y = 150;
	 * 		plane3.z = 20;
	 * 
	 * 		addChild(plane1);
	 * 		addChild(plane2);
	 * 		addChild(plane3);
	 * 		
	 * 		zBuffer.sort(this);
	 * </code>
	 */
	public class ZBuffer
	{
		// *********************************************************************************
		// CLASS DECLARATIONS
		// *********************************************************************************
		
		// CONSTANTS ///////////////////////////////////////////////////////////////////////
		
		// CLASS MEMBERS ///////////////////////////////////////////////////////////////////
		
		// MEMBERS /////////////////////////////////////////////////////////////////////////
		
		// *********************************************************************************
		// CONSTRUCTOR
		// *********************************************************************************
		
		/**
		 * Creates a new <code>ZBuffer</code> instance.
		 */
		public function ZBuffer()
		{
		}
		
		// *********************************************************************************
		// API
		// *********************************************************************************
		
		/**
		 * The <code>sort</code> method sorts a given <code>DisplayObjectContainer</code>'s
		 * child depths according to their location along the Z axis. If recursive sorting 
		 * is desired, the <code>recursiveSort</code> method can be used instead.
		 * 
		 * @param	container	A <code>DisplayObjectContainer</code> containing children in 
		 * 						need of depth sorting.
		 * 
		 * @see	#recursiveSort
		 */
		public function sort(container:DisplayObjectContainer):void
		{
			// If the container contains only one child or 
			// none at all, exit from this method.
			if(container.numChildren < 2)
				return;
			
			// The count is the number of sorting operations
			// that need to be performed.
			var count:int = container.numChildren;
			var a:int = 0;
			
			// Check each child's z location compared to the
			// next child's and sort depths accordingly.
			while(a < count)
			{
				var b:int = a - 1;

				var childA:DisplayObject = container.getChildAt(a);
				var childB:DisplayObject = (b > 0) ? container.getChildAt(b) : null;

				if(childB && childB.z < childA.z)
				{
					trace ("a:"+a);
					trace ("b:"+b);
					container.swapChildrenAt(a, b);

					a--;
				}
				else
					a++;
			}
		}
		
		/**
		 * The <code>recursiveSort</code> method sorts a given <code>DisplayObjectContainer</code>'s 
		 * child depths according to their location along the Z axis. It also recursively sort's 
		 * each child's children if the child is a <code>DisplayObjectContainer</code> as well.
		 * 
		 * @param	container	A <code>DisplayObjectContainer</code> containing children in 
		 * 						need of depth sorting.
		 * 
		 * @see	#sort
		 */
		public function recursiveSort(container:DisplayObjectContainer):void
		{
			// The container contains no children. Exit
			// from this method.
			if(container.numChildren == 0)
			{
				return;
			}
			// The container contains only one child. If the 
			// child is a container itself, recursively sort
			// it's children, then exit from this method.
			else if(container.numChildren == 1)
			{
				var child:DisplayObject = container.getChildAt(0);
				
				if(child is DisplayObjectContainer)
					recursiveSort(DisplayObjectContainer(child));
				
				return;
			}
			// The container contains two or more children. 
			// Check each child to see if it is a container 
			// and, if so, recursively sort it's children, 
			// then sort the child itself.
			else
			{
				// The count is the number of sorting operations
				// that need to be performed.
				var count:int = container.numChildren;
				var a:int = 0;
				
				while(a < count)
				{
					var b:int = a - 1;
	
					var childA:DisplayObject = container.getChildAt(a);
					var childB:DisplayObject = (a > 0) ? container.getChildAt(b) : null;
	
					if(childB && childB.z < childA.z)
					{
						container.swapChildrenAt(a, b);
	
						a--;
					}
					else
						a++;
				}
			}
		}
	}
}