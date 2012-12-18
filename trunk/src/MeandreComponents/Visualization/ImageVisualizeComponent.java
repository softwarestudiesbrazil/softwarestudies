import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.Writer;

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
		///
		//see if sorting needs to be done first
		int sortIndex = InputCommand[0].lastIndexOf("sort");
		//only sort if user has entered sort command
		if(sortIndex != -1){
			String sortCommand = InputCommand[0].substring(InputCommand[0].lastIndexOf("sort")+5,InputCommand[0].lastIndexOf("/"));
			//depends if I am taking file from client end or file residing on server end
			String file = InputCommand[0].substring(InputCommand[0].lastIndexOf("/"),InputCommand[0].length());
			//rewrite file without headers
			Writer output = new BufferedWriter(new FileWriter(file+"tmp"));
			BufferedReader readbuffer = new BufferedReader(new FileReader(file));
			
			//sort file
			Runtime rt = Runtime.getRuntime();
			Process p = null;
			String[] runCommand = new String[] {"sh","-c",file+" "+sortCommand};
		    p = rt.exec(runCommand);
		    p.waitFor();
			//sorted file has same file name
	    
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
