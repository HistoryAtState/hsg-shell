'use strict';

const fs = require('fs').promises;

let redirectMap = null;
const FILE_NAME = '/tmp/redirect-sample.json';

const aws = require('aws-sdk');
const s3 = new aws.S3({ region: 'us-east-1' });
const s3Params = {
  Bucket: 'redirectbuket',
  Key: 'redirect-sample.json',
};
const getFromS3 = async () => 
    s3.getObject(s3Params).promise()
    .then(res => res.Body.toString('utf-8'))
    

const writeFile = async (filehandle,jsonString) => 
    filehandle.writeFile(jsonString)

const writeToFile = async () => fs.open(FILE_NAME, 'w+')
                                    .then(handle => getFromS3()
                                                    .then(data => writeFile(handle, data))
                                                    .then(() => handle)
                                    )
async function fetchRedirections() {
    //check if the redirects are in tmpa
    return fs.open(FILE_NAME)
        .catch(err => writeToFile())
        .then(handle => handle.stat().then(stat => {
            return {handle,stat}
        }))
        .then(({handle, stat}) => {
            if (stat.mtimeMs + (3600 * 1000) < Date.now()) {
                // renew file
                return handle
                .close()
                .then(() => writeToFile())
            } else {
                return handle
            }
        })
        .then(handle => handle.close())
        .then(() => fs.open(FILE_NAME))
        .then(handle => handle
                .readFile()
                .then(data => handle.close().then(() => data))
            )
        .then(res => JSON.parse(res))
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