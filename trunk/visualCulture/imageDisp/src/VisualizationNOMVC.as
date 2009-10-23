// ActionScript file

import com.boostworthy.display.ZBuffer;

import flare.animate.Parallel;
import flare.animate.Sequence;
import flare.animate.Tween;

import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.Capabilities;

import mx.controls.Image;
import mx.controls.sliderClasses.Slider;
import mx.events.FlexEvent;
import mx.graphics.*;

private const DATASET_ROOT:String = "/AsianCult/SWS02/projects/Lev/Mondrian_600dpi/run";
private const IMAGES_PATH:String = "images/resized";

private var par:Parallel;
private var images : Array = new Array();
private var dots : Array = new Array();

private const TICK_INTERVAL:uint = 5;
private const GRAPH_WIDTH:uint = 800;
private const GRAPH_HEIGHT:uint = 600;
private var imgZBuffer:ZBuffer = new ZBuffer();
private var imageLoader:Loader;
private var randomlySized:Boolean = false;

[Bindable] private var statsArray:Array = new Array();

private function doMouseWheel(evt:MouseEvent):void {
	for each (var image:Image in images) {
		image.percentWidth += evt.delta;
		image.percentHeight += evt.delta;
		if (image.numChildren > 1)
			image.removeChildAt(image.numChildren-1);
		
		var dot:Sprite = new Sprite();
		
		image.addEventListener(FlexEvent.UPDATE_COMPLETE, onImgUpdComplete2);
	}
}

private function onImgUpdComplete2(e:Event):void {
	var img:Image = e.currentTarget as Image;
	img.removeEventListener(FlexEvent.UPDATE_COMPLETE, onImgUpdComplete2);
	if (img.percentWidth > 0 && img.percentHeight > 0) {
		img.x -= img.width/10;
		img.y -= img.height/10;
	}
	
		var dot:Sprite = new Sprite();
//	img.graphics.clear();
		
	dot.graphics.beginFill(0xFFCC00);
	dot.graphics.drawCircle(img.contentWidth/2, img.contentHeight/2, 3);
	dot.graphics.endFill();
	img.addChild(dot);
}

private function displayImage(img_:String):void {
	var image:Image = new Image();
	
	image.source = IMAGES_PATH + "/" + img_;
	//			var myImage:BitmapData;
	//			var bmp:Bitmap = e.target.content as Bitmap;
	//			myImage = bmp.bitmapData;
	//			var mat:Matrix = new Matrix();
	//			mat.scale(.2, .2);
	//		    image.height = myImage.height*.2;
	//		    image.width = myImage.width*.2;
	//		    image.graphics.beginBitmapFill(myImage, mat, false, true);
	//		    image.graphics.drawRect(0, 0, image.width, image.height);
	//		    image.graphics.endFill();
	image.scaleContent = true;
	image.maintainAspectRatio = true;
	var scale:Number = Math.random()*10;
	
	image.percentWidth = scale;
	image.percentHeight = scale;

	image.x = Math.random() * GRAPH_WIDTH;
	image.y = Math.random() * GRAPH_HEIGHT;
	image.z = 0;
	image.toolTip = img_;
	image.addEventListener(MouseEvent.MOUSE_OVER, onHoverImage);
	image.addEventListener(MouseEvent.MOUSE_OUT, onHoverOutImage);
	image.addEventListener(FlexEvent.UPDATE_COMPLETE, onImgUpdComplete);
	
	PictureBox.addChild(image);

	images.push(image);
	imgZBuffer.sort(PictureBox);
	
	counter.text = images.length.toString();
	randomlySized = true;
}

/**
 * The auto adjustment will not occur in the Image control’s complete event.
 * This value will be updated in the last updateComplete event (the one after the complete event) 
 * @param e:Event
 * 
 */
private function onImgUpdComplete(e:Event):void {
	var img:Image = e.currentTarget as Image;
	img.removeEventListener(FlexEvent.UPDATE_COMPLETE, onImgUpdComplete);

	var dot:Sprite = new Sprite();
//	img.graphics.clear();
		
	dot.graphics.beginFill(0xFFCC00);
	dot.graphics.drawCircle(img.contentWidth/2, img.contentHeight/2, 3);
	dot.graphics.endFill();
	
	dot.graphics.lineStyle(1,0xFF0000);
	dot.graphics.drawRect(0,0,img.contentWidth, img.contentHeight);
	dot.graphics.lineTo(img.contentWidth, img.contentHeight);
	dot.graphics.moveTo(0, img.contentHeight);
	dot.graphics.lineTo(img.contentWidth, 0);
	
	img.addChild(dot);

}

private function onHoverOutImage(e:Event):void {
	var img:Image = e.currentTarget as Image;
	img.alpha = imgAlpha.value/100;
}

private function onHoverImage(e:Event):void {
	var img:Image = e.currentTarget as Image;
	img.alpha = 1;
	img.z--;
	trace(img.source);
	imgZBuffer.recursiveSort(PictureBox);
	img.z++;
}

private function loadDataFileFromURL():void {
	
	var fileName:String = "files.txt";
	var dataLoader:URLLoader = new URLLoader(new URLRequest(fileName));
	dataLoader.addEventListener(Event.COMPLETE, processData); 
	
	fileName = "result.txt";
	var dataLoader2:URLLoader = new URLLoader(new URLRequest(fileName));
	
	dataLoader2.addEventListener(Event.COMPLETE, loadData); 
	/*var newWindow:Window = new Window();
	newWindow.systemChrome = NativeWindowSystemChrome.NONE;
	newWindow.transparent = true;
	newWindow.title = "New Window";
	newWindow.width = 200;
	newWindow.height = 200;
	newWindow.open(true);*/
}

private function creationCompleteHandler(event: Event): void
{
	nativeWindow.x = (Capabilities.screenResolutionX - nativeWindow.width) / 2;
	nativeWindow.y = (Capabilities.screenResolutionY - nativeWindow.height) / 2;
}

private function loadDataFileFromFilesystem():void {
	var file:File = new File();
	file.nativePath = DATASET_ROOT+"/result.csv";
	trace (file.nativePath);
	var stream:FileStream = new FileStream();
	stream.open(file, FileMode.READ);
	// Read the entire contents of the file as a string
	var contents:String = stream.readUTFBytes( stream.bytesAvailable );
	
}

/**
 * Load statistical data from file
 * @param e Event
 * 
 */        
private function loadData(e:Event):void
{
	var file:String = e.target.data;
	var lines:Array = file.split('\n');
	var statistics:Array = lines[0].split(',');
	
	for (var i:Number = 2; i < lines.length; i++) {
		var data:Array = lines[i].split(',');
		if (data.length > 1) {
			statsArray.push(data);
		}
	}
	statsX.dataProvider = statistics;
	//statsX.labelField = "code";
	statsX.data = statistics;
	statsX.enabled = true;
	statsX.prompt = "Statistic";
	
	statsY.dataProvider = statistics;
	//statsY.labelField = "code";
	statsY.data = statistics;
	statsY.enabled = true;
	statsY.prompt = "Statistic";
	
}

private function chooseStat():void {
	var arrPar:Parallel = new Parallel();
	var image:Image;
	var statMaxX:Number = Number.MIN_VALUE;
	var statMinX:Number = Number.MAX_VALUE;
	var statMaxY:Number = Number.MIN_VALUE;
	var statMinY:Number = Number.MAX_VALUE;
	
	var statIsNumX:Boolean = false;
	var statIsNumY:Boolean = false;
	
	// get min and max (numerical) values if stat is numeric
	for each (var statLine:Array in statsArray) {
		if (!isNaN(statLine[statsX.selectedIndex])) {
			statMaxX = Math.max(statLine[statsX.selectedIndex], statMaxX);
			statMinX = Math.min(statLine[statsX.selectedIndex], statMinX);
			statIsNumX = true;
		}
		if (!isNaN(statLine[statsY.selectedIndex])) {
			statMaxY = Math.max(statLine[statsY.selectedIndex], statMaxY);
			statMinY = Math.min(statLine[statsY.selectedIndex], statMinY);
			statIsNumY = true;
		}
	}
	if (statIsNumX) {
		maxValueX.text = statMaxX.toString();
		minValueX.text = statMinX.toString();
	}
	else {
		maxValueX.text = "max";
		minValueX.text = "min";
	}
	if (statIsNumY) {
		maxValueY.text = statMaxY.toString();
		minValueY.text = statMinY.toString();
	}
	else {
		maxValueY.text = "max";
		minValueY.text = "min";
	}
	
	
	var statLine2:Array;
	
	var tX:Tween;
	var tY:Tween;
	var tScale:Tween;
	
	for (var i:int; i<images.length; i++) {
		image = images[i];
		statLine2 = statsArray[i];
		//image.toolTip = image.source.toString();
		if (statIsNumX)
		{
			//image.toolTip += "\nx:" + statLine2[statsX.selectedIndex].toString();
			tX = new Tween(image, 2, {x:(statLine2[statsX.selectedIndex]-statMinX)*GRAPH_WIDTH/(statMaxX-statMinX)});
		}
		else
			tX = new Tween(image, 2, {x:i*GRAPH_WIDTH/images.length});
		
		if (statIsNumY)
		{
			//image.toolTip += "\ny:" + statLine2[statsY.selectedIndex].toString();
			tY = new Tween(image, 2, {y:GRAPH_HEIGHT-(statLine2[statsY.selectedIndex]-statMinY)*GRAPH_HEIGHT/(statMaxY-statMinY)});
		}
		else
			tY = new Tween(image, 2, {y:GRAPH_HEIGHT-i*GRAPH_HEIGHT/images.length});

		arrPar.add(tX);
		arrPar.add(tY);
		
		if (randomlySized) {
			tScale = new Tween(image, 2, {percentWidth:10/image.scaleX, percentHeight:10/image.scaleY});
			arrPar.add(tScale);
		}
		
	}
	
	if (randomlySized) randomlySized = false;
	arrPar.play();
}

private function processData(e:Event):void {
	var pastHeader:Boolean = false;
	var lines:Array = e.target.data.split("\n");
	for each (var line:String in lines) {
		displayImage(line);
//		displayImage(line);
/*		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);

		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);

		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);
		displayImage(line);*/
	}
}

public function onLoad():void {
	systemManager.addEventListener(MouseEvent.MOUSE_WHEEL, doMouseWheel);
	PictureBox.removeAllChildren();
	imageLoader = new Loader();
	par = new Parallel();
	loadDataFileFromURL();
}

private function animate():void {
	for each (var image:Image in images)
	{
		var t0:Tween = new Tween(image, 10, {rotationY:360});
		var t1:Tween = new Tween(image, 5, {x:360})
			var seq:Sequence = new Sequence(t0,t1);
		par.add(seq);
	}
	par.play();
}

private function onAlphaChange(value:int):void {
	for each (var image:Image in images)
	{
		image.alpha = value/100;
	}
}

private function onZoomChanged(value:int):void {
	for each (var image:Image in images)
	{
		image.percentHeight = value;
		image.percentWidth = value;
	}
}

private function arrangeDiag():void {
	var arrPar:Parallel = new Parallel();
	var image:Image;
	for (var i:int; i<images.length; i++)
	{
		image = images[i];
		var t1:Tween = new Tween(image, 5, {x:i*GRAPH_WIDTH/images.length,y:GRAPH_HEIGHT-i*GRAPH_HEIGHT/images.length,z:-50,rotationY:30});
		arrPar.add(t1);
	}
	arrPar.play();
	rotate.value = 30;
}

private function slider_rollOver(evt:MouseEvent):void {
	Slider(evt.currentTarget).tickInterval = TICK_INTERVAL;
}

private function slider_rollOut(evt:MouseEvent):void {
	Slider(evt.currentTarget).tickInterval = 0;
}

private function onSliderMoved(value:int):void {
	for each (var image:Image in images) {
		image.rotationY = value;
	}
}
