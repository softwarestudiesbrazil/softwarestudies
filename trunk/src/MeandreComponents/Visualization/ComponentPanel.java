import java.io.*;
import java.awt.*;
import java.awt.event.*;

import javax.swing.*;
import javax.swing.filechooser.*;

public class ComponentPanel extends JPanel implements ActionListener{
	JButton browseButton;
	JFileChooser fc;
	JTextArea log;
	static private final String newline = "\n";
	File[] filesInDirectory;
	
/*	public File[] getFilesInDir(){
		return filesInDirectory;
	}*/
	public ComponentPanel(){
		super(new BorderLayout());
		
		filesInDirectory = null;
		
        log = new JTextArea(5,20);
        log.setMargin(new Insets(5,5,5,5));
        log.setEditable(false);
        JScrollPane logScrollPane = new JScrollPane(log);
        
        fc = new JFileChooser();
        fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
        
        browseButton = new JButton("Browse");
        browseButton.addActionListener(this);
	
        JPanel buttonPanel = new JPanel(); //use FlowLayout
        buttonPanel.add(browseButton);
        
        add(buttonPanel, BorderLayout.PAGE_START);
        add(logScrollPane, BorderLayout.CENTER);
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		// TODO Auto-generated method stub
		if (e.getSource() == browseButton) {
			int returnVal = fc.showOpenDialog(ComponentPanel.this);
			
			if (returnVal == JFileChooser.APPROVE_OPTION) {
                //File file = fc.getSelectedFile();
				this.filesInDirectory = fc.getSelectedFile().listFiles();
                //This is where a real application would open the file.
				for ( File file : this.filesInDirectory ) {
					log.append("Opening: " + file.getName() + "." + newline);
					
				}
            } else {
                log.append("Open command cancelled by user." + newline);
            }
            log.setCaretPosition(log.getDocument().getLength());
            
			//call TCP Class
    		Client client = new Client(this.filesInDirectory);
    		client.run();
		}
	}
	
	public static void main(String[] args){
        JFrame frame = new JFrame("FileChooserDemo");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
 
        //Add content to the window.
        frame.add(new ComponentPanel());
 
        //Display the window.
        frame.pack();
        frame.setVisible(true);
	}
}
