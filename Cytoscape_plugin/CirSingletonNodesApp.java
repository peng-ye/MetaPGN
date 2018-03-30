import org.cytoscape.app.swing.AbstractCySwingApp;
import org.cytoscape.app.swing.CySwingAppAdapter;
public class CirSingletonNodesApp extends AbstractCySwingApp
{    
	public CirSingletonNodesApp(CySwingAppAdapter adapter)    
	{        
		super(adapter);        
		adapter.getCySwingApplication().addAction(new MenuAction(adapter));   
		}
	} 
