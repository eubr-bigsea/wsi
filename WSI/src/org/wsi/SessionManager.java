package org.wsi;

import java.io.IOException;
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

import org.apache.commons.lang.exception.ExceptionUtils;


@Path("/session/")
@Singleton
public class SessionManager {
	private final static String filepath_properties_default = getHomeDirectory() + "/wsi_config.xml";
	private final static String filepath_properties =  getConfigurationFileName();
	private Map<String, Session> sessions = new HashMap<String, Session>();
	private static final long max_seconds_keep_alive_session = 3600;
	public static GlobalProperties global_properties = null; 
	
	@GET
	@Path("/new/")
	@Produces(MediaType.TEXT_PLAIN)
	public Response startNewSession() {
		clean_old_sessions();
		load_properties();
		
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
		return Response.ok().status(Status.OK).entity("Error. No information to display").build();
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
				sessions.remove(sessionToken);
				return Response.status(Status.OK).entity(opt_results).build();
			}
		} catch (Exception e) {
			e.printStackTrace();
			sessions.remove(sessionToken);
			String stack_trace = ExceptionUtils.getStackTrace(e);
			String error_message = "Error. " + e.getMessage() + "\n"
					+ "The session will be destroyed\n\n"
					+ stack_trace;
			return Response.status(Status.BAD_REQUEST).entity(error_message).build();
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
	
	private void load_properties() {
		if (global_properties == null) {
			global_properties = new GlobalProperties();
			try {
				global_properties.loadProperties(filepath_properties);
			} catch (IOException e) {
				try {
					System.out.println("Saved default configuration file in '" + filepath_properties + "'");
					global_properties.storeProperties(filepath_properties);
				} catch (IOException e1) {
					e1.printStackTrace();
				}
			}
		}
	}
	
	private static String getConfigurationFileName() {
		String conf_from_env = System.getenv("WSI_CONFIG_FILE");
		if (conf_from_env != null) {
			return conf_from_env;
		}
		return filepath_properties_default;
	}
	
	private static String getHomeDirectory() {
		String home_wsi = System.getenv("WSI_HOME");
		if (home_wsi != null) {
			return home_wsi;
		}
		return System.getenv("HOME");
	}
}
