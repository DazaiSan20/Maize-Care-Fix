const admin = require('./firebaseService');

exports.sendToDevice = async (token, payload) => {
  try {
    const message = { token, notification: payload };
    const response = await admin.messaging().send(message);
    return response;
  } catch (err) {
    throw err;
  }
};
