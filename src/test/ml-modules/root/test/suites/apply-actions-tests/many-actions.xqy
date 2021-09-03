xquery version "1.0-ml";

import module namespace events = "http://marklogic.com/event-sourcing" at "/com.marklogic.event-sourcing/event-sourcing-lib.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

let $new-content := events:apply-event(
	document {
		<test>
			<color important="true">red</color>
			<color>green</color>
			<number>5</number>
			<number>7</number>
		</test>
	},
	let $event := events:build-event((
		events:build-add-node("/test", <color>blue</color>),
		events:build-add-attributes("/test/color[. = 'red']", attribute hello {"world"}),
		events:build-remove-path("/test/color[. = 'green']"),
		events:build-replace-node("/test/number/text()", text {10}),
		events:build-replace-attributes("/test/color/@important[. = 'true']", attribute important {"false"})
	))
		let $_ := xdmp:log($event)
			return $event
)

return test:assert-equal-xml(
	<test>
		<color important="false" hello="world">red</color>
		<number>10</number>
		<number>10</number>
		<color>blue</color>
	</test>,
	$new-content
)

