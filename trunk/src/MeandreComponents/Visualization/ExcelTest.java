import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
 
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.WorkbookFactory; // This is included in poi-ooxml-3.6-20091214.jar
import org.apache.poi.ss.usermodel.Workbook;
 
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;

//Example of how a new entry is made
public class ExcelTest { 
	public static void main(String[] args) throws IOException, InvalidFormatException{
		//replace path with one on jeju
		Workbook workbook = WorkbookFactory.create(new FileInputStream("C:\\Users\\ommirbod\\Desktop\\log2.xls"));
		Sheet sheet = workbook.getSheetAt(0);
		int rownum = sheet.getPhysicalNumberOfRows();
		Row row = null;
		double id;
		if(rownum==0){
			row = sheet.createRow(rownum);
			id = 0;
		}
		else{
			row = sheet.getRow(rownum-1);
			id = row.getCell(0).getNumericCellValue();
			row = sheet.createRow(rownum);
		}
		Cell cell = row.createCell(0);
		//new generated ID
		double newid = id+1;
	    cell.setCellValue(newid);
	    FileOutputStream fileOut = new FileOutputStream("C:\\Users\\ommirbod\\Desktop\\log2.xls");
	    workbook.write(fileOut);
	    fileOut.close();
	}
}