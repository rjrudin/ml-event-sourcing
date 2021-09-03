package com.marklogic.eventsourcing;

import com.marklogic.junit.Fragment;

public class EventDoc extends Fragment {

	public EventDoc(Fragment other) {
		super(other);
	}

	public String getEventDateTime() {
		return getElementValue("/events:envelope/events:headers/events:event-dateTime");
	}
}
