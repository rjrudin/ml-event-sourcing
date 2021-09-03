package com.marklogic.eventsourcing;

import com.marklogic.junit.MarkLogicNamespaceProvider;
import org.jdom2.Namespace;

import java.util.List;

public class EventSourcingNamespaceProvider extends MarkLogicNamespaceProvider {

	@Override
	protected List<Namespace> buildListOfNamespaces() {
		List<Namespace> list = super.buildListOfNamespaces();
		list.add(Namespace.getNamespace("events", "http://marklogic.com/event-sourcing"));
		return list;
	}
}
