const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const params = {
        TableName: "univ-dev-lab-courses",
        Item: {
            id: { S: event.id },
            title: { S: event.title },
            watchHref: { S: event.watchHref },
            authorId: { S: event.authorId },
            length: { S: event.length },
            category: { S: event.category }
        }
    };

    dynamodb.putItem(params, (err) => {
        if (err) callback(err);
        else callback(null, event);
    });
};