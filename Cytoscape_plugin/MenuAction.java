import java.awt.Color;
import java.awt.event.ActionEvent;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;

import org.cytoscape.app.CyAppAdapter;
import org.cytoscape.application.CyApplicationManager;
import org.cytoscape.application.swing.AbstractCyAction;

import org.cytoscape.model.CyNetwork;
import org.cytoscape.model.CyNode;
import org.cytoscape.model.CyEdge;
import org.cytoscape.view.model.CyNetworkView;
import org.cytoscape.view.presentation.property.BasicVisualLexicon;

public class MenuAction extends AbstractCyAction {	

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private final CyAppAdapter adapter;	
	
	double centerX = 35032.1111;
	double centerY = 1530.1111;
	double Radius = 99930.5111;
	double xvalueBegin = 0;
	double yvalueBegin = 0;
	double xvalueEnd = 0;
	double yvalueEnd = 0;
	double area_num = 0;
	double x1 = 0;
	double y1 = 0;
	double x2 = 0;
	double y2 = 0;
	double xm = 0;
	double ym = 0;
	
	CyNode blueNodeBegin = null;
	CyNode blueNodeEnd = null;
	int count;
	int jRed = 0;// the number of red node in a area
	int tempmax = 0;
	CyNode maxendnode = null;
	int blueNodeBeginInt;
	int blueNodeEndInt; 
	int k3 = 0;
	int z1 = 0;
	int t = 0;
	
	List<String> nodeAlreadyRedNodeList = new LinkedList<String>();//ergodic red nodes
	List<CyNode> nodeRedAreaNode = new LinkedList<CyNode>();//red nodes in a area
	
	List<String> nodeRedEdgeList = new LinkedList<String>();//ergodic red edges
	List<CyEdge> nodeRedEdge = new LinkedList<CyEdge>();//ergodic red edges
	
	List<String> nodeAlreadyBlueNodeList = new LinkedList<String>();//ergodic blue nodes
	List<CyNode> nodeBlueEndNode = new LinkedList<CyNode>();//end nodes of blue
	
	List<String> nodeBlueEdgeList = new LinkedList<String>();//ergodic blue edges
	
	public MenuAction(CyAppAdapter adapter) {
		super("Arrange node", adapter.getCyApplicationManager(), "network",
				adapter.getCyNetworkViewManager());
		this.adapter = adapter;
		setPreferredMenu("Select");
	}	
	
	public void actionPerformed(ActionEvent e) {
		final CyApplicationManager manager = adapter.getCyApplicationManager();
		final CyNetworkView networkView = manager.getCurrentNetworkView();
		final CyNetwork network = networkView.getModel();		
		int i = 0;
		mainCircle(network,networkView);
	    List<NewNode> SelectList = new ArrayList<NewNode>();
		for (CyNode node1 : network.getNodeList()) {
			if ((network.getRow(node1).get("status", Integer.class)== 3)) {
				
				double xblue = networkView.getNodeView(node1).getVisualProperty(BasicVisualLexicon.NODE_X_LOCATION);
				double yblue = networkView.getNodeView(node1).getVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION);
								    
				network.getRow(node1).set("coordinate",xblue + "_" + yblue);
				int value1 = network.getRow(node1).get("order", Integer.class);
				
				NewNode node = new NewNode();
				node.order = value1;
				node.node = node1;
				SelectList.add(node);
				count++;
				networkView.getNodeView(node1).setVisualProperty(BasicVisualLexicon.NODE_FILL_COLOR, Color.blue);//initializion the color of all the nodes, according to the value of "status" in nodes
			}
			else if (network.getRow(node1).get("status", Integer.class)== 2) {
				networkView.getNodeView(node1).setVisualProperty(BasicVisualLexicon.NODE_FILL_COLOR, Color.red);//initializion the color of all the nodes, according to the value of "status" in node
			}
			else if(network.getRow(node1).get("status", Integer.class)== 1){
				networkView.getNodeView(node1).setVisualProperty(BasicVisualLexicon.NODE_FILL_COLOR, Color.green);//initializion the color of all the nodes, according to the value of "status" in node
			}
		}	
		for (CyEdge edge0 : network.getEdgeList()) {
			if ((network.getRow(edge0).get("status", Integer.class)== 3)) {
				networkView.getEdgeView(edge0).setVisualProperty(BasicVisualLexicon.EDGE_UNSELECTED_PAINT, Color.blue);//initializion the color of all the nodes, according to the value of "status" in edge
			}
			else if ((network.getRow(edge0).get("status", Integer.class)== 2)) {
				networkView.getEdgeView(edge0).setVisualProperty(BasicVisualLexicon.EDGE_UNSELECTED_PAINT, Color.red);//initializion the color of all the nodes, according to the value of "status" in edge
			}
			else if ((network.getRow(edge0).get("status", Integer.class)== 1)) {
				networkView.getEdgeView(edge0).setVisualProperty(BasicVisualLexicon.EDGE_UNSELECTED_PAINT, Color.green);//initializion the color of all the nodes, according to the value of "status" in edge
			}
		}
		
		
		ComparatorNodes comparatorNodes = new ComparatorNodes();
		Collections.sort(SelectList, comparatorNodes); 		
		
		//ergodic all the nodes ,and find the specific blue by "order"
		for (NewNode node : SelectList) {			
			if (					
					!nodeAlreadyBlueNodeList.contains(network.getRow(node.node).get("name", String.class))
			   ){			
				    if(blueNodeBegin == null){
				    	List<CyNode> neighborNode = network.getNeighborList(node.node,CyEdge.Type.ANY); 		   
				    	for (CyNode nodeblue: neighborNode){
				    		if((network.getRow(nodeblue).get("status",Integer.class)==3)
				    		&&(network.getRow(node.node).get("status",Integer.class)==3)		
				    		){
				    		}				    		
				    		else {	
				    			z1++;
				    		}
				    	}
				    	if(z1 < 1){	
				    	}
				    	else if(z1 > 0){				    		
				    		blueNodeBegin = node.node;
				    		z1 = 0;
				    	}
					}						
					int noderidInt = network.getRow(node.node).get("order",Integer.class);//blueNei2µÄorder
					
					int cutmax = tempmax - noderidInt;
					
					if(((noderidInt <= tempmax)&&(cutmax<20))||(maxendnode==null)
					 ){						
						    neiList(i,node.node,network,networkView);						    
					 }
					else if(noderidInt > tempmax){
							blueNodeBeginInt = network.getRow(blueNodeBegin).get("order",Integer.class);
							
						    blueNodeEndInt = network.getRow(maxendnode).get("order",Integer.class);	
							
						    int cutrid = blueNodeEndInt - blueNodeBeginInt;						    
//to prevent the distance too far between two blue nodes	   
							if((cutrid>0)&&(cutrid<30)){
								networkView.getNodeView(blueNodeBegin);	//beginNode
																	
								for(CyNode nodeRed: nodeRedAreaNode){
									networkView.getNodeView(nodeRed);//Node
								}
								for(CyEdge redEdge:nodeRedEdge){
									networkView.getEdgeView(redEdge);//Node
								}
								networkView.getNodeView(maxendnode);
//call the funtion of arrange the node
								area_num++;
								areaRedNode(network,networkView,blueNodeBegin,maxendnode);
								nearNode(network,networkView);								
								k3 = 0;
								
								blueNodeBegin = null;
								maxendnode = null;
								tempmax = 0;								
								nodeRedAreaNode.clear();//
								nodeRedEdgeList.clear();
								nodeRedEdge.clear();
								nodeBlueEndNode.clear();
								jRed = 0;
								if(blueNodeBegin == null){
							    	List<CyNode> neighborNode = network.getNeighborList(node.node,CyEdge.Type.ANY); 		   
							    	for (CyNode nodeblue: neighborNode){
							    		if((network.getRow(nodeblue).get("status",Integer.class)==3)
							    		&&(network.getRow(node.node).get("status",Integer.class)==3)		
							    		){
							    		}				    		
							    		else {	
							    			z1++;
							    		}
							    	}
							    	if(z1 < 1){	
							    	}
							    	else if(z1 > 0){				    		
							    		blueNodeBegin = node.node;
							    		z1 = 0;
							    	}
								}
								neiList(i,node.node,network,networkView);
							}
							else {									
								blueNodeBegin = null;
								maxendnode = null;
								tempmax = 0;
								nodeRedAreaNode.clear();
								nodeRedEdgeList.clear();
								nodeRedEdge.clear();
								nodeBlueEndNode.clear();
								jRed = 0;
							}
					}
					else if(cutmax>20){
						nodeAlreadyBlueNodeList.add(network.getRow(node.node).get("name", String.class));
						blueNodeBegin = null;
						maxendnode = null;
						tempmax = 0;
						nodeRedAreaNode.clear();
						nodeRedEdgeList.clear();
						nodeRedEdge.clear();
						nodeBlueEndNode.clear();
						jRed = 0;
					}
				}
			 }	
	}
	
	public void mainCircle(CyNetwork network,CyNetworkView networkView){
		int curr_order=-1, curr_i=0; double curr_rad=0;
		int m = 0;
		int i = 0;
		int count = 0;
		int vnode2 = 0;
		double xvalue;
		double yvalue;
		List<NewNode1> SelectList = new ArrayList<NewNode1>();
		
		for (CyNode node1 : network.getNodeList()) {
			if (network.getRow(node1).get("order", Integer.class) != 0) {				
				int value1 = network.getRow(node1).get("order", Integer.class);
				NewNode1 node = new NewNode1();
				node.order = value1;
				node.status = network.getRow(node1).get("status", Integer.class);
				node.node = node1;
				SelectList.add(node);
				count++;	
			}
		}			
		ComparatorNodes1 comparatorNodes = new ComparatorNodes1();
		Collections.sort(SelectList, comparatorNodes);  
		for (NewNode1 vnodenext : SelectList) {
			CyNode nodenext = vnodenext.node;
			i++;
			vnode2 = vnodenext.order;
			
			if ((network.getRow(nodenext).get("order", Integer.class) != 0)) {
				if (curr_order != vnode2) {
					curr_i= i;
					curr_order = vnode2; 
					curr_rad = Radius;					
					m = 0;
				}
				else {	
						m++;						
				}	
				int a = m%2;
				if(m == 0){
					curr_rad = curr_rad + m;
				}
				else {
					if(a == 0){		
						curr_rad = curr_rad + 70*m;								
					}
					else {
						curr_rad = curr_rad - 70*m;							
					}
				}
					
				xvalue = centerX + (int) (curr_rad * Math.cos(Math.PI * 2 / count * curr_i));
			    yvalue = centerY + (int) (curr_rad * Math.sin(Math.PI * 2 / count * curr_i));
		
				//set the value of coordinates to nodes
				networkView.getNodeView(nodenext).setVisualProperty(BasicVisualLexicon.NODE_X_LOCATION, xvalue);
				networkView.getNodeView(nodenext).setVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION, yvalue);
				network.getRow(nodenext).set("coordinate",xvalue + "_" + yvalue);
		    }
		}	
		networkView.updateView();	
	}
	//place other nodes one by one near one of the two blue nodes as much as possible
	public void nearNode(CyNetwork network,CyNetworkView networkView){
		int i = 0;
		int u = 0;
		for (CyNode node : nodeRedAreaNode) {		
			if((network.getRow(node).get("coordinate", String.class)== null)||(network.getRow(node).get("coordinate", String.class)== "")){
				near1(i,network,networkView,u);		
			}
		}
		networkView.updateView();
	}	
	public void near1(int i,CyNetwork network,CyNetworkView networkView,int u){			
		for (CyNode node : nodeRedAreaNode) {			
			if ((network.getRow(node).get("coordinate", String.class)== null)||(network.getRow(node).get("coordinate", String.class)== "")){						
				u = 1;	
				near2(i,network,networkView,node,u);
			}
			else if((network.getRow(node).get("coordinate", String.class)!= null)&&(network.getRow(node).get("coordinate", String.class)!= "")){
				u = 2;	
				near2(i,network,networkView,node,u);	
			}
		}
	}
	
	public void near2(int i,CyNetwork network,CyNetworkView networkView,CyNode node, int u){
		int count = 10;	
		double xvalue;
		double yvalue;
		double centerX;
		double centerY;
		double Radius = 150.00;
		List<CyNode> neighborList = network.getNeighborList(node, CyEdge.Type.ANY);				
		for(CyNode nodenei : neighborList){			
				if(u == 1){
					if ((network.getRow(nodenei).get("coordinate", String.class)!= "")
							&&(network.getRow(nodenei).get("coordinate", String.class)!= null)){
								centerX = (networkView.getNodeView(nodenei).getVisualProperty(BasicVisualLexicon.NODE_X_LOCATION));
								centerY = (networkView.getNodeView(nodenei).getVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION));
								i++;
								xvalue = centerX + (int) (Radius * Math.cos(Math.PI * 2 / count * i));
								yvalue = centerY + (int) (Radius * Math.sin(Math.PI * 2 / count * i));
								networkView.getNodeView(node).setVisualProperty(BasicVisualLexicon.NODE_X_LOCATION, xvalue);
								networkView.getNodeView(node).setVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION, yvalue);					
								network.getRow(node).set("coordinate","last" + xvalue + "_" + yvalue);
								u++;
								near2(i,network,networkView,node,u);
						}
				}
				else if(u == 2){
					if ((network.getRow(nodenei).get("coordinate", String.class)== "")
							||(network.getRow(nodenei).get("coordinate", String.class)== null)){
								centerX = (networkView.getNodeView(node).getVisualProperty(BasicVisualLexicon.NODE_X_LOCATION));
								centerY = (networkView.getNodeView(node).getVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION));
								i++;
								xvalue = centerX + (int) (Radius * Math.cos(Math.PI * 2 / count * i));
								yvalue = centerY + (int) (Radius * Math.sin(Math.PI * 2 / count * i));
								networkView.getNodeView(nodenei).setVisualProperty(BasicVisualLexicon.NODE_X_LOCATION, xvalue);
								networkView.getNodeView(nodenei).setVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION, yvalue);					
								network.getRow(nodenei).set("coordinate","last" + xvalue + "_" + yvalue);
						}
				}					
		}
	}
	
//Recursive function
	public void neiList(int n,CyNode node,CyNetwork network,CyNetworkView networkView){
		if (n <= 20){			
		    n++;	

		    List<CyEdge> neighborListEdge = network.getAdjacentEdgeList(node,CyEdge.Type.ANY); 		   
			for (CyEdge edge1: neighborListEdge){
				 if((network.getRow(edge1).get("status",Integer.class)==2)
						 &&(!nodeRedEdgeList.contains(network.getRow(edge1).get("name", String.class)))
						 &&(!nodeRedEdge.contains(edge1))
						 ){
					 nodeAlreadyBlueNodeList.add(network.getRow(node).get("name", String.class));
					 nodeRedEdgeList.add(network.getRow(edge1).get("name", String.class));
					 nodeRedEdge.add(edge1);				

					 CyNode nodeTarget = edge1.getTarget();
					 CyNode nodeSource = edge1.getSource();
					 CyNode node2 = null;
					 if(edge1.getSource().equals(node)){	
							 node2 = nodeTarget;						
					 }
					 else if(edge1.getTarget().equals(node)){						 
							 node2 = nodeSource;
					 }
					 
					if( (network.getRow(node2).get("status",Integer.class)==2)
						&&(!nodeRedAreaNode.contains(node2))
						&&(!nodeAlreadyRedNodeList.contains(network.getRow(node2).get("name", String.class)))
						){
							nodeRedAreaNode.add(node2);
							nodeAlreadyRedNodeList.add(network.getRow(node2).get("name", String.class));	
							jRed++;
							neiList(n,node2,network,networkView);
						}
					else if((network.getRow(node2).get("status",Integer.class)==3)
						&&(network.getRow(node).get("status", Integer.class)==3)
						&&(!nodeAlreadyBlueNodeList.contains(network.getRow(node2).get("name", String.class)))
						&&(!nodeBlueEndNode.contains(node2))
						){	
							nodeAlreadyBlueNodeList.add(network.getRow(node).get("name", String.class));
						}
					else if( (network.getRow(node2).get("status",Integer.class)==3)
						&&(network.getRow(node).get("status", Integer.class)==2)
						&&(!nodeAlreadyBlueNodeList.contains(network.getRow(node2).get("name", String.class)))
						&&(!nodeBlueEndNode.contains(node2))
						){									
							nodeBlueEndNode.add(node2);
							blueNodeEnd = node2;
							int endRidInt = network.getRow(blueNodeEnd).get("order",Integer.class);
							
							if((tempmax==0)&&(maxendnode == null)){
							   tempmax = endRidInt;
							   maxendnode = blueNodeEnd;
							  }
							else if(endRidInt>tempmax){
							   tempmax = endRidInt;
							   maxendnode = blueNodeEnd;
							  }	
						}
				 }		 
				 else if((network.getRow(edge1).get("status",Integer.class)==3)						 
						 &&(!nodeBlueEdgeList.contains(network.getRow(edge1).get("name", String.class)))
						 ){
							 nodeBlueEdgeList.add(network.getRow(edge1).get("name", String.class));
				 }				
			}
		}
	}
	
//arrange nodes in a area
    public void areaRedNode(CyNetwork network,CyNetworkView networkView,CyNode blueNodeBegin,CyNode maxendnode){
	    
	    xvalueBegin	= networkView.getNodeView(blueNodeBegin).getVisualProperty(BasicVisualLexicon.NODE_X_LOCATION);   
		yvalueBegin = networkView.getNodeView(blueNodeBegin).getVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION);
		xvalueEnd = networkView.getNodeView(maxendnode).getVisualProperty(BasicVisualLexicon.NODE_X_LOCATION);
		yvalueEnd = networkView.getNodeView(maxendnode).getVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION);	
		int m = 0;
		int k1 = 0;
		int curr_k = 0;
		double d = 0;
		double x = 0;
		double x0 = 0;
		double y0 = 0;
		double xNewvalue = 0;
		double yNewvalue = 0;
		double angleA;
		double angleP;
		double angleQ;
		CyNode blueTemp = null;
		CyNode blueTemp2 = null;		
		double xValue;	
		double K = (0.5)*(Math.sqrt((xvalueEnd - xvalueBegin) * (xvalueEnd - xvalueBegin) + (yvalueEnd - yvalueBegin) * (yvalueEnd - yvalueBegin)));
		for (CyNode areaNode : nodeRedAreaNode) {
			if((network.getRow(areaNode).get("coordinate", String.class) == null)
			   ||(network.getRow(areaNode).get("coordinate", String.class) == "")
			){
				k1++;	
				blueRedBlue(areaNode,network,networkView,m,k1,blueTemp,blueTemp2);
			}
		}
		for (CyNode areaNode2 : nodeRedAreaNode) {
			if((network.getRow(areaNode2).get("coordinate", String.class) == null)
			   ||(network.getRow(areaNode2).get("coordinate", String.class) == "")	
			){
				blueRedBlue2(areaNode2,network,networkView);				
			}
		}
		t = 0;	
			double M = (k1+2-k3)*(2*Math.PI*Radius)/count;
			double a = (2*K)/M;	
			if((a == 0)||(a < 0)){
				return ;
			}
			else {					
				List<Double> rootValue = root(a,x,networkView);	
				xValue = rootValue.get(0);	
				d = M / (2 * xValue);	
				if(xValue <= 0){	
					return ;
				}
				else if((xValue >0)&&(d > K)){
					angleA = Math.asin(K/d);
					angleP = Math.atan2(yvalueEnd - yvalueBegin, xvalueEnd - xvalueBegin);
					angleQ = Math.PI - (Math.PI/2 - angleA - angleP);					
					if((xvalueBegin > 0)&&(yvalueBegin > 0)){						
						x0 = xvalueBegin + Math.abs(Math.cos(angleQ)) * d;
						y0 = yvalueBegin + Math.abs(Math.sin(angleQ)) * d;
					}
					else if((xvalueBegin > 0)&&(yvalueBegin < 0)){						
						x0 = xvalueBegin - Math.cos(angleQ) * d;
						y0 = yvalueBegin - Math.sin(angleQ) * d;
					}
					else if((xvalueBegin < 0)&&(yvalueBegin > 0)){
						x0 = xvalueBegin - Math.abs(Math.cos(angleQ)) * d;
						y0 = yvalueBegin - Math.abs(Math.sin(angleQ)) * d;
					}	
					else if((xvalueBegin < 0)&&(yvalueBegin < 0)){
						x0 = xvalueBegin - Math.abs(Math.cos(angleQ)) * d;
						y0 = yvalueBegin - Math.abs(Math.sin(angleQ)) * d;
					}	
					
					for (CyNode areaNode2: nodeRedAreaNode){					
						if((network.getRow(areaNode2).get("coordinate", String.class) == null)||(network.getRow(areaNode2).get("coordinate", String.class) == "")){	
							curr_k++;
								xNewvalue = x0 + (int) (d * Math.cos(((Math.PI * 2 - 2 * angleA)/ (k1+1-k3)) * curr_k + angleA + Math.PI*0.5 + angleP));
								yNewvalue = y0 + (int) (d * Math.sin(((Math.PI * 2 - 2 * angleA)/ (k1+1-k3)) * curr_k + angleA + Math.PI*0.5 + angleP));
							
							network.getRow(areaNode2).set("coordinate",Double.toString(xNewvalue) + "_"+ Double.toString(yNewvalue) + "_" + curr_k);
							
							networkView.getNodeView(areaNode2).setVisualProperty(BasicVisualLexicon.NODE_X_LOCATION, xNewvalue);
							networkView.getNodeView(areaNode2).setVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION, yNewvalue);
						}
					}
				}	
				for (CyNode areaNode2 : nodeRedAreaNode) {
					if((network.getRow(areaNode2).get("coordinate", String.class) == null)
					   ||(network.getRow(areaNode2).get("coordinate", String.class) == "")	
					){
						blueRedBlue2(areaNode2,network,networkView);						
					}
				}				
			}
    }¨
    
//  middle
    public void blueRedBlue(CyNode areaNode,CyNetwork network,CyNetworkView networkView,
    		int m,int k1,CyNode blueTemp,CyNode blueTemp2){    
    	int blueTempOrder = 0 ;
    	int blueTemp2Order = 0;
    	List<CyNode> blueRedBlue = network.getNeighborList(areaNode,CyEdge.Type.ANY);
		for (CyNode blue : blueRedBlue) {
			if((network.getRow(blue).get("status", Integer.class)==3)
				){
				m++;
				if((blueTemp == null)&&(m < 2)){
					blueTemp = blue;		
					blueTempOrder = network.getRow(blueTemp).get("order", Integer.class); 
				}
				else if((m < 3)&&(m > 1)){
					blueTemp2 = blue;	
					blueTemp2Order = network.getRow(blueTemp2).get("order", Integer.class);
				}					
			}	
		}		
		int cutblueTemp = blueTemp2Order - blueTempOrder;
		
		if((m == 2)&&((network.getRow(areaNode).get("order", Integer.class)==0))&&((cutblueTemp < 50)&&(cutblueTemp > -50))
				){			
			k3++;
			x1	= networkView.getNodeView(blueTemp).getVisualProperty(BasicVisualLexicon.NODE_X_LOCATION);   
			y1 = networkView.getNodeView(blueTemp).getVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION);
			x2 = networkView.getNodeView(blueTemp2).getVisualProperty(BasicVisualLexicon.NODE_X_LOCATION);
			y2 = networkView.getNodeView(blueTemp2).getVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION);
			double b = Math.abs(Math.atan2(y2 - y1,x2 - x1));
			double a1 = Math.PI/2 - b;
		
			double xvalueMiddle = (x1 + x2) / 2;
			double yvalueMiddle = (y1 + y2) / 2;	
			
			if((k3%2) == 0){
				xm = xvalueMiddle + k3*Math.sqrt((xvalueMiddle - x1) * (xvalueMiddle - x1) + (yvalueMiddle - y1) * (yvalueMiddle - y1)) * Math.cos(a1);
				ym = yvalueMiddle + k3*Math.sqrt((xvalueMiddle - x1) * (xvalueMiddle - x1) + (yvalueMiddle - y1) * (yvalueMiddle - y1)) * Math.sin(a1);
			}
			else {
				xm = xvalueMiddle - k3*Math.sqrt((xvalueMiddle - x1) * (xvalueMiddle - x1) + (yvalueMiddle - y1) * (yvalueMiddle - y1)) * Math.cos(a1);
				ym = yvalueMiddle - k3*Math.sqrt((xvalueMiddle - x1) * (xvalueMiddle - x1) + (yvalueMiddle - y1) * (yvalueMiddle - y1)) * Math.sin(a1);
			}
			networkView.getNodeView(areaNode).setVisualProperty(BasicVisualLexicon.NODE_X_LOCATION, xm);
			networkView.getNodeView(areaNode).setVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION, ym);
			network.getRow(areaNode).set("coordinate",Double.toString(xm) + "_"+ Double.toString(ym));
			network.getRow(areaNode).set("search","k1=" + Integer.toString(k1) + "_" + "k3=" + Integer.toString(k3));				
		} 
		m = 0;
		blueTemp = null;
		if(m > 2){				   			
		} 		
	}
//    middle2
    public void blueRedBlue2(CyNode areaNode,CyNetwork network,CyNetworkView networkView){
    	int countCoo = 0;    	
    	CyNode cooNode1 = null;
    	CyNode cooNode2 = null;  
    	int cooNode1Order = 0;
    	int cooNode2Order = 0;
			t++;
			if(t < 5){
				List<CyNode> redCoordinate = network.getNeighborList(areaNode,CyEdge.Type.ANY);
				for (CyNode coordinateNode : redCoordinate) {    					
					if((network.getRow(coordinateNode).get("coordinate", String.class) == null)
					  ||(network.getRow(coordinateNode).get("coordinate", String.class) == "")
					){    						
					}
					else {
						countCoo++;
						if(countCoo == 1){
							cooNode1 = coordinateNode;
							cooNode1Order = network.getRow(cooNode1).get("order", Integer.class); 
						}
						else if(countCoo == 2){
							cooNode2 = coordinateNode;
							cooNode2Order = network.getRow(cooNode2).get("order", Integer.class); 
						}
					}
				}
				int cutcooNode = cooNode1Order - cooNode2Order;
				if((countCoo == 2) && ((cutcooNode < 50) && (cutcooNode > 50))){
					double x11	= networkView.getNodeView(cooNode1).getVisualProperty(BasicVisualLexicon.NODE_X_LOCATION);   
					double y11 = networkView.getNodeView(cooNode1).getVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION);
					double x22 = networkView.getNodeView(cooNode2).getVisualProperty(BasicVisualLexicon.NODE_X_LOCATION);
					double y22 = networkView.getNodeView(cooNode2).getVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION);
        			double b = Math.abs(Math.atan2(y22 - y11,x22 - x11));
        			double a1 = Math.PI/2 - b;
        		
        			double xvalueMiddle = (x11 + x22) / 2;
        			double yvalueMiddle = (y11 + y22) / 2;	
        			
        			double xm2 = xvalueMiddle - t*Math.sqrt((xvalueMiddle - x11) * (xvalueMiddle - x11) + (yvalueMiddle - y11) * (yvalueMiddle - y11)) * Math.cos(a1);
        			double ym2 = yvalueMiddle - t*Math.sqrt((xvalueMiddle - x11) * (xvalueMiddle - x11) + (yvalueMiddle - y11) * (yvalueMiddle - y11)) * Math.sin(a1);
        		
        			networkView.getNodeView(areaNode).setVisualProperty(BasicVisualLexicon.NODE_X_LOCATION, xm2);
        			networkView.getNodeView(areaNode).setVisualProperty(BasicVisualLexicon.NODE_Y_LOCATION, ym2);
        			network.getRow(areaNode).set("coordinate",Double.toString(xm2) + "_"+ Double.toString(ym2));
        			network.getRow(areaNode).set("search","k1=" + "_" + "t=" + Integer.toString(t));
				}
    	}
	}
    
    public List<Double> root(double a,double x,CyNetworkView networkView){
    	List<Double> root = new LinkedList<Double>();	
    	int i = 2;    	
		while (i<5){
			double lower = -(Math.PI)/2 +(i - 1)*Math.PI;
			double upper = lower + Math.PI;
				
			double lValue = f(lower,a);
			double uValue = f(upper,a);
			if((lValue*uValue) > 0){
				if(root.size()==0){
					root.add(0.0);
					}
				else {
					}
			}
			else if(lValue*uValue <= 0){
				double xvalue = uniRoot(a,lower,upper);							
				if(xvalue <= 0){
				}
				else if(xvalue >  0) {	
					root.add(xvalue);	
					return root;
				}			
			}
			i++;
		}				
			root.add(-1.0);
			return root;			
    }
    
//  f = sinx - a*x
    public double f(double x,double a){    	
    	double rootValue = Math.sin(x) - a * x;    	
    	return rootValue ;    	
    }
//Dichotomy function
    public double uniRoot(double a,double lower,double upper){
    	double ret = -1;
    	if(lower > upper){
    		return -1;
    	}
    	double mid = (lower + upper)/2;
    	double mid2 = Math.sin(mid)-a*mid;
    	if(mid2 < Math.abs(0.001)){    		
    		return mid;
    	}
    	if(mid2 < 0){    		
    		uniRoot(a,mid2,upper);
    	}
    	if(mid2 > 0){    	
    		uniRoot(a,lower,mid2);    		
    	}
    	return ret;  
    }
    
}

class NewNode {
	 int order;
	 CyNode	node;
	 int getorder(){
		 return order;
	 }
	 CyNode getnode(){
		 return node;
	 }
}
class ComparatorNodes implements Comparator<NewNode>{
	public final int compare(NewNode pFirst, NewNode pSecond) {	
			
		int aFirstorder = pFirst.order;			
		int aSecondorder =  pSecond.order;
		int difforder = aFirstorder - aSecondorder;	
		if (difforder > 0)	
			   return 1;
		
			if (difforder < 0)	
			   return -1;
		else return 0;
		
}
}
class NewNode1 {
	 int order;
	 int status;
	 CyNode	node;
	 int getorder(){
		 return order;
	 }
	 int getstatus(){
		 return status;
	 }
	 CyNode getnode(){
		 return node;
	 }
}

class ComparatorNodes1 implements Comparator<NewNode1>{
	public final int compare(NewNode1 pFirst, NewNode1 pSecond) {	
			
		int aFirstorder = pFirst.order;			
		int aSecondorder =  pSecond.order;
		int aFirststatus = pFirst.status;			
		int aSecondstatus =  pSecond.status;
		int difforder = aFirstorder - aSecondorder;	
		int diffstatus = aFirststatus - aSecondstatus;	
	
		if ((diffstatus>0)&&(difforder>0))
			return 1;
		if ((diffstatus>0)&&(difforder<0))
			return -1;
		if ((diffstatus>0)&&(difforder==0))
			return -1;		
		
		if ((diffstatus<0)&&(difforder>0))
			return 1;
		if ((diffstatus<0)&&(difforder<0))
			return -1;
		if ((diffstatus<0)&&(difforder==0))
			return 1;
		
		if ((diffstatus==0)&&(difforder>0))
			return 1;
		if ((diffstatus==0)&&(difforder<0))
			return -1;
		if ((diffstatus==0)&&(difforder==0))
			return 0;
		
		else return 0;
}
}
