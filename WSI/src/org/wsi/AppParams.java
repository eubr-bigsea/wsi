package org.wsi;

import java.util.NoSuchElementException;
import java.util.StringTokenizer;

import org.apache.el.parser.ParseException;

public class AppParams {
	private static final String delimiter_token = " ";
	private String app_session_id;
	private double weight;
	private double deadline;
	
	public AppParams(String parsable_string) throws ParseException {
		try {
			StringTokenizer st = new StringTokenizer(parsable_string);
			String app_session_id = st.nextToken(delimiter_token);
			String weight_str = st.nextToken(delimiter_token);
			String deadline_str = st.nextToken(delimiter_token);
			
			this.app_session_id = app_session_id;
			this.weight = Double.parseDouble(weight_str);
			this.deadline = Double.parseDouble(deadline_str);
		} catch (NoSuchElementException err) {
			throw new ParseException("Impossible to parse the app parameters");
		}
	}

	public String getApp_session_id() {
		return app_session_id;
	}

	public double getWeight() {
		return weight;
	}

	public double getDeadline() {
		return deadline;
	}
}
