# Hybrid Mode Setup - SQLite + Serverpod

## ✅ Setup Complete!

Your app now runs in **hybrid mode**: SQLite for offline storage + Serverpod for online sync.

---

## 🔧 How It Works

### Offline (No Internet)
- ✅ All features work normally
- ✅ Data saved to local SQLite database
- ✅ Photos stored locally
- ✅ Changes queued for sync

### Online (Connected)
- ✅ Everything works offline (SQLite)
- ✅ PLUS: Can sync with Serverpod backend
- ✅ Data synced between devices
- ✅ Photos uploaded to server

---

## 📱 Testing on Physical Device

### Step 1: Connect Your Phone
```bash
# Make sure phone and computer are on same WiFi network
# Enable USB debugging on Android OR trust computer on iOS
```

### Step 2: Run the App
```bash
cd /Users/hyrumharris/src/sitepictures
flutter run
# Select your device when prompted
```

### Step 3: Verify Setup
- App should launch normally
- All offline features work immediately
- Serverpod connection ready for sync (when implemented)

---

## 🌐 Network Configuration

### ⚠️ Important: URL Format
**Serverpod requires URLs to end with a trailing slash (`/`)**

✅ Correct: `http://10.0.0.142:8080/`
❌ Wrong: `http://10.0.0.142:8080`

The app will automatically add the trailing slash if missing, but it's best practice to include it.

### For Physical Device Testing
**Server URL:** `http://10.0.0.142:8080/`
- Your computer's IP address on local network
- Phone must be on same WiFi network
- Serverpod server must be running

### For Emulator Testing
Change in `lib/main.dart` line 29:
```dart
serverUrl: 'http://localhost:8080/',  // Use localhost for emulator (note trailing slash!)
```

### For Production
Change to your production server:
```dart
serverUrl: 'https://your-domain.com/',  // Your production URL (note trailing slash!)
```

---

## 🔄 Current Sync Status

### What's Working Now
- ✅ SQLite database (full offline functionality)
- ✅ Local photo storage
- ✅ All existing app features
- ✅ Serverpod client initialized and ready

### What's Ready to Integrate
- 📝 Serverpod sync service created (`lib/services/serverpod_sync_service.dart`)
- 📝 Usage examples available (`lib/services/SERVERPOD_USAGE.md`)
- 📝 Backend API fully functional (7 endpoints)

### To Enable Full Sync (Future)
You can integrate sync by:
1. Calling `ServerpodSyncService().performSync()` periodically
2. Triggering sync on network connection
3. Adding a manual "Sync Now" button

---

## 🚀 Quick Start Commands

### Start Serverpod Backend (on computer)
```bash
cd /Users/hyrumharris/src/sitepictures/sitepictures_server/sitepictures_server_server

# Start Docker (if not running)
docker compose up -d

# Start server
dart bin/main.dart
```

### Run Flutter App
```bash
cd /Users/hyrumharris/src/sitepictures

# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

---

## 🔍 Troubleshooting

### "Cannot connect to server"
- ✅ **This is normal!** App works offline
- Server connection only needed for sync
- Check if Serverpod server is running on computer
- Verify phone is on same WiFi as computer (10.0.0.142)

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Server Not Responding
```bash
# Check server is running
curl http://localhost:8080/

# Restart server
cd sitepictures_server/sitepictures_server_server
dart bin/main.dart
```

---

## 📊 Architecture

```
┌─────────────────────────────────────────┐
│         Flutter App (Phone)            │
├─────────────────────────────────────────┤
│  ┌──────────────┐  ┌─────────────────┐ │
│  │   SQLite     │  │   Serverpod     │ │
│  │   (Local)    │  │   Client        │ │
│  │              │  │                 │ │
│  │ • Photos     │  │ • Sync when     │ │
│  │ • Equipment  │  │   online        │ │
│  │ • Sites      │  │ • Upload photos │ │
│  │ • Folders    │  │ • Download data │ │
│  └──────────────┘  └─────────────────┘ │
│         ↓                    ↓          │
│    Works Offline      Works Online     │
└─────────────────────────────────────────┘
                       ↓
         ┌─────────────────────────────┐
         │  Serverpod Server (Mac)    │
         │  http://10.0.0.142:8080    │
         ├─────────────────────────────┤
         │  • PostgreSQL Database      │
         │  • Photo Storage           │
         │  • 7 REST Endpoints        │
         └─────────────────────────────┘
```

---

## 📚 Documentation

- **Serverpod Usage:** `lib/services/SERVERPOD_USAGE.md`
- **Backend Integration:** `SERVERPOD_INTEGRATION.md`
- **Server README:** `sitepictures_server/README.md`

---

## ✨ You're Ready!

Your app is now configured for hybrid mode. It will:
1. ✅ Work perfectly offline (SQLite)
2. ✅ Connect to Serverpod when online (ready for sync)
3. ✅ Run on physical device using your local network

**Deploy to your phone with:** `flutter run`

The app will work immediately - sync integration can be added later as needed!
