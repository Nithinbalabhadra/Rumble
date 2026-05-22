# Manual Premium Activation Flow (MVP/Trial)

This trial flow supports free guest access while restricting room hosting to manually approved premium hosts.

## Trial flow
1. User signs up and can join rooms for free.
2. If user attempts to host and is not premium, app shows `TrialPaywallWidget`.
3. User pays via manual UPI transfer and sends screenshot over WhatsApp support.
4. Admin verifies payment and sets `isPremiumHost = true` in Firestore `/users/{uid}`.
5. On next host attempt, user can create room.

## Firestore security
`firestore.rules` enforces room creation only for authenticated users where:
`users/{uid}.isPremiumHost == true`

## Important
- Keep gameplay outcomes independent from payment.
- This is an interim beta method before formal payment gateway onboarding.
