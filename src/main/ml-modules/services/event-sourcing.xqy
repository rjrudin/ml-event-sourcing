xquery version "1.0-ml";

module namespace resource = "http://marklogic.com/rest-api/resource/event-sourcing";

import module namespace events = "http://marklogic.com/event-sourcing" at "/com.marklogic.event-sourcing/event-sourcing-lib.xqy";

declare namespace rapi = "http://marklogic.com/rest-api";

(:
TODO For now, using this to replay events. It doesn't seem to make sense to use /v1/documents because we don't actually
want the document to be retrieved - we want to build it by retrievin events and replaying them.
:)
declare function get(
	$context as map:map,
	$params as map:map
) as document-node()*
{
	let $content-uri := map:get($params, "uri")
	let $dateTime := xs:dateTime(map:get($params, "dateTime"))
	return document {
		events:replay-events($content-uri, $dateTime)
	}
};

declare function put(
	$context as map:map,
	$params as map:map,
	$input as document-node()*
) as document-node()?
{
	post($context, $params, $input)
};

declare %rapi:transaction-mode("update") function post(
	$context as map:map,
	$params as map:map,
	$input as document-node()*
) as document-node()*
{
	let $content-uri := map:get($params, "uri")
	let $results := events:update(doc($content-uri), $input/element())

	return document {
		xdmp:to-json(
			map:new(
				map:entry("event-doc-uri", $results[2])
			)
		)
	}
};
