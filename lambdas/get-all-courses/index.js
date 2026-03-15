const AWS = require("aws-sdk");
const dynamodb = new AWS.DynamoDB({ region: "eu-central-1" });

exports.handler = (event, context, callback) => {
    const params = { TableName: "univ-dev-lab-courses" };

    dynamodb.scan(params, (err, data) => {
        if (err) {
            callback(err);
        } else {
            const courses = data.Items.map(item => ({
                id: item.id.S,
                title: item.title ? item.title.S : "",
                authorId: item.authorId ? item.authorId.S : "",
                length: item.length ? item.length.S : "",
                category: item.category ? item.category.S : ""
            }));
            callback(null, courses);
        }
    });
};