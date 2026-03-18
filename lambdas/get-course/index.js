const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");

const client = new DynamoDBClient({ region: "eu-central-1" });

exports.handler = async (event, context) => {
    // Беремо id з event.id або з event.pathParameters.id (для API Gateway)
    const params = {
        TableName: "univ-dev-lab-courses",
        Key: { "id": { S: event.id || event.pathParameters?.id } }
    };

    try {
        const data = await client.send(new GetItemCommand(params));

        // Якщо курс знайдено — повертаємо його, якщо ні — порожній об'єкт
        if (data.Item) {
            return {
                id: data.Item.id.S,
                title: data.Item.title.S,
                authorId: data.Item.authorId.S,
                length: data.Item.length.S,
                category: data.Item.category.S
            };
        } else {
            return {};
        }
    } catch (err) {
        console.error("Помилка отримання курсу:", err);
        throw err;
    }
};