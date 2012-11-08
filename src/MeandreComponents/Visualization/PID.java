import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;

import au.com.bytecode.opencsv.CSVReader;


public class PID {
	
	public static void main(String[] args){
		int id=0;
		try{
			CSVReader reader = new CSVReader(new FileReader("PIDlog.csv"));
		    String [] nextLine;
		    int prev=0;
		    while ((nextLine = reader.readNext()) != null) {
		    	prev=Integer.parseInt(nextLine[1]);
		    }
		    id = (prev != 0) ? (prev+1) : 1; 
		    
		} catch (Exception e){e.printStackTrace();}
		String imgFilePaths = "/Users/culturevis/Documents/MeandreTesting/ImageAnalyze/images";
		String[] runCommand = new String[] {"sh", "-c","matlab -nodisplay -r \"path(path,'/Applications/Programming/softwarestudies/matlab/FeatureExtractor'); FeatureExtractor('"+imgFilePaths+"', '"+imgFilePaths+"/results'); exit;\" & PID=$!; echo $PID,"+id+",started,$(date +'%F %T') >> PIDlog.csv"};
		
		String line;
		//execute command
		Runtime rt = Runtime.getRuntime();
		Process p = null;
		try {
			p = rt.exec(runCommand);
			p.waitFor();
			
			BufferedReader in = new BufferedReader(
		               new InputStreamReader(p.getInputStream()) ); //interesting...must open input stream on java end or else matlab can't export to files
		       while ((line = in.readLine()) != null) {
		         //System.out.println(line); //don't output to screen, just write the files 
		       }
		       in.close();
			
		} catch (Exception e) {e.printStackTrace();}
	}
}
