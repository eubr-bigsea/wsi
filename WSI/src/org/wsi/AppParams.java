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

import java.util.NoSuchElementException;
import java.util.StringTokenizer;

public class AppParams {
	private static final String delimiter_token = " ";
	private String app_session_id;
	private double weight;
	private double deadline;
	private String stage_id;
	private double N;
	
	public AppParams(String parsable_string) throws Exception {
		try {
			StringTokenizer st = new StringTokenizer(parsable_string);
			String app_session_id = st.nextToken(delimiter_token);
			String weight_str = st.nextToken(delimiter_token);
			String deadline_str = st.nextToken(delimiter_token);
			String stage_id = st.nextToken(delimiter_token);
			String N = st.nextToken(delimiter_token);
			
			this.app_session_id = app_session_id;
			this.weight = Double.parseDouble(weight_str);
			this.deadline = Double.parseDouble(deadline_str);
			this.stage_id = stage_id;
			this.N = Double.parseDouble(N);
		} catch (NoSuchElementException err) {
			throw new Exception("Impossible to parse the app parameters");
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
	
	public double getN() {
		return N;
	}

	public String getStageID() {
		return stage_id;
	}
}
