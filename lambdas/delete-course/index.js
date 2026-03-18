const { DynamoDBClient, DeleteItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: "eu-central-1" });

exports.handler = async (event) => {
    const id = event.pathParameters ? event.pathParameters.id : event.id;
    try {
        await client.send(new DeleteItemCommand({
            TableName: "univ-dev-lab-courses",
            Key: { "id": { S: id } }
        }));
        return {
            statusCode: 200,
            headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
            body: JSON.stringify({ message: "Deleted successfully", id: id })
        };
    } catch (err) {
        return { statusCode: 500, headers: { "Access-Control-Allow-Origin": "*" }, body: JSON.stringify({ error: err.message }) };
    }
};