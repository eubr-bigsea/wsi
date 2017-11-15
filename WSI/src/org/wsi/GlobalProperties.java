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

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.InvalidPropertiesFormatException;
import java.util.Properties;

public class GlobalProperties {
	public String DB_IP = "localhost";
	public String DB_port = "3306";
	public String DB_dbName = "150test";
	public String DB_user = "root";
	public String DB_pass = "biagio";
	
	public String OptDB_tablename = "OPT_SESSIONS_RESULTS_TABLE";
	
	public String DAGSIM_HOME = "/home/work/Dagsim";
	public String RESULTS_HOME = "/home/work/TPCDS500-D_processed_logs";
	public String OPTIMIZE_HOME = "/home/work/Optimize/optimize";
	public String OPTIMIZE_NUM_PROCESSES = "1";
	public String RESOPT_HOME = "/home/work/ResOpt";
	public String LUNDSTROM_HOME = "/home/work/spark-lundstrom-master";
	public String UPLOAD_HOME = "/home/work/Uploaded";
	
	public void storeProperties(String filepath) throws FileNotFoundException, IOException {
		Properties global_properties = new Properties();
		
		global_properties.setProperty("DB_IP", DB_IP);
		global_properties.setProperty("DB_port", DB_port);
		global_properties.setProperty("DB_dbName", DB_dbName);
		global_properties.setProperty("DB_user", AppsPropDB_user);
		global_properties.setProperty("DB_pass", DB_pass);
		
		global_properties.setProperty("OptDB_tablename", OptDB_tablename);
		
		global_properties.setProperty("DAGSIM_HOME", DAGSIM_HOME);
		global_properties.setProperty("RESULTS_HOME", RESULTS_HOME);
		global_properties.setProperty("OPTIMIZE_HOME", OPTIMIZE_HOME);
		global_properties.setProperty("RESOPT_HOME", RESOPT_HOME);
		global_properties.setProperty("LUNDSTROM_HOME", LUNDSTROM_HOME);
		global_properties.setProperty("UPLOAD_HOME", UPLOAD_HOME);
		
		global_properties.storeToXML(new FileOutputStream(filepath), "");
	}
	
	public void loadProperties(String filepath) 
			throws InvalidPropertiesFormatException, FileNotFoundException, IOException {
		Properties global_properties = new Properties();
		global_properties.loadFromXML(new FileInputStream(filepath));
		
		DB_IP = global_properties.getProperty("DB_IP");
		DB_port = global_properties.getProperty("DB_port");
		DB_dbName = global_properties.getProperty("DB_dbName");	
		DB_user = global_properties.getProperty("DB_user");
		DB_pass = global_properties.getProperty("DB_pass");
		
		OptDB_tablename = global_properties.getProperty("OptDB_tablename");
		
		DAGSIM_HOME = global_properties.getProperty("DAGSIM_HOME");
		RESULTS_HOME = global_properties.getProperty("RESULTS_HOME");
		OPTIMIZE_HOME = global_properties.getProperty("OPTIMIZE_HOME");
		OPTIMIZE_NUM_PROCESSES = global_properties.getProperty("OPTIMIZE_NUM_PROCESSES");
		RESOPT_HOME = global_properties.getProperty("RESOPT_HOME");
		LUNDSTROM_HOME = global_properties.getProperty("LUNDSTROM_HOME");
		UPLOAD_HOME = global_properties.getProperty("UPLOAD_HOME");
	}
}
