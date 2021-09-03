package com.marklogic.eventsourcing;

import com.marklogic.junit.Fragment;
import org.junit.Test;

public class SingleUpdateTest extends AbstractTest {

	@Test
	public void test() {
		writeXml(TEST_URI, "<test><color>green</color></test>");

		update(TEST_URI, new AddAction("/test", "<color xmlns=''>blue</color>"));

		Fragment xml = getXmlDocument(TEST_URI);
		xml.assertElementExists("/test/color[1][. = 'green']");
		xml.assertElementExists("/test/color[2][. = 'blue']");
		xml.assertElementCount("Should have two colors", "/test/color", 2);

		// TODO Assert on event document
	}
}
