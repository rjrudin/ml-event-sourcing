package com.marklogic.eventsourcing;

import com.marklogic.junit.Fragment;
import org.junit.Test;

public class SearchEventsTest extends AbstractTest {

	@Test
	public void test() {
		writeXml(TEST_URI, "<root><first/><second/></root>");
		update(TEST_URI, new AddAction("/root/first", "<color xmlns=''>red</color>"));
		update(TEST_URI, new AddAction("/root/second", "<color xmlns=''>green</color>"));
		update(TEST_URI, new ReplaceAction("/root/second/color", "<color xmlns=''>yellow</color>"));
		update(TEST_URI, new RemoveAction("/root/first/color[. = 'red']"));

		Fragment frag = super.getXmlDocument(TEST_URI);
		frag.assertElementExists("/root/first[not(node())]");
		frag.assertElementExists("/root/second/color[. = 'yellow']");
		frag.assertElementCount("Should just have one color", "/root/second/color", 1);
	}
}
