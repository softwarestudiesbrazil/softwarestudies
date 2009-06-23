package extractor;

import java.awt.image.BufferedImage;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DecimalFormat;

import javax.imageio.ImageIO;

import misc.ImageUtil;

public class ColorInspector {

	BufferedImage bimg;
	
	
	public ColorInspector() {
		bimg = null;
	}
	
	public void loadImage(File imageFile) {
		try {
			bimg = ImageIO.read(imageFile);
		}
		catch (IOException e) {
			return;
		}
	}
	
	private int getIndex(int rIndex, int gIndex, int bIndex, int numBlock) {
		return (rIndex*numBlock + gIndex)*numBlock+bIndex;
	}
	
	private void normalize(double[] d, double max) {
		double sum = 0;
		for (int i=0;i<d.length;i++) sum += d[i];
		for (int i=0;i<d.length;i++) d[i] = d[i] * max / sum;
	}
	
	public double[] processRGB(int numBlock) {
		
		if (bimg == null) return null;

		double[] ret = new double[numBlock*numBlock*numBlock];
	
		int[] rgb = ImageUtil.getRgbFromBufferedImage(bimg);
		
		int w = bimg.getWidth();
		int h = bimg.getHeight();
		
		for (int i=0;i<w*h;i++) {
			
			int b = rgb[i*3];
			int g = rgb[i*3+1];
			int r = rgb[i*3+2];
			
			int rIndex = r * numBlock / 256;
			if (rIndex == numBlock) rIndex--;
			
			int gIndex = g * numBlock / 256;
			if (gIndex == numBlock) gIndex--;
			
			int bIndex = b * numBlock / 256;
			if (bIndex == numBlock) bIndex--;
			
			ret[getIndex(rIndex,gIndex,bIndex,numBlock)] += 1;
		}

		normalize(ret,100);
		
		return ret;
		
	}

public double[] processHSV(int numBlock) {
		
		if (bimg == null) return null;

		double[] ret = new double[numBlock*numBlock*numBlock];
	
		int[] rgb = ImageUtil.getRgbFromBufferedImage(bimg);
		
		int w = bimg.getWidth();
		int h = bimg.getHeight();
		
		for (int i=0;i<w*h;i++) {
			
			int b = rgb[i*3];
			int g = rgb[i*3+1];
			int r = rgb[i*3+2];
		
			double[] hsv = ImageUtil.rgb2hsv(r, g, b);
			
			int hIndex = (int)(hsv[0] * numBlock);
			if (hIndex==numBlock) hIndex--;
			
			int sIndex = (int)(hsv[1] * numBlock);
			if (sIndex==numBlock) sIndex--;
			
			int vIndex = (int)(hsv[2] * numBlock);
			if (vIndex==numBlock) vIndex--;
			
			ret[getIndex(hIndex,sIndex,vIndex,numBlock)] += 1;
		}

		normalize(ret,100);
		
		return ret;
		
	}

	
public void outputRGB(File outputFile, double[] frequency, int numBlock) {
	try {
		BufferedWriter bw = new BufferedWriter(new FileWriter(outputFile));
		bw.write("mean_R\tmean_G\tmean_B\tpercentage\n");
		bw.write("double\tdouble\tdouble\tdouble\n");
		for (int i=0;i<numBlock;i++) {
			for (int j=0;j<numBlock;j++) {
				for (int k=0;k<numBlock;k++) {
					double blockSize = 256.0 / numBlock;
					double meanR = i*blockSize + blockSize/2.0;
					double meanG = j*blockSize + blockSize/2.0;
					double meanB = k*blockSize + blockSize/2.0;
					bw.write(meanR+"\t");
					bw.write(meanG+"\t");
					bw.write(meanB+"\t");
					bw.write(frequency[getIndex(i,j,k,numBlock)]+"\n");
				}
			}
		}
		bw.close();
	}
	catch (IOException e) {
		e.printStackTrace();
	}
}

public void outputHSV(File outputFile, double[] frequency, int numBlock) {
	try {
		BufferedWriter bw = new BufferedWriter(new FileWriter(outputFile));
		bw.write("mean_H\tmean_S\tmean_V\tpercentage\n");
		bw.write("double\tdouble\tdouble\tdouble\n");
		DecimalFormat f = new DecimalFormat("0.0000");
		for (int i=0;i<numBlock;i++) {
			for (int j=0;j<numBlock;j++) {
				for (int k=0;k<numBlock;k++) {
					double blockSize = 1.0/numBlock;
					double meanH = i*blockSize + blockSize/2.0;
					double meanS = j*blockSize + blockSize/2.0;
					double meanV = k*blockSize + blockSize/2.0;
					bw.write(f.format(meanH)+"\t");
					bw.write(f.format(meanS)+"\t");
					bw.write(f.format(meanV)+"\t");
					bw.write(frequency[getIndex(i,j,k,numBlock)]+"\n");
				}
			}
		}
		bw.close();
	}
	catch (IOException e) {
		e.printStackTrace();
	}
}

	
	public static void main(String[] args) {

		if (args.length != 2) {
			System.out.println("Please call using Python wrapper");
		}
		
		String input = args[0];
		int numBlock = Integer.parseInt(args[1]);
		String outputPrefix = new String(input);
			
		int p = outputPrefix.lastIndexOf(".");
		outputPrefix = outputPrefix.substring(0, p);
		
		String rgbOutput = outputPrefix + ".rgb.txt";
		String hsvOutput = outputPrefix + ".hsv.txt";
		
		ColorInspector ci = new ColorInspector();
		ci.loadImage(new File(input));
		double[] temp;
		temp = ci.processRGB(numBlock);
		ci.outputRGB(new File(rgbOutput), temp, numBlock);
		//temp = ci.processHSV(numBlock);
		//ci.outputHSV(new File(hsvOutput), temp, numBlock);
		
	}
	
}
