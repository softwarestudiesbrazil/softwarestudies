import java.io.*;
import java.net.*;

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
			do{
				try{
					//////
					file = (Object[])in.readObject();
					String filename = (String) file[0];
					System.err.println("name is: "+filename);
					byte[] filebytes = (byte[]) file[1];
					FileOutputStream fileout = new FileOutputStream(filename);
					fileout.write(filebytes);
					//File f = new File(filename);
					//FileUtils.writeByteArrayToFile(f, filebytes);
					sendMessage("end");
					System.exit(0);
					/////
					
					message = (String)in.readObject();
					System.out.println("client>" + message);
					if (message.equals("end"))
						sendMessage("end");
				}
				catch(ClassNotFoundException classnot){
					System.err.println("Data received in unknown format");
				}
			}while(!message.equals("end"));
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
	public static void main(String args[])
	{
		Server server = new Server();
		while(true){
			server.run();
		}
	}
}