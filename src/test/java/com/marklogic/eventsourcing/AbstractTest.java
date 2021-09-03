package com.marklogic.eventsourcing;

import com.marklogic.client.io.BytesHandle;
import com.marklogic.client.io.Format;
import com.marklogic.junit.ClientTestHelper;
import com.marklogic.junit.Fragment;
import com.marklogic.junit.NamespaceProvider;
import com.marklogic.junit.spring.AbstractSpringTest;
import org.springframework.test.context.ContextConfiguration;

@ContextConfiguration(classes = {TestConfig.class})
public abstract class AbstractTest extends AbstractSpringTest {

	protected final static String TEST_URI = "/test.xml";

	@Override
	protected NamespaceProvider getNamespaceProvider() {
		return new EventSourcingNamespaceProvider();
	}

	protected void writeXml(String uri, String xml) {
		getClient().newDocumentManager().write(
			uri,
			new BytesHandle(xml.getBytes()).withFormat(Format.XML)
		);
	}

	protected String update(String uri, Action... actions) {
		return update(uri, 0, actions);
	}

	protected String update(String uri, long sleepTime, Action... actions) {
		if (sleepTime > 0) {
			try {
				Thread.sleep(sleepTime);
			} catch (InterruptedException e) {
				// ignore
			}
		}
		return new EventSourcingManager(getClient()).update(uri, actions);
	}

	protected Fragment getXmlDocument(String uri) {
		return newHelper(ClientTestHelper.class).parseUri(uri);
	}

	protected TestDoc getTestDocument(String uri) {
		return new TestDoc(getXmlDocument(uri));
	}

	protected EventDoc getEventDocument(String uri) {
		return new EventDoc(getXmlDocument(uri));
	}

	protected TestDoc replayTestDocEvents(String uri, String eventDocumentUri) {
		String dateTime = getEventDocument(eventDocumentUri).getEventDateTime();
		String xml = new EventSourcingManager(getClient()).replayEvents(uri, dateTime);
		return new TestDoc(parse(xml));
	}
}
