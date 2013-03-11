import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.Writer;
import java.util.ArrayList;

import org.meandre.annotations.Component;
import org.meandre.annotations.ComponentInput;
import org.meandre.annotations.ComponentOutput;
import org.meandre.annotations.ComponentProperty;
import org.meandre.core.ComponentContext;
import org.meandre.core.ComponentContextProperties;
import org.seasr.datatypes.core.BasicDataTypesTools;
import org.seasr.datatypes.core.DataTypeParser;
import org.seasr.datatypes.core.Names;
import org.seasr.meandre.components.abstracts.AbstractExecutableComponent;

@Component(	creator = "Omeed Mirbod",
			description = "Send Path to Component",
			tags = "text",
			name = "ImageVisualize")
public class ImageVisualizeComponent extends AbstractExecutableComponent {

	//Component input port (uncomment if needed)
    @ComponentInput(
            name = Names.PORT_TEXT,
            description="Path to file containing Image File Paths"
    )
    protected static final String IN_FILE_PATH = Names.PORT_TEXT;
	
    @ComponentInput(
            name = "PORT_TEXT_3",
            description="Montage Command Input"
    )
    protected static final String IN_COMMAND = "PORT_TEXT_3";
    
    @ComponentOutput(
            name = Names.PORT_TEXT_2,
            description = "Result File Path"
    )
    protected static final String OUT_RESULT_PATH = Names.PORT_TEXT_2;

    /*
    @ComponentOutput(
            name = Names.PORT_OBJECT_2,
            description = "Result Files(zipped)"
    )
    protected static final String OUT_RESULT_FILES = Names.PORT_OBJECT_2;
    */
    
    @ComponentOutput(
            name = Names.PORT_TEXT,
            description = "Log File Path"
    )
    protected static final String OUT_LOG_PATH = Names.PORT_TEXT;
    
    @ComponentOutput(
            name = Names.PORT_OBJECT,
            description = "Log file(Text Document)"
    )
    protected static final String OUT_LOG_FILE = Names.PORT_OBJECT;
    
    @ComponentProperty(
    		name = Names.PORT_TEXT,
    		description = "The text message to send to output",
    		//default value: allows component to execute without user input
    		defaultValue = "Place Directory Path Here"
    )
    protected static final String PROP_MESSAGE = Names.PORT_TEXT;
    
    private String _text;
    
	@Override
	public void initializeCallBack(ComponentContextProperties ccp)
			throws Exception {
		//Get component property
		_text = getPropertyOrDieTrying(PROP_MESSAGE,false,false,ccp); //_text is

	}

	@Override
	public void executeCallBack(ComponentContext cc) throws Exception {
		//send to output, could also replace _text with a String
		Object input = cc.getDataComponentFromInput(IN_FILE_PATH);
		Object input_2 = cc.getDataComponentFromInput(IN_COMMAND);
		String InputFilePath[] = DataTypeParser.parseAsString(input);
		String InputCommand[] = DataTypeParser.parseAsString(input_2);
/***		
		Runtime rt = Runtime.getRuntime();
		Process p = null;
		
		//check if file is in correct format(comma separated and with subheader)
		String filename = InputFilePath[0];
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
		
		//leave original file untouched, filenametmp is created if modifications were needed
		if(filenametmp != null)
			filename = filenametmp;
		
		//see if sorting needs to be done first
		//int sortIndex = InputCommand[0].lastIndexOf("sort");
		//only sort if user has entered sort command
		boolean sort = false;
		boolean flag = false;
		ArrayList<String> sortargs = new ArrayList<String>();
		String[] commandToken = InputCommand[0].split("\\s");
		//String filename = "";
		//String filename = InputFilePath[0]; //MUST BE AN IMAGEANALYSIS RESULT FILE
		for(int i=0;i<commandToken.length;i++){
			if(commandToken[i].equals("-sort")){
				flag = true;
				continue;
			}
			if(flag){
				if(!(commandToken[i].charAt(0) == ('-')))
					sortargs.add(commandToken[i]);
				//if(commandToken[i].charAt(0) == ('/'))
				//	filename = commandToken[i];
				else
					flag = false;
			}
		}
		
		if(sortargs.size() > 0){
			sort = true;
			String args = "";
			for(int i=0;i<sortargs.size();i++)
				args+=sortargs.get(i)+" ";
			String[]headCommand = {"sh", "-c", "head -n +2 "+filename+" > "+filename+".head.csv"};
			String[]tailCommand = {"sh", "-c", "tail -n +3 "+filename+" > "+filename+".tail.csv"};
			String[]sortCommand = {"sh", "-c","java -jar /Users/culturevis/Desktop/Meandre-1.4.11/meandre-instance/published_resources/csvsort.jar "+filename+".tail.csv "+args.trim()};
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
	    
		}
***/		
		//String montageArgs = InputCommand[0].replaceAll("-sort[^.]*", "");
		
		ClientImageVisualize client = new ClientImageVisualize(InputFilePath[0],InputCommand[0],false);
		client.run();
/***
		//delete temporary created file if exists
		if(filenametmp != null){
			File file = new File(filenametmp);
			file.delete();
		}
***/
		cc.pushDataComponentToOutput(OUT_RESULT_PATH,BasicDataTypesTools.stringToStrings(client.OutputResultPath));
		//should output just montage args: cc.pushDataComponentToOutput(OUT_RESULT_PATH,BasicDataTypesTools.stringToStrings(montageArgs));
		//cc.pushDataComponentToOutput(OUT_LOG_PATH,BasicDataTypesTools.stringToStrings(client.OutputLogPath));
	}

	@Override
	public void disposeCallBack(ComponentContextProperties ccp)
			throws Exception {

	}

}
