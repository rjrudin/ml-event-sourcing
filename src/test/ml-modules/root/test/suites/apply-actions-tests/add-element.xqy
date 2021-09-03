xquery version "1.0-ml";

import module namespace events = "http://marklogic.com/event-sourcing" at "/com.marklogic.event-sourcing/event-sourcing-lib.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

test:assert-equal-xml(
	<test>
		<color>green</color>
		<color>blue</color>
	</test>,

	events:apply-event(
		document {
			<test>
				<color>green</color>
			</test>
		},
		events:build-event(
			events:build-add-node("/test", <color>blue</color>)
		)
	)
),

test:assert-equal-xml(
	<test>
		<color>green</color>
		<wrapped>
			<color>blue</color>
		</wrapped>
	</test>,

	events:apply-event(
		document {
			<test>
				<color>green</color>
			</test>
		},
		events:build-event(
			events:build-add-node("/test",
				<wrapped>
					<color>blue</color>
				</wrapped>
			)
		)
	)
)

