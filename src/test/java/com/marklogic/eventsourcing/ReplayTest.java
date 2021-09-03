package com.marklogic.eventsourcing;

import org.junit.Test;

public class ReplayTest extends AbstractTest {

	@Test
	public void test() {
		writeXml(TEST_URI, "<test><color>green</color></test>");

		String secondEventUri = update(TEST_URI, new AddAction("/test", "<color xmlns=''>blue</color>"));
		String thirdEventUri = update(TEST_URI, new AddAction("/test", "<color xmlns=''>red</color>"));
		String fourthEventUri = update(TEST_URI, new AddAction("/test", "<color xmlns=''>yellow</color>"));

		replayTestDocEvents(TEST_URI, secondEventUri).assertColors("green", "blue");
		replayTestDocEvents(TEST_URI, thirdEventUri).assertColors("green", "blue", "red");
		replayTestDocEvents(TEST_URI, fourthEventUri).assertColors("green", "blue", "red", "yellow");
	}
}
