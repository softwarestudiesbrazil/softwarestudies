  import java.io.*;
import java.net.*;
import java.util.ArrayList;

import org.apache.poi.util.IOUtils;
public class Client{
	Socket requestSocket;
	ObjectOutputStream out;
 	ObjectInputStream in;
 	String message;
 	
 	////
 	File[] userFiles;
 	ArrayList<File> commands;
 	////
 	
	Client(File[] files){
/////		
		this.userFiles = files;
/////		
	}
	void run()
	{
		try{
			///////
			commands = new ArrayList<File>();
			for ( File file : userFiles ) {
				String name = file.getName().toLowerCase();
				if(name.endsWith("jpg") || name.endsWith("png")){
					commands.add(file);
					System.err.println(name);
				}
			}
			System.err.println(commands.size());
			//////
			requestSocket = new Socket("jeju.ucsd.edu", 2000);
			System.out.println("Connected to jeju in port 2000");

			out = new ObjectOutputStream(requestSocket.getOutputStream());
			out.flush();
			in = new ObjectInputStream(requestSocket.getInputStream());

			do{
				message = (String)in.readObject();
				System.out.println("server>" + message);
				//send files one at a time
				//Object file[];
				for(int i=0;i<commands.size();i++)
				{
					Object[] file = PrepareFileToSend(commands.get(i).getPath(),commands.get(i).getName());
					out.writeObject(file);
					out.flush();
					System.out.println("client>" + "sent file");
					message = (String)in.readObject();
					System.out.println("server>" + message);
				}
				//sendMessageBulk(commands);
				//message = "bye";
				//sendMessage(message);
				System.exit(0);
			}while(!message.equals("end"));
		}
		catch(UnknownHostException unknownHost){
			System.err.println("You are trying to connect to an unknown host!");
		}
		catch(IOException ioException){
			ioException.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally{
/*
			try{
				//in.close();
				//out.close();
				//requestSocket.close();
			}
			catch(IOException ioException){
				ioException.printStackTrace();
			}*/
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
	
	void sendMessageBulk(ArrayList<File> commands){
		Object file[];
		try{
			for(int i=0;i<commands.size();i++){
//				System.err.println(commands.get(i).getPath());System.exit(0);
				InputStream bis = new FileInputStream(commands.get(i).getPath());
				byte[] filebytes = IOUtils.toByteArray(bis);
				System.err.println(filebytes.length);
				file = new Object[2];
				file[0] = commands.get(i).getName();
				file[1] = filebytes;
				out.writeObject(file);
				out.flush();
				System.out.println("client>" + "sent file");
				
			}
		}
		catch(IOException ioException){
			ioException.printStackTrace();
		}		
	}
	
	Object[] PrepareFileToSend(String FilePath,String FileName)
	{
		Object file[];
		try{
			InputStream bis = new FileInputStream(FilePath);
			byte[] filebytes = IOUtils.toByteArray(bis);
			file = new Object[2];
			file[0] = FileName;
			file[1] = filebytes;
			return file;
		} catch(Exception e){e.printStackTrace();}
		return null;
	}
/*	public static void main(String args[])
	{
		Client client = new Client();
		client.run();
	}
	*/
}