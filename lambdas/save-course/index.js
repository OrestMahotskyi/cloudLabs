const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: "eu-central-1" });

exports.handler = async (event) => {
    const body = event.body ? JSON.parse(event.body) : event;
    const id = body.title.replace(/\s+/g, '-').toLowerCase();

    try {
        await client.send(new PutItemCommand({
            TableName: "univ-dev-lab-courses",
            Item: {
                id: { S: id },
                title: { S: body.title },
                authorId: { S: body.authorId },
                length: { S: body.length },
                category: { S: body.category }
            }
        }));
        return {
            statusCode: 201,
            headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
            body: JSON.stringify({ id: id, ...body })
        };
    } catch (err) {
        return { statusCode: 500, headers: { "Access-Control-Allow-Origin": "*" }, body: JSON.stringify({ error: err.message }) };
    }
};