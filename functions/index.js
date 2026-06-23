const { onRequest } = require('firebase-functions/v2/https');
const { beforeUserDeleted } = require('firebase-functions/v2/identity');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp();

const db = getFirestore();

const WEBHOOK_SECRET = process.env.REVENUECAT_WEBHOOK_SECRET ?? '';

const PREMIUM_EVENTS = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'PRODUCT_CHANGE',
  'UNCANCELLATION',
  'NON_RENEWING_PURCHASE',
]);

const FREE_EVENTS = new Set([
  'CANCELLATION',
  'EXPIRATION',
  'BILLING_ISSUE',
  'SUBSCRIPTION_PAUSED',
]);

const HANDLED_EVENTS = new Set([...PREMIUM_EVENTS, ...FREE_EVENTS]);

function resolveTierFromProductId(productId) {
  if (!productId) return 'free';
  const id = productId.toLowerCase();
  if (id.includes('yearly') || id.includes('annual')) return 'yearly';
  if (id.includes('six') || id.includes('6_month')) return 'six_month';
  if (id.includes('three') || id.includes('3_month')) return 'three_month';
  if (id.includes('monthly') || id.includes('month')) return 'monthly';
  return 'monthly';
}

exports.revenueCatWebhook = onRequest(
  { region: 'us-central1', invoker: 'public' },
  async (req, res) => {
    if (req.method !== 'POST') return res.status(405).send('Method Not Allowed');

    if (WEBHOOK_SECRET) {
      const authHeader = req.headers['authorization'] ?? '';
      if (authHeader !== WEBHOOK_SECRET) {
        console.warn('revenueCatWebhook: Unauthorized request');
        return res.status(401).send('Unauthorized');
      }
    }

    const event = req.body?.event;
    if (!event) return res.status(400).send('Bad Request: missing event');

    const { type: eventType, app_user_id: appUserId, product_id: productId, expiration_at_ms: expirationAtMs } = event;

    console.log(`revenueCatWebhook: event=${eventType} uid=${appUserId}`);

    if (!HANDLED_EVENTS.has(eventType)) return res.status(200).send('OK');

    if (!appUserId || appUserId.startsWith('$RCAnonymousID')) return res.status(200).send('OK');

    const isPremiumEvent = PREMIUM_EVENTS.has(eventType);
    const newTier = isPremiumEvent ? resolveTierFromProductId(productId) : 'free';
    const isPremium = isPremiumEvent;

    const userRef = db.collection('usuarios').doc(appUserId);

    try {
      const snapshot = await userRef.get();
      if (!snapshot.exists) {
        console.warn(`revenueCatWebhook: User not found uid=${appUserId}`);
        return res.status(200).send('OK');
      }

      const currentData = snapshot.data();
      const wasAlreadyPremium = currentData.isPremium === true;

      const updates = {
        tier: newTier,
        isPremium: isPremium,
        updatedAt: FieldValue.serverTimestamp(),
      };

      if (isPremium && !wasAlreadyPremium) updates.premiumSince = FieldValue.serverTimestamp();
      if (!isPremium) updates.premiumSince = null;
      if (expirationAtMs) updates.premiumExpiresAt = new Date(expirationAtMs);

      await userRef.update(updates);
      console.log(`revenueCatWebhook: Updated uid=${appUserId} tier=${newTier} isPremium=${isPremium}`);
      return res.status(200).send('OK');
    } catch (error) {
      console.error('revenueCatWebhook: Firestore update failed', error);
      return res.status(500).send('Internal Server Error');
    }
  }
);

exports.onUserDeleted = beforeUserDeleted(async (event) => {
  const user = event.data;
  const uid = user.uid;
  console.log(`onUserDeleted: Cleaning up Firestore for uid=${uid}`);
  try {
    await db.collection('usuarios').doc(uid).delete();
    console.log(`onUserDeleted: Deleted document for uid=${uid}`);
  } catch (error) {
    console.error(`onUserDeleted: Failed for uid=${uid}`, error);
  }
});
