import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Vector;

import javax.swing.JTextArea;

public class ClientImageVisualize{
	Socket requestSocket;
	ObjectOutputStream out;
 	ObjectInputStream in;
 	//String message;
 	Object message;
 	JTextArea ClientLog;
 	String DirectoryPath;
 	
 	String OutputLogPath;
 	String OutputResultPath;
 	Object vector;
 	
 	ClientImageVisualize(String dirPath){
 		DirectoryPath = dirPath;
 	}
 	
	void run()
	{
		try{
			//1. creating a socket to connect to the server
			requestSocket = new Socket("jeju.ucsd.edu", 2002);
			System.out.println("Connected to jeju in port 2002");
			//2. get Input and Output streams
			out = new ObjectOutputStream(requestSocket.getOutputStream());
			out.flush();
			in = new ObjectInputStream(requestSocket.getInputStream());
			try{
			message = in.readObject();
			sendMessage(DirectoryPath);
			//ClientLog.append("Connection to Server Successful\n");
			//3: Communicating with the server
				do{
					message = in.readObject(); //get Object from server
					
					if(message instanceof Vector){ //is a file content
						vector = message;
					}
					else if(((String) message).charAt(0) == '/' && ((String) message).endsWith("_log.txt")) //is log file path
						OutputLogPath = (String)message;
					
					else if(((String) message).charAt(0) == '/' && ((String) message).endsWith("resultMontage.jpg")) //is result path
						OutputResultPath = (String)message;
					
					else{
						//It is debug messages, can output to error port if needed.
					}
					
					//ClientLog.append(message+"\n"); //send messages back to user
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