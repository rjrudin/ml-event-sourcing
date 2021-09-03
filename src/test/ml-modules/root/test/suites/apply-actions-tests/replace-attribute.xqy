xquery version "1.0-ml";

import module namespace events = "http://marklogic.com/event-sourcing" at "/com.marklogic.event-sourcing/event-sourcing-lib.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

test:assert-equal-xml(
	<test>
		<color>green</color>
		<color example="true">blue</color>
	</test>,

	events:apply-event(
		document {
			<test>
				<color>green</color>
				<color example="false">blue</color>
			</test>
		},
		events:build-event(
			events:build-replace-attributes(
				"/test/color[2]/@example",
				attribute example {"true"}
			)
		)
	)
)