xquery version "1.0";

(:
    FRUS volume images API
:)

declare namespace s3xml="http://s3.amazonaws.com/doc/2006-03-01/";

import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace functx = "http://www.functx.com";
import module namespace s3="http://history.state.gov/ns/xquery/s3" at "/db/apps/hsg-publish/modules/s3.xqm";

declare function local:contents-to-resources($contents) {
    for $item in $contents
    let $key := data($item/s3xml:Key)
    let $filename := functx:substring-after-last-match($key, '/')
    let $size := data($item/s3xml:Size)
    let $last-modified := data($item/s3xml:LastModified)
    return
        <resource>
            <filename>{$filename}</filename>
            <s3-key>{$key}</s3-key>
            <size>{$size}</size>
            <last-modified>{$last-modified}</last-modified>
        </resource>
};

(: provide this function a directory like 'frus/frus1964-68v12/ebook/' and it will update
the existing cache of that directory's contents :)
declare function local:update-leaf-directory($directory as xs:string) {
    let $bucket := $config:S3_BUCKET
    let $delimiter := '/'
    let $marker := ()
    let $max-keys := ()
    let $prefix := $directory
    let $list := s3:bucket-list($bucket, $delimiter, (), (), $prefix)
    let $contents := $list[2]/s3xml:ListBucketResult/s3xml:Contents[s3xml:Key ne $prefix]
    let $resources :=
        <resources prefix="{$prefix}">{
            local:contents-to-resources($contents)
        }</resources>
    return
        $resources
};

declare function local:dispatch-query() {
    let $start-time := util:system-time()
    let $vol-id := request:get-parameter('volume', ())
    return
        if ($vol-id) then
            let $hits := local:update-leaf-directory(concat('frus/', $vol-id, '/'))//filename[not(matches(., '(?:\.txt|\.xml)$'))]
            let $hitcount := count($hits)
            let $end-time := util:system-time()
            let $runtime := (($end-time - $start-time) div xs:dayTimeDuration('PT1S'))
            return
              <results>
                 <summary>
                    <images>{$hitcount}</images>
                    <time>{$runtime} seconds</time>
                    <datetime-retrieved>{current-dateTime()}</datetime-retrieved>
                 </summary>
                 <images>{
                     for $hit in $hits
                     return
                          <image>{$hit/string()}</image>
                 }</images>
              </results>
        else
            <error>missing volume parameter</error>
};

local:dispatch-query()
