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
			throws InvalidPropertiesFormatException, FileNotFoundException, IOException, RuntimeException {
		Properties global_properties = new Properties();
		global_properties.loadFromXML(new FileInputStream(filepath));
		
		AppsPropDB_IP = global_properties.getProperty("AppsPropDB_IP");
		if (AppsPropDB_IP == null) {
			throw new RuntimeException("The property 'AppsPropDB_IP' cannot be found in the config file");
		}
		
		AppsPropDB_port = global_properties.getProperty("AppsPropDB_port");
		if (AppsPropDB_port == null) {
			throw new RuntimeException("The property 'AppsPropDB_port' cannot be found in the config file");
		}
		
		AppsPropDB_dbName = global_properties.getProperty("AppsPropDB_dbName");
		if (AppsPropDB_dbName == null) {
			throw new RuntimeException("The property 'AppsPropDB_dbName' cannot be found in the config file");
		}
		
		AppsPropDB_user = global_properties.getProperty("AppsPropDB_user");
		if (AppsPropDB_user == null) {
			throw new RuntimeException("The property 'AppsPropDB_user' cannot be found in the config file");
		}
		
		AppsPropDB_pass = global_properties.getProperty("AppsPropDB_pass");
		if (AppsPropDB_pass == null) {
			throw new RuntimeException("The property 'AppsPropDB_pass' cannot be found in the config file");
		}

		OtherConfigFile = global_properties.getProperty("OtherConfigFile");
		if (OtherConfigFile == null) {
			throw new RuntimeException("The property 'OtherConfigFile' cannot be found in the config file");
		}
		
		OptDB_IP = global_properties.getProperty("OptDB_IP");
		if (OptDB_IP == null) {
			throw new RuntimeException("The property 'OptDB_IP' cannot be found in the config file");
		}
		
		OptDB_port = global_properties.getProperty("OptDB_port");
		if (OptDB_port == null) {
			throw new RuntimeException("The property 'OptDB_port' cannot be found in the config file");
		}
		
		OptDB_dbName = global_properties.getProperty("OptDB_dbName");
		if (OptDB_dbName == null) {
			throw new RuntimeException("The property 'OptDB_dbName' cannot be found in the config file");
		}
		
		OptDB_user = global_properties.getProperty("OptDB_user");
		if (OptDB_user == null) {
			throw new RuntimeException("The property 'OptDB_user' cannot be found in the config file");
		}
		
		OptDB_pass = global_properties.getProperty("OptDB_pass");
		if (OptDB_pass == null) {
			throw new RuntimeException("The property 'OptDB_pass' cannot be found in the config file");
		}
	}

	public String getOptCmd() throws IOException, RuntimeException {
		return getPropertyInOtherConfigFile("OPTIMIZE_HOME");
	}
	
	public String getCSVPath() throws IOException, RuntimeException {
		return getPropertyInOtherConfigFile("UPLOAD_HOME");
	}
	
	private String getPropertyInOtherConfigFile(String key_property) throws IOException, RuntimeException {
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
