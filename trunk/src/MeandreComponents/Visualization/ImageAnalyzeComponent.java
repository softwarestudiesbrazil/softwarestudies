import org.meandre.annotations.Component;
import org.meandre.annotations.ComponentInput;
import org.meandre.annotations.ComponentOutput;
import org.meandre.annotations.ComponentProperty;
import org.meandre.core.ComponentContext;
import org.meandre.core.ComponentContextProperties;
import org.seasr.datatypes.core.BasicDataTypes.Strings;
import org.seasr.datatypes.core.BasicDataTypesTools;
import org.seasr.datatypes.core.DataTypeParser;
import org.seasr.datatypes.core.Names;
import org.seasr.meandre.components.abstracts.AbstractExecutableComponent;

//
@Component(	creator = "Omeed Mirbod",
			description = "Send Path to Component",
			tags = "text",
			name = "ImageAnalyze")
public class ImageAnalyzeComponent extends AbstractExecutableComponent {

	//Component input port (uncomment if needed)
    @ComponentInput(
            name = Names.PORT_TEXT,
            description="Path to file containing Image File Paths"
    )
    protected static final String IN_FILE_PATH = Names.PORT_TEXT;
	
    @ComponentOutput(
            name = Names.PORT_TEXT,
            description = "Result File Path"
    )
    protected static final String OUT_RESULT_PATH = Names.PORT_TEXT;

    @ComponentOutput(
            name = Names.PORT_TEXT,
            description = "Result Files(zipped)"
    )
    protected static final String OUT_RESULT_FILES = Names.PORT_TEXT;
    
    @ComponentOutput(
            name = Names.PORT_TEXT,
            description = "Log File Path"
    )
    protected static final String OUT_LOG_PATH = Names.PORT_TEXT;
    
    @ComponentOutput(
            name = Names.PORT_TEXT,
            description = "Log file(Text)"
    )
    protected static final String OUT_LOG_FILE = Names.PORT_TEXT;
    
    @ComponentProperty(
    		name = Names.PORT_TEXT,
    		description = "The text message to send to output",
    		//default value: allows component to execute without user input
    		defaultValue = "Hello World!"
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
		String InputFilePath[] = DataTypeParser.parseAsString(input);
		ClientImageAnalyze client = new ClientImageAnalyze(InputFilePath[0]);
		client.run();
		cc.pushDataComponentToOutput(OUT_RESULT_PATH,BasicDataTypesTools.stringToStrings(client.OutputPath));

	}

	@Override
	public void disposeCallBack(ComponentContextProperties ccp)
			throws Exception {

	}

}
