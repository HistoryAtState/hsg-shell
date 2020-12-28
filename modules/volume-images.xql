xquery version "1.0";

(:
    FRUS volume images API
:)

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace s3="http://s3.amazonaws.com/doc/2006-03-01/";
declare namespace functx = "http://www.functx.com";

import module namespace aws_config = "http://history.state.gov/ns/xquery/aws_config" at '/db/apps/s3/modules/aws_config.xqm';
import module namespace bucket = 'http://www.xquery.co.uk/modules/connectors/aws/s3/bucket' at '/db/apps/s3/modules/xaws/modules/uk/co/xquery/www/modules/connectors/aws-exist/s3/bucket.xq';

declare function functx:substring-after-last-match
  ( $arg as xs:string? ,
    $regex as xs:string )  as xs:string {

   replace($arg,concat('^.*',$regex),'')
 } ;

declare function local:contents-to-resources($contents) {
    for $item in $contents
    let $key := data($item/s3:Key)
    let $filename := functx:substring-after-last-match($key, '/')
    let $size := data($item/s3:Size)
    let $last-modified := data($item/s3:LastModified)
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
    let $bucket := 'static.history.state.gov'
    let $delimiter := '/'
    let $marker := ()
    let $max-keys := ()
    let $prefix := $directory
    let $list := bucket:list($aws_config:AWS-ACCESS-KEY, $aws_config:AWS-SECRET-KEY, $bucket, $delimiter, (), (), $prefix)
    let $contents := $list[2]/s3:ListBucketResult/s3:Contents[s3:Key ne $prefix]
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
            let $hits := local:update-leaf-directory(concat('frus/', $vol-id, '/'))//filename[not(ends-with(., '.txt'))]
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
