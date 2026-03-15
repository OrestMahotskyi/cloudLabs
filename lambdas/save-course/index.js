const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const id = event.title.replace(/\s+/g, '-').toLowerCase();
    const params = {
        TableName: "univ-dev-lab-courses",
        Item: {
            id: { S: id },
            title: { S: event.title },
            watchHref: { S: `http://www.pluralsight.com/courses/${id}` },
            authorId: { S: event.authorId },
            length: { S: event.length },
            category: { S: event.category }
        }
    };

    dynamodb.putItem(params, (err) => {
        if (err) callback(err);
        else callback(null, { id: id, ...event });
    });
};