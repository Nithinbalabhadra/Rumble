const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.handleReport = functions.database
  .ref('/reports/{id}')
  .onCreate(async (snap) => {
    const r = snap.val();
    if (!r || !r.offenderId) return null;

    await admin.database().ref(`/banned_users/${r.offenderId}`).update({
      banned: true,
      source: 'report',
      updatedAt: Date.now(),
    });
    return null;
  });
