xquery version "3.1";

module namespace appendix-a = "http://history.state.gov/ns/site/hsg/appendix-a";

import module namespace templates="http://exist-db.org/xquery/templates";


declare 
    %templates:replace
function appendix-a:chart-into($node as node(), $model as map(*)) {
    let $chart-intro := doc('/db/apps/frus-history/frus-production-chart/frus-production-chart-intro.html')
    return (
        $chart-intro
    )
};

declare 
    %templates:replace
function appendix-a:chart-data($node as node(), $model as map(*)) {
    let $chart-data := util:binary-to-string(util:binary-doc('/db/apps/frus-history/frus-production-chart/frus-production-chart-data.json'))
    let $chart-parameters := util:binary-to-string(util:binary-doc('/db/apps/frus-history/frus-production-chart/frus-production-chart-parameters.json'))
    return (
    <script type="text/javascript">
        const g = window.g = new Dygraph(document.getElementById("graph"), {$chart-data}, {$chart-parameters});
    </script>
    )
};

declare 
    %templates:replace
function appendix-a:chart-title($node as node(), $model as map(*)) {
    <h1>Appendix A: Historical <span class="font-italic">Foreign Relations</span> Timeliness and
        Production Charts</h1>
};
