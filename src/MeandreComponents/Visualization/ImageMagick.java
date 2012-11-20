import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.Writer;


public class ImageMagick {

	private String txtImagePaths; 		//file path to be passed to FeatureExtractor
	private String clientFilePath;		//file path uploaded by user
	private String clientDirectoryPath; //Directory of file uploaded by user
	private String feedbackMessage;		//feedback message to pass back to user
	
	public ImageMagick(String filepath){
		clientFilePath = filepath;
		clientDirectoryPath = new String();
		feedbackMessage = new String();
		txtImagePaths = new String();
	}
	
	public void GenerateImgPathsFile(){
		Writer output = null;
		this.clientDirectoryPath = clientFilePath.substring(0,clientFilePath.lastIndexOf("/"));
		File configFile = new File(clientDirectoryPath+"/paths.txt");
		
		txtImagePaths = configFile.getAbsolutePath();
		BufferedReader readbuffer = null; //Reader for file uploaded by client
		String strRead; //reads in each line in Reader
		
		try {
			output = new BufferedWriter(new FileWriter(configFile)); //Open output file for writing
			readbuffer = new BufferedReader(new FileReader(clientFilePath));
			String headers[] = readbuffer.readLine().split(","); //first line is header, don't write it to file
			
			int imagefileindex = 0;
			for(int i=0;i<headers.length;i++){ //find index of where image filenames
				if(headers[i].toLowerCase().equals("filename")) //filename is the header of all image filenames
					imagefileindex = i;
			}
			
			while ((strRead=readbuffer.readLine())!=null){
				String splitarray[] = strRead.split("\t");
				String filename = splitarray[imagefileindex];
				output.write(filename+"\n"); //write one line to file
			}
			output.close();
			
			this.feedbackMessage = "ImageMagick Image Path File Created"; 
			
		} catch(Exception e){e.printStackTrace();}
	}
	
	public String getMessage(){
		return this.feedbackMessage;
	}
	
	public String getIMImageFilePath(){
		return this.txtImagePaths;
	}
	
	public String getIMImageDirPath(){
		return this.clientDirectoryPath;
	}
}
