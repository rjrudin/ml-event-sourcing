package com.marklogic.eventsourcing;

import com.marklogic.junit.Fragment;

public class TestDoc extends Fragment {

	public TestDoc(Fragment other) {
		super(other);
	}

	public void assertColorCount(String message, int count) {
		assertElementCount(message, "/test/color", count);
	}

	public void assertColors(String... colors) {
		int len = colors.length;
		assertColorCount(format("Expecting %d colors", len), len);
		String xpath = "/test/color[%d][. = '%s']";
		for (int i = 0; i < len; i++) {
			assertElementExists(format(xpath, i + 1, colors[i]));
		}

	}
}
