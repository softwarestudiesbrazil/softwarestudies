package misc;

import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.awt.image.ConvolveOp;
import java.awt.image.Kernel;

public class ImageUtil {
	
	public static final int BORDER_ZERO = 0;
	public static final int BORDER_COPY = 1;
	public static final int BORDER_PARTIAL = 2;
	
	public static double rgb2gray(int r, int g ,int b) {
	  return 0.2989 * r + 0.5870 * g + 0.1140 * b; 
	}
	
	
	public static double[] rgb2hsv(int r, int g, int b) {
		
		double[] hsv = new double[3];
		
		int min; // Min. value of RGB
		int max; // Max. value of RGB
		int delMax; // Delta RGB value

		if (r > g) {
			min = g;
			max = r;
		}
		else {
			min = r;
			max = g;
		}
		if (b > max) max = b;
		if (b < min) min = b;

		delMax = max - min;
		
		double H = 0, S;
		double V = max / 255f;

		if (delMax == 0) {
			H = 0;
			S = 0;
		}
		else {
			S = (double)delMax / max;
			if (r == max) H = ((double)(g - b) / (double) delMax) * 60;
			else if (g == max) H = (2 + (double)(b - r) / (double) delMax) * 60;
			else if (b == max) H = (4 + (double)(r - g) / (double) delMax) * 60;
		}
		if (H < 0) H += 360;
		if (H > 360) H -= 360;
		
		hsv[0] = H / 360f;
		hsv[1] = S;
		hsv[2] = V;
		
		return hsv;
	}
	
	public static BufferedImage createBufferedImageFromRgb(int[] rgb, int w, int h) {
		BufferedImage out = new BufferedImage(w,h,BufferedImage.TYPE_INT_RGB);

		int[] rgbs = new int[w*h];
		for (int i=0;i<w*h;i++) {
			rgbs[i] = 0 | (rgb[i*3]) | (rgb[i*3+1]<<8) | (rgb[i*3+2]<<16);
		}
		
		out.setRGB(0, 0, w, h, rgbs, 0, w);
		
		return out;
	}
	
	public static int[] getRgbFromBufferedImage(BufferedImage bimg) {

		int w = bimg.getWidth();
		int h = bimg.getHeight();
		
		int[] rgbs = new int[w*h];
		int[] ret = new int[w*h*3];

		bimg.getRGB(0, 0, w, h, rgbs, 0, w);
	
		for (int i=0;i<w*h;i++) {
			ret[i*3]   = rgbs[i] & 0xff;
			ret[i*3+1] = (rgbs[i] >> 8) & 0xff;
			ret[i*3+2] = (rgbs[i] >> 16) & 0xff;
		}
		
		return ret;
	}
	
	
	private static double norm(double dx, double dy) {
		return Math.sqrt(dx*dx + dy*dy);
	}
	
	public static double[] nonMaxSuppress(double[] xGradient, double[] yGradient, int width, int height, int border) {
		
		double[] magnitude = new double[width * height];
		
		for (int y = border; y < height-border; y++) {
			for (int x = border; x < width-border; x++) {
				int index = y * width + x;
				int indexN = index - width;
				int indexS = index + width;
				int indexW = index - 1;
				int indexE = index + 1;
				int indexNW = indexN - 1;
				int indexNE = indexN + 1;
				int indexSW = indexS - 1;
				int indexSE = indexS + 1;
				
				double xGrad = xGradient[index];
				double yGrad = yGradient[index];
				double gradMag = norm(xGrad, yGrad);

				double nMag = norm(xGradient[indexN], yGradient[indexN]);
				double sMag = norm(xGradient[indexS], yGradient[indexS]);
				double wMag = norm(xGradient[indexW], yGradient[indexW]);
				double eMag = norm(xGradient[indexE], yGradient[indexE]);
				double neMag = norm(xGradient[indexNE], yGradient[indexNE]);
				double seMag = norm(xGradient[indexSE], yGradient[indexSE]);
				double swMag = norm(xGradient[indexSW], yGradient[indexSW]);
				double nwMag = norm(xGradient[indexNW], yGradient[indexNW]);
				double tmp;
				if (xGrad * yGrad <=  0 
					? Math.abs(xGrad) >= Math.abs(yGrad)
						? (tmp = Math.abs(xGrad * gradMag)) >= Math.abs(yGrad * neMag - (xGrad + yGrad) * eMag) 
							&& tmp > Math.abs(yGrad * swMag - (xGrad + yGrad) * wMag) 
						: (tmp = Math.abs(yGrad * gradMag)) >= Math.abs(xGrad * neMag - (yGrad + xGrad) * nMag) 
							&& tmp > Math.abs(xGrad * swMag - (yGrad + xGrad) * sMag)
					: Math.abs(xGrad) >= Math.abs(yGrad)
						? (tmp = Math.abs(xGrad * gradMag)) >= Math.abs(yGrad * seMag + (xGrad - yGrad) * eMag)
							&& tmp > Math.abs(yGrad * nwMag + (xGrad - yGrad) * wMag)
						: (tmp = Math.abs(yGrad * gradMag)) >= Math.abs(xGrad * seMag + (yGrad - xGrad) * sMag)
							&& tmp > Math.abs(xGrad * nwMag + (yGrad - xGrad) * nMag)
					) {
					magnitude[index] = gradMag;
				} else {
					magnitude[index] = 0;
				}
			}
		}	
		return magnitude;
	}
	
	public static double[] normalizeContrastByteImage(double[] oneChannel) {
		int size = oneChannel.length;
		int[] histogram = new int[256];
		double[] output = new double[size];
		
		for (int i = 0; i < size; i++) {
			int d = (int)oneChannel[i];
			histogram[d]++;
		}
		int[] remap = new int[256];
		int sum = 0;
		int j = 0;
		for (int i = 0; i < histogram.length; i++) {
			sum += histogram[i];
			int target = sum*255/size;
			for (int k = j+1; k <=target; k++) {
				remap[k] = i;
			}
			j = target;
		}
		
		for (int i = 0; i < size; i++) {
			int d = (int)oneChannel[i];
			output[i] = remap[d];
		}
		return output;
	}
	
	
	public static double[] convolve(double[] oneChannel, int w, int h, double[] kernel, int kw, int kh, int borderMode) {
		
		double[] ret = new double[oneChannel.length];
		
		int offsetX = (kw-1)/2;
		int offsetY = (kh-1)/2;
		
		for (int y=0;y<h;y++) {
			for (int x=0;x<w;x++) {
				
				double sum = 0;

				int offsetK = 0;
				int startX = x - offsetX;
				int stopX  = x + (kw - offsetX);
				int startY = y - offsetY;
				int stopY  = y + (kh - offsetY);
				
				boolean done = false;
				
				convolving:
				for (int yy=startY;yy<stopY;yy++) {
					for (int xx=startX;xx<stopX;xx++) {
						int idx = yy*w + xx;
						if (idx >= 0 && idx < oneChannel.length) {
							sum += oneChannel[yy*w+xx] * kernel[offsetK]; 
						}
						else {
							switch (borderMode) {
								case BORDER_ZERO:
									ret[y*w+x] = 0.0;
									done = true;
									break convolving;
								case BORDER_COPY:
									ret[y*w+x] = oneChannel[y*w+x];
									done = true;
									break convolving;
							}
						}
						offsetK++;
					}
				}
				
				if (!done) {
					ret[y*w+x] = sum;
				}
				
			}
		}
		return ret;
	}
	
	public static ConvolveOp getVerticalSobelOp() {
		float[] vsobel = {-1f, -2f, -1f,
						   0f,  0f,  0f,
						   1f,  2f,  1f};
		return getConvolveOp(new Kernel(3,3,vsobel));
	}
	
	public static ConvolveOp getHorizontalSobelOp() {
		float[] hsobel = {1f,  0f, -1f,
						  2f,  0f, -2f,
						  1f,  0f, -1f};
		return getConvolveOp(new Kernel(3,3,hsobel));
	}
	
	
	private static double gaussian2d(double dx, double dy, double sigma) {
		double sigma_sq = sigma * sigma;
		return Math.exp(-(0.5f*dx*dx/sigma_sq + 0.5f*dy*dy/sigma_sq));
	}
	
	public static double[] getGaussianKernel(int kwidth, double sigma) {
		double[] gaussian = new double[kwidth*kwidth];
		double sum = 0;
		for (int i=0;i<kwidth;i++) {
			for (int j=0;j<kwidth;j++) {
				double dx = j - 0.5*(kwidth-1);
				double dy = i - 0.5*(kwidth-1);
				double g = gaussian2d(dx,dy,sigma);
				gaussian[i*kwidth+j] = g;
				sum += g;
			}
		}
		// normalize
		for (int i=0;i<kwidth;i++) {
			for (int j=0;j<kwidth;j++) {
				gaussian[i*kwidth+j] /= sum;
			}
		} 
		return gaussian;
	}
	

	public static ConvolveOp getConvolveOp(Kernel kernel) {
		RenderingHints hints =
			new RenderingHints(RenderingHints.KEY_RENDERING,
							   RenderingHints.VALUE_RENDER_DEFAULT);
		return new ConvolveOp(kernel,ConvolveOp.EDGE_ZERO_FILL,hints);
	}
	
	
}
