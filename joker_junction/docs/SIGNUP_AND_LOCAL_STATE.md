# Signup & Local State Behavior

## One-time signup verification
- Verification is done at signup time (not every login):
  - 18+ acknowledgement
  - liveness acknowledgement
  - Aadhaar fallback acknowledgement
- Signup captures profile image path/URL, Gmail, and mobile number.
- Session/profile is restored from local storage on next app open.

## Local card movement persistence
- Card positions are stored in local storage per room key:
  - `room_<ROOM_ID>_card_positions`
- Stored values are loaded when opening the room again to keep drag motion smooth and consistent.

## Joker Junction Specifics
- App name: **Joker Junction** (not Virtual Living Room or Rumble)
- Default player name format: "Joker Junction Player"
- Tagline: "Your circle. Your rules. Your table."
- Session data persists across app restarts for seamless player experience
