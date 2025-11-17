const admin = require('firebase-admin');
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');


const serviceAccount = require('./lib/scripts/tolab-e1b84-firebase-adminsdk-fbsvc-5b87e225f9.json');


const projectId = serviceAccount.project_id;

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: projectId,
});

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.post('/send-notification', async (req, res) => {
  const { token, title, body } = req.body;

  const message = {
    notification: {
      title,
      body,
    },
    token,
  };

  try {
    const response = await admin.messaging().send(message);
    res.status(200).send({ success: true, response });
  } catch (error) {
    res.status(500).send({ success: false, error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Notification server is running on port ${PORT}`);
});
