import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.ServerSocket;
import java.net.Socket;


public class ServerImageVisualize {
	ServerSocket providerSocket;
	Socket connection = null;
	ObjectOutputStream out;
	ObjectInputStream in;
	String message;
	ServerImageVisualize(){}
	void run()
	{
		try{
			//1. creating a server socket
			providerSocket = new ServerSocket(2001, 10);
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
					message = (String)in.readObject(); //Directory path from client
					
					if(message.charAt(0) == '/'){ //if it is a directory
						System.out.println("Received Directory:"+message);
						
						//call ImageMagic class to prepare images and files
						ImageMagick im = new ImageMagick(message);
						im.GenerateImgPathsFile();
						sendMessage(im.getMessage());
						
						//Now call montage command using UNIX class
						UnixCommands u = new UnixCommands();
						u.RunImageMontage(im.getIMImageFilePath(),im.getIMImageDirPath());
						sendMessage(u.getMontagePath());
						sendMessage("bye");
						break;
					}
					
					
					
				} catch(Exception e){e.printStackTrace();}
				
				
			} while(!message.equals("bye"));
			
			
		} catch(Exception e){e.printStackTrace();}
		
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
		ServerImageVisualize server = new ServerImageVisualize();
		while(true){
			server.run();
		}
	}
}
