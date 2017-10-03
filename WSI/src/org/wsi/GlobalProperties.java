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
	public String AppsPropDB_IP = "localhost";
	public String AppsPropDB_port = "3306";
	public String AppsPropDB_dbName = "150test";
	public String AppsPropDB_user = "root";
	public String AppsPropDB_pass = "biagio";
	
	public String OptDB_IP = "localhost";
	public String OptDB_port = "3306";
	public String OptDB_dbName = "150test";
	public String OptDB_tablename = "OPT_SESSIONS_RESULTS_TABLE";
	public String OptDB_user = "root";
	public String OptDB_pass = "biagio";
	
	public String DAGSIM_HOME = "/home/work/Dagsim";
	public String RESULTS_HOME = "/home/work/TPCDS500-D_processed_logs";
	public String OPTIMIZE_HOME = "/home/work/Optimize/optimize";
	public String RESOPT_HOME = "/home/work/ResOpt";
	public String LUNDSTROM_HOME = "/home/work/spark-lundstrom-master";
	public String UPLOAD_HOME = "/home/work/Uploaded";
	
	public void storeProperties(String filepath) throws FileNotFoundException, IOException {
		Properties global_properties = new Properties();
		
		global_properties.setProperty("AppsPropDB_IP", AppsPropDB_IP);
		global_properties.setProperty("AppsPropDB_port", AppsPropDB_port);
		global_properties.setProperty("AppsPropDB_dbName", AppsPropDB_dbName);
		global_properties.setProperty("AppsPropDB_user", AppsPropDB_user);
		global_properties.setProperty("AppsPropDB_pass", AppsPropDB_pass);
		
		global_properties.setProperty("OptDB_IP", OptDB_IP);
		global_properties.setProperty("OptDB_port", OptDB_port);
		global_properties.setProperty("OptDB_dbName", OptDB_dbName);
		global_properties.setProperty("OptDB_tablename", OptDB_tablename);
		global_properties.setProperty("OptDB_user", OptDB_user);
		global_properties.setProperty("OptDB_pass", OptDB_pass);
		
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
		
		AppsPropDB_IP = global_properties.getProperty("AppsPropDB_IP");
		AppsPropDB_port = global_properties.getProperty("AppsPropDB_port");
		AppsPropDB_dbName = global_properties.getProperty("AppsPropDB_dbName");	
		AppsPropDB_user = global_properties.getProperty("AppsPropDB_user");
		AppsPropDB_pass = global_properties.getProperty("AppsPropDB_pass");
		
		OptDB_IP = global_properties.getProperty("OptDB_IP");	
		OptDB_port = global_properties.getProperty("OptDB_port");	
		OptDB_dbName = global_properties.getProperty("OptDB_dbName");
		OptDB_tablename = global_properties.getProperty("OptDB_tablename");
		OptDB_user = global_properties.getProperty("OptDB_user");
		OptDB_pass = global_properties.getProperty("OptDB_pass");
		
		DAGSIM_HOME = global_properties.getProperty("DAGSIM_HOME");
		RESULTS_HOME = global_properties.getProperty("RESULTS_HOME");
		OPTIMIZE_HOME = global_properties.getProperty("OPTIMIZE_HOME");
		RESOPT_HOME = global_properties.getProperty("RESOPT_HOME");
		LUNDSTROM_HOME = global_properties.getProperty("LUNDSTROM_HOME");
		UPLOAD_HOME = global_properties.getProperty("UPLOAD_HOME");
	}
}
