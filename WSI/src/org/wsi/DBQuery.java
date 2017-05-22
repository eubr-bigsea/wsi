package org.wsi;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class DBQuery {
	private final static String JDBC_DRIVER = "com.mysql.jdbc.Driver";  
	private final static String DB_URL = "jdbc:mysql://myserver.biagiofesta.it/150test";
	private final static String USER_DB = "root";
	private final static String PASS_DB = "biagio";
	private final static String APPLICATIONS_TABLE = "APPLICATION_PROFILE_TABLE";
	private final static String RUNNINGS_TABLE = "RUNNING_APPLICATION_TABLE";
	
	public queryApp get_information_from_session_id(String application_session_id) throws Exception {
		Class.forName(JDBC_DRIVER);
		
		Connection conn = DriverManager.getConnection(DB_URL, USER_DB, PASS_DB);
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
			return rtn;
		}
		
		throw new Exception("No application session id in the database");
	}
	
	public String build_select_section() {
		List<String> cols_sel = new ArrayList<String>();
		cols_sel.add("application_id");
		cols_sel.add("chi_0");
		cols_sel.add("chi_c");
		cols_sel.add("phi_mem");
		cols_sel.add("vir_mem");
		cols_sel.add("phi_core");
		cols_sel.add("vir_core");
		
		String rtn = "SELECT ";
		for (int i = 0; i < cols_sel.size(); ++i) {
			String col = cols_sel.get(i);
			rtn += (i == 0 ? "" : ", ") + "`" + APPLICATIONS_TABLE + "`.`" + col + "`";
		}
		return rtn;
	}
}
