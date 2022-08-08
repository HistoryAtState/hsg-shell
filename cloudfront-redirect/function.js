'use strict';

const fs = require('fs').promises;

let redirectMap = null;

const aws = require('aws-sdk');
const s3 = new aws.S3({ region: 'us-east-1' });
const s3Params = {
  Bucket: 'redirectbuket',
  Key: 'redirect-sample.json',
};
 
async function fetchRedirections() {
    //check if the redirects are in tmp
    let stats = null;
    try {
        /* code */
        stats = await fs.stat('/tmp/redirect-sample.json')
        console.log(JSON.stringify(stats))
    } catch (e) {}

    if(!stats || stats.mtimeMs + (3600 * 1000) < Date.now()) {
        const response = await s3.getObject(s3Params).promise();
        const jsonResponse = JSON.parse(response.Body.toString('utf-8'));
            
        await fs.writeFile('/tmp/redirect-sample.json', response.Body.toString('utf-8'));
    }

    let data = await fs.readFile('/tmp/redirect-sample.json');
    if(data) return JSON.parse(data);
}

exports.handler = async (event, context) => {
    if(!redirectMap) {
        redirectMap = await fetchRedirections();
    }
    
    const request = event.Records[0].cf.request;
    const uri  = request.uri;
    const redirect = redirectMap ? redirectMap[uri] : null;
    //if on the redirect list 
    if(redirect) {
        const newUrl = `https://history.state.gov${redirect.to}`;
        const response = {
            status: +redirect.status,
            statusDescription: 'Moved Permanently',
            headers: {
                location: [{
                    key: 'Location',
                    value: newUrl,
                }],
            },
        }

        return response;
    }
    /*
     * return the viewer request
     */
    return request;
};