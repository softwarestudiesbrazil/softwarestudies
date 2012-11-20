import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
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
}
