package org.wsi;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class OptProxy {
	// DB configuration
	private final static String DB_IP = SessionManager.global_properties.OptDB_IP;
	private final static String DB_NAME_DB = SessionManager.global_properties.OptDB_dbName;
	private final static String DB_URL = "jdbc:mysql://" + DB_IP + ":" 
							+ SessionManager.global_properties.OptDB_port + "/" + DB_NAME_DB + "?useSSL=false";
	private final static String USER_DB = SessionManager.global_properties.OptDB_user;
	private final static String PASS_DB = SessionManager.global_properties.OptDB_pass;
	private final static String OPT_TABLENAME = SessionManager.global_properties.OptDB_tablename;
	private final static String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";
	
	public String invoke_opt(String csv_input, String num_avil_cores) 
			throws IOException, InterruptedException, ClassNotFoundException, SQLException, RuntimeException {
		final String OPT_CMD = SessionManager.global_properties.OPTIMIZE_HOME;
		final String PathFileCSV = SessionManager.global_properties.UPLOAD_HOME;
			
		String filename = UUID.randomUUID().toString() + ".csv";
		String filepath =  PathFileCSV + "/" + filename;
		
		// Open file
		File csv_file = new File(filepath);
		boolean not_exists = csv_file.createNewFile();
		if (not_exists == false) {
			throw new IOException("The csv file cannot be create because '" + filepath + "' already exists");
		}
		System.out.println("File '" + filepath + "' has been created");
		
		// Write CSV string into file
		BufferedWriter file_buffer = new BufferedWriter(new FileWriter(csv_file));
		file_buffer.write(csv_input);
		file_buffer.close();
		
		// Execute opt
		String cmd_to_exec = OPT_CMD + " " + filename + " " + num_avil_cores;
		Runtime rt = Runtime.getRuntime();
		Process opt_process = rt.exec(cmd_to_exec);
		System.out.println("Executing: '" + cmd_to_exec + "'");
		
		// Now get the application IDs involved (first field of CSV row)
		List<String> appIDs_invoved = new ArrayList<String>();
		String[] rows_csv = csv_input.split("\\r?\\n");
		for (String row : rows_csv) {
			String[] fields = row.split(",");
			appIDs_invoved.add(fields[0]);
		}
		
		// Wait for termination of opt
		int return_status = opt_process.waitFor();
		System.out.println("Return status of process: '" + return_status + "'");
		if (return_status != 0) {
			throw new RuntimeException("The optimizer '" + cmd_to_exec + "' has been terminated with error. "
					+ "Status: " + String.valueOf(return_status));
		}
		
		// Now read opt results from table in database
		String opt_results = query_resuls_opt(filename, appIDs_invoved);
		return opt_results;
	}
	
	private String query_resuls_opt(String filename, List<String> appIDs) 
			throws SQLException, ClassNotFoundException, RuntimeException {
		// Load driver
		Class.forName(JDBC_DRIVER);

		// Open DB connection
		Connection conn = DriverManager.getConnection(DB_URL, USER_DB, PASS_DB);
		
		
		String return_values = "";
		
		for (String appID : appIDs) {
			// Prepare query
			Statement stmt = conn.createStatement();
			String query = "SELECT nu"
					+ " FROM `" + OPT_TABLENAME + "`"
					+ " WHERE opt_id = \"" + filename + "\" AND app_id = \"" + appID + "\";";
			System.out.println(query);

			// Execute query
			ResultSet result = stmt.executeQuery(query);
			
			// Retrieve number of results
			boolean no_rows = result.last();
			int number_of_rows = result.getRow();
			result.beforeFirst();
						
			// Fetch result
			if (no_rows == true || number_of_rows != 1) {
				throw new RuntimeException("The number of results is '" + number_of_rows + "' and should be 1.\n"
						+ "No rows: " + String.valueOf(no_rows) + "\n"
						+ "The query were '" + query + "'");
			} else {
				result.next();
			}
			String nu_string = result.getString(0);
			
			// Append the 'nu' value to the returned string
			return_values += nu_string + "\n";
		}
		
		return return_values;
	}
}
