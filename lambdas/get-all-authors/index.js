const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: "eu-central-1" });

exports.handler = async () => {
    try {
        const data = await client.send(new ScanCommand({ TableName: "univ-dev-lab-authors" }));
        const authors = data.Items ? data.Items.map(item => ({
            id: item.id.S,
            firstName: item.firstName ? item.firstName.S : "",
            lastName: item.lastName ? item.lastName.S : ""
        })) : [];

        return {
            statusCode: 200,
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            body: JSON.stringify(authors)
        };
    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: err.message })
        };
    }
};