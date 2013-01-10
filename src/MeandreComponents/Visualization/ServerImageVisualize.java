import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

import au.com.bytecode.opencsv.CSVReader;


public class ServerImageVisualize {
	ServerSocket providerSocket;
	ServerSocket fileSocket;

	Socket connection = null;
	Socket connectionfile = null;
	ObjectOutputStream out;
	ObjectInputStream in;
	String message;
	ServerImageVisualize(){
		try {
			providerSocket = new ServerSocket(2001, 10);
			fileSocket = new ServerSocket(10000,10);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	void run()
	{
		try{
			FileWriter outFile = new FileWriter("/Users/culturevis/Documents/MeandreTesting/progress.txt");
			PrintWriter progressFile = new PrintWriter(outFile);
			//1. creating a server socket
			//providerSocket = new ServerSocket(2001, 10); //2001
			//fileSocket = new ServerSocket(10000,10);
			//2. Wait for connection
			System.out.println("Waiting for connection");
			progressFile.println("Waiting for connection");
			progressFile.flush();
			connection = providerSocket.accept();
			System.out.println("Connection received from " + connection.getInetAddress().getHostName());
			progressFile.println("Connection received from " + connection.getInetAddress().getHostName());
			progressFile.flush();
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
						String[] message_array = message.split("[\\|]");
						//System.out.println("first part is: "+message_array[0]);
						//System.out.println("second part is: "+message_array[1]);
						UnixCommands u = null;
						ArrayList<String> batch = new ArrayList<String>();
						if(message_array[1].indexOf("batch---") != -1){
							String[] stringarray = message_array[1].split("---");
							batch = Utilities.GetMontageCommands(stringarray[1]);
						}
						//if batch is true, then call ImageVisualize functions in loop
						if(batch.size() > 0){
							//open socket to get text file containing file from ImageAnalyze
							String VisServerFilePath = "";
							System.out.print("Opening socket to receive data file...");
							progressFile.print("Opening socket to receive data file...");
							progressFile.flush();
							//fileSocket = new ServerSocket(10000,10);
							connectionfile = fileSocket.accept();
							File tmpFile = new File("/Users/culturevis/Documents/MeandreTesting/sortedVisFile.csv");
							//System.out.println("Got connection from Meandre for Batch Visualize");
							VisServerFilePath = tmpFile.getAbsolutePath();
							byte[] b = new byte[1024];
						    int len = 0;
						    int bytcount = 1024;
						    FileOutputStream inFile = new FileOutputStream(tmpFile);
						    InputStream is = connectionfile.getInputStream();
						    BufferedInputStream bin = new BufferedInputStream(is, 1024);
						    while ((len = bin.read(b, 0, 1024)) != -1) {
						      bytcount = bytcount + 1024;
						      inFile.write(b, 0, len);
						    }
						    inFile.close();
						    //is.close();//
						    System.out.println("DONE");
						    progressFile.println("DONE");
						    progressFile.flush();
						    //loop through each montage command and generate file
							for(int i=0;i<batch.size();i++){
								System.out.print("Processing ("+(i+1)+"/"+batch.size()+"): "+batch.get(i)+"...");
								progressFile.print("Processing ("+(i+1)+"/"+batch.size()+"): "+batch.get(i)+"...");
								progressFile.flush();
								//an element in this ArrayList is of format: Montage -w 4000 -h 3000 -tilewidth 100 -tileheight 100 -sort1 BrightnessMean -label Year -sort 13d+ 14d-
								
								//change file based on sort command(if any) and get montage command without sort text
								String montageCommand = Utilities.SortFile(batch.get(i),VisServerFilePath);
								
								//rest is calling ImageVisualize component code
								ImageMagick im = new ImageMagick(VisServerFilePath);
								im.GenerateImgPathsFile();
								u = new UnixCommands();
								u.RunImageMontage(im.getIMImageFilePath(),im.getIMImageDirPath(),montageCommand,(i+1),progressFile);
								System.out.println("DONE");
								progressFile.println("DONE");
								progressFile.flush();
							}
						}
						else{
							
							//file is being transferred from Meandre Server
							String VisServerFilePath = "";
							if(message_array[1].indexOf("-sort") != -1){
								System.out.println("About to open socket for file transfer...");
								///fileSocket = new ServerSocket(10000,10);
								
								connectionfile = fileSocket.accept();
								File tmpFile = new File("/Users/culturevis/Documents/MeandreTesting/sortedVisFile.csv");
								System.out.println("Got connection from Meandre for Visualize");
								VisServerFilePath = tmpFile.getAbsolutePath();
								byte[] b = new byte[1024];
							    int len = 0;
							    int bytcount = 1024;
							    FileOutputStream inFile = new FileOutputStream(tmpFile);
							    InputStream is = connectionfile.getInputStream();
							    BufferedInputStream bin = new BufferedInputStream(is, 1024);
							    while ((len = bin.read(b, 0, 1024)) != -1) {
							      bytcount = bytcount + 1024;
							      inFile.write(b, 0, len);
							    }
							    inFile.close();
							    //connectionfile.close();
							}
							else{
								//check to see if file path is in log file, if so find it on jeju
								CSVReader reader = new CSVReader(new FileReader("PIDlog.csv"));
								String [] nextLine;
								
							    while ((nextLine = reader.readNext()) != null) {
							        if(nextLine[5].equals(message_array[0])){
							        	VisServerFilePath = nextLine[4];
							        	break;
							        }
							    }
							}
							//call ImageMagic class to prepare images and files
						    ImageMagick im = null;
						    if(VisServerFilePath.equals(""))
						    	im = new ImageMagick(message_array[0]);
						    else
						    	im = new ImageMagick(VisServerFilePath);
							im.GenerateImgPathsFile();
							sendMessage(im.getMessage());
							//Now call montage command using UNIX class
							u = new UnixCommands();
							String montageArgs = message_array[1].replaceAll("-sort[^.]*", "");
							u.RunImageMontage(im.getIMImageFilePath(),im.getIMImageDirPath(),montageArgs,-1,progressFile);
						}
						//end loop for batch
						
						sendMessage(u.getMontagePath());
						progressFile.println("File Location: "+u.getMontagePath());
						progressFile.close();
						sendMessage("bye");
						break;
					}
					
					
					
				} catch(Exception e){e.printStackTrace();}
				
				
			} while(!message.equals("bye"));
			
			
		} catch(Exception e){e.printStackTrace();}
		
		finally{
			//4: Closing connection
			try{
				//close streams
				in.close();
				out.close();
				//close sockets
				connection.close();
				connectionfile.close();
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
		//So it seems like port is always open until program ends...which in practice should be never
		//providerSocket.close();
		//fileSocket.close();
	}
}
