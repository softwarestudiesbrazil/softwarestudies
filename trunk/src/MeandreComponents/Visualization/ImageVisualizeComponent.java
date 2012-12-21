import java.io.BufferedReader;
import java.io.BufferedWriter;
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
            name = Names.PORT_TEXT,
            description="Path to file containing Image File Paths"
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
		
		Runtime rt = Runtime.getRuntime();
		Process p = null;
		
		
		//see if sorting needs to be done first
		//int sortIndex = InputCommand[0].lastIndexOf("sort");
		//only sort if user has entered sort command
		boolean flag = false;
		ArrayList<Integer> sortargs = new ArrayList<Integer>();
		String[] commandToken = InputCommand[0].split(" ");
		for(int i=0;i<commandToken.length;i++){
			if(commandToken[i].equals("-sort")){
				flag = true;
				sortargs.add(i);
			}
			if(flag){
				if(!(commandToken[i].charAt(0) == ('/') || commandToken[i].charAt(0) == ('-')))
					sortargs.add(i);
				else
					flag = false;
			}
		}
		
		if(sortargs.size() > 0){
			String[]headCommand = {"sh", "-c", "head -n +2 sortTest.csv > sortTest.head.csv"};
			String[]tailCommand = {"sh", "-c", "tail -n +3 sortTest.csv > sortTest.tail.csv"};
			String[]sortCommand = {"sh", "-c","java -jar csvsort.jar "+"sortTest.tail.csv 0i+ 2d+"};
			String[]joinCommand = {"sh", "-c","cat sortTest.head.csv sortTest.tail.csv > sortTest.csv;rm sortTest.tail.csv;rm sortTest.head.csv"};

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
		
		ClientImageVisualize client = new ClientImageVisualize(InputFilePath[0],InputCommand[0]);
		client.run();
		cc.pushDataComponentToOutput(OUT_RESULT_PATH,BasicDataTypesTools.stringToStrings(client.OutputResultPath));
		//cc.pushDataComponentToOutput(OUT_LOG_PATH,BasicDataTypesTools.stringToStrings(client.OutputLogPath));
	}

	@Override
	public void disposeCallBack(ComponentContextProperties ccp)
			throws Exception {

	}

}
