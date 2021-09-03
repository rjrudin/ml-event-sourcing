package com.marklogic.eventsourcing;

public class RemoveAction implements Action {

	private String path;

	public RemoveAction(String path) {
		this.path = path;
	}

	@Override
	public String toXml() {
		StringBuilder sb = new StringBuilder("<remove xmlns='http://marklogic.com/event-sourcing'>");
		sb.append("<path>").append(path).append("</path></remove>");
		return sb.toString();
	}

	public String getPath() {
		return path;
	}
}
