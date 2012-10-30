import java.io.*;
import java.net.*;

import javax.swing.JTextArea;
/**
 * 
 * This class creates a socket connection to jeju server, once the connection
 * is successful it sends the directory path the user provided. It then keeps listening
 * for feedback messages coming from the server, and relay them back to the user.
 * This class is called by ImageAnalyzeView.java 
 *
 * TODO Will result files be given back to user through interface or will
 * 		user use ftp to get files? (In doc section "ImageAnalyze Meandre Workflow
 * 		Component" how is the "return" section accomplished)
 */
public class ClientImageAnalyze{
	Socket requestSocket;
	ObjectOutputStream out;
 	ObjectInputStream in;
 	String message;
 	JTextArea ClientLog;
 	String DirectoryPath;
 	
 	ClientImageAnalyze(String dirPath,JTextArea log){
 		ClientLog = log;
 		ClientLog.setText("Connecting to Server...\n");
 		DirectoryPath = dirPath;
 		
 	}
	void run()
	{
		try{
			//1. creating a socket to connect to the server
			requestSocket = new Socket("jeju.ucsd.edu", 2000);
			System.out.println("Connected to jeju in port 2000");
			//2. get Input and Output streams
			out = new ObjectOutputStream(requestSocket.getOutputStream());
			out.flush();
			in = new ObjectInputStream(requestSocket.getInputStream());
			try{
			message = (String)in.readObject();
			sendMessage(DirectoryPath);
			ClientLog.append("Connection to Server Successful\n");
			//3: Communicating with the server
				do{	
					message = (String)in.readObject(); //get message from server
					
					ClientLog.append(message+"\n"); //send messages back to user
				}while(!message.equals("bye"));

			}catch(ClassNotFoundException classNot){
				System.err.println("data received in unknown format");
			}
		}
		catch(UnknownHostException unknownHost){
			System.err.println("You are trying to connect to an unknown host!");
		}
		catch(IOException ioException){
			ioException.printStackTrace();
		}
		finally{
			//4: Closing connection
			try{
				in.close();
				out.close();
				requestSocket.close();
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
			System.out.println("client>" + msg);
		}
		catch(IOException ioException){
			ioException.printStackTrace();
		}
	}
}