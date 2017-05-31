package org.wsi;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.inject.Singleton;
import javax.ws.rs.Consumes;
import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;


@Path("/session/")
@Singleton
public class SessionManager {
	private Map<String, Session> sessions = new HashMap<String, Session>();
	private static final long max_seconds_keep_alive_session = 3600;
	
	@GET
	@Path("/test/")
	@Produces(MediaType.TEXT_PLAIN)
	public String test() {
		return "It works!";
	}
	
	@GET
	@Path("/new/")
	@Produces(MediaType.TEXT_PLAIN)
	public Response startNewSession() {
		clean_old_sessions();
		String uniqueID =  UUID.randomUUID().toString();
		Session new_session = new Session(uniqueID);
		sessions.put(uniqueID, new_session);
		return Response.status(Status.OK).entity(uniqueID).build();
	}
	
	@GET
	@Path("/info/{info_type}")
	@Produces(MediaType.TEXT_PLAIN)
	public Response getInfo(@PathParam("info_type") String info_type) {		
		if (info_type.compareToIgnoreCase("numberofsessions") == 0) {
			return Response.ok().status(Status.OK).entity(String.valueOf(sessions.size())).build();
		}
		return Response.ok().status(Status.OK).entity("Error.No information to display").build();
	}
	
	@POST
	@Path("/setcalls/")
	@Produces(MediaType.TEXT_PLAIN)
	public Response setCalls(
			@DefaultValue("none") @QueryParam("SID") String sessionToken,
			@DefaultValue("-1") @QueryParam("ncalls") int numberOfCalls,
			@DefaultValue("-1") @QueryParam("ncores") int numberOfCores) {
		Session session = sessions.get(sessionToken);
		if (session == null) {
			return Response.status(Status.UNAUTHORIZED).entity("Error. Token not identified").build();
		}
		if (numberOfCalls == -1 || numberOfCores == -1) {
			return Response.status(Status.BAD_REQUEST).entity("Error. Parameters not properly configured").build();
		}
		session.setNumberOfCalls(numberOfCalls);
		session.setNumberOfCoresAvail(numberOfCores);
		return Response.status(Status.OK).entity("OK. Numbers have been set").build();
	}
	
	@POST
	@Path("/setparams/")
	@Produces(MediaType.TEXT_PLAIN)
	@Consumes(MediaType.TEXT_PLAIN)
	public Response setAppParam(
			@DefaultValue("none") @QueryParam("SID") String sessionToken,
			String appParam) {
		Session session = sessions.get(sessionToken);
		if (session == null) {
			return Response.status(Status.UNAUTHORIZED).entity("Error. Token not identified").build();
		}
		try {
			AppParams newparams = new AppParams(appParam);
			int remain_calls = session.setNewAppParams(newparams);
			if (remain_calls > 0) {
				return Response.status(Status.OK).entity("OK. AppParams have been set. " + 
						String.valueOf(remain_calls) + " remain to set").build();
			} else {
				String opt_results = session.getOptResults();
				sessions.remove(session);
				return Response.status(Status.OK).entity(opt_results).build();
			}
		} catch (Exception e) {
			e.printStackTrace();
			return Response.status(Status.BAD_REQUEST).entity("Error. " + e.getMessage()).build();
		}
	}
	
	private final static long max_ms_keep_alive = max_seconds_keep_alive_session * 1000;
	private void clean_old_sessions() {
		List<String> key_session_to_erase = new ArrayList<String>();
		
		for (Map.Entry<String, Session> session : sessions.entrySet()) {
			Timestamp time_creation = session.getValue().getTimeCreation();
			Timestamp current_time = new Timestamp(System.currentTimeMillis());
			long ms_elapsed = current_time.getTime() - time_creation.getTime();
			if (ms_elapsed > max_ms_keep_alive) {
				key_session_to_erase.add(session.getKey());
			}
		}
		
		for (String key_to_erase : key_session_to_erase) {
			sessions.remove(key_to_erase);
		}
	}
}
