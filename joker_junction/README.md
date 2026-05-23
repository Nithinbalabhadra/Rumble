# 🃏 Joker Junction

**Your circle. Your rules. Your table.**

A social card game sandbox built for India. Play rummy with friends, no real money, fully compliant.

## 📱 Platform

- **PWA-First**: Install from any browser, works offline
- **Zero-Cost Launch**: Firebase free tier, Agora free minutes
- **India-Optimized**: Legal, compliant with IT Act & Online Gaming Rules 2023

## 🎮 Features

- ✅ Real-time multiplayer card table (2-6 players)
- ✅ Drag-and-drop card physics (Flame 2D engine)
- ✅ Spatial audio chat (Agora.io)
- ✅ Shared scorepad with session history
- ✅ Premium Host Pass (₹101/week) for room creation
- ✅ Guests play FREE forever
- ✅ In-app moderation & reporting
- ✅ Automated ban system with strike tracking

## 💰 Monetization

- **Host Pass**: ₹101/week to create & host rooms
- **Guests**: Always free
- **No gambling**: App never handles real money, calculates winnings, or auto-pays prizes
- **Manual Phase (0-50 users)**: UPI + WhatsApp screenshot
- **Automated Phase (50+ users)**: Razorpay Payment Links

## ⚖️ Legal

- **Classification**: Online Social Game (permissible under Online Gaming Regulation Rules, 2023)
- **Intermediary Status**: IT Act Section 2(w) — platform is not responsible for user outcomes
- **No State Restrictions**: Not a gambling platform, so AP Gaming Act 2023 does NOT apply
- **Compliance**: GDPR-ready, IT Rules 2021 audit trails, CERT-In 180-day log retention

## 🚀 Build Roadmap

### Week 1: Foundation & Auth
- [ ] PWA setup, Firebase, routing
- [ ] Phone OTP auth + age gate
- [ ] Deploy to Firebase Hosting

### Week 2: The Table
- [ ] Card drag-and-drop with Flame 2D
- [ ] Agora voice chat integration
- [ ] Shared scorepad

### Week 3: Monetization & Legal
- [ ] Host Pass paywall (₹101/week)
- [ ] WhatsApp Business + UPI ID setup
- [ ] Terms of Service & Privacy Policy

### Week 4: Growth & Safety
- [ ] Automated moderation system
- [ ] Invite sharing & viral loop
- [ ] PWA install prompt

### Post-50 Users: Scale
- [ ] Razorpay integration
- [ ] MSME/Udyam registration
- [ ] Business bank account

## 📂 Project Structure

```
joker_junction/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/                   # Configuration & constants
│   ├── models/                   # Data models (Player, Room, etc.)
│   ├── screens/                  # UI screens (Login, Lobby, Game Table)
│   ├── services/                 # Business logic (Auth, Firebase, Agora)
│   ├── widgets/                  # Reusable UI components
│   └── utils/                    # Helpers & utilities
├── web/
│   ├── manifest.json             # PWA metadata
│   ├── index.html                # Entry HTML
│   └── flutter_service_worker.js # Service worker for offline
├── pubspec.yaml                  # Dependencies
├── firestore.rules               # Firestore security rules
├── functions/                    # Firebase Cloud Functions
│   └── index.js                  # Moderation, payments, expiry logic
├── docs/
│   ├── UPI_TIP_JAR_NOTES.md
│   ├── SIGNUP_AND_LOCAL_STATE.md
│   ├── MANUAL_PREMIUM_ACTIVATION_FLOW.md
│   └── DEPLOYMENT.md
└── README.md
```

## 🛠️ Tech Stack

| Layer | Tech | Notes |
|-------|------|-------|
| **Frontend** | Flutter Web (Dart) | PWA-capable, installable |
| **Physics** | Flame 2D | Card drag, animations |
| **Voice** | Agora.io | Spatial audio for players |
| **Backend** | Firebase (Firestore + Cloud Functions) | Serverless, real-time sync |
| **Auth** | Firebase Phone OTP | 10K verifications/month free |
| **Hosting** | Firebase Hosting | .web.app domain, 10GB/month |
| **Payments** | UPI (manual) → Razorpay (auto) | 2% transaction fee, no setup cost |

## 📊 Hosting Costs at Launch

| Scale | Cost |
|-------|------|
| **0-50 users** | ₹0/month (all free tiers) |
| **50-500 users** | ~₹500-2,000/month (Agora + Razorpay) |
| **500+ users** | ~₹5,000-15,000/month (scale + GST filing) |

## 🔗 Useful Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Console](https://console.firebase.google.com)
- [Flame 2D Engine](https://flame-engine.org)
- [Agora Documentation](https://docs.agora.io)
- [Online Gaming Rules 2023 (MeitY)](https://www.meity.gov.in)

## 📝 License

MIT License. Built with ❤️ for India.

---

**Next Steps**:
1. Clone this repo
2. Follow `docs/DEPLOYMENT.md` for setup
3. Deploy to Firebase Hosting
4. Share your invite code with friends!

**Support**: Open an issue or email [your-email]
