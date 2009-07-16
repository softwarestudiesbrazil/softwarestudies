package extractor;

import java.awt.image.BufferedImage;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import javax.imageio.ImageIO;

import misc.ImageUtil;

public class LineFeature {
	
	private static final int MAX_LINE_NUM = 100000;

	private static int[][] DIRECTIONS = new int[][] {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}};
	
	private double sigma;
	private int gaussianWidth;
	private double lowThreshold;
	private double highThreshold;
	private int lengthThreshold;
	
	/** line number of each pixel */
	private int[] lineNo;
	
	/** length of each line */
	private double[] lineLength = new double[MAX_LINE_NUM];
	
	/** absolute length of each line */
	private double[] lineAbsLength = new double[MAX_LINE_NUM];
	
	/** number of turns on each line */
	private int[] turnCount = new int[MAX_LINE_NUM];
	
	/** line dominant orientation */
	private int[] lineOrientation = new int[MAX_LINE_NUM];
	
	/** line angle */
	private double[] lineAngle = new double[MAX_LINE_NUM];
	
	/** HOG */
	private long[] histogramOfGradients = new long[4];
	
	/** number of lines */
	private int nLine;
	
	/** current index for lineLength and turnCount */
	private int currentLineNo;
	
	/** magnitude of gradients */
	private double[] magnitude;

	/** width of image */
	private int width;
	
	/** height of image */
	private int height;
	
	
	
	public LineFeature(double low, double high, int gWidth, double sgm, int lengthThresh) {
		sigma = sgm;
		gaussianWidth = gWidth;
		lowThreshold = low;
		highThreshold = high;
		lengthThreshold = lengthThresh;
	}
	
	
	
	private void lineTrace() {

		lineNo = new int[width * height];
		currentLineNo = 1;
		
		int count;
		int diff;
		int[][] info = new int[2][];
		int[] d = new int[2];
		int offset = 0;
		for (int y=0; y < height;y++) {
			for (int x=0; x < width;x++) {
				if (lineNo[offset] == 0 && 
						magnitude[offset] >= highThreshold) {
		
					lineNo[offset] = currentLineNo;
					
					count = 0;
					
					done:
					for (int dir=0;dir<DIRECTIONS.length;dir++) {
						int x2 = x+DIRECTIONS[dir][0];
						int y2 = y+DIRECTIONS[dir][1];
						int i2 = x2 + y2*width;
						if (i2 >= 0 && i2 < magnitude.length
								&& lineNo[i2] == 0 
								&& magnitude[i2] >= lowThreshold) {

							d[count] = dir;
							info[count] = follow(x2, y2, i2, dir); 
							
							count++;
							if (count == 2) break done;
						}
					}

					if (count > 0) {
					
						int dx,dy;
						if (count == 1) {
							dx = info[0][7] - x;
							dy = info[0][8] - y;
						}
						else {
							diff = (d[1] - d[0] + 8) % 8;
							if (diff == 0) info[0][4]++;
							else if (diff == 3 || diff == 4) info[0][6]++;
							else info[0][5]++;
						
							info[0][4] += info[1][4];
							info[0][5] += info[1][5];
							info[0][6] += info[1][6];
							
							info[0][0] += info[1][0];
							info[0][1] += info[1][1];
							info[0][2] += info[1][2];
							info[0][3] += info[1][3];
							
							dx = info[0][7] - info[1][7];
							dy = info[0][8] - info[1][8];
						}
						
						int max = -1, max_idx = 0;
						for (int i=0;i<4;i++) {
							if (info[0][i] > max) {
								max = info[0][i];
								max_idx = i;
							}
						}
						 
						lineLength[currentLineNo] = info[0][0]+info[0][2]+Math.sqrt(2)*(info[0][1]+info[0][3]);
						turnCount[currentLineNo] = info[0][5] + info[0][6];
						lineAbsLength[currentLineNo] = Math.sqrt(Math.pow(dx,2)+ Math.pow(dy,2));
						lineOrientation[currentLineNo] = max_idx;
						lineAngle[currentLineNo] = Math.atan2(Math.abs(dy), dx);
						
						//System.out.println("l=" + lineLength[currentLineNo]);
						
						
						
						
						currentLineNo++;
					}
					else {
						lineNo[offset] = -1;
					}
					 
				}
				offset++;
			}
		}
		
		nLine = currentLineNo - 1;
		
 	}
 
	private int[] follow(int x1, int y1, int i1, int dir) {
		
		// ret[0] = count for 0 degree 
		// ret[1] = count for 45 degree
		// ret[2] = count for 90 degree
		// ret[3] = count for 135 degree
		
		// ret[4] = number of 0 degree turns
		// ret[5] = number of 45/-45/135/-135 degree turns
		// ret[6] = number of 90/-90 degree turns
		
		// ret[7] = last x
		// ret[8] = last y
		
		int[] ret = new int[9];
		int nextDir = dir; 
		boolean stillGoing;
		
		while (true) {
			
			lineNo[i1] = currentLineNo;
			ret[dir % 4]++;
			
			stillGoing = false;
			
			for (int k=0;k<DIRECTIONS.length - 1;k++) {
					
				if (k%2==0) {
					nextDir = (dir+(k+1)/2)%DIRECTIONS.length;
				}
				else {
					nextDir = (dir-(k+1)/2+DIRECTIONS.length)%DIRECTIONS.length;
				}
				
				int x2 = x1+DIRECTIONS[nextDir][0];
				int y2 = y1+DIRECTIONS[nextDir][1];
				int i2 = y2*width + x2;
				
				if (i2 >= 0 && i2 < magnitude.length
						&& lineNo[i2] == 0 
						&& magnitude[i2] >= lowThreshold) {
					
						//System.out.printf("From (%d,%d)[%f] to (%d,%d)[%f]\n",x1,y1,magnitude[i1],x2,y2,magnitude[i2]);
						x1 = x2;
						y1 = y2;
						i1 = i2;
						dir = nextDir;
						
						// update turn info
						if (k == 0) ret[4]++;
						else if (k == 3 || k == 4) ret[6]++;
						else ret[5]++;
						
						stillGoing = true;
						break;
				}
			}		
			
			// done, return
			if (!stillGoing) {
				ret[7] = x1;
				ret[8] = y1;
				return ret;
			}
		}
	}
	
	
	public void process(File imageFile) {
		try {
			BufferedImage bimg = ImageIO.read(imageFile);
			
			// if type of imageFile is not supported 
			if (bimg == null) return;
		
			width = bimg.getWidth();
			height = bimg.getHeight();
			int[] rgbs = new int[width*height];
			bimg.getRGB(0, 0, width, height, rgbs, 0, width);
			
			//double[] gray = new double[width*height];
			double[][] channel = new double[3][width*height];
			
			for (int j=0; j < rgbs.length; j++) {
				int b = rgbs[j] & 0xff;
				int g = (rgbs[j] >> 8) & 0xff;
				int r = (rgbs[j] >> 16) & 0xff;
				
				channel[0][j] = r;
				channel[1][j] = g;
				channel[2][j] = b;
				
				//gray[j] = 0.299f * r + 0.587f * g + 0.114f * b;
			}
			
			// normalize contrast
			//gray = ImageUtil.normalizeContrastByteImage(gray);
					
			// apply gaussian filer to remove noise
			//gray = ImageUtil.convolve(gray, width, height, 
			//                          ImageUtil.getGaussianKernel(gaussianWidth, sigma), 
			//                          gaussianWidth, gaussianWidth, ImageUtil.BORDER_COPY);
			channel[0] = ImageUtil.convolve(channel[0], width, height, 
			                          ImageUtil.getGaussianKernel(gaussianWidth, sigma), 
			                          gaussianWidth, gaussianWidth, ImageUtil.BORDER_COPY);
			channel[1] = ImageUtil.convolve(channel[1], width, height, 
			                          ImageUtil.getGaussianKernel(gaussianWidth, sigma), 
			                          gaussianWidth, gaussianWidth, ImageUtil.BORDER_COPY);
			channel[2] = ImageUtil.convolve(channel[2], width, height, 
			                          ImageUtil.getGaussianKernel(gaussianWidth, sigma), 
			                          gaussianWidth, gaussianWidth, ImageUtil.BORDER_COPY);

			
			// compute gradient using [-1 0 1] and its transpose
			double[] gx = new double[width*height];
			double[] gy = new double[width*height];
			
			//gx = ImageUtil.convolve(gray,width,height,new double[] {-1,0,1}, 3, 1, ImageUtil.BORDER_ZERO); 
			//gy = ImageUtil.convolve(gray,width,height,new double[] {-1,0,1}, 1, 3, ImageUtil.BORDER_ZERO);

			double[][] channelGx = new double[3][];
			double[][] channelGy = new double[3][];
			channelGx[0] = ImageUtil.convolve(channel[0],width,height,new double[] {-1,0,1}, 3, 1, ImageUtil.BORDER_ZERO);
			channelGy[0] = ImageUtil.convolve(channel[0],width,height,new double[] {-1,0,1}, 1, 3, ImageUtil.BORDER_ZERO);
			
			channelGx[1] = ImageUtil.convolve(channel[2],width,height,new double[] {-1,0,1}, 3, 1, ImageUtil.BORDER_ZERO);
			channelGy[1] = ImageUtil.convolve(channel[2],width,height,new double[] {-1,0,1}, 1, 3, ImageUtil.BORDER_ZERO);
			
			channelGx[2] = ImageUtil.convolve(channel[2],width,height,new double[] {-1,0,1}, 3, 1, ImageUtil.BORDER_ZERO);
			channelGy[2] = ImageUtil.convolve(channel[2],width,height,new double[] {-1,0,1}, 1, 3, ImageUtil.BORDER_ZERO);
			
			for (int i=0;i<width*height;i++) {
				//gx[i] = Math.max(Math.max(channelGx[0][i], channelGx[1][i]), channelGx[2][i]);
				//gy[i] = Math.max(Math.max(channelGy[0][i], channelGy[1][i]), channelGy[2][i]);
				gx[i] = channelGx[0][i] + channelGx[1][i] + channelGx[2][i];
				gy[i] = channelGy[0][i] + channelGy[1][i] + channelGy[2][i];
			}
			
 			
			// apply non-maximum suppression
			magnitude = ImageUtil.nonMaxSuppress(gx, gy, width, height, gaussianWidth);

			// compute HOG
			double EPS = 1e-7;
			for (int i=0;i<width*height;i++) {
				if (magnitude[i] != 0) {
					double dx = gx[i];
					double dy = Math.abs(gy[i]);
					if (dx > EPS) {
						if (dy > 2.5 * dx) histogramOfGradients[2]++; // 90
						else if (dy < 0.4 * dx) histogramOfGradients[0]++; // 0
						else histogramOfGradients[1]++; // 45
					}
					else if (dx < -EPS){
						if (dy > 2.5 * -dx) histogramOfGradients[2]++; // 90
						else if (dy < 0.4 * -dx) histogramOfGradients[0]++; // 0
						else histogramOfGradients[3]++; // 135
					}
					else {
						histogramOfGradients[2]++;  // 90
					}
				}
			}
			
			// trace line
			lineTrace();
			
			
		} catch (IOException e) {
			return;
		}
	}

	
	public void outputSummary(File outputFile) {
		if (outputFile != null) {
			try {
				BufferedWriter bw = new BufferedWriter(new FileWriter(outputFile));
				int total = 0;
				int totalTurns = 0;
				double totalLength = 0;
				double totalStraightness = 0.0;
				double totalAngle = 0.0;
				for (int i=1;i<=nLine;i++) {
					if (lineLength[i] >= lengthThreshold) {
						//bw.write("" + (total+1) + "\t" + lineLength[i] + "\t" + turnCount[i] + "\n");
						totalTurns += turnCount[i];
						totalLength += lineLength[i];
						totalStraightness += (lineAbsLength[i]/lineLength[i]);
						totalAngle += (lineAngle[i]*180.0/Math.PI);
						total++;
					}
				}
				double imgSize = this.width * this.height;
				bw.write("gaussianWidth=\t" + gaussianWidth + "\n");
				bw.write("sigma=\t" + sigma + "\n");
				bw.write("lowThreshold=\t" + lowThreshold + "\n");
				bw.write("highThreshold=\t" + highThreshold + "\n");
				bw.write("lenghtThreshold=\t" + lengthThreshold + "\n");
				bw.write("image_size=\t" + imgSize + "\n");
				bw.write("total_number_of_lines_over_image_size=\t" + ((double)total/imgSize) + "\n");
				bw.write("average_length_over_image_size=\t" + (((double)totalLength/total)/imgSize) + "\n");
				bw.write("average_number_of_turns_over_image_size=\t" + (((double)totalTurns/total)/imgSize) + "\n");
				bw.write("average_straightness=\t" + totalStraightness/total + "\n");
				bw.write("average_line_angle=\t" + totalAngle/total + "\n");
				bw.close();
			}
			catch (IOException e) {
				return;
			}			
		}
	}
	
	public void outputImage(File outputImage) {
		
		if (outputImage != null) {
			try {
				BufferedImage bimg = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);

				int[] rgbs = new int[width*height];

				int[] color = new int[nLine+1];
				for (int i=0;i <= nLine; i++) {
					color[i] = (int)(Math.random() * 0xffffff);
				}

				for (int k=0;k< width*height;k++) {
					int v = (lineNo[k] > 0 ? color[lineNo[k] - 1] : 0);
					if (lineNo[k] > 0 && lineLength[lineNo[k]] < lengthThreshold) v = 0;
					rgbs[k] = 0 | (v << 16) | (v << 8) | v;
				}
				bimg.setRGB(0, 0, width, height, rgbs, 0, width);

				ImageIO.write(bimg, "png", outputImage);

			} catch (IOException e) {
				return;
			}
		}
		
	}
	
	
	public void outputLineDetail(File f) {
		if (f != null) {
			try {
				BufferedWriter bw = new BufferedWriter(new FileWriter(f));
				bw.write("number\tturns\tlength\t|length|\tstraightness\tangle\n");
				for (int i=1;i<=nLine;i++) {
					if (lineLength[i] >= lengthThreshold) {
						bw.write("" + i);
						bw.write("\t" + turnCount[i]);
						bw.write("\t" + lineLength[i]);
						bw.write("\t" + lineAbsLength[i]);
						bw.write("\t" + (lineAbsLength[i]/lineLength[i]));
						/*
						switch (lineOrientation[i]) {
							case 0:
								bw.write("\t0");
								break;
							case 1:
								bw.write("\t45");
								break;
							case 2:
								bw.write("\t90");
								break;
							case 3:
								bw.write("\t135");
								break;
						}
						*/
						// convert to degree
						bw.write("\t" + (lineAngle[i]*180.0/Math.PI));
						bw.write("\n");
					}
				}
				bw.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void outputHog(File f) {
		if (f != null) {
			try {
				BufferedWriter bw = new BufferedWriter(new FileWriter(f));
				bw.write("degree\tcounts\n");
				bw.write("0\t" + histogramOfGradients[0] + "\n");
				bw.write("45\t" + histogramOfGradients[1] + "\n");
				bw.write("90\t" + histogramOfGradients[2] + "\n");
				bw.write("135\t" + histogramOfGradients[3] + "\n");
				bw.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	public static void main(String[] args) {
		
		if (args.length != 9) {
			System.out.println("Please run this program using Python wrapper.");
			return;
		}
		
		String input = args[0];
		String outputImage = args[1];
		String summaryFile = args[2];
		String detailFile = args[3];

		double low = Double.parseDouble(args[4]);
		double high = Double.parseDouble(args[5]);
		int kWidth = Integer.parseInt(args[6]);
		double sigma = Double.parseDouble(args[7]);
		int lineThreshold = Integer.parseInt(args[8]);

		LineFeature lineFeature = new LineFeature(low,high,kWidth,sigma,lineThreshold);
		lineFeature.process(new File(input));
		lineFeature.outputImage(new File(outputImage));
		lineFeature.outputSummary(new File(summaryFile));
		lineFeature.outputLineDetail(new File(detailFile));
				
	}
	
}
