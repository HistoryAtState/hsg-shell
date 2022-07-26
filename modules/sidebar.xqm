xquery version "3.1";

(:
 : Template functions to handle HSG sidebars
 :)
module namespace side = "http://history.state.gov/ns/site/hsg/sidebar";

declare function side:info($node, $model) {
    <div id="info" class="hsg-panel">
        <div class="hsg-panel-heading">
            <h2 class="hsg-sidebar-title">Info</h2>
        </div>
        <ul class="hsg-list-group">
            <li class="hsg-list-group-item"><a href="#" id="hsg-cite-footer-button">Cite this resource</a></li>
        </ul>
    </div>
};
