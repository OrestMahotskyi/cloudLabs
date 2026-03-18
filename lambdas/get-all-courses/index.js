const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");

// Створюємо клієнт для DynamoDB (v3)
const client = new DynamoDBClient({ region: "eu-central-1" });

exports.handler = async (event, context) => {
    const params = { TableName: "univ-dev-lab-courses" };

    try {
        // 1. Отримуємо дані з DynamoDB
        const data = await client.send(new ScanCommand(params));

        // 2. Форматуємо дані (перетворюємо з формату DynamoDB у звичайний JSON)
        const courses = data.Items ? data.Items.map(item => ({
            id: item.id ? item.id.S : "",
            title: item.title ? item.title.S : "",
            authorId: item.authorId ? item.authorId.S : "",
            length: item.length ? item.length.S : "",
            category: item.category ? item.category.S : ""
        })) : [];

        // 3. ПРАВИЛЬНА ВІДПОВІДЬ ДЛЯ API GATEWAY (Lambda Proxy Integration)
        return {
            statusCode: 200,
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*", // Дозволяє запити з будь-якого домену (важливо для фронтенду)
                "Access-Control-Allow-Methods": "GET,OPTIONS"
            },
            body: JSON.stringify(courses) // Тіло відповіді обов'язково має бути рядком (string)
        };

    } catch (err) {
        console.error("Помилка сканування бази:", err);

        // Повертаємо помилку у форматі, який зрозуміє API Gateway
        return {
            statusCode: 500,
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            body: JSON.stringify({
                message: "Internal Server Error",
                error: err.message
            })
        };
    }
};