xquery version "1.0-ml";

module namespace events = "http://marklogic.com/event-sourcing";

declare variable $URI-BASE := "/com.marklogic.event-sourcing";

declare variable $COLLECTION-EVENT := "http://marklogic.com/event-sourcing/event";
(: TODO Create event-specific roles :)
declare variable $ROLE-READER := "rest-reader";
declare variable $ROLE-WRITER := "rest-writer";

declare variable $TRACE-EVENT := "event-sourcing";

(:
Apply the actions in the given event against the given content node. No updates are performed by this function, so it's
ideal for testing out a set of actions to see what impact it will have.
:)
declare function apply-event(
	$content as node()?,
	$event as element(events:event)
)
{
	let $sheet := build-stylesheet($event)
	return xdmp:xslt-eval($sheet, $content)
};

(:
Built an XSL stylesheet with transforms based on the actions in the given. Keeping this public so it can be easily
accessed for e.g. unit testing purposes, or to override parts of the returned transform.
:)
declare function build-stylesheet($event as element(events:event))
{
	<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
		{
			for $remove-action in $event/events:remove
			return element xsl:template {
				attribute match {$remove-action/events:path/text()}
			},

			for $replace-action in $event/events:replace
			return element xsl:template {
				attribute match {$replace-action/events:path/text()},
				for $attr in $replace-action/events:attributes/@*
				return <xsl:attribute name="{fn:local-name($attr)}">{$attr/fn:string()}</xsl:attribute>,
				$replace-action/events:node/node()
			},

			for $add-action in $event/events:add
			return element xsl:template {
				attribute match {$add-action/events:path/text()},
				<xsl:copy>
					{
						for $attr in $add-action/events:attributes/@*
						return <xsl:attribute name="{fn:local-name($attr)}">{$attr/fn:string()}</xsl:attribute>
					}
					<xsl:apply-templates select="@*|node()"/>
					{$add-action/events:node/node()}
				</xsl:copy>
			}
		}
		<xsl:template match="@*|node()">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:template>
	</xsl:stylesheet>
};

declare function build-event($actions as element()*)
{
	element events:event {
		$actions
	}
};

declare function build-add-node(
	$path as xs:string,
	$node as node()
) as element(events:add)
{
	element events:add {
		element events:path {$path},
		element events:node {$node}
	}
};

declare function build-add-attributes(
	$path as xs:string,
	$attributes as attribute()+
) as element(events:add)
{
	element events:add {
		element events:path {$path},
		element events:attributes {
			$attributes
		}
	}
};

declare function build-remove-path($path as xs:string) as element(events:remove)
{
	element events:remove {
		element events:path {$path}
	}
};

declare function build-replace-node(
	$path as xs:string,
	$node as node()
) as element(events:replace)
{
	element events:replace {
		element events:path {$path},
		element events:node {$node}
	}
};

declare function build-replace-attributes(
	$path as xs:string,
	$attributes as attribute()+
) as element(events:replace)
{
	element events:replace {
		element events:path {$path},
		element events:attributes {
			$attributes
		}
	}
};

(:
Apply the actions in the given event against the given content; insert the actions as a new document with a reference to the URI
associated with the given content; replace the given content with the new content; and then return, in order, the new content, the event
document URI, and the event document.
:)
declare function update(
	$current-content as node(),
	$event as element(events:event)
) as item()+
{
	update(
		xdmp:node-uri($current-content),
		$current-content,
		$event
	)
};

(:
Apply the actions in the given event against the given content; insert the actions as a new document with a reference to the given
content URI; replace the given content with the new content; and then return, in order, the new content, the event
document URI, and the event document.
:)
declare function update(
	$content-uri as xs:string,
	$current-content as node(),
	$event as element(events:event)
) as item()+
{
	create-initial-event-if-necessary($content-uri, $current-content),

	let $new-content := apply-event($current-content, $event)
	let $_ := xdmp:node-replace($current-content, $new-content)

	return ($new-content, insert-event($content-uri, $event))
};


declare private function insert-event(
	$content-uri as xs:string,
	$event as element(events:event)
) as item()+
{
	let $event-doc := build-event-document($content-uri, $event)
	let $event-id := $event-doc/events:headers/events:event-id/fn:string()

	let $event-doc-uri := $URI-BASE || "/event/" || $event-id || ".xml"

	(: TODO Allow for customizing permissions and collections :)
	let $_ := xdmp:document-insert($event-doc-uri, $event-doc,
		(
			xdmp:default-permissions($event-doc-uri),
			xdmp:permission($ROLE-READER, "read"),
			xdmp:permission($ROLE-WRITER, "update")
		),
		$COLLECTION-EVENT
	)
	return ($event-doc-uri, $event-doc)
};

(:
	If no event exists yet for the content URI, then we need to insert an additional event that captures the addition of
	the existing content. This allows us to support replay. In addition, the event is marked as the initial one so that
	during replay, it's clear which of the two events with the same dateTime is the first one.
:)
declare private function create-initial-event-if-necessary(
	$content-uri as xs:string,
	$current-content as node()
) as empty-sequence()
{
	let $event-exists := xdmp:exists(
		cts:search(/, event-query($content-uri))
	)
	where fn:not($event-exists)
	return
		let $event := element events:event {
			attribute initial {"true"},
			element events:add {
				element events:path {"/"},
				element events:node {$current-content}
			}
		}
		let $_ := insert-event($content-uri, $event)
		return ()
};

(:
Build an envelope containing the given event and some metadata.
:)
declare private function build-event-document(
	$content-uri as xs:string,
	$event as element(events:event)
) as element(events:envelope)
{
	element events:envelope {
		element events:headers {
			element events:event-id {sem:uuid-string()},
			element events:event-dateTime {fn:current-dateTime()},
			(: TODO Allow for specifying an application-specific user e.g. via an http header :)
			element events:user {xdmp:get-current-user()},
			element events:content-uri {$content-uri}
		},
		element events:instance {$event}
	}
};

(:
TODO Writing this without a range index for now. Ultimately, we'll want a range index on events-dateTime so that we
only get the event documents needed based on the given dateTime, and we can get them back in sorted order as well.
:)
declare function replay-events(
	$content-uri as xs:string,
	$dateTime as xs:dateTime
) as node()?
{
	xdmp:trace($TRACE-EVENT, text {"Replying events for URI", $content-uri, "up through", $dateTime}),

	let $event-docs := cts:search(
		/events:envelope,
		event-query($content-uri)
	)
	where $event-docs
	return
		let $ordered-event-docs :=
			for $doc in $event-docs
			let $event-dateTime := xs:dateTime($doc/events:headers/events:event-dateTime)
			let $priority :=
				if ($doc/events:instance/events:event/@initial = "true") then 1
				else 0
			where $event-dateTime <= $dateTime
			order by $event-dateTime ascending, $priority descending
			return $doc

		return apply-events-r(
			document {()},
			$ordered-event-docs
		)
};

declare function event-query($content-uri as xs:string) as cts:query
{
	cts:and-query((
		cts:collection-query($COLLECTION-EVENT),
		cts:element-value-query(xs:QName("events:content-uri"), $content-uri)
	))
};

declare private function apply-events-r(
	$content as node()?,
	$event-docs as element(events:envelope)*
) as node()?
{
	if ($event-docs) then
		apply-events-r(
			let $event-doc := fn:head($event-docs)
			let $headers := $event-doc/events:headers
			let $_ := xdmp:trace($TRACE-EVENT,
				text {"Applying event with ID", $headers/events:event-id, "and dateTime", $headers/events:event-dateTime}
			)
			return apply-event($content, $event-doc/events:instance/events:event),
			fn:tail($event-docs)
		)
	else
		$content
};

(:
add:"/path[. = 'test']||element local name||optional value"

This doesn't support a namespace prefix on the element, as it doesn't have any knowledge of what those namespaces
would be for an application. An application should use its own function for parsing an "add" constraint so that it can
register namespace prefixes.
:)
declare function parse-add(
	$qtext as xs:string,
	$right as schema-element(cts:query)
) as schema-element(cts:query)
{
	let $tokens := fn:tokenize($right/cts:text/fn:string(), "\|\|")
	let $path := $tokens[1]
	let $element-local-name := $tokens[2]
	let $element-value := $tokens[3]
	let $query :=
		cts:element-query(
			xs:QName("events:add"),
			cts:and-query((
				cts:element-value-query(xs:QName("events:path"), $path),
				if ($element-value) then
					cts:element-value-query(xs:QName($element-local-name), $element-value)
				else
					cts:element-query(xs:QName($element-local-name), cts:and-query(()))
			))
		)
	return document {$query}/node()
};

declare function parse-remove(
	$qtext as xs:string,
	$right as schema-element(cts:query)
) as schema-element(cts:query)
{
	let $path := $right/cts:text/fn:string()
	let $query :=
		cts:element-query(
			xs:QName("events:remove"),
			cts:element-value-query(xs:QName("events:path"), $path, "punctuation-sensitive")
		)
	return document {$query}/node()
};
