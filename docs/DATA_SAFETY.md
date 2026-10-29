# Google Play Console Data Safety Form: Answers & Guidance

This guide provides the exact answers required when filling out the **Data Safety** questionnaire in Google Play Console for **K-Drama Crosswords** (`com.kdramacrosswords.app`).

---

## 1. Data Collection & Sharing Overview

| Question | Answer | Notes / Reason |
|---|---|---|
| **Does your app collect or share any of the required user data types?** | **No** | The app is 100% offline. `android.permission.INTERNET` is omitted. |
| **Is all of the user data collected by your app encrypted in transit?** | **Not Applicable** | No data is collected or transmitted over any network. |
| **Do you provide a way for users to request that their data be deleted?** | **Yes** | Deleting the app or clearing local app storage via Android Settings permanently deletes all local save files. |

---

## 2. Specific Data Type Declarations

All 14 Google Play data categories are declared as **Not Collected**:

1. **Location**:
   - Approximate location: **No**
   - Precise location: **No**
2. **Personal Info**:
   - Name, Email, User IDs, Address, Phone number, Race/ethnicity, Political/religious beliefs, Sexual orientation, Other info: **No**
3. **Financial Info**:
   - Credit card, debit card, bank account numbers, Purchase history, Credit score, Other financial info: **No**
4. **Health & Fitness**:
   - Health info, Fitness info: **No**
5. **Messages**:
   - Emails, SMS/MMS, Other in-app messages: **No**
6. **Photos and Videos**:
   - Photos, Videos: **No**
7. **Audio Files**:
   - Voice/sound recordings, Music files, Other audio: **No**
8. **Files and Docs**:
   - Files and documents: **No**
9. **Calendar**:
   - Calendar events: **No**
10. **Contacts**:
    - Contacts: **No**
11. **App Activity**:
    - App interactions, In-app search history, Installed apps, Other user-generated content, Other actions: **No**
12. **Web Browsing**:
    - Web browsing history: **No**
13. **App Info and Performance**:
    - Crash logs, Diagnostics, Other app performance data: **No**
14. **Device or Other IDs**:
    - Device or other IDs (e.g., Advertising ID, IMEI, MAC address): **No**

---

## 3. Security Practices

- **Data encryption in transit**: N/A (no data transferred).
- **Data deletion request**: Users can delete all saved data at any time by uninstalling the application or clearing storage via the Android device settings menu.
- **Independent Security Review**: Optional declaration. App complies with OWASP Mobile Application Security Verification Standard (MASVS) Level 1 for offline storage.

---

## 4. Ads Declaration
- **Does your app contain advertisements?**
  - Select: **No** (The app does not contain ads, ad banners, native ads, or interstitial video ads).

---

## 5. Target Audience & Content Declaration
- **Target Age Group**: 13 and older, and also accessible to children under 13 (Family Policy compliant).
- **Appeal to Children**: Designed as an all-ages family-friendly trivia game with no inappropriate themes or violence.
