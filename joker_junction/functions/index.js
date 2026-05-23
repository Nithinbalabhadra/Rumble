const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Handle report submissions and apply strike system
 * Strike 1: Warning
 * Strike 2: 24-hour suspension
 * Strike 3: Permanent ban
 */
exports.handleReport = functions.firestore
  .document('/reports/{id}')
  .onCreate(async (snap) => {
    const report = snap.data();
    const reportedUserId = report.targetUid;
    const reportedByUserId = report.reportedBy;

    if (!reportedUserId) return null;

    try {
      // Get reported user
      const userRef = admin.firestore().collection('users').doc(reportedUserId);
      const userDoc = await userRef.get();
      
      if (!userDoc.exists) return null;

      const userData = userDoc.data();
      const phone = userData.phone;

      if (!phone) return null;

      // Get phone hash for ban tracking
      const crypto = require('crypto');
      const phoneHash = crypto
        .createHash('sha256')
        .update(phone)
        .digest('hex');

      // Get current strike count
      const bannedUserRef = admin.firestore().collection('banned_users').doc(phoneHash);
      const bannedUserDoc = await bannedUserRef.get();
      
      let strikeCount = bannedUserDoc.exists ? (bannedUserDoc.data().strikeCount || 0) : 0;
      strikeCount += 1;

      const now = new Date();
      let action = 'warning';
      let updateData = {
        strikeCount: strikeCount,
        lastReportedAt: now,
        lastReport: report.reason,
      };

      if (strikeCount === 2) {
        action = 'suspended';
        const suspendedUntil = new Date(now.getTime() + 24 * 60 * 60 * 1000); // 24 hours
        updateData.suspendedUntil = suspendedUntil;
        
        // Revoke Agora token (if Agora integration exists)
        // TODO: Call Agora Ban API to revoke user's current token
      } else if (strikeCount >= 3) {
        action = 'banned';
        updateData.isBanned = true;
        updateData.bannedAt = now;
        
        // Update user record to mark as banned
        await userRef.update({ isBanned: true });
      }

      // Write ban/strike record
      await bannedUserRef.set(updateData, { merge: true });

      // Write audit log
      await admin.firestore().collection('audit_logs').add({
        action: action,
        targetUserId: reportedUserId,
        reportId: snap.id,
        reportReason: report.reason,
        strikeCount: strikeCount,
        timestamp: now,
        updatedBy: 'system',
      });

      // Write notification to user
      await admin.firestore().collection('users').doc(reportedUserId).collection('notifications').add({
        type: action,
        message: `Strike ${strikeCount}: ${report.reason}`,
        timestamp: now,
        read: false,
      });

      console.log(`Report processed: ${reportedUserId}, strike ${strikeCount}, action: ${action}`);
      return null;
    } catch (error) {
      console.error('Error handling report:', error);
      return null;
    }
  });

/**
 * Auto-expire host passes daily (runs at midnight IST)
 */
exports.expireHostPasses = functions.pubsub
  .schedule('0 18 * * *') // 18:30 UTC = midnight IST (adjusted for timezone)
  .onRun(async () => {
    try {
      const now = admin.firestore.Timestamp.now();
      const expiredHosts = await admin
        .firestore()
        .collection('users')
        .where('isPremiumHost', '==', true)
        .where('hostPassExpiry', '<=', now)
        .get();

      const batch = admin.firestore().batch();
      expiredHosts.docs.forEach((doc) => {
        batch.update(doc.ref, { isPremiumHost: false });
      });

      await batch.commit();
      console.log(`Expired ${expiredHosts.size} host passes`);
      return null;
    } catch (error) {
      console.error('Error expiring host passes:', error);
      return null;
    }
  });

/**
 * Razorpay webhook handler (Phase 2 integration)
 * Triggered when payment is confirmed
 */
exports.razorpayWebhook = functions.https.onRequest(async (req, res) => {
  // Verify Razorpay webhook signature
  const crypto = require('crypto');
  const secret = functions.config().razorpay?.webhook_secret;
  
  if (!secret) {
    console.error('Razorpay webhook secret not configured');
    res.status(400).send('Webhook secret not configured');
    return;
  }

  const signature = req.headers['x-razorpay-signature'];
  const body = JSON.stringify(req.body);
  const expected = crypto
    .createHmac('sha256', secret)
    .update(body)
    .digest('hex');

  if (signature !== expected) {
    res.status(400).send('Invalid signature');
    return;
  }

  try {
    const event = req.body;
    
    // Only process successful payment events
    if (event.event !== 'payment.captured') {
      res.status(200).send('OK');
      return;
    }

    const phone = event.payload?.payment?.entity?.notes?.phone;
    const amount = event.payload?.payment?.entity?.amount; // in paise
    const paymentId = event.payload?.payment?.entity?.id;

    if (!phone || amount !== 10100) { // 10100 paise = ₹101
      res.status(200).send('OK - amount mismatch');
      return;
    }

    // Find user by phone
    const usersQuery = await admin
      .firestore()
      .collection('users')
      .where('phone', '==', phone)
      .limit(1)
      .get();

    if (usersQuery.empty) {
      console.error('No user found for phone:', phone);
      res.status(200).send('OK - user not found');
      return;
    }

    const userDoc = usersQuery.docs[0];
    const now = admin.firestore.Timestamp.now();
    const expiryDate = new Date(now.toDate());
    expiryDate.setDate(expiryDate.getDate() + 7); // +7 days

    // Activate Host Pass
    await userDoc.ref.update({
      isPremiumHost: true,
      hostPassExpiry: admin.firestore.Timestamp.fromDate(expiryDate),
      lastPaymentId: paymentId,
      lastPaymentAt: now,
    });

    // Log transaction
    await admin.firestore().collection('transactions').add({
      uid: userDoc.id,
      phone: phone,
      amount: 101,
      razorpayPaymentId: paymentId,
      type: 'host_pass_weekly',
      expiresAt: admin.firestore.Timestamp.fromDate(expiryDate),
      createdAt: now,
    });

    // Write audit log
    await admin.firestore().collection('audit_logs').add({
      action: 'host_pass_activated',
      userId: userDoc.id,
      paymentId: paymentId,
      amount: 101,
      expiresAt: expiryDate,
      timestamp: now,
      updatedBy: 'razorpay_webhook',
    });

    console.log(`Host pass activated for ${phone} until ${expiryDate}`);
    res.status(200).send('OK');
  } catch (error) {
    console.error('Error processing Razorpay webhook:', error);
    res.status(500).send('Internal error');
  }
});
