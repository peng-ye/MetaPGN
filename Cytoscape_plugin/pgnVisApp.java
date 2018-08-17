import org.cytoscape.app.swing.AbstractCySwingApp;
import org.cytoscape.app.swing.CySwingAppAdapter;
public class pgnVisApp extends AbstractCySwingApp
{    
	public pgnVisApp(CySwingAppAdapter adapter)    
	{        
		super(adapter);        
		adapter.getCySwingApplication().addAction(new MenuAction(adapter));   
		}
	} 
