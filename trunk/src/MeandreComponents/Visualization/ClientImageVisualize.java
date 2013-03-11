import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Vector;

import javax.swing.JTextArea;

import au.com.bytecode.opencsv.CSVReader;

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
 	boolean BatchFile;
 	String VisServer;
 	String OutputLogPath;
 	String OutputResultPath;
 	Object vector;
 	
 	File tmpFile;
 	
 	ClientImageVisualize(String dirPath,String montageCommand, boolean batch){
 		DirectoryPath = dirPath;
 		MontageCommand = montageCommand;
 		BatchFile = batch;
 	}
 	
	void run()
	{
		boolean FileWriteback = false;
		
		try{
			FileInputStream fstream = new FileInputStream("serverconfig.txt");
			DataInputStream infile = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(infile));
			this.VisServer = br.readLine();
			//1. creating a socket to connect to the server
			requestSocket = new Socket(this.VisServer, 2001); //2001
			System.out.println("Connected to jeju in port 2001");
			//2. get Input and Output streams
			out = new ObjectOutputStream(requestSocket.getOutputStream());
			out.flush();
			in = new ObjectInputStream(requestSocket.getInputStream());
			try{
			//message = in.readObject();
			checkFileFormat();
			String filename = getFileString();
			//String filename="";
			if(!BatchFile)
				FileWriteback = checkSort();
			//Open file socket if a sorted file needs to be written to Vis Server
			if(FileWriteback){
				sendMessage(DirectoryPath+ "|"+MontageCommand+"|"+filename);
				//message = in.readObject(); //wait for acknowledgment from Vis Server
				//if(((String) message).equals("Waiting For File..."))
						WriteFileToVisServer(); //write file to Vis Server
			}
			else{
				sendMessage(DirectoryPath+ "|"+MontageCommand+"|"+filename);
				WriteFileToVisServer();///
			}
			//ClientLog.append("Connection to Server Successful\n");
			//3: Communicating with the server
				do{
					message = in.readObject(); //get Object from server
					
					if(message instanceof Vector){ //is a file content
						vector = message;
					}
					else if(((String) message).charAt(0) == '/' && ((String) message).endsWith("_vislog.txt")) //is log file path
						OutputLogPath = (String)message;
					
					else if(((String) message).charAt(0) == '/' && ((String) message).endsWith(".jpg")) //is result path
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
	
	void checkFileFormat(){
		Runtime rt = Runtime.getRuntime();
		Process p = null;
		try{
			//check if file is in correct format(comma separated and with subheader)
			String filename = this.DirectoryPath;
			String filenametmp = null;
			BufferedReader reader = new BufferedReader(new FileReader(filename));
			String line = reader.readLine().trim();
			
			if(line.split("\t").length > 1){ //if not csv, then convert to csv
				filenametmp = filename+".tmp";
				reader.close();
				String[] csvcommand = {"sh","-c","tr '\\t' ',' < "+filename+" > "+filenametmp+";"};
				try{
					p = rt.exec(csvcommand);
					p.waitFor();
				} catch(Exception e){e.printStackTrace();}
				
			}
			
			//at this point datafile is a csv
			if(filenametmp == null)
				reader = new BufferedReader(new FileReader(filename));
			else
				reader = new BufferedReader(new FileReader(filenametmp));
			line = reader.readLine();
			int fileindex=0;
			String[] header = line.split(",");
			for(int i=0;i<header.length;i++){ //see where index of filename is
				if(header[i].equals("filename"))
					fileindex = i;
			}
			
			line = reader.readLine();
			String[] subheader = line.split(",");
			if(!subheader[fileindex].equals("string")){ //if string is not present then there is no subheader
				//insert second row using awk
				if(filenametmp == null){
					filenametmp = filename+".tmp";
					String[] awkcommand = {"sh","-c","awk -v \"s=,,\" '(NR==2) { print s } 1' "+filename+" > "+filenametmp+";"};
					try{
						p = rt.exec(awkcommand);
						p.waitFor();
					} catch(Exception e){e.printStackTrace();}
				}
				else{
					String[] awkcommand = {"sh","-c","awk -v \"s=,,\" '(NR==2) { print s } 1' "+filenametmp+" > "+filenametmp+".row;mv "+filenametmp+".row "+filenametmp+";"};
					try{
						p = rt.exec(awkcommand);
						p.waitFor();
					} catch(Exception e){e.printStackTrace();}
				}		
				
			}
			
			if(filenametmp != null)
				filename = filenametmp;
			
			this.DirectoryPath = filename;
			
		}catch(Exception e){e.printStackTrace();}
		//leave original file untouched, filenametmp is created if modifications were needed
	}
	public String getFileString(){

		String filename = "";
		boolean flag = false;
		String file = this.DirectoryPath;
		
		ArrayList<String> sortargs = new ArrayList<String>();
		String[] commandToken = this.MontageCommand.split("\\s");
		
		//check command if there is sort argument
		for(int i=0;i<commandToken.length;i++){
			if(commandToken[i].equals("-sort")){
				flag = true;
				continue;
			}
			if(flag){
				if(!(commandToken[i].charAt(0) == ('-')))
					sortargs.add(commandToken[i]);
				else
					flag = false;
			}
		}
//
		ArrayList<Integer> columns = new ArrayList<Integer>();
		if(sortargs.size() > 0){
			for(int i=0;i<sortargs.size();i++)
				columns.add(Integer.parseInt(sortargs.get(i).replaceAll("\\D+","")));
			
			try {
				BufferedReader br = new BufferedReader(new FileReader(file));
				String[] line;
				line = br.readLine().split(",");
				br.close();
				for(int i=0;i<columns.size();i++)
					filename+="_"+line[columns.get(i)];
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		String name="";
		if(this.DirectoryPath.lastIndexOf("/") != -1)
			name = this.DirectoryPath.substring(this.DirectoryPath.lastIndexOf("/")+1,this.DirectoryPath.lastIndexOf("."));
		else
			name = this.DirectoryPath.substring(this.DirectoryPath.indexOf(0),this.DirectoryPath.lastIndexOf("."));
		if(columns.size()>0)
			name+="_sortby";
		return (name+filename);
	}
	public boolean checkSort(){
		Runtime rt = Runtime.getRuntime();
		Process p = null;
		boolean sort = false;
		boolean flag = false;
		
		String filename = this.DirectoryPath;
		ArrayList<String> sortargs = new ArrayList<String>();
		String[] commandToken = this.MontageCommand.split("\\s");
		
		//check command if there is sort argument
		for(int i=0;i<commandToken.length;i++){
			if(commandToken[i].equals("-sort")){
				flag = true;
				continue;
			}
			if(flag){
				if(!(commandToken[i].charAt(0) == ('-')))
					sortargs.add(commandToken[i]);
				else
					flag = false;
			}
		}
		
		//if there are sort arguments
		if(sortargs.size() > 0){
			sort = true;
			String args = "";
			for(int i=0;i<sortargs.size();i++)
				args+=sortargs.get(i)+" ";
			String[]headCommand = {"sh", "-c", "head -n +2 "+filename+" > "+filename+".head.csv"};
			String[]tailCommand = {"sh", "-c", "tail -n +3 "+filename+" > "+filename+".tail.csv"};
			String[]sortCommand = {"sh", "-c","java -jar csvsort.jar "+filename+".tail.csv "+args.trim()};
			String[]joinCommand = {"sh", "-c","cat "+filename+".head.csv "+filename+".tail.csv > "+filename+";rm "+filename+".tail.csv;rm "+filename+".head.csv"};

			try {
				p = rt.exec(headCommand);
				p.waitFor();
				p = rt.exec(tailCommand);
				p.waitFor();
				p = rt.exec(sortCommand);
				p.waitFor();
				p = rt.exec(joinCommand);
				p.waitFor();
				return sort;
			} catch(Exception e){e.printStackTrace();}
		}
		return sort;
	}
	
	void WriteFileToVisServer(){

		byte[] buf = new byte[1024];
		try{
			Socket fileSocket = new Socket(this.VisServer, 10000);
			OutputStream os = fileSocket.getOutputStream();
			//os.flush();
			//ObjectInputStream is = new ObjectInputStream(fileSocket.getInputStream());
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