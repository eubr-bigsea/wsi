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

public class AppSession {
	public String application_session_id;
	public String application_id;
	public double dataset_size;
	public long submission_time;
	public long ending_time;
	
	public void print_info_on_log() {
		String dump = "-----APP SESSION INSTANCE------\n" +
					  "Application Session ID: " + application_session_id + "\n" +
					  "Application ID: " + application_id + "\n" +
					  "Dataset Size: " + dataset_size + "\n" +
					  "Submission Time: " + submission_time + "\n" +
					  "Ending Time: " + ending_time + "\n";
		System.out.println(dump);
	}
}
