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

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class DBQuery {
	private final static String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";
	
	private final static String DB_URL = "jdbc:mysql://" + SessionManager.global_properties.AppsPropDB_IP + ":" 
					+ SessionManager.global_properties.AppsPropDB_port  + "/" + SessionManager.global_properties.AppsPropDB_dbName
					+ "?useSSL=false";
	
	private final static String USER_DB = SessionManager.global_properties.AppsPropDB_user;
	private final static String PASS_DB = SessionManager.global_properties.AppsPropDB_pass;
	private final static String APPLICATIONS_TABLE = "APPLICATION_PROFILE_TABLE";
	private final static String RUNNINGS_TABLE = "RUNNING_APPLICATION_TABLE";
	
	public queryApp get_information_from_session_id(String application_session_id) 
			throws ClassNotFoundException, RuntimeException, SQLException {
		Class.forName(JDBC_DRIVER);
		
		Connection conn;
		try {
			conn = DriverManager.getConnection(DB_URL, USER_DB, PASS_DB);
		} catch (SQLException e) {
			throw new SQLException(e.getMessage() + " Cannot link to URL: " + DB_URL);
		}
		Statement stmt = conn.createStatement();
		String query_str = build_select_section();
		query_str += " FROM `" + RUNNINGS_TABLE + "` JOIN `" + APPLICATIONS_TABLE + "` ON `" + RUNNINGS_TABLE + "`.`application_id` = `" 
				+ APPLICATIONS_TABLE + "`.`application_id`";
		query_str += " WHERE `application_session_id` = \"" + application_session_id + "\"";
		query_str += ";";
		System.out.println(query_str);
		ResultSet result = stmt.executeQuery(query_str);
		
		if (result.next()) {
			queryApp rtn = new queryApp();
			rtn.application_id = result.getString("application_id");
			rtn.chi_0 = result.getDouble("chi_0");
			rtn.chi_c = result.getDouble("chi_c");
			rtn.phi_memory = result.getDouble("phi_mem");
			rtn.vir_memory = result.getDouble("vir_mem");
			rtn.phi_core = result.getInt("phi_core");
			rtn.vir_core = result.getInt("vir_core");
			rtn.dataset_size = result.getDouble("dataset_size");
			return rtn;
		}
		
		throw new RuntimeException("No application session id '" + application_session_id + "' in the database");
	}
	
	private String build_select_section() {
		List<String> cols_sel = new ArrayList<String>();
		cols_sel.add("application_id");
		cols_sel.add("chi_0");
		cols_sel.add("chi_c");
		cols_sel.add("phi_mem");
		cols_sel.add("vir_mem");
		cols_sel.add("phi_core");
		cols_sel.add("vir_core");
		cols_sel.add("dataset_size");
		
		String rtn = "SELECT ";
		for (int i = 0; i < cols_sel.size(); ++i) {
			String col = cols_sel.get(i);
			rtn += (i == 0 ? "" : ", ") + "`" + APPLICATIONS_TABLE + "`.`" + col + "`";
		}
		return rtn;
	}
}
