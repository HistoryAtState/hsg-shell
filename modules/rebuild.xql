xquery version "3.0";

import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pmu="http://www.tei-c.org/tei-simple/xquery/util";
import module namespace odd="http://www.tei-c.org/tei-simple/odd2odd";

declare namespace expath="http://expath.org/ns/pkg";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

<html>
    <body>
        <h1>Regenerating XQuery code from ODD files</h1>
        <ul>
            {
                for $source in ("frus.odd", "departmenthistory.odd")
                for $module in ("web")
                for $file in pmu:process-odd(
                        odd:get-compiled($config:odd-source, $source),
                        $config:odd-compiled,
                        $module,
                        $config:odd-compiled,
                        $config:module-config)?("module")
                return
                    <li>{ $file }</li>
            }
        </ul>
    </body>
</html>
