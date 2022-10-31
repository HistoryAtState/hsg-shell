xquery version "3.0";

module namespace pagination="http://history.state.gov/ns/site/hsg/pagination";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace ut="http://history.state.gov/ns/site/hsg/app-util" at "app-util.xqm";

(:~
 : Create a bootstrap pagination element to navigate through the hits.
 :)
declare
    %templates:default('key', 'hits')
    %templates:default('start', 1)
    %templates:default("per-page", 10)
    %templates:default("min-hits", 0)
    %templates:default("max-pages", 100)
function pagination:paginate($node as node(), $model as map(*), $key as xs:string, $start as xs:int, $per-page as xs:int, $min-hits as xs:int,
    $max-pages as xs:int) {
    let $log := util:log('debug', ('pagination.xqm, count($model?hits)=', count($model?hits)))
    let $parameters := ut:get-parameter-values(('start'))
    return (
        if ($min-hits < 0 or count($model($key)) >= $min-hits) then (
            element { node-name($node) } {
                $node/@*,
                let $count := xs:integer(ceiling(count($model($key))) div $per-page) + 1
                let $middle := ($max-pages + 1) idiv 2
                return (
                    if ($start = 1)
                    then (
                        <li class="disabled">
                            <a><i class="glyphicon glyphicon-fast-backward"/></a>
                        </li>,
                        <li class="disabled">
                            <a><i class="glyphicon glyphicon-backward"/></a>
                        </li>
                    )
                    else (
                        <li>
                            <a href="{
                                ut:serialize-parameters(
                                    map:merge(
                                        ($parameters, map {'start': 1}),
                                        map{"duplicates": "use-last"}
                                    )
                                )
                            }">
                                <i class="glyphicon glyphicon-fast-backward"/>
                            </a>
                        </li>,
                        <li>
                            <a href="{
                                ut:serialize-parameters(
                                    map:merge(
                                        ($parameters, map {'start': max(($start - $per-page, 1 ))}),
                                        map{"duplicates": "use-last"}
                                    )
                                )
                            }">
                                <i class="glyphicon glyphicon-backward"/>
                            </a>
                        </li>
                    ),
                    let $startPage := xs:integer(ceiling($start div $per-page))
                    let $lowerBound := max(($startPage - ($max-pages idiv 2), 1))
                    let $upperBound := min(($lowerBound + $max-pages - 1, $count))
                    let $lowerBound := max(($upperBound - $max-pages + 1, 1))

                    for $i in $lowerBound to $upperBound
                    return (
                        if ($i = ceiling($start div $per-page))
                        then (
                            <li class="active">
                                <a href="{
                                    ut:serialize-parameters(
                                        map:merge(
                                            ($parameters, map {'start': max((($i - 1) * $per-page + 1, 1))}),
                                            map{"duplicates": "use-last"}
                                        )
                                    )
                                }">
                                    { $i }
                                </a>
                            </li>
                        )
                        else (
                            <li>
                                <a href="{
                                    ut:serialize-parameters(
                                        map:merge(
                                            ($parameters, map {'start': max((($i - 1) * $per-page + 1 , 1))}),
                                            map{"duplicates": "use-last"}
                                        )
                                    )
                                }">
                                    { $i }
                                </a>
                            </li>
                        )
                    )
                    ,
                    if ($start + $per-page < count($model($key)))
                    then (
                        <li>
                            <a href="{
                                ut:serialize-parameters(
                                    map:merge(
                                        ($parameters, map {'start': $start + $per-page}),
                                        map{"duplicates": "use-last"}
                                    )
                                )
                            }">
                                <i class="glyphicon glyphicon-forward"/>
                            </a>
                        </li>,
                        <li>
                            <a href="{
                                ut:serialize-parameters(
                                    map:merge(
                                        ($parameters, map { 'start': max( (($count - 1) * $per-page + 1, 1)) }),
                                        map{"duplicates": "use-last"}
                                    )
                                )
                            }">
                                <i class="glyphicon glyphicon-fast-forward"/>
                            </a>
                        </li>
                    )
                    else (
                        <li class="disabled">
                            <a><i class="glyphicon glyphicon-forward"/></a>
                        </li>,
                        <li>
                            <a><i class="glyphicon glyphicon-fast-forward"/></a>
                        </li>
                    )
                )
            }
        )
        else (
            util:log('info', 'pagination.xqm, No results to show in pagination.')
        )
    )
};
