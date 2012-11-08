import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;


public class PID {
	
	public static void main(String[] args){
		String imgFilePaths = "/Users/culturevis/Documents/MeandreTesting/ImageAnalyze/images";
		String[] runCommand = new String[] {"sh", "-c","matlab -nodisplay -r \"path(path,'/Applications/Programming/softwarestudies/matlab/FeatureExtractor'); FeatureExtractor('"+imgFilePaths+"', '"+imgFilePaths+"/results'); exit;\" & PID=$!; echo $PID,0,started >> PIDlog.csv"};
		
		String line;
		//execute command
		Runtime rt = Runtime.getRuntime();
		Process p = null;
		try {
			p = rt.exec(runCommand);
			p.waitFor();
			
			BufferedReader in = new BufferedReader(
		               new InputStreamReader(p.getInputStream()) ); //interesting, must open input stream or else matlab crashes
		       while ((line = in.readLine()) != null) {
		         //System.out.println(line);
		       }
		       in.close();
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
