package com.marklogic.eventsourcing;

public class AddAction implements Action {

	private String path;
	private String node;

	public AddAction(String path, String node) {
		this.path = path;
		this.node = node;
	}

	@Override
	public String toXml() {
		StringBuilder sb = new StringBuilder("<add xmlns='http://marklogic.com/event-sourcing'>");
		sb.append("<path>").append(path).append("</path>");
		sb.append("<node>").append(node).append("</node></add>");
		return sb.toString();
	}

	public String getPath() {
		return path;
	}

	public String getNode() {
		return node;
	}
}
