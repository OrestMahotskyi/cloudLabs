const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const params = { TableName: "univ-dev-lab-authors" }; // Назва твоєї таблиці з terraform apply

    dynamodb.scan(params, (err, data) => {
        if (err) {
            callback(err);
        } else {
            const authors = data.Items.map(item => ({
                id: item.id.S,
                firstName: item.firstName ? item.firstName.S : "",
                lastName: item.lastName ? item.lastName.S : ""
            }));
            callback(null, authors);
        }
    });
};