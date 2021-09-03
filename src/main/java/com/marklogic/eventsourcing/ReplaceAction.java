package com.marklogic.eventsourcing;

public class ReplaceAction implements Action {

	private String path;
	private String node;

	public ReplaceAction(String path, String node) {
		this.path = path;
		this.node = node;
	}

	@Override
	public String toXml() {
		StringBuilder sb = new StringBuilder("<replace xmlns='http://marklogic.com/event-sourcing'>");
		sb.append("<path>").append(path).append("</path>");
		sb.append("<node>").append(node).append("</node></replace>");
		return sb.toString();
	}

	public String getPath() {
		return path;
	}

	public String getNode() {
		return node;
	}
}
