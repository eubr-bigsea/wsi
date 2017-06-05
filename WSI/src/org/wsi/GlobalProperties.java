package org.wsi;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.util.InvalidPropertiesFormatException;
import java.util.Properties;

public class GlobalProperties {
	public String AppsPropDB_IP = "localhost";
	public String AppsPropDB_port = "3306";
	public String AppsPropDB_dbName = "150test";
	public String AppsPropDB_user = "root";
	public String AppsPropDB_pass = "biagio";
	
	public String OtherConfigFile = "~/.ws_properties";
	public String OptDB_IP = "localhost";
	public String OptDB_port = "3306";
	public String OptDB_dbName = "150test";
	public String OptDB_user = "root";
	public String OptDB_pass = "biagio";
	
	public void storeProperties(String filepath) throws FileNotFoundException, IOException {
		Properties global_properties = new Properties();
		
		global_properties.setProperty("AppsPropDB_IP", AppsPropDB_IP);
		global_properties.setProperty("AppsPropDB_port", AppsPropDB_port);
		global_properties.setProperty("AppsPropDB_dbName", AppsPropDB_dbName);
		global_properties.setProperty("AppsPropDB_user", AppsPropDB_user);
		global_properties.setProperty("AppsPropDB_pass", AppsPropDB_pass);
		
		global_properties.setProperty("OtherConfigFile", OtherConfigFile);
		global_properties.setProperty("OptDB_IP", OptDB_IP);
		global_properties.setProperty("OptDB_port", OptDB_port);
		global_properties.setProperty("OptDB_dbName", OptDB_dbName);
		global_properties.setProperty("OptDB_user", OptDB_user);
		global_properties.setProperty("OptDB_pass", OptDB_pass);
		
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

		OtherConfigFile = global_properties.getProperty("OtherConfigFile");
		
		OptDB_IP = global_properties.getProperty("OptDB_IP");	
		OptDB_port = global_properties.getProperty("OptDB_port");	
		OptDB_dbName = global_properties.getProperty("OptDB_dbName");
		OptDB_user = global_properties.getProperty("OptDB_user");
		OptDB_pass = global_properties.getProperty("OptDB_pass");
	}

	public String getOptCmd() throws IOException, RuntimeException {
		return getPropertyInOtherConfigFile("OPTIMIZE_HOME");
	}
	
	public String getCSVPath() throws IOException, RuntimeException {
		return getPropertyInOtherConfigFile("UPLOAD_HOME");
	}
	
	private String getPropertyInOtherConfigFile(String key_property) throws IOException, RuntimeException {
		if (OtherConfigFile == null) {
			throw new RuntimeException("The other configuration file has not been set");
		}
		File otherconfigfile = new File(OtherConfigFile);
		BufferedReader file_reader = new BufferedReader(new FileReader(otherconfigfile));
		boolean row_found = false;
		
		String current_line;
		String property_value = "";
		while ((current_line = file_reader.readLine()) != null && row_found == false) {
			int finder = current_line.indexOf(key_property);
			if (finder != -1) {
				property_value = key_property.substring(finder + key_property.length() + 1);
				row_found = true;
			}
		}
		file_reader.close();
		
		if (row_found == false) {
			throw new RuntimeException("The property '" + key_property + "' "
					+ "cannot be found in the configuration file '" + OtherConfigFile + "'");
		}
		
		return property_value;
	}
}
