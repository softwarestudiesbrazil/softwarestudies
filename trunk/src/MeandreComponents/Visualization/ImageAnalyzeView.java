import java.awt.BorderLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;

/**
 * 
 * This class creates an interface for user to input text which will be passed to another
 * class to do the actual processing and socket connection. It contains a log window
 * which is used to receive feedback messages from the server(jeju).
 *
 * TODO How should results be displayed to user
 */
public class ImageAnalyzeView extends JPanel implements ActionListener{
	JButton submitButton;	//click to submit information to server
	JTextArea log;			//log feedback information
	JTextField filePath;	//input field for file path
	
	public ImageAnalyzeView(){
		super(new BorderLayout());
		
        log = new JTextArea(5,20);
        log.setMargin(new Insets(5,5,5,5));
        log.setEditable(false);
        
        submitButton = new JButton("Submit");
        submitButton.addActionListener(this);
        filePath = new JTextField(30);
        
        JScrollPane logScrollPane = new JScrollPane(log);
        
        JPanel componentsPanel = new JPanel(); //use FlowLayout
        componentsPanel.add(filePath);
        componentsPanel.add(submitButton);
        
        add(componentsPanel,BorderLayout.PAGE_START);
        add(logScrollPane, BorderLayout.CENTER);
	}
	
	@Override
	public void actionPerformed(ActionEvent e) {
		String path = filePath.getText();
		
		//if statements will represent checking for a valid directory path
		if(path.length() == 0)
			log.setText("Not a valid Directory");
		
		//send directory to client class to 
		else{
			//call TCP Class
			ClientImageAnalyze client = new ClientImageAnalyze(path,log);
			client.run();
		}
	}
	
	public static void main(String[] args){
        JFrame frame = new JFrame("ImageAnalyzeView");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
 
        //Add content to the window.
        frame.add(new ImageAnalyzeView());
 
        //Display the window.
        frame.pack();
        frame.setVisible(true);
	}

}