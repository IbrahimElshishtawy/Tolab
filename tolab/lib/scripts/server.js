const express = require('express');
const app = express();
const sendNotification = require('./sendNotification');
app.use(express.json());

app.post('/send-notification', sendNotification);

app.listen(3000, () => {
  console.log('🚀 Server running on port 3000');
});
