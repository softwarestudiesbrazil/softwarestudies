import org.meandre.annotations.Component;
import org.meandre.annotations.ComponentInput;
import org.meandre.annotations.ComponentOutput;
import org.meandre.annotations.ComponentProperty;
import org.meandre.core.ComponentContext;
import org.meandre.core.ComponentContextProperties;
import org.seasr.datatypes.core.BasicDataTypesTools;
import org.seasr.datatypes.core.Names;
import org.seasr.meandre.components.abstracts.AbstractExecutableComponent;

//
@Component(	creator = "Omeed Mirbod",
			description = "Send Path to Component",
			tags= "text",
			name = "OutputText")
public class HelloWorldComponent extends AbstractExecutableComponent {
/*
	//Component input port (uncomment if needed)
    @ComponentInput(
            name = Names.PORT_TEXT,
            description="Input description"
    )
    protected static final String IN_TEXT = Names.PORT_TEXT;
*/	
    @ComponentOutput(
            name = Names.PORT_TEXT,
            description = "Send a string to output"
    )
    protected static final String OUT_TEXT = Names.PORT_TEXT;
    
    
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
		cc.pushDataComponentToOutput(OUT_TEXT,BasicDataTypesTools.stringToStrings(_text));

	}

	@Override
	public void disposeCallBack(ComponentContextProperties ccp)
			throws Exception {

	}

}
