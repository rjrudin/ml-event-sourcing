package com.marklogic.eventsourcing;

import java.util.ArrayList;
import java.util.List;

public class EventBuilder {

	private List<Action> actions = new ArrayList<>();

	public EventBuilder() {

	}

	public EventBuilder(Action... actionsArray) {
		with(actionsArray);
	}

	public EventBuilder add(String path, String node) {
		return with(new AddAction(path, node));
	}

	public EventBuilder with(Action... actionsArray) {
		for (Action a : actionsArray) {
			actions.add(a);
		}
		return this;
	}

	public String toXml() {
		StringBuilder sb = new StringBuilder("<event xmlns='http://marklogic.com/event-sourcing'>");
		for (Action a : actions) {
			sb.append(a.toXml());
		}
		sb.append("</event>");
		return sb.toString();
	}
}
