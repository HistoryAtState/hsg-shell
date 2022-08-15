xquery version "3.1";

let $chart-intro := doc('/db/apps/frus-history/frus-production-chart/frus-production-chart-intro.html')
let $chart-data := util:binary-to-string(util:binary-doc('/db/apps/frus-history/frus-production-chart/frus-production-chart-data.json'))
let $chart-parameters := util:binary-to-string(util:binary-doc('/db/apps/frus-history/frus-production-chart/frus-production-chart-parameters.json'))
return 
<div data-template="pages:load">
   <div data-template="templates:surround" data-template-with="templates/site.xml" data-template-at="content">
      <div>
         <div id="static-title" class="hidden">
            <span data-template="frus-history:monograph-page-title"/> - History of the Foreign
            Relations Series - Historical Documents</div>
         <div class="row">
            <div class="hsg-breadcrumb-wrapper">
               <ol class="breadcrumb" data-template="app:fix-links">
                  <li>
                     <a href="$app">Home</a>
                  </li>
                  <li>
                     <a href="$app/historicaldocuments">Historical Documents</a>
                  </li>
                  <li>
                     <a data-template="frus:volume-breadcrumb"/>
                  </li>
                  <li class="section-breadcrumb">
                     <a class="section" data-template="frus:section-breadcrumb"/>
                  </li>
               </ol>
            </div>
         </div>
         <div class="row">
            <div class="hsg-navigation-wrapper">
               <h2 class="hsg-navigation-title" id="navigation-title" data-template="frus-history:monograph-title"/>
            </div>
         </div>
         <div class="row" data-template="pages:navigation">
            <a data-template="pages:navigation-link" data-template-direction="previous" class="page-nav nav-prev">
               <i class="glyphicon glyphicon-chevron-left"/>
            </a>
            <a data-template="pages:navigation-link" data-template-direction="next" class="page-nav nav-next">
               <i class="glyphicon glyphicon-chevron-right"/>
            </a>
            <div class="hsg-width-main">
               <div id="content-inner">
                  <div id="content-container" data-template="app:fix-links">
                     <div class="content">
                         <div xmlns="http://www.w3.org/1999/xhtml">
                         <h1>Appendix A: Historical <span class="font-italic">Foreign Relations</span> Timeliness and
                    Production Charts</h1>
        <style type="text/css">
            .dygraph-title {{
                font-size: 75%;
                color: #606060;
                margin-bottom: 2em;
            }}
            em {{
                font-weight: inherit;
                font-style: oblique;
            }}
            .dygraph-ylabel {{
                color: rgb(155,17,30);
            }}
            .dygraph-y2label {{
                color: rgb(73, 102, 144);
            }}
            .dygraph-axis-label-x {{
                color: rgb(73, 102, 144);
            }}
            .dygraph-axis-label-y {{
                color: rgb(155,17,30);
            }}
            .dygraph-axis-label-y2 {{
                color: rgb(73, 102, 144);
            }}
            .dygraph-legend {{
                margin-top: 10px;
            }}
        </style>
        <div class="bordered" style="margin-bottom: 1em">
            <div id="graph" style="width: 100%; height: 400px"/>
            <div style="margin-top: 1em; margin-left: 1em">
                <p style="margin-bottom: 0">Select Datasets to Display Above:<br/>
                    <input type="checkbox" id="0" checked="checked" onClick="change(this)"/>
                    <label for="0" style="font-weight: normal; color: inherit;">Annual <em>FRUS</em>
                        Production</label><br/>
                    <input type="checkbox" id="1" checked="checked" onClick="change(this)"/>
                    <label for="1" style="font-weight: normal; color: inherit;">Average <em>FRUS</em>
                        Lag</label><br/>
                    <input type="checkbox" id="2" onClick="change(this)"/>
                    <label for="2" style="font-weight: normal; color: inherit;">Average Regular
                            <em>FRUS</em> Lag</label>
                </p>
            </div>
        </div>
        {$chart-intro}
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/dygraph/1.0.1/dygraph-combined.js"></script>
        <script type="text/javascript">
            setStatus();
            function setStatus() {{
                document.getElementById("visibility").innerHTML =
                    g.visibility().toString();
            }}
            function change(el) {{
                g.setVisibility(parseInt(el.id), el.checked);
                setStatus();
            }}
        </script>
        <script type="text/javascript">
            g = new Dygraph(document.getElementById("graph"),{$chart-data},{$chart-parameters});
        </script>
    </div>
                     </div>
                  </div>
               </div>
            </div>
            <!-- TOC Sidebar -->
            <aside class="hsg-width-sidebar" data-template="app:fix-links">
               <div data-template="toc:table-of-contents-sidebar" data-template-heading="false" data-template-highlight="true"/>
            </aside>
         </div>
      </div>
   </div>
</div>