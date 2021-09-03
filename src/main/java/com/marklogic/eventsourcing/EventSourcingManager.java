package com.marklogic.eventsourcing;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.marklogic.client.DatabaseClient;
import com.marklogic.client.extensions.ResourceManager;
import com.marklogic.client.io.Format;
import com.marklogic.client.io.StringHandle;
import com.marklogic.client.util.RequestParameters;

/**
 * TODO Move to client subproject
 */
public class EventSourcingManager extends ResourceManager {

	public EventSourcingManager(DatabaseClient client) {
		client.init("event-sourcing", this);
	}

	/**
	 * @param uri
	 * @param dateTime TODO Using a String here since SimpleDateFormat can't handle microseconds, need to find a
	 *                 replacement
	 * @return
	 */
	public String replayEvents(String uri, String dateTime) {
		RequestParameters params = new RequestParameters();
		params.add("uri", uri);
		params.add("dateTime", dateTime);
		return getServices().get(params, new StringHandle()).get();
	}

	public String update(String uri, Action... actions) {
		return update(uri, new EventBuilder(actions).toXml());
	}

	public String update(String uri, String actionsXml) {
		RequestParameters params = new RequestParameters();
		params.add("uri", uri);
		String json = getServices().post(params, new StringHandle(actionsXml).withFormat(Format.XML), new StringHandle()).get();
		try {
			return new ObjectMapper().readTree(json).get("event-doc-uri").asText();
		} catch (Exception ex) {
			throw new RuntimeException("Unable to retrieve field event-doc-uri from JSON: " + json, ex);
		}
	}
}
