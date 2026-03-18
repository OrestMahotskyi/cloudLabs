const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({ region: "eu-central-1" });

exports.handler = async (event) => {
    console.log("Отриманий івент:", JSON.stringify(event)); // Це допоможе знайти помилку в логах CloudWatch

    try {
        // 1. Розбираємо тіло запиту (body)
        let body;
        if (event.body) {
            body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
        } else {
            body = event;
        }

        // 2. Визначаємо ID (пріоритет у ID з URL)
        const id = (event.pathParameters && event.pathParameters.id) ? event.pathParameters.id : body.id;

        if (!id) {
            return {
                statusCode: 400,
                headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
                body: JSON.stringify({ message: "Missing course ID" })
            };
        }

        // 3. Готуємо дані для DynamoDB
        const params = {
            TableName: "univ-dev-lab-courses",
            Item: {
                id: { S: id },
                title: { S: body.title || "" },
                watchHref: { S: body.watchHref || `http://www.pluralsight.com/courses/${id}` },
                authorId: { S: body.authorId || "" },
                length: { S: body.length || "" },
                category: { S: body.category || "" }
            }
        };

        await client.send(new PutItemCommand(params));

        // 4. Повертаємо успішну відповідь
        return {
            statusCode: 200,
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "PUT,OPTIONS"
            },
            body: JSON.stringify({ id, ...body })
        };

    } catch (err) {
        console.error("Помилка UPDATE:", err);
        return {
            statusCode: 500,
            headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
            body: JSON.stringify({
                message: "Internal Server Error",
                error: err.message,
                stack: err.stack
            })
        };
    }
};