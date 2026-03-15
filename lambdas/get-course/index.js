const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const params = {
        TableName: "univ-dev-lab-courses",
        Key: { "id": { S: event.id || event.pathParameters.id } }
    };

    dynamodb.getItem(params, (err, data) => {
        if (err) callback(err);
        else callback(null, data.Item ? {
            id: data.Item.id.S,
            title: data.Item.title.S,
            authorId: data.Item.authorId.S,
            length: data.Item.length.S,
            category: data.Item.category.S
        } : {});
    });
};