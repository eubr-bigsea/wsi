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
