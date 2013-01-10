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
		//System.out.println("client path is: "+clientFilePath);
		this.clientDirectoryPath = clientFilePath.substring(0,clientFilePath.lastIndexOf("/"));
		//File configFile = new File(clientDirectoryPath+"/pathsVis.txt"); // see UnixCommands
		File configFile = new File("pathsVis.txt");
		//txtImagePaths = configFile.getAbsolutePath(); can't give absoluate path to montage for image file list using @ command
		txtImagePaths = configFile.getName();
		BufferedReader readbuffer = null; //Reader for file uploaded by client
		String strRead; //reads in each line in Reader
		
		try {
			output = new BufferedWriter(new FileWriter(configFile)); //Open output file for writing
			readbuffer = new BufferedReader(new FileReader(clientFilePath));
			String headers[] = readbuffer.readLine().split(","); //first line is header, don't write it to file
			int imagefileindex = 0;
			int imagedirindex = 0;
			for(int i=0;i<headers.length;i++){ //find index of where image filenames
				if(headers[i].toLowerCase().replaceAll("\t", "").equals("filename"))
					imagefileindex = i;
				if(headers[i].toLowerCase().replaceAll("\t", "").equals("path"))
					imagedirindex = i;
			}
			//System.out.println(clientFilePath);
			//System.out.println(imagefileindex);
			
			strRead=readbuffer.readLine(); //second line is also not of interest as it contains data types, not values
			while ((strRead=readbuffer.readLine())!=null){
				String splitarray[] = strRead.split(",");
				String filename = splitarray[imagefileindex];
				String filepath = splitarray[imagedirindex];
				if(!filename.replaceAll("\t", "").trim().equals(""))
					output.write(filepath.replaceAll("\t", "")+filename.replaceAll("\t", "")+"\n"); //write one line to file
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
