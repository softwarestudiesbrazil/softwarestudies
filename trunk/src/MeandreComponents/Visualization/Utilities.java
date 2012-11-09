import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.apache.commons.compress.archivers.ArchiveOutputStream;
import org.apache.commons.compress.archivers.ArchiveStreamFactory;
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.utils.IOUtils;

public class Utilities {
	
	static byte[] buffer = new byte[1024];
	//public static String zipfile(String[] files){

	public static void main(String[] args){
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
}
