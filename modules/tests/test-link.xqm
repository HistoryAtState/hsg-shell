xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-link";

import module namespace link="http://history.state.gov/ns/site/hsg/link" at "../link.xqm";
import module namespace templates="http://exist-db.org/xquery/html-templating";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare boundary-space preserve;

(:
 :  WHEN calling link:report-issue()
 :  GIVEN a $node (e.g. <a data-template="link:report-issue">Report an issue on this page</a>)
 :  GIVEN a $model
 :  THEN return the element with an added @href populated by link:email($email, $subject, $body)
 :      WHERE $email is 'history@state.gov'
 :      WHERE $subject is 'Problem on page XXX'
 :      WHERE $body is the result of link:report-issue-body($node, $model)
 :)

declare %test:assertEquals("mailto:history@state.gov?subject=Error%20on%20page%20%60test-path%60&amp;body=%0D%0A_________________________________________________________%0D%0APlease%20provide%20any%20additional%20information%20above%20this%20line%0D%0A%0D%0ARequested%20URL%3A%0D%0A%09example.com%2Fthispage") function x:link-report-issue() {
    let $node := <a data-template="link:report-issue">Report an issue on this page</a>
    let $config := map{
        $templates:CONFIG_FN_RESOLVER : function($functionName as xs:string, $arity as xs:int) {
            try {
                function-lookup(xs:QName($functionName), $arity)
            } catch * {
                ()
            }
        },
        $templates:CONFIG_PARAM_RESOLVER : map{}
    }
    let $model := map {
        $templates:CONFIGURATION : $config,
        "url": "example.com/thispage",
        "local-uri":  "thispage"
    }
    return link:report-issue($node, $model)/@href/string(.)
};

(:
 :  WHEN calling link:report-issue-body()
 :  GIVEN a $node in the context of an error page (e.g. <a data-template="link:report-issue">Report an issue on this page</a>)
 :  GIVEN a $model containing the requested url (e.g. $model?url = 'example.com/thispage')
 :  THEN return the URI-encoded concatenation of strings (e.g. 'reply above this line', the requested URL, and the error message (can't really be reproduced by XQsuite)
 :)

declare 
    %test:assertEquals('%0D%0A_________________________________________________________%0D%0APlease%20provide%20any%20additional%20information%20above%20this%20line%0D%0A%0D%0ARequested%20URL%3A%0D%0A%09example.com%2Fthispage')
function x:link-report-issue-body(){
    let $html := doc('/db/apps/hsg-shell/tests/data/error-page.xml')
    let $node := $html/html/body[1]/footer[1]/section[3]/div[1]/div[1]/p[1]/a[1]
    let $config := map{
        $templates:CONFIG_FN_RESOLVER : function($functionName as xs:string, $arity as xs:int) {
            try {
                function-lookup(xs:QName($functionName), $arity)
            } catch * {
                ()
            }
        },
        $templates:CONFIG_PARAM_RESOLVER : map{}
    }
    let $model := map {
        $templates:CONFIGURATION : $config,
        "url": "example.com/thispage"
    }
    return link:report-issue-body($node, $model) => encode-for-uri()
};

(:
 :  WHEN calling link:email
 :  GIVEN an $email address (e.g. history@state.gov)
 :  GIVEN an $subject line as a string (e.g. 'Subject Line')
 :  GIVEN a $body as a string(e.g. 'Email body')
 :  THEN return the concatenated and URL encoded string (e.g. 'mailto:history@state.gov?subject=Subject%20line&body=Email%20body')
 :)

declare %test:assertEquals('mailto:history@state.gov?subject=Subject%20line&amp;body=Email%20body') function x:link-email() {
    let $email := 'history@state.gov'
    let $subject := 'Subject line'
    let $body := 'Email body'
    return link:email($email, $subject, $body)
};

(:
 :  WHEN calling link:email
 :  GIVEN an $email address (e.g. history@state.gov)
 :  GIVEN no $subject line
 :  GIVEN a $body as a string(e.g. 'Email body')
 :  THEN return the concatenated and URL encoded string (e.g. 'mailto:history@state.gov?body=Email%20body')
 :)

declare %test:assertEquals('mailto:history@state.gov?body=Email%20body') function x:link-email-no-subject() {
    let $email := 'history@state.gov'
    let $subject := ()
    let $body := 'Email body'
    return link:email($email, $subject, $body)
};

(:
 :  WHEN calling link:email
 :  GIVEN an $email address (e.g. history@state.gov)
 :  GIVEN an $subject line as a string (e.g. 'Subject Line')
 :  GIVEN no $body
 :  THEN return the concatenated and URL encoded string (e.g. 'mailto:history@state.gov?subject=Subject%20line')
 :)

declare %test:assertEquals('mailto:history@state.gov?subject=Subject%20line') function x:link-email-no-body() {
    let $email := 'history@state.gov'
    let $subject := 'Subject line'
    let $body := ()
    return link:email($email, $subject, $body)
};

(:
 :  WHEN calling link:email
 :  GIVEN an $email address (e.g. history@state.gov)
 :  GIVEN a $subject line as a string (e.g. 'Subject Line')
 :  GIVEN a $body longer than 2K characters (e.g. see below!)
 :  THEN return the email link with the url-encoding of the first 2K characters of the body
 :)
 
declare
    %test:assertEquals("mailto:history@state.gov?subject=Subject%20Line&amp;body=Descended%20from%20astronomers%20something%20incredible%20is%20waiting%20to%20be%20known%20a%20billion%20trillion%20network%20of%20wormholes%20great%20turbulent%20clouds%20decipherment.%20The%20carbon%20in%20our%20apple%20pies%20tendrils%20of%20gossamer%20clouds%20cosmic%20ocean%20vanquish%20the%20impossible%20cosmos%20globular%20star%20cluster.%20Colonies%20gathered%20by%20gravity%20made%20in%20the%20interiors%20of%20collapsing%20stars%20courage%20of%20our%20questions%20intelligent%20beings%20kindling%20the%20energy%20hidden%20in%20matter.%20With%20pretty%20stories%20for%20which%20there%27s%20little%20good%20evidence%20gathered%20by%20gravity%20two%20ghostly%20white%20figures%20in%20coveralls%20and%20helmets%20are%20softly%20dancing%20two%20ghostly%20white%20figures%20in%20coveralls%20and%20helmets%20are%20softly%20dancing%20across%20the%20centuries%20hearts%20of%20the%20stars.%0AA%20still%20more%20glorious%20dawn%20awaits%20a%20very%20small%20stage%20in%20a%20vast%20cosmic%20arena%20intelligent%20beings%20Flatland%20of%20brilliant%20syntheses%20corpus%20callosum.%20Encyclopaedia%20galactica%20two%20ghostly%20white%20figures%20in%20coveralls%20and%20helmets%20are%20softly%20dancing%20the%20carbon%20in%20our%20apple%20pies%20realm%20of%20the%20galaxies%20two%20ghostly%20white%20figures%20in%20coveralls%20and%20helmets%20are%20softly%20dancing%20great%20turbulent%20clouds.%20Euclid%20preserve%20and%20cherish%20that%20pale%20blue%20dot%20paroxysm%20of%20global%20death%20something%20incredible%20is%20waiting%20to%20be%20known%20realm%20of%20the%20galaxies%20with%20pretty%20stories%20for%20which%20there%27s%20little%20good%20evidence.%0ATingling%20of%20the%20spine%20dispassionate%20extraterrestrial%20observer%20hydrogen%20atoms%20science%20Vangelis%20intelligent%20beings.%20Sea%20of%20Tranquility%20shores%20of%20the%20cosmic%20ocean%20realm%20of%20the%20galaxies%20are%20creatures%20of%20the%20cosmos%20preserve%20and%20cherish%20that%20pale%20blue%20dot%20great%20turbulent%20clouds%3F%20Gathered%20by%20gravity%20concept%20of%20the%20number%20one%20across%20the%20centuries%20muse%20about%20paroxysm%20of%20global%20death%20muse%20about.%20Paroxysm%20of%20global%20death%20a%20still%20more%20glorious%20dawn%20awaits%20stirred%20by%20starlight%20a%20mote%20of%20dust%20suspended%20in%20a%20sunbeam%20shores%20of%20the%20cosmic%20ocean%20preserve%20and%20cherish%20that%20pale%20blue%20dot.%0AVastness%20is%20bearable%20only%20through%20love%20emerged%20into%20consciousness%20astonishment%20the%20carbon%20in%20our%20apple%20pies%20Jean-Fran%C3%A7ois%20Champollion%20realm%20of%20the%20galaxies%3F%20P")
function x:link-email-long-body() {
    let $email := 'history@state.gov'
    let $subject := 'Subject Line'
    let $body := "Descended from astronomers something incredible is waiting to be known a billion trillion network of wormholes great turbulent clouds decipherment. The carbon in our apple pies tendrils of gossamer clouds cosmic ocean vanquish the impossible cosmos globular star cluster. Colonies gathered by gravity made in the interiors of collapsing stars courage of our questions intelligent beings kindling the energy hidden in matter. With pretty stories for which there's little good evidence gathered by gravity two ghostly white figures in coveralls and helmets are softly dancing two ghostly white figures in coveralls and helmets are softly dancing across the centuries hearts of the stars.
A still more glorious dawn awaits a very small stage in a vast cosmic arena intelligent beings Flatland of brilliant syntheses corpus callosum. Encyclopaedia galactica two ghostly white figures in coveralls and helmets are softly dancing the carbon in our apple pies realm of the galaxies two ghostly white figures in coveralls and helmets are softly dancing great turbulent clouds. Euclid preserve and cherish that pale blue dot paroxysm of global death something incredible is waiting to be known realm of the galaxies with pretty stories for which there's little good evidence.
Tingling of the spine dispassionate extraterrestrial observer hydrogen atoms science Vangelis intelligent beings. Sea of Tranquility shores of the cosmic ocean realm of the galaxies are creatures of the cosmos preserve and cherish that pale blue dot great turbulent clouds? Gathered by gravity concept of the number one across the centuries muse about paroxysm of global death muse about. Paroxysm of global death a still more glorious dawn awaits stirred by starlight a mote of dust suspended in a sunbeam shores of the cosmic ocean preserve and cherish that pale blue dot.
Vastness is bearable only through love emerged into consciousness astonishment the carbon in our apple pies Jean-François Champollion realm of the galaxies? Paroxysm of global death citizens of distant epochs Tunguska event a mote of dust suspended in a sunbeam not a sunrise but a galaxyrise a very small stage in a vast cosmic arena. Bits of moving fluff with pretty stories for which there's little good evidence great turbulent clouds great turbulent clouds from which we spring bits of moving fluff.
Orion's sword Hypatia dispassionate extraterrestrial observer astonishment the sky calls to us bits of moving fluff. Courage of our questions shores of the cosmic ocean Sea of Tranquility with pretty stories for which there's little good evidence extraordinary claims require extraordinary evidence the carbon in our apple pies. Inconspicuous motes of rock and gas another world inconspicuous motes of rock and gas inconspicuous motes of rock and gas Sea of Tranquility citizens of distant epochs.
The only home we've ever known Drake Equation muse about are creatures of the cosmos how far away great turbulent clouds. Preserve and cherish that pale blue dot a very small stage in a vast cosmic arena citizens of distant epochs venture citizens of distant epochs stirred by starlight. Network of wormholes extraordinary claims require extraordinary evidence the ash of stellar alchemy a still more glorious dawn awaits a very small stage in a vast cosmic arena not a sunrise but a galaxyrise.
A still more glorious dawn awaits tesseract finite but unbounded paroxysm of global death Apollonius of Perga light years. Hundreds of thousands emerged into consciousness vastness is bearable only through love corpus callosum Euclid extraordinary claims require extraordinary evidence. Colonies gathered by gravity concept of the number one something incredible is waiting to be known made in the interiors of collapsing stars bits of moving fluff. Take root and flourish bits of moving fluff with pretty stories for which there's little good evidence vanquish the impossible citizens of distant epochs take root and flourish.
Worldlets dispassionate extraterrestrial observer finite but unbounded trillion the ash of stellar alchemy network of wormholes. Dream of the mind's eye globular star cluster muse about extraplanetary concept of the number one globular star cluster. Rich in mystery a mote of dust suspended in a sunbeam venture across the centuries the sky calls to us hundreds of thousands? Courage of our questions vastness is bearable only through love extraordinary claims require extraordinary evidence extraordinary claims require extraordinary evidence shores of the cosmic ocean Sea of Tranquility?
The ash of stellar alchemy consciousness muse about light years Drake Equation vanquish the impossible? Dream of the mind's eye globular star cluster stirred by starlight not a sunrise but a galaxyrise Sea of Tranquility realm of the galaxies. From which we spring a very small stage in a vast cosmic arena made in the interiors of collapsing stars something incredible is waiting to be known another world preserve and cherish that pale blue dot.
Quasar two ghostly white figures in coveralls and helmets are softly dancing rich in mystery a billion trillion dream of the mind's eye hundreds of thousands. Bits of moving fluff intelligent beings concept of the number one laws of physics something incredible is waiting to be known citizens of distant epochs? The only home we've ever known laws of physics descended from astronomers a still more glorious dawn awaits two ghostly white figures in coveralls and helmets are softly dancing descended from astronomers?
The carbon in our apple pies a mote of dust suspended in a sunbeam how far away of brilliant syntheses a still more glorious dawn awaits encyclopaedia galactica. Preserve and cherish that pale blue dot permanence of the stars courage of our questions Orion's sword preserve and cherish that pale blue dot the only home we've ever known? White dwarf as a patch of light hearts of the stars dream of the mind's eye vanquish the impossible network of wormholes.
Hundreds of thousands ship of the imagination light years culture invent the universe rings of Uranus? A very small stage in a vast cosmic arena at the edge of forever the carbon in our apple pies emerged into consciousness a mote of dust suspended in a sunbeam stirred by starlight. From which we spring dream of the mind's eye network of wormholes how far away intelligent beings as a patch of light."
    return link:email($email, $subject, $body)
};