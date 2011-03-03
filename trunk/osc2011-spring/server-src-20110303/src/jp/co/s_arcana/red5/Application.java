package jp.co.s_arcana.red5;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.red5.logging.Red5LoggerFactory;
import org.red5.server.adapter.ApplicationAdapter;
import org.red5.server.api.IClient;
import org.red5.server.api.IConnection;
import org.red5.server.api.IScope;
import org.red5.server.api.Red5;
import org.red5.server.api.ScopeUtils;
import org.red5.server.api.service.ServiceUtils;
import org.red5.server.api.stream.IBroadcastStream;
import org.slf4j.Logger;

public class Application extends ApplicationAdapter {
	
	private static final String SELF_APP_NAME = "conference";
	
	private static final String LOBBY_SCOPE_NAME = "room";
	
	private static Logger log = Red5LoggerFactory.getLogger(Application.class, SELF_APP_NAME);
	

	@Override
	public synchronized boolean connect(IConnection conn, IScope scope, Object[] params) {
		log.debug("connect: start");
		
		boolean result =  super.connect(conn, scope, params);
		
		if(scope != null && scope.hasParent() && LOBBY_SCOPE_NAME.equals( scope.getParent().getName() ) ){
			log.debug("###set isJoinedRoom to true in connect");
			conn.getClient().setAttribute("isJoinedRoom", true);
			
			this.updateClientList();
		}

		log.debug("###connect(): end");
		return result;
	}
	
	private static boolean isClientJoinedToConferenceRoom(IScope _scope) {
		return (_scope != null && _scope.hasParent() && LOBBY_SCOPE_NAME.equals( _scope.getParent().getName() ) );
	}

	@Override
	public boolean roomJoin(IClient client, IScope scope) {
		boolean result = super.roomJoin(client, scope);
		this.updateRoomCount(scope);
		return result;
	}

	@Override
	public void roomLeave(IClient client, IScope scope) {
		super.roomLeave(client, scope);
		this.updateRoomCount(scope);
	}
	
	@Override
	public synchronized void disconnect(IConnection conn, IScope scope) {
		log.debug("###disconnect(): start");
		
		if(scope != null && scope.hasParent() && LOBBY_SCOPE_NAME.equals( scope.getParent().getName() ) ){
		
			log.debug("###set isJoinedRoom to false in disconnect");
			conn.getClient().setAttribute("isJoinedRoom", false);
			conn.getClient().setAttribute("published", false);
			
			this.updateClientList();
		}

		super.disconnect(conn, scope);

		log.debug("###disconnect(): end");
	}
	
	
	@Override
	public synchronized void streamPublishStart(IBroadcastStream stream){
		log.debug("###streamPublishStart(): start");
		
		super.streamPublishStart(stream);
		
		IConnection conn = Red5.getConnectionLocal();
		IClient client = conn.getClient();
		client.setAttribute("published", true);
		
		this.updateClientList();

		
		log.debug("###streamPublishStart(): end");
	}
	
	@Override
	public synchronized void streamBroadcastClose(IBroadcastStream stream){
		log.debug("###streamBroadcastClose(): start");
		
		IConnection conn = Red5.getConnectionLocal();
		IClient client = conn.getClient();

		log.debug("###stream.getPublishedName(): " + stream.getPublishedName() );
		
		if( stream.getPublishedName().equals( "publish:" + client.getId() ) ){
			client.setAttribute("published", false);
		}
		
		this.updateClientList();
		
		super.streamBroadcastClose(stream);

		log.debug("###streamBroadcastClose(): end");
	}
	
	
	//=============================================================================
	// These methods invoked from clients
	//=============================================================================

	//----------------------------------------------------------------
	// for Conference
	//----------------------------------------------------------------
	
	public synchronized String getClientId() {
		IConnection conn = Red5.getConnectionLocal();
		IClient client = conn.getClient();

		return client.getId();
	}
	
	public synchronized void setClientName(String newName) {
		IConnection conn = Red5.getConnectionLocal();
		IClient client = conn.getClient();
		client.setAttribute("name", newName);

		this.updateClientList();
		this.updateRoomCount(conn.getScope());
	}

	public synchronized void getRoomCount() {
		IClient client = Red5.getConnectionLocal().getClient();
		IScope scope = Red5.getConnectionLocal().getScope();
		
		// ロビーに接続した場合、人数情報を通知する
		if(scope != null && LOBBY_SCOPE_NAME.equals( scope.getName() ) ){
			log.debug("###client connected to lobby.");

			Object[] params = this.getRoomCountList(scope);
			ServiceUtils.invokeOnClient(client, scope, 
					"onRoomCountUpdated", params );
			
		}
	}
	
	//----------------------------------------------------------------
	// callback to client
	//----------------------------------------------------------------
	
	/**
	 * 同じ部屋のクライアントに対して、クライアント情報を通知する
	 */
	public synchronized void updateClientList() {

		IConnection conn = Red5.getConnectionLocal();
		IScope scope = conn.getScope();
		
		if(scope != null && scope.hasParent() && LOBBY_SCOPE_NAME.equals( scope.getParent().getName() ) ){
			
			log.debug("###invoke updateClientList");

			Collection<IClient> clients = conn.getScope().getClients();
			Collection<Map<String,Object>> clientList = new ArrayList<Map<String,Object>>();
			
			for(IClient client : clients) {
				Map<String, Object> map = new HashMap<String, Object>();

				map.put("id", client.getId());
				map.put("name", (String)client.getAttribute("name"));
				map.put("published", client.getAttribute("published"));
				map.put("isJoinedRoom", client.getAttribute("isJoinedRoom"));
				
				log.debug("###    client.getId(): {}", client.getId());
				log.debug("###    client.getAttribute(\"name\"): {}", client.getAttribute("name"));
				log.debug("###    client.getAttribute(\"published\"): {}", client.getAttribute("published"));
				log.debug("###    client.getAttribute(\"isJoinedRoom\"): {}", client.getAttribute("isJoinedRoom"));
				
				clientList.add( map );
			}
			
			ServiceUtils.invokeOnAllConnections(scope, 
					"onClientListUpdated", new Object[]{ clientList } );
		}
	}

	/**
	 * ロビーにいるクライアントに対して、各部屋の参加人数情報を通知する
	 */
	public synchronized void updateRoomCount(IScope scope) {
		log.debug("###invoke updateRoomCount... scope: {}", scope.getName());
			
		IScope appScope = ScopeUtils.findApplication(scope);
		log.debug("###     appScope.getClients().size(): {}", appScope.getClients().size());
		
		Object[] params = this.getRoomCountList(scope);
		ServiceUtils.invokeOnAllConnections(appScope, 
				"onRoomCountUpdated",  params);
	}
	
	
	private Object[] getRoomCountList(IScope scope) {
		IScope appScope = ScopeUtils.findApplication(scope);
		IScope lobbyScope = appScope.getScope(LOBBY_SCOPE_NAME);

		Iterator<String> childScopeNames = lobbyScope.getScopeNames();

		Collection<Map<String,Object>> roomCountList = new ArrayList<Map<String,Object>>();
		
		while(childScopeNames.hasNext()){
			String childName = childScopeNames.next();

			if (childName.startsWith(":")) {
				childName = childName.substring(1, childName.length());
			}
			IScope roomScope = lobbyScope.getScope(childName);
			
			if(roomScope == null){
				break;
			}

			Map<String, Object> map = new HashMap<String, Object>();
			
			Set<IClient> clients = roomScope.getClients();
			Integer activeClientCount = 0;
			Integer inactiveClientCount = 0;
			for(IClient client:clients){
				if( (Boolean) client.getAttribute("isJoinedRoom") ){
					activeClientCount++;
				} else {
					inactiveClientCount++;
				}
			}

			map.put("roomName", childName);
			map.put("count", activeClientCount);

			log.debug("### roomName: {}", childName);
			log.debug("###    count: {}", activeClientCount);
			log.debug("###    inactive: {}", inactiveClientCount);
			
			roomCountList.add( map );
			
		}
		
		return new Object[]{ roomCountList };
	}
	
}
