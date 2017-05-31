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
	
	public String OptCmd = "/opt/optimizer";
	public String OptDB_IP = "localhost";
	public String OptDB_port = "3306";
	public String OptDB_dbName = "150test";
	public String OptDB_user = "root";
	public String OptDB_pass = "biagio";
	public String OptPathCSV = "/tmp";
	
	public void storeProperties(String filepath) throws FileNotFoundException, IOException {
		Properties global_properties = new Properties();
		
		global_properties.setProperty("AppsPropDB_IP", AppsPropDB_IP);
		global_properties.setProperty("AppsPropDB_port", AppsPropDB_port);
		global_properties.setProperty("AppsPropDB_dbName", AppsPropDB_dbName);
		global_properties.setProperty("AppsPropDB_user", AppsPropDB_user);
		global_properties.setProperty("AppsPropDB_pass", AppsPropDB_pass);
		
		global_properties.setProperty("OptCmd", OptCmd);
		global_properties.setProperty("OptDB_IP", OptDB_IP);
		global_properties.setProperty("OptDB_port", OptDB_port);
		global_properties.setProperty("OptDB_dbName", OptDB_dbName);
		global_properties.setProperty("OptDB_user", OptDB_user);
		global_properties.setProperty("OptDB_pass", OptDB_pass);
		global_properties.setProperty("OptPathCSV", OptPathCSV);
		
		global_properties.storeToXML(new FileOutputStream(filepath), "");
	}
	
	public void loadProperties(String filepath) throws InvalidPropertiesFormatException, FileNotFoundException, IOException {
		Properties global_properties = new Properties();
		global_properties.loadFromXML(new FileInputStream(filepath));
		
		AppsPropDB_IP = global_properties.getProperty("AppsPropDB_IP");
		AppsPropDB_port = global_properties.getProperty("AppsPropDB_port");
		AppsPropDB_dbName = global_properties.getProperty("AppsPropDB_dbName");
		AppsPropDB_user = global_properties.getProperty("AppsPropDB_user");
		AppsPropDB_pass = global_properties.getProperty("AppsPropDB_pass");

		OptDB_IP = global_properties.getProperty("OptCmd");
		OptDB_port = global_properties.getProperty("OptDB_port");
		OptDB_dbName = global_properties.getProperty("OptDB_dbName");
		OptDB_user = global_properties.getProperty("OptDB_user");
		OptDB_pass = global_properties.getProperty("OptDB_pass");
		OptPathCSV = global_properties.getProperty("OptPathCSV");
	}
}
