const AWS = require('aws-sdk');
const sqs = new AWS.SQS();
const mapping = JSON.parse(process.env['CLIENT_QUEUES'])

exports.handler = async (event) => {
    try {
        // Map client to SQS queue URL
        const dn = event.requestContext.identity.clientCert?.subjectDN
        if (!dn) return error('Failed to identify client', 403);
        const cn = dn.match(/,CN=([^,]+)/)[1];
        const queueName = mapping[cn]
        if (!queueName) return error('No queue mapping for client', 404);
        const queueUrl = sqs.getQueueUrl({QueueName: queueName}).QueueUrl

        // Forward request to SQS
        const target = event.headers['X-Amz-Target'];
        const requestParams = JSON.parse(event.body);
        const sqsResponse = await sqs[target]({...requestParams, QueueUrl: queueUrl}).promise();
        return {
            statusCode: 200,
            body: JSON.stringify(sqsResponse),
        };
    } catch (error) {
        console.error(error);
        return error(error.message);
    }
};

function error(message, statusCode = 500) {
    return {
        statusCode,
        body: JSON.stringify({error: error.message}),
    }
}