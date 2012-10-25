import java.io.*;
import java.net.*;

import org.apache.commons.io.FileUtils;

public class Server{
	ServerSocket providerSocket;
	Socket connection = null;
	ObjectOutputStream out;
	ObjectInputStream in;
	String message;
	
	/////
	Object[] file;
	/////
	
	Server(){}
	void run()
	{
		try{
			//1. creating a server socket
			providerSocket = new ServerSocket(2000, 10);
			//2. Wait for connection
			System.out.println("Waiting for connection");
			connection = providerSocket.accept();
			System.out.println("Connection received from " + connection.getInetAddress().getHostName());
			//3. get Input and Output streams
			out = new ObjectOutputStream(connection.getOutputStream());
			out.flush();
			in = new ObjectInputStream(connection.getInputStream());
			sendMessage("Connection successful");
			//4. The two parts communicate via the input and output streams
			int count=0;
			do{
				try{
					//////
					file = (Object[])in.readObject();
					writeFile(file,"/Users/culturevis/Documents/MeandreTesting/ImageAnalyze/ClientImages/");
					sendMessage("Server downloaded file: "+(String) file[0]);
					
					/////
					count+=1;
					//message = (String)in.readObject();
					//System.out.println("client>" + message);
					if(count==4){
						writeConfigFile("/Users/culturevis/Documents/MeandreTesting/ImageAnalyze/ClientImages/");
						runFeatureExtractor("/Users/culturevis/Documents/MeandreTesting/ImageAnalyze/ClientImages/");
						System.exit(0);
					}else 
						continue;
					if (message.equals("end"))
						sendMessage("end");
				}
				catch(ClassNotFoundException classnot){
					System.err.println("Data received in unknown format");
				}
			}while(true);
		}
		catch(IOException ioException){
			ioException.printStackTrace();
		}
		finally{
			//4: Closing connection
			try{
				in.close();
				out.close();
				providerSocket.close();
			}
			catch(IOException ioException){
				ioException.printStackTrace();
			}
		}
	}
	void sendMessage(String msg)
	{
		try{
			out.writeObject(msg);
			out.flush();
			System.out.println("server>" + msg);
		}
		catch(IOException ioException){
			ioException.printStackTrace();
		}
	}
	
	void writeFile(Object[] file, String path)
	{
		try{
			String filename = (String) file[0];
			System.err.println("name is: "+filename);
			byte[] filebytes = (byte[]) file[1];
			FileOutputStream fileout = new FileOutputStream(path+filename);
			fileout.write(filebytes);
			File f = new File(path+filename);
			FileUtils.writeByteArrayToFile(f, filebytes);
		} catch(Exception e){e.printStackTrace();}
	}
	
	void writeConfigFile(String path)
	{
		Writer output = null;
		File configFile = new File(path+"paths.txt");
		try {
		output = new BufferedWriter(new FileWriter(configFile));
			String files;
			File folder = new File(path);
			File[] listOfFiles = folder.listFiles();
			for (int i = 0; i < listOfFiles.length; i++) 
			{
				if (listOfFiles[i].isFile()) 
				{
					files = listOfFiles[i].getPath();
					if(listOfFiles[i].getName().equals("paths.txt")) continue;
					output.write(files+"\n");
				}
			}
			output.close();
			File scriptFile = new File(path+"runFeatureExtractor.sh");
			output = new BufferedWriter(new FileWriter(scriptFile));
			output.write("matlab -nodisplay -r \"path(path,'/Applications/Programming/softwarestudies/matlab/FeatureExtractor'); FeatureExtractor('"+path+"paths.txt', '"+path+"results'); exit;\"");
			output.close();
		} catch (IOException e) {e.printStackTrace();}
	}
	
	void runFeatureExtractor(String path)
	{
		Runtime rt = Runtime.getRuntime();
		Process p = null;
		String permissionCommand = "chmod +x "+path+"runFeatureExtractor.sh";
		String runCommand = path+"runFeatureExtractor.sh";
		String removeCommand = "rm "+path+"runFeatureExtractor.sh";
		try{
			p = rt.exec(permissionCommand);
			p.waitFor();
			p = rt.exec(runCommand);
			p.waitFor();
			p = rt.exec(removeCommand);
			p.waitFor();
		} catch(Exception e){e.printStackTrace();}
	    InputStream output = p.getInputStream();
	    //System.out.println( output );
	}
	public static void main(String args[])
	{
		Server server = new Server();
		while(true){
			server.run();
		}
	}
}

/*
matlab -nodisplay -r "path(path,'/Applications/Programming/softwarestudies/matlab/FeatureExtractor'); FeatureExtractor('paths.txt', 'results'); exit;"
*/