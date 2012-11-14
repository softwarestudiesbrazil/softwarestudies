import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Writer;

import au.com.bytecode.opencsv.CSVReader;

/**
 * 
 * This class will generate UNIX commands to run various tasks needed by the
 * workflow components.
 *
 */
public class UnixCommands {
	Runtime rt = null;
	Process p = null;
	String feedbackMessage = null;
	File log_file;
	File result_file;
	int JobID;
	public UnixCommands(){
		rt = Runtime.getRuntime();
		this.feedbackMessage = new String(); //for GUI version of this component, as debug message
		log_file = null;	//path of feature extractor result log file, will get sent to Meandre Server
		result_file = null;	//path of feature extractor result txt files(grouped by UNIX paste), will get sent to Meandre Server
		JobID = 0;		//unique job id of this ImageAnalysis, will get sent to Meandre Server 
	}
	
	/**
	 * Creates a process to call FeatureExtractor using option 2 calling method in 
	 * FeatureExtractor documentation. A bash file is created containing the command,
	 * bash script is called, once process is finished the bash script is deleted.
	 * 
	 * @param imgFilePaths - txt file containing list of image file paths
	 * @param imgFilePathsDir - Directory of the txt file
	 * 
	 * TODO need a method to keep track of progress, listening to generated log file and
	 * 		comparing it to list of imgFilePaths could be one method.
	 */
	
	public void RunFeatureExtractor(String imgFilePaths,String imgDirPath){
		int id=0;
		try{
			CSVReader reader = new CSVReader(new FileReader("PIDlog.csv"));
		    String [] nextLine;
		    int prev=0;
		    while ((nextLine = reader.readNext()) != null) {
		    	prev=Integer.parseInt(nextLine[0]);
		    }
		    id = (prev != 0) ? (prev+1) : 1;
		    this.JobID = id;
		    
		} catch (Exception e){e.printStackTrace();}
		//String imgFilePaths = "/Users/culturevis/Documents/MeandreTesting/ImageAnalyze/images";
		String[] runCommand = new String[] {"sh", "-c","matlab -nodisplay -r \"path(path,'/Applications/Programming/softwarestudies/matlab/FeatureExtractor'); FeatureExtractor('"+imgFilePaths+"', '"+imgFilePaths+"results'); exit;\" & PID=$!; echo "+id+",$PID,started,$(date +'%F %T'),"+imgFilePaths+" >> PIDlog.csv"};
		
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
			
		       //Use Unix Paste to combine txt files into one
		       String pasteCommand = PrepareUnixPaste(imgDirPath); //was imgFilePaths
		       runCommand = new String[] {"sh","-c",pasteCommand};
		       p = rt.exec(runCommand);
		       p.waitFor();
		       
		       //update log file using UNIX AWK command
		       String awkCommand = "TMPFILE=`mktemp numbers.tmpXXX`;awk -F, -v OFS=',' '($1+0) == "+this.JobID+" { $3 = \"Finished\" } 1' PIDlog.csv > $TMPFILE;rm PIDlog.csv;mv $TMPFILE PIDlog.csv";
		       runCommand = new String[] {"sh","-c",awkCommand};
		       p = rt.exec(runCommand);
		       p.waitFor();
		       
		} catch (Exception e) {e.printStackTrace();}
		this.feedbackMessage = "FeatureExtractor Executed with code: "+p.exitValue();
	}

	/*
	public void RunFeatureExtractor(String imgFilePaths,String imgFilePathsDir){
		Writer output = null;
		File scriptFile = new File(imgFilePathsDir+"/runFeatureExtractor.sh");
		try{
			output = new BufferedWriter(new FileWriter(scriptFile));
			output.write("matlab -nodisplay -r \"path(path,'/Applications/Programming/softwarestudies/matlab/FeatureExtractor'); FeatureExtractor('"+imgFilePaths+"', '"+imgFilePaths+"results'); exit;\"");
			output.close();
		} catch(Exception e){
			e.printStackTrace();
		}
		String permissionCommand = "chmod +x "+imgFilePathsDir+"/runFeatureExtractor.sh";
		String runCommand = imgFilePathsDir+"/runFeatureExtractor.sh";
		String removeCommand = "rm "+imgFilePathsDir+"/runFeatureExtractor.sh";
		
		try {
			//1: set permission to execute script 2: execute script 3: remove script
			p = rt.exec(permissionCommand);
			p.waitFor(); //waits for process to finish
			p = rt.exec(runCommand);
			p.waitFor();
			p = rt.exec(removeCommand);
			p.waitFor();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		this.feedbackMessage = "FeatureExtractor Executed with code: "+p.exitValue();
	}
	*/
	
	public String PrepareUnixPaste(String dirName){
    	File dir = new File(dirName);
    	//System.err.println(dir.getAbsolutePath());System.exit(0);
    	File[] txtfiles = dir.listFiles(new FilenameFilter() { 
    	         public boolean accept(File dir, String filename)
    	              { return filename.endsWith(".txt"); }
    	});
    	
    	String command = "paste ";
    	for(int i=0;i<txtfiles.length;i++){
    		if(txtfiles[i].getName().endsWith("_log.txt")){
    			this.log_file = new File(txtfiles[i].getAbsolutePath());
    			continue;
    		}
    		command+= txtfiles[i]+" ";
    	}
    	command+= "> "+dirName+"/resultsCollection.txt";
    	this.result_file = new File(dirName+"/resultsCollection.txt");
    	return command;
	}
	
	public String getMessage(){
		return this.feedbackMessage;
	}
}
