'use strict';

const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient();

exports.handler = async function (event, context, callback) {
    var response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/html; charset=utf-8',
        },
        body: "<p>Hello world!</p>",
    };
    event.Records.forEach( async record => {
        console.log("RECORD")
        console.log(record)
        let item = JSON.parse(record.body.replaceAll('\\',''))
        console.log(item)
        let params = {
            TableName : process.env.DDB_TABLE,
            Item: {
                year:  item.year,
                title: item.title
            }
        }
        try {
            let data = await documentClient.put(params).promise()
        }
        catch (err) {
            console.log(err)
            return err
        }
    })

    callback(null, response);
};