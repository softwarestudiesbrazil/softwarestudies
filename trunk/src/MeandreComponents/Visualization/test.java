import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Writer;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;


public class test {
	/**
	 * @param args
	 * @throws IOException
	 */
	public static void main(String[] args) throws IOException{
	/*	
		File dir =  new File("C:\\Users\\ommirbod\\Desktop\\Other\\test");
		if(!dir.exists()){
			if (dir.mkdir()) {
				System.out.println("Directory is created!");
			} else {
				System.out.println("Failed to create directory!");
			}
		}
		File file = new File(dir+"test.txt");
		Writer out = new BufferedWriter(new FileWriter(file));
		out.write("Hello"+"\n"); //write one line to file
		out.close();
	*/
		
		/*
		DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss");
		Date date = new Date();
		System.out.println(dateFormat.format(date));
		System.out.println(dateFormat.format(date) instanceof String);
		
		*/
		
		/*
		String montage = "Montage -w 4000 -h 3000 -tilewidth 100 -tileheight 100 -sort1 BrightnessMean -label Year /Documents/Meandre/images/results/resultCollection.txt";
		String ResultFile = montage.substring(montage.lastIndexOf(" ")+1);
		System.out.println(ResultFile);
		String parameters = montage.substring(0, montage.lastIndexOf(" ")-1);
		System.out.println(parameters);
		*/
		/*
		String clientFilePath = "/document/folder1/folder2/folder3/path.txt";
		String metapath = clientFilePath.substring(0,clientFilePath.lastIndexOf("/"))+"/meta.txt";
		System.out.println(metapath);
		
		*/
		/*
		String t = "this is a test";
		System.out.println(t.lastIndexOf("this"));
		*/
		/*
		String file = "/Users/culturevis/Documents/MeandreTesting/100UserDigitalTraditionalArt.tsv";
		Writer output = new BufferedWriter(new FileWriter("/Users/culturevis/Documents/MeandreTesting/filteredTraditionArt.txt"));
		BufferedReader readbuffer = new BufferedReader(new FileReader(file));
		String filepath = "/Volumes/SWS06/DeviantART Project/Images";
		String strRead; //reads in each line in Reader
		while ((strRead=readbuffer.readLine())!=null){
			String splitarray[] = strRead.split("\t");
			//System.out.println(filepath+"/"+splitarray[1]+"\"");
			if((new File(filepath+"/"+splitarray[1])).exists()){
				output.write("\""+filepath + "/" + splitarray[1]+"\""+"\n"); //write one line to file
			}
			//output.write(filepath + "/" + splitarray[1]+"\""+"\n");

		}
		output.close();
		*/
		//String command = "C:\\Users\\ommirbod\\Desktop\\Other\\sortTest.csv 0i+ 2d+;montage -tile 1x9 -sort num1 num2 C:\\Users\\ommirbod\\Desktop\\Other\\sortTest.csv";
		//String[] commandToken = command.split(";");
		//String[] cmdCommand = {"cmd ","java -jar C:\\Users\\ommirbod\\Desktop\\Other\\csvsort.jar "+"\""+commandToken[0]+"\""};
		//System.out.println(cmdCommand[0]+cmdCommand[1]);
		
		/*
		String[]headCommand = {"sh", "-c", "head -n +2 sortTest.csv > sortTest.head.csv"};
		String[]tailCommand = {"sh", "-c", "tail -n +3 sortTest.csv > sortTest.tail.csv"};
		String[]sortCommand = {"sh", "-c","java -jar csvsort.jar "+"sortTest.tail.csv 0i+ 2d+"};
		String[]joinCommand = {"sh", "-c","cat sortTest.head.csv sortTest.tail.csv > sortTest.csv;rm sortTest.tail.csv;rm sortTest.head.csv"};
		
		Runtime rt = Runtime.getRuntime();
		Process p = null;
		try {
			p = rt.exec(headCommand);
			p.waitFor();
			p = rt.exec(tailCommand);
			p.waitFor();
			p = rt.exec(sortCommand);
			p.waitFor();
			p = rt.exec(joinCommand);
			p.waitFor();
		} catch(Exception e){e.printStackTrace();}
		
		
		*/
/*		
		 BufferedReader stdInput = new BufferedReader(new 
	               InputStreamReader(p.getInputStream()));
	          BufferedReader stdError = new BufferedReader(new 
	               InputStreamReader(p.getErrorStream()));
	          // read the output from the command
	          String s = null;
	          System.out.println("Here is the standard output of the command:\n");
	          while ((s = stdInput.readLine()) != null) {
	              System.out.println(s);
	          }
	          // read any errors from the attempted command
	          System.out.println("Here is the standard error of the command (if any):\n");
	          while ((s = stdError.readLine()) != null) {
	              System.out.println(s);
	          }
*/

		
		/*
		int sortIndex = command.lastIndexOf("sort");
		System.out.println(sortIndex);
		if(sortIndex != -1){
			String sortCommand = command.substring(command.lastIndexOf("sort")+5,command.indexOf("/")).trim();
			String file = command.substring(command.indexOf("/"),command.length());
			System.out.println(file);
			System.out.println(sortCommand);
		}
		*/
		
		String command = "montage -x 12 -y 14 -z 16 -sort 2i- 4d-";
		//String newstr = command.replaceAll("-sort[^.]*", "");
		//System.out.println(newstr);
/*		
		boolean flag = false;
		ArrayList<String> sortargs = new ArrayList<String>();
		String[] commandToken = command.split("\\s");
		String filename = "";
		for(int i=0;i<commandToken.length;i++){
			System.out.println(commandToken[i]+" "+flag);
			if(commandToken[i].equals("-sort")){
				System.out.println("flag is now true");
				flag = true;
				continue;
			}
			if(flag){
				if(commandToken[i].charAt(0) != ('-'))
					sortargs.add(commandToken[i]);
				else
					flag = false;
			}
		}
		
		for(int i=0;i<sortargs.size();i++)
			System.out.println(sortargs.get(i));
*/		
		/*
		String[] montageArgs = command.split("-sort");
		System.out.println(montageArgs[0]);
		*/
		
		//java -jar csvsort.jar /Users/culturevis/Documents/MeandreTesting/ImageAnalyze/images/25_2013-01-02_12-36-37/resultsCollection.txt.tail.csv 0i+ 2d+
		//head -n +2 /Users/culturevis/Documents/MeandreTesting/ImageAnalyze/images/25_2013-01-02_12-36-37/resultsCollection.txt > /Users/culturevis/Documents/MeandreTesting/ImageAnalyze/images/25_2013-01-02_12-36-37/resultsCollection.txt.head.csv
		
		String montageCommand = "batch---/Document/folder1/folder2/test.txt";
		if(montageCommand.indexOf("batch---")!= -1){
			String[] stringarray = montageCommand.split("---");
			System.out.println(stringarray.length);
			System.out.println(stringarray[0]);
			System.out.println(stringarray[1]);
		}
	}
	
}
