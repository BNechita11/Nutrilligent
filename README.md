# Nutrilligent – Smart Lifestyle Companion

Nutrilligent is a mobile application built with Flutter and Firebase, designed to support a healthy, balanced, and sustainable lifestyle. The app integrates nutrition tracking, physical activity, emotional awareness, and community support into a single, unified experience.

---

## Functional Specifications

Nutrilligent offers a personalized experience for users through the following key features:

### Authentication & Onboarding
- Secure login and registration via email or Google account.
- Onboarding questionnaire to collect user-specific data (e.g., age, height, weight, emotional state, activity level).
- Personalized daily calorie goal and lifestyle plan based on onboarding responses.

### Daily Dashboard
- Tracks meals, water intake, steps, mood (via "Vibe Check"), and emotional wellness.
- Offers daily recommendations for recipes, workouts, and meditations.
- Quick Actions and personalized notifications.
- Weekly progress analysis and visual summaries.

### Community Feed
- Users can post updates, engage with others through reactions and comments.
- Fosters accountability, encouragement, and motivation.

### Personal Progress
- Body progress photo gallery and emotional journaling.
- View past entries and reflect on physical and mental growth.

---

## Technical Specifications

### Frontend
- **Framework**: Flutter (cross-platform for Android/iOS)
- **Language**: Dart
- **State Management**: Provider + ChangeNotifier
- **UI Components**: Lottie animations, Syncfusion gauges, FL Chart for graphs
- **Themes**: Dark, and Custom Purple themes
- **Device Integration**: SharedPreferences for local settings, flutter_local_notifications for reminders

### Backend & Cloud
- **Platform**: Firebase
  - Cloud Firestore: Real-time NoSQL database
  - Firebase Auth: Secure authentication
  - Firebase Messaging: Push notifications

### Data Structure
- `users/`: user profiles
- `users/{uid}/dailyStats/`: per-day stats for each user
- `journalEntries/`, `posts/`, `reactions/`, `bodyProgressPhotos/`: additional collections for extended features

## Architecture Overview

- Modular and layered architecture:
  - `screens/`: logical UI screens (Dashboard, MeScreen, CommunityScreen)
  - `widgets/`: reusable UI components
  - `models/`: data structures and Firestore mapping
  - `services/`: business logic and backend interactions
  - `providers/`: state synchronization
  - `themes/` and `extensions/`: visual styling and utility extensions

Data flow follows a unidirectional architecture:
- UI → Provider → Service → Firebase → UI

---

## User Flow

1. **Authentication & Onboarding**:
   - New users complete a setup process for personalized goal tracking.
2. **Daily Interaction**:
   - Users log meals, water, steps, mood, and view motivational insights.
3. **Community Features**:
   - Users can post, comment, and engage with others.
4. **Progress Tracking**:
   - Visual and journal-based tracking of physical and emotional well-being.

---
## Setup Instructions

### Prerequisites
- Flutter SDK (v3.10+)
- Dart SDK (v3.0+)
- Firebase project configured (Auth, Firestore, Messaging)
- Android Studio or VS Code

### Installation

```bash
git clone https://github.com/yourusername/nutrilligent.git
cd nutrilligent
flutter pub get
flutter run
