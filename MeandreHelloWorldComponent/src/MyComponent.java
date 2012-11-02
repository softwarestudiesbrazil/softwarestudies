import org.meandre.annotations.Component;
import org.meandre.annotations.ComponentInput;
import org.meandre.core.ComponentContext;
import org.meandre.core.ComponentContextException;
import org.meandre.core.ComponentContextProperties;
import org.meandre.core.ComponentExecutionException;
import org.meandre.core.ExecutableComponent;

@Component(creator = "Omeed Mirbod", description = "Test Component",
tags= "images,pictures", name = "MyComponent")


public class MyComponent implements ExecutableComponent {

	public void dispose(ComponentContextProperties arg0)
			throws ComponentExecutionException, ComponentContextException {
		// TODO Auto-generated method stub

	}


	public void execute(ComponentContext arg0)
			throws ComponentExecutionException, ComponentContextException {
		// TODO Auto-generated method stub
		arg0.getOutputConsole().println("hello world");

	}


	public void initialize(ComponentContextProperties arg0)
			throws ComponentExecutionException, ComponentContextException {
		// TODO Auto-generated method stub

	}
}
