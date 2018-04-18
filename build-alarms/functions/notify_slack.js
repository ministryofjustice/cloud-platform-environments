'use strict';

const https = require('https');
const url = require('url');

var functions = {};

//
// Post a message to the slack hook.
//
functions.slack = function(text, hook_url, done) {
    const slack_hook_url_parts =
        url.parse(hook_url);

    const options = {
        hostname: slack_hook_url_parts.host,
        port: 443,
        path: slack_hook_url_parts.pathname,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    };
    console.log(JSON.stringify(options));

    var req = https.request(options, function(res) {
        res.setEncoding('utf8');
        res.on('data', function(chunk) {
            console.log('data');
            done(null, chunk);
        });
        res.on('end', function() {
            console.log('end');
            done(null, null);
        });
    });

    req.on('error', function(err) {
        done(err, null);
    });

    // write data to request body
    req.write(JSON.stringify({
        text: text
    }));
    req.end();
};

//
// Handle the CodeBuild CloudWatch Event and post the message to slack so we know the progress of our build.
//
functions.handler = function(event, context) {

    console.log(JSON.stringify(event));

    const status = event.detail['build-status'];
    const project = event.detail['project-name'];

    // If failed.  Get logs path.
    var text = project+' '+status;
    if (status === 'FAILED') {
        text += '\n';
        text += 'https://console.aws.amazon.com/codebuild/home?region='+event.region+'#/projects/'+project+'/view';
    }

    const SLACK_HOOK_URL = process.env.SLACK_HOOK_URL;
    functions.slack(text, SLACK_HOOK_URL, function(err, results) {
        if (err) return context.fail(err);
        else return context.succeed(results);
    });
};

module.exports = functions;