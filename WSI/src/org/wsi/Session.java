package org.wsi;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Session {
	private String sessionToken;
	private Timestamp timeCreation;
	private int numberOfCalls;
	private List<AppParams> appsParams = new ArrayList<>();
	
	Session(String sessionToken) {
		this.sessionToken = sessionToken;
		this.timeCreation = new Timestamp(System.currentTimeMillis());
		this.numberOfCalls = -1;
	}
	
	public void setNumberOfCalls(int numberOfCalls) {
		this.numberOfCalls = numberOfCalls;
	}
	
	public int setNewAppParams(AppParams appParams) throws Exception {
		if (numberOfCalls < 0) {
			throw new Exception("The number of calls must to be set before");
		}
		if (appsParams.size() >= numberOfCalls) {
			throw new Exception("The number of calls has been set with " + 
					String.valueOf(numberOfCalls) + " but there is an overflow of calls");
		}
		appsParams.add(appParams);
		int number_params_still_to_set = numberOfCalls - appsParams.size();
		return number_params_still_to_set;
	}
	
	public Timestamp getTimeCreation() {
		return timeCreation;
	}

	public String getSessionToken() {
		return sessionToken;
	}
	
	public String generateCSV() throws Exception {
		ArrayList<String> rows_csv = new ArrayList<String>();
		for (int i = 0; i < numberOfCalls; ++i) {
			AppParams params = appsParams.get(i);
			queryApp queryResult = new DBQuery().get_information_from_session_id(params.getApp_session_id());
			String csv_row = queryResult.application_id + ","
					+ params.getWeight() + ","
					+ queryResult.chi_0 + ","
					+ queryResult.chi_c + ","
					+ queryResult.vir_memory + ","
					+ queryResult.phi_memory + ","
					+ queryResult.vir_core + ","
					+ queryResult.phi_core + ","
					+ params.getDeadline();
			rows_csv.add(csv_row);
		}
		String csv_final = "";
		for (String row : rows_csv) {
			csv_final += row + "\n";
		}
		return csv_final;
	}
	
}
