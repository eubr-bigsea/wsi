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
import java.net.URI;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.Response.Status;

import org.glassfish.jersey.client.ClientConfig;

public class WSI_Driver {
	final static private String server_domain = "localhost";
	final static private String server_protocol = "http";
	final static private String server_port = "8080";
	final static private String server_uri = server_protocol + "://" + server_domain + ":" + server_port +"/WSI/session";
	final static private int number_of_calls = 3;
	final static private String fake_application_session = "application_1483347394756_";
	
	public static void main(String[] args) throws Exception {
		System.out.println("connecting to " + server_uri);
		
		ClientConfig config = new ClientConfig();
		Client client = ClientBuilder.newClient(config);
		
		WebTarget target = client.target(getBaseURI());
		
		// Create new session
		String token_id = target.path("/new/").request().accept(MediaType.TEXT_PLAIN).get(String.class).toString();
		System.out.println("The session token is: " + token_id);
		
		// Set the number of async calls
		Response response_set = target.path("/setcalls/").queryParam("SID", token_id)
				.queryParam("ncalls", String.valueOf(number_of_calls))
				.queryParam("ncores", "2")
				.request().accept(MediaType.TEXT_PLAIN).post(null);
		
		if (response_set.getStatus() == Status.OK.getStatusCode()) {
			System.out.println(response_set.readEntity(String.class));
			
			// Set application parameters
			for (int i = 0; i < number_of_calls; ++i) {
				String application_session_id = fake_application_session + String.valueOf(i);
				double weight = 0.33;
				double deadline = 3.14;
				String body_post = application_session_id + " " + String.valueOf(weight) + " " + String.valueOf(deadline);
				Response response_setparam = target.path("/setparams/").queryParam("SID", token_id)
						.request().accept(MediaType.TEXT_PLAIN).post(Entity.entity(body_post, MediaType.TEXT_PLAIN));
				if (response_setparam.getStatus() == Status.OK.getStatusCode()) {
					System.out.println(response_setparam.readEntity(String.class));
				} else {
					throw new Exception(response_setparam.readEntity(String.class));
				}
			}
		} else {
			System.out.println(response_set.getStatusInfo());
		}
	}
	
	private static URI getBaseURI() {
        return UriBuilder.fromUri(server_uri).build();
    }

}
