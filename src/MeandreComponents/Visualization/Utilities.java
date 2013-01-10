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
import java.util.ArrayList;
import java.util.Vector;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/*
import org.apache.commons.compress.archivers.ArchiveOutputStream;
import org.apache.commons.compress.archivers.ArchiveStreamFactory;
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.utils.IOUtils;
*/
import au.com.bytecode.opencsv.CSVReader;

public class Utilities {
	
	//static byte[] buffer = new byte[1024];
	//public static String zipfile(String[] files){
/*
	public static void zip(String[] args){
		try{
			final OutputStream out = new FileOutputStream("C:\\Users\\ommirbod\\Desktop\\javazipped.zip");
	        ArchiveOutputStream os = new
	        ArchiveStreamFactory().createArchiveOutputStream("zip", out);
			String[] files = {"C:\\Users\\ommirbod\\Desktop\\a.txt",
					"C:\\Users\\ommirbod\\Desktop\\b.txt",
					"C:\\Users\\ommirbod\\Desktop\\c.txt",
					"C:\\Users\\ommirbod\\Desktop\\d.txt"};
			for(int i=0;i<files.length;i++){
		        os.putArchiveEntry(new ZipArchiveEntry(files[i].substring(files[i].lastIndexOf("\\")+1,files[i].length())));
		        IOUtils.copy(new FileInputStream(files[i]), os);
		        os.closeArchiveEntry();
			}
	       
	        //out.close();
	        os.close(); 
		} catch(Exception e){e.printStackTrace();}
    }
*/
/*	
	public static void sendFile(OutputStream out, File file){
		byte[] bytearray = new byte[(int) file.length()];
		try{
			BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
			bis.read(bytearray, 0, bytearray.length);
		    out.write(bytearray, 0, bytearray.length);
		    out.flush();
		}
		catch(Exception e){e.printStackTrace();}
	}
*/
/*
	public static void sendFileVector(ObjectOutputStream out, File file){
		Vector v = new Vector();
		try {
			CSVReader reader = new CSVReader(new FileReader(file.getAbsolutePath()), '\t');
			String [] nextLine;
		    while ((nextLine = reader.readNext()) != null)
		        v.add(nextLine);
		    
		    out.writeObject(v);
		    System.err.println("vector file sent");
		} catch (Exception e) { e.printStackTrace(); }
	}
*/
	/**
	 * Takes a file and outputs its content through a socket via ObjectOutputStream.
	 * Data is sent in 6Mb buffer stream to avoid heap space error.
	 * 
	 * @param out - The output stream to write to(Should be from socket)
	 * @param file - The File object that will be written to the socket
	 * 
	 */
	public static void sendFileVector(ObjectOutputStream out, File file){
		Vector v = new Vector();
		int buffer = 0;
		try {
			CSVReader reader = new CSVReader(new FileReader(file.getAbsolutePath()), '\t');
			String [] nextLine;
			
		    while ((nextLine = reader.readNext()) != null){
		    	out.writeObject(nextLine);
		    	if(buffer>6000000){
		    		out.reset();buffer=0;
		    	}
		    	buffer+=(nextLine.length*8);
		    }
		    System.err.println("vector file sent");
		} catch (Exception e) {System.err.println(buffer); e.printStackTrace(); }
	}
	
	public static void sendFile(File file)
	{
		byte[] buf = new byte[1024];
		String MeandreFilePath = "";
		try{
			Socket fileSocket = new Socket("neen.ucsd.edu", 10000);
			OutputStream os = fileSocket.getOutputStream();
			//ObjectInputStream is = new ObjectInputStream(fileSocket.getInputStream());
			BufferedOutputStream out = new BufferedOutputStream(os, 1024);
			FileInputStream in = new FileInputStream(file.getAbsolutePath());
		    int i = 0;
		    int bytecount = 1024;
		    while ((i = in.read(buf, 0, 1024)) != -1) {
		      bytecount = bytecount + 1024;
		      out.write(buf, 0, i);
		      out.flush();
		    }
		    //wait for meandre server(neen) file location to be sent back
		    //MeandreFilePath = (String) ois.readObject();
		    fileSocket.shutdownOutput();
		    System.out.println("Bytes Sent :" + bytecount);
		    System.out.println("File Created on Meandre: "+MeandreFilePath);
		
		} catch(Exception e){e.printStackTrace();}
	}
	
	/**
	 * Takes a file path and determines whether the file contains a list of
	 * montage commands for batch visualize or if the file only contains data
	 * for 1 imageVisualize component
	 * 
	 * @param filepath - The file to check its content
	 * 
	 * returns - An arraylist containing montage commands or an empty array(if not batch visualize)  
	 */
	public static ArrayList<String> GetMontageCommands(String filepath){
		ArrayList<String> montages = new ArrayList<String>();
		try{
			FileInputStream fstream = new FileInputStream(filepath);
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String linetext;
			while((linetext = br.readLine()) != null){
				if(linetext.toLowerCase().indexOf("montage") != -1){
					montages.add(linetext);
				}
			}
			br.close();
			in.close();
			return montages;
		} catch(Exception e){e.printStackTrace();}
		return montages;
	}
	
	public static String SortFile(String FullMontageCommand,String filename){
		String montageCommand = "";
		//System.out.println("Full montage command is: "+FullMontageCommand);
		boolean flag = false;
		Runtime rt = Runtime.getRuntime();
		Process p = null;
		
		ArrayList<String> sortargs = new ArrayList<String>();
		String[] commandToken = FullMontageCommand.split("\\s");
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
		
		if(sortargs.size() > 0){
			String args = "";
			for(int i=0;i<sortargs.size();i++)
				args+=sortargs.get(i)+" ";
			String[]headCommand = {"sh", "-c", "head -n +2 "+filename+" > "+filename+".head.csv"};
			String[]tailCommand = {"sh", "-c", "tail -n +3 "+filename+" > "+filename+".tail.csv"};
			String[]sortCommand = {"sh", "-c","java -jar /Users/culturevis/Documents/MeandreTesting/csvsort.jar "+filename+".tail.csv "+args.trim()};
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
			} catch(Exception e){e.printStackTrace();}
			montageCommand = FullMontageCommand.replaceAll("-sort[^.]*", "");
		}
		else
			montageCommand = FullMontageCommand;
		return montageCommand;
		
	}
}
