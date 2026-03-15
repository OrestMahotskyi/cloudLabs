const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const params = {
        TableName: "univ-dev-lab-courses",
        Key: { "id": { S: event.id } }
    };

    dynamodb.deleteItem(params, (err) => {
        if (err) callback(err);
        else callback(null, { message: "Deleted successfully" });
    });
};