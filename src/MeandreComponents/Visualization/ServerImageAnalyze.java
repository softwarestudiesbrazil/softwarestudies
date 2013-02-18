import java.io.*;
import java.net.*;
/**
 * 
 * This class creates a socket on the server (jeju) listening for any connection
 * to port 2000. Once a connection is made, it takes the file path from user, calls
 * FeatureExtractor class to prepare arguments to FeatureExtractor and then calls the
 * Unix class to execute the unix command to FeatureExtractor.
 * 
 * TODO Have results from FeatureExtractor, how to return to user?
 *
 */
public class ServerImageAnalyze{
	ServerSocket providerSocket;
	Socket connection = null;
	ObjectOutputStream out;
	ObjectInputStream in;
	String message;
	boolean stopServer = false;
	ServerImageAnalyze(){
		try {
			providerSocket = new ServerSocket(2000, 10);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			stopServer = true;
			System.err.println("Error: Stopping Server");
		}
	}
	void run()
	{
		try{
			FileWriter outFile = new FileWriter("/Users/culturevis/Documents/MeandreTesting/progress.txt");
			PrintWriter progressFile = new PrintWriter(outFile);
			
			//1. creating a server socket

			//2. Wait for connection
			System.out.println("Waiting for connection");
			progressFile.print("Waiting for connection...");
			progressFile.flush();
			
			connection = providerSocket.accept();
			System.out.println("Connection received from " + connection.getInetAddress().getHostName());
			//3. get Input and Output streams
			out = new ObjectOutputStream(connection.getOutputStream());
			out.flush();
			in = new ObjectInputStream(connection.getInputStream());
			sendMessage("Connection successful");
			progressFile.println("OK");
			progressFile.println("Performing Image Analysis");
			progressFile.flush();
			//4. The two parts communicate via the input and output streams
			do{
				try{
					System.out.println("waiting for String");
					message = (String)in.readObject();
					System.out.println("String is: "+message);
					//message = "/Users/culturevis/Documents/MeandreTesting/ImageAnalyze/images/paths_short.txt";
					if(message.charAt(0) == '/'){ //There must be a better way to check for a directory String
						System.out.println("got the path:"+message);
						sendMessage("Received Directory: "+message);
						
						//call FeatureExtractor class to prepare images and files
						FeatureExtractor f = new FeatureExtractor(message);
						f.GenerateImgPathsFile(progressFile);
						sendMessage(f.getMessage());
						
						//Now call FeatureExtractor command using UNIX class
						UnixCommands u = new UnixCommands();
						u.RunFeatureExtractor(f.getFEImageFilePath(),f.getFEImageDirPath(),f.getClientFilePath(),f.getNumImages(),progressFile);
						sendMessage(u.getMessage());
						
						//Now compile files(logPath,logFile,resultPath,resultFile) and send back to Meandre Server
						//System.out.println("before sending paths");
						sendMessage(u.log_file.getAbsolutePath());
						//Utilities.sendFileVector(out,u.log_file);
						sendMessage(u.result_file.getAbsolutePath());
						//Utilities.sendFileVector(out,u.result_file);
						sendMessage("file");
						Utilities.sendFile(u.result_file);
						String MeandreFilePath = (String)in.readObject();
					    System.out.println("File Created on Meandre: "+MeandreFilePath);
					    progressFile.println("Meandre File Path: "+MeandreFilePath);
						u.updateMeandreFilePath(MeandreFilePath);
						//sendMessage(f.getFEImageDirPath());
						
						//sendMessage("bye");
					
					}
					if (message.equals("bye"))
						sendMessage("bye");
				}
				catch(ClassNotFoundException classnot){
					System.err.println("Data received in unknown format");
				}
			}while(!message.equals("bye"));
			progressFile.close();
		}
		catch(IOException ioException){
			ioException.printStackTrace();
			System.err.println("Error: Stopping Server");
			stopServer = true;
		}
		finally{
			//4: Closing connection
			try{
				in.close();
				out.close();
			}
			catch(IOException ioException){
				ioException.printStackTrace();
				System.err.println("Error: Stopping Server");
				stopServer = true;
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
	public static void main(String args[])
	{
		ServerImageAnalyze server = new ServerImageAnalyze();
		while(!server.stopServer){
			server.run();
		}
		try {
			server.providerSocket.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}