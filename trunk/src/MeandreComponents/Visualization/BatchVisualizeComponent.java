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
			name = "BatchImageVisualize")
public class BatchVisualizeComponent extends AbstractExecutableComponent {

	//Component input port (uncomment if needed)
    @ComponentInput(
            name = Names.PORT_TEXT,
            description="Path to result data file from ImageAnalyze(from Meandre Server)"
    )
    protected static final String IN_FILE_PATH = Names.PORT_TEXT;
    
    @ComponentInput(
            name = "PORT_TEXT_3",
            description="Path to file with montage commands list(from Visualize Server)"
    )
    protected static final String IN_COMMAND = "PORT_TEXT_3";
    
    @ComponentOutput(
            name = Names.PORT_TEXT_2,
            description = "Result File Path"
    )
    protected static final String OUT_RESULT_PATH = Names.PORT_TEXT_2;
    
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
		Object input2 = cc.getDataComponentFromInput(IN_COMMAND);
		String InputFilePath[] = DataTypeParser.parseAsString(input);
		String InputCommands[] = DataTypeParser.parseAsString(input2);
		
		//need to let ClientImageVisualize know this is a file containing montage commands, not a file path to ImageAnalysis data
		ClientImageVisualize client = new ClientImageVisualize(InputFilePath[0],"batch---"+InputCommands[0],true);
		client.run();
		
		//end loop
		cc.pushDataComponentToOutput(OUT_RESULT_PATH,BasicDataTypesTools.stringToStrings(client.OutputResultPath));
		//cc.pushDataComponentToOutput(OUT_LOG_PATH,BasicDataTypesTools.stringToStrings(client.OutputLogPath));
	}

	@Override
	public void disposeCallBack(ComponentContextProperties ccp)
			throws Exception {

	}

}
