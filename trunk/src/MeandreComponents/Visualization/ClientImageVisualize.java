import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Vector;

import javax.swing.JTextArea;

public class ClientImageVisualize{
	Socket requestSocket;
	Socket fileSocket;
	ObjectOutputStream out;
 	ObjectInputStream in;
 	//String message;
 	Object message;
 	JTextArea ClientLog;
 	String DirectoryPath;
 	String MontageCommand;
 	boolean FileWriteback;
 	
 	String OutputLogPath;
 	String OutputResultPath;
 	Object vector;
 	
 	File tmpFile;
 	
 	ClientImageVisualize(String dirPath,String montageCommand, boolean sort){
 		DirectoryPath = dirPath;
 		MontageCommand = montageCommand;
 		FileWriteback = sort;
 	}
 	
	void run()
	{
		try{
			//1. creating a socket to connect to the server
			requestSocket = new Socket("jeju.ucsd.edu", 2001);
			System.out.println("Connected to jeju in port 2001");
			//2. get Input and Output streams
			out = new ObjectOutputStream(requestSocket.getOutputStream());
			out.flush();
			in = new ObjectInputStream(requestSocket.getInputStream());
			try{
			//message = in.readObject();
				
			//Open file socket if a sorted file needs to be written to Vis Server
			if(FileWriteback){
				sendMessage(DirectoryPath+ "|"+MontageCommand);
				message = in.readObject(); //wait for acknowledgment from Vis Server
				if(((String) message).equals("Waiting For File..."))
						WriteFileToVisServer(); //write file to Vis Server
			}
			else
				sendMessage(DirectoryPath+ "|"+MontageCommand);
			
			//ClientLog.append("Connection to Server Successful\n");
			//3: Communicating with the server
				do{
					message = in.readObject(); //get Object from server
					
					if(message instanceof Vector){ //is a file content
						vector = message;
					}
					else if(((String) message).charAt(0) == '/' && ((String) message).endsWith("_vislog.txt")) //is log file path
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
	
	void WriteFileToVisServer(){
		byte[] buf = new byte[1024];
		try{
			Socket fileSocket = new Socket("jeju.ucsd.edu", 10000);
			OutputStream os = fileSocket.getOutputStream();
			ObjectInputStream is = new ObjectInputStream(fileSocket.getInputStream());
			BufferedOutputStream out = new BufferedOutputStream(os, 1024);
			FileInputStream in = new FileInputStream(this.DirectoryPath);
		    int i = 0;
		    int bytecount = 1024;
		    while ((i = in.read(buf, 0, 1024)) != -1) {
		      bytecount = bytecount + 1024;
		      out.write(buf, 0, i);
		      out.flush();
		    }
		    fileSocket.shutdownOutput();
		
		} catch(Exception e){e.printStackTrace();}
	}
}