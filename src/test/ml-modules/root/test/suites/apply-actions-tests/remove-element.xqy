xquery version "1.0-ml";

import module namespace events = "http://marklogic.com/event-sourcing" at "/com.marklogic.event-sourcing/event-sourcing-lib.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

test:assert-equal-xml(
	<test>
		<color>blue</color>
	</test>,

	events:apply-event(
		document {
			<test>
				<color>green</color>
				<color>blue</color>
			</test>
		},
		<event xmlns="http://marklogic.com/event-sourcing">
			<remove>
				<path>/test/color[. = 'green']</path>
			</remove>
		</event>
	)
),

test:assert-equal-xml(
	<test>
		<color>green</color>
	</test>,

	events:apply-event(
		document {
			<test>
				<color>green</color>
				<color>blue</color>
			</test>
		},
		events:build-event(
			events:build-remove-path("/test/color[. = 'blue']")
		)
	)
),

test:assert-equal-xml(
	<test>
		<color>blue</color>
	</test>,

	events:apply-event(
		document {
			<test>
				<color>green</color>
				<color>blue</color>
			</test>
		},
		events:build-event(
			events:build-remove-path("/test/color[1]")
		)
	)
)