xquery version "3.0";

import module namespace pmu="http://www.tei-c.org/tei-simple/xquery/util" at "/db/apps/tei-simple/content/util.xql";
import module namespace odd="http://www.tei-c.org/tei-simple/odd2odd" at "/db/apps/tei-simple/content/odd2odd.xql";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

declare variable $odd-root := "/db/apps/hsg-shell/resources/odd";

declare variable $odd-source := $odd-root || "/source";

declare variable $odd-compiled := $odd-root || "/compiled";

declare variable $module-config := doc($odd-source || "/configuration.xml")/*;

<html>
    <body>
        <h1>Regenerating XQuery code from ODD files</h1>
        <ul>
        {
            for $source in ("frus.odd", "departmenthistory.odd")
            for $module in ("web")
            for $file in pmu:process-odd(
                doc(odd:get-compiled($odd-source, $source, $odd-compiled)),
                $odd-compiled,
                $module,
                "../generated",
                $module-config)?("module")
            return
                <li>{$file}</li>
        }
        </ul>
    </body>
</html>
