import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;


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
					//message could be in 3 formats: InputFile | MontageCommand, InputFile | "", InputFile | "batch"
					message = (String)in.readObject(); //Directory path from client
					
					if(message.charAt(0) == '/'){ //if it is a directory
						String[] message_array = message.split("|");
						System.out.println("Received Directory:"+message);
						UnixCommands u = null;
						ArrayList<String> batch = new ArrayList<String>();
						
						if(message_array[1].equals("batch")){
							batch = Utilities.CheckIfBatch(message);
						}
						//if batch is true, then call ImageVisualize functions in loop
						if(batch.size() > 0){
							for(int i=0;i<batch.size();i++){
								//an element in this ArrayList is of format: Montage -w 4000 -h 3000 -tilewidth 100 -tileheight 100 -sort1 BrightnessMean -label Year /Documents/Meandre/images/results/resultCollection.txt
								String resultFilePath = batch.get(i).substring(batch.get(i).lastIndexOf(" ")+1); //assuming last parameter is a file path
								String montageCommand = batch.get(i).substring(0, batch.get(i).lastIndexOf(" "));
								
								//rest is calling ImageVisualize component code
								ImageMagick im = new ImageMagick(resultFilePath);
								im.GenerateImgPathsFile();
								u = new UnixCommands();
								u.RunImageMontage(im.getIMImageFilePath(),im.getIMImageDirPath(),montageCommand);
							}
						}
						else{
							//call ImageMagic class to prepare images and files
							ImageMagick im = new ImageMagick(message_array[0]);
							
							im.GenerateImgPathsFile();
							sendMessage(im.getMessage());
							//Now call montage command using UNIX class
							u = new UnixCommands();
							u.RunImageMontage(im.getIMImageFilePath(),im.getIMImageDirPath(),message_array[1]);
						}
						//end loop for batch
						
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
