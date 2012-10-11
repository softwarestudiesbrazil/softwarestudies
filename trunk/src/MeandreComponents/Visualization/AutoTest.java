import com.jcraft.jsch.*;

import java.io.*;
//SSH implementation
public class AutoTest {
	public static void main(String[] args) throws JSchException, IOException{
		JSch jsch=new JSch();
		String host = "jeju.ucsd.edu";
		String user = "culturevis";
		Session session=jsch.getSession(user, host, 22);
		
	    UserInfo ui=new MyUserInfo();
	    session.setUserInfo(ui);
	    session.connect();
	    
	    String[] commands = new String[3];
	    Channel channel = null;
	    commands[0] = "pwd";
	    commands[1] = "echo \"Hello World\" >> /Users/culturevis/Documents/MeandreTesting/text.txt";
	    commands[2] = "cat /Users/culturevis/Documents/MeandreTesting/text.txt";
	    
	    for(int c=0;c<commands.length;c++){
	    	String command = commands[c];
		    channel=session.openChannel("exec");
		    ((ChannelExec)channel).setCommand(command);
		    
		    channel.setInputStream(null);
	
		    //channel.setOutputStream(System.out);
	
		    //FileOutputStream fos=new FileOutputStream("/tmp/stderr");
		    //((ChannelExec)channel).setErrStream(fos);
		    ((ChannelExec)channel).setErrStream(System.err);
	
		    InputStream in=channel.getInputStream();
		    
		    channel.connect();
	
		    byte[] tmp=new byte[1024];
		    while(true){
		      while(in.available()>0){
		        int i=in.read(tmp, 0, 1024);
		        if(i<0)break;
		        System.out.print(new String(tmp, 0, i));
		        System.out.println("aha");
		      }
		      if(channel.isClosed()){
		        System.out.println("exit-status: "+channel.getExitStatus());
		        break;
		      }
		      try{Thread.sleep(1000);}catch(Exception ee){}
		    }
	    }
	    channel.disconnect();
	    session.disconnect();
	    
	}
	public static class MyUserInfo implements UserInfo, UIKeyboardInteractive{
		String passwd;
		
		public String getPassword(){ return passwd; }
		public boolean promptYesNo(String str){ return true;}
		public boolean promptPassphrase(String message){ return true; }
		public String getPassphrase(){ return null; }
		public void showMessage(String message){}
		public boolean promptPassword(String message){
			passwd = "password";
			return true;
		}
		@Override
		public String[] promptKeyboardInteractive(String destination,
				String name, String instruction, String[] prompt, boolean[] echo) {
			// TODO Auto-generated method stub
			String[] response = new String[1];
			response[0] = "password";
			return response;
		}
	}
}
