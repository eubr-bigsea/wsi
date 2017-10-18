/*
 * Copyright 2017 Biagio Festa

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	    http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
 * */
package org.wsi;

import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Enumeration;
import java.util.NoSuchElementException;
import java.util.Properties;
import java.util.StringTokenizer;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

@Path("/WSDB/")
public class WebServiceDB {
	private static final String delimiter_token = " ";
	private final static String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";
	private final static String RUNNINGS_TABLE = "RUNNING_APPLICATION_TABLE";
	private String db_url;
	private String db_user;
	private String db_password;

	@POST
	@Path("/register/newapp/")
	@Produces(MediaType.TEXT_PLAIN)
	@Consumes(MediaType.TEXT_PLAIN)
	public Response registerNewApplication(String body_post) {
		AppSession new_app_session = null;
			
		try {
			new_app_session = parseNewAppInfo(body_post);
			new_app_session.print_info_on_log();
		} catch (NoSuchElementException e) {
			return Response.status(Status.BAD_REQUEST).entity("Error. The given application is not valid.").build();
		}

		readConfiguration();
		
		try {
			insertNewAppSessionIntoDB(new_app_session);
		} catch (ClassNotFoundException | SQLException | IOException e) {
			return Response.status(Status.BAD_REQUEST).entity("Error. " + e.getMessage() + ".").build();
		}
		return Response.status(Status.OK).entity("OK. The application has been registered.").build();
	}
	
	@POST
	@Path("/register/endapp/")
	@Produces(MediaType.TEXT_PLAIN)
	@Consumes(MediaType.TEXT_PLAIN)
	public Response registerEndApplication(String body_post) {
		AppSession ended_app_session = null;
		
		try {
			ended_app_session = parseEndAppInfo(body_post);
			ended_app_session.print_info_on_log();
		} catch (NoSuchElementException e) {
			return Response.status(Status.BAD_REQUEST).entity("Error. The given application is not valid.").build();
		}
		
		readConfiguration();
		
		try {
			updateEndingAppSessionIntoDB(ended_app_session);
		} catch (ClassNotFoundException | SQLException | IOException e) {
			return Response.status(Status.BAD_REQUEST).entity("Error. " + e.getMessage() + ".").build();
		}
		return Response.status(Status.OK).entity("OK. The application has been registered as ended.").build();
	}
	
	
	private static AppSession parseNewAppInfo(String body_post) throws NoSuchElementException {
		// The body is a string in the form
		// APP_SESSION_ID APPLICATION_ID DATASET_SIZE SUBMISSION_TIME
		AppSession app_session = new AppSession();
		StringTokenizer st = new StringTokenizer(body_post);
		app_session.application_session_id = st.nextToken(delimiter_token);
		app_session.application_id = st.nextToken(delimiter_token);
		app_session.dataset_size = Double.valueOf(st.nextToken(delimiter_token));
		app_session.submission_time = Long.valueOf(st.nextToken(delimiter_token));
		app_session.weight= Double.valueOf(st.nextToken(delimiter_token));
		app_session.deadline = Double.valueOf(st.nextToken(delimiter_token));
		app_session.num_cores = Integer.valueOf(st.nextToken(delimiter_token));
		return app_session;
	}
	
	private static AppSession parseEndAppInfo(String body_post) throws NoSuchElementException {
		// The body is a string in the form
		// APP_SESSION_ID ENDING_TIME
		AppSession app_session = new AppSession();
		StringTokenizer st = new StringTokenizer(body_post);
		app_session.application_session_id = st.nextToken(delimiter_token);
		app_session.ending_time = Long.valueOf(st.nextToken(delimiter_token));
		return app_session;
	}
	
	private void insertNewAppSessionIntoDB(AppSession app_session) throws ClassNotFoundException, SQLException, IOException {
		// Load JDBC driver
		Class.forName(JDBC_DRIVER);
		
		Connection conn = DriverManager.getConnection(db_url, db_user, db_password);
		Statement stmt = conn.createStatement();
		String stmt_str = "INSERT INTO `" + RUNNINGS_TABLE + "`"
				+ " (`application_session_id`, `application_id`, `dataset_size`, `submission_time`, `status`, `weight`, `deadline`, `num_cores`)"
				+ " VALUES ("
				+ "'" + app_session.application_session_id + "', "
				+ "'" + app_session.application_id + "', "
				+ app_session.dataset_size + ", "
				+ "FROM_UNIXTIME('" + app_session.submission_time/1000 + "'), "
				+ "'RUNNING',"
                                + app_session.weight + ", "
                                + app_session.deadline + ", "
                                + app_session.num_cores
                                + ");";
		System.out.println(stmt_str);
		
		int result = stmt.executeUpdate(stmt_str);
		if (result <= 0) {
			throw new IOException("The insert had not effect.");
		}
	}
	
	private void updateEndingAppSessionIntoDB(AppSession app_session) throws ClassNotFoundException, SQLException, IOException {
		// Load JDBC driver
		Class.forName(JDBC_DRIVER);
		
		Connection conn = DriverManager.getConnection(db_url, db_user, db_password);
		Statement stmt = conn.createStatement();
		String stmt_str = "UPDATE `" + RUNNINGS_TABLE + "`"
				+ " SET `status` = '" + "END" + "',"
				+ " `ending_time` = FROM_UNIXTIME('" + app_session.ending_time/1000 + "')"
				+ " WHERE `application_session_id` = '" + app_session.application_session_id + "';";
		
		int result = stmt.executeUpdate(stmt_str);
		if (result <= 0) {
			throw new IOException("The insert had not effect.");
		}
	}
	
	private void readConfiguration() {
		String address_db_server = readWsConfig("AppsPropDB_IP");
		String port_db_server = readWsConfig("OptDB_port");
		String database_name = readWsConfig("AppsPropDB_dbName");
		
		db_url = "jdbc:mysql://" + address_db_server + ":" 
				+ port_db_server  + "/" + database_name
				+ "?useSSL=false";
		db_user = readWsConfig("AppsPropDB_user");
		db_password = readWsConfig("AppsPropDB_pass");
	}

	public String readWsConfig(String variable)
	{
		String filename = System.getenv("HOME") + "/" + "wsi_config.xml";

		try {
			File file = new File(filename);
			FileInputStream fileInput = new FileInputStream(file);
			Properties properties = new Properties();
			properties.loadFromXML(fileInput);
			fileInput.close();

			Enumeration enuKeys = properties.keys();
			while (enuKeys.hasMoreElements()) 
			{
				String key = (String) enuKeys.nextElement();
				String value = properties.getProperty(key);
				//System.out.println(key + ": " + value);
				if (key.equals(variable)) return(value);
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		return("Error: variable not found in wsi_cnfig.xml file");
	}
}
