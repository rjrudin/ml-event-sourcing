xquery version "1.0-ml";

import module namespace events = "http://marklogic.com/event-sourcing" at "/com.marklogic.event-sourcing/event-sourcing-lib.xqy";
import module namespace test = "http://marklogic.com/roxy/test-helper" at "/test/test-helper.xqy";

test:assert-equal-xml(
	<test>
		<first>
			<color>green</color>
			<color>blue</color>
		</first>
		<second>
			<color>red</color>
			<color>yellow</color>
		</second>
	</test>,

	events:apply-event(
		document {
			<test>
				<first>
					<color>green</color>
				</first>
				<second>
					<color>red</color>
				</second>
			</test>
		},
		events:build-event((
			events:build-add-node("/test/second", <color>yellow</color>),
			events:build-add-node("/test/first", <color>blue</color>)
		))
	)
),

test:assert-equal-xml(
	<test>
		<wrapper>
			<color>green</color>
			<color>yellow</color>
		</wrapper>
		<wrapper>
			<color>red</color>
			<color>yellow</color>
		</wrapper>
	</test>,

	events:apply-event(
		document {
			<test>
				<wrapper>
					<color>green</color>
				</wrapper>
				<wrapper>
					<color>red</color>
				</wrapper>
			</test>
		},
		events:build-event(
			events:build-add-node("/test/wrapper", <color>yellow</color>)
		)
	)
),

test:assert-equal-xml(
	<test>
		<parent>
			<wrapper>
				<color>green</color>
				<color>yellow</color>
			</wrapper>
		</parent>
		<wrapper>
			<color>red</color>
			<color>yellow</color>
		</wrapper>
	</test>,

	events:apply-event(
		document {
			<test>
				<parent>
					<wrapper>
						<color>green</color>
					</wrapper>
				</parent>
				<wrapper>
					<color>red</color>
				</wrapper>
			</test>
		},
		events:build-event(
			events:build-add-node("//wrapper", <color>yellow</color>)
		)
	)
)

