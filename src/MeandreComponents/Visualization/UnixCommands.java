import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;

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
	public UnixCommands(){
		rt = Runtime.getRuntime();
		this.feedbackMessage = new String();
		
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
	
	public String getMessage(){
		return this.feedbackMessage;
	}
}
