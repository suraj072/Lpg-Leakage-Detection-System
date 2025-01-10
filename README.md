# LPG Gas Leak Monitoring App

![Flutter Logo](https://img.shields.io/badge/Flutter-3.0-blue.svg) ![Firebase Logo](https://img.shields.io/badge/Firebase-Integrated-orange.svg) ![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)

A **Flutter-based LPG Gas Leak Monitoring App** that ensures safety by continuously monitoring gas levels, temperature, and humidity. The app provides real-time alerts for potential gas leaks using Firebase integration and triggers an audio alarm for immediate attention.

---

## Features

- **Real-time Monitoring**: Keeps track of LPG gas levels, temperature, and humidity.
- **Firebase Integration**: Syncs data to Firebase for seamless real-time updates.
- **Audio Alarm**: Plays a loud alarm sound when a gas leak is detected.
- **User-friendly Interface**: Simple and intuitive design for easy monitoring.
- **Cross-platform Support**: Works seamlessly on both Android and iOS devices.

---

## Screenshots

| Home Screen               | Monitoring Data         | Alert Notification       |
|---------------------------|-------------------------|--------------------------|
| ![Home Screen](link-to-image) | ![Monitoring Data](link-to-image) | ![Alert Notification](link-to-image) |

---

## Tech Stack

- **Flutter**: Frontend framework for building a seamless UI.
- **Firebase**: Backend integration for real-time database and notifications.
- **Dart**: Programming language for app development.

---

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/lpg-gas-monitoring-app.git
   ```

2. Navigate to the project directory:

   ```bash
   cd lpg-gas-monitoring-app
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Connect to your Firebase project:
   - Download the `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) from Firebase Console.
   - Place the files in the appropriate directories.

5. Run the app:

   ```bash
   flutter run
   ```

---

## Usage

1. Open the app and grant necessary permissions.
2. Monitor the gas, temperature, and humidity levels in real time.
3. Respond immediately to any audio or visual alerts for safety.

---

## Project Structure

```
lib/
├── main.dart            # Entry point of the app
├── screens/             # App screens
├── services/            # Firebase and other backend integrations
├── widgets/             # Custom widgets
├── utils/               # Helper functions
assets/
├── images/              # App images and icons
├── audio/               # Alarm sounds
```  

---

## Contribution

Contributions are welcome! If you'd like to contribute to this project:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-name
   ```
3. Make your changes and commit them:
   ```bash
   git commit -m 'Add new feature'
   ```
4. Push to your fork and submit a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

For any inquiries or feedback, feel free to contact me:

- **Name**: Suraj Paul  
- **Email**: paulsuraj044@gmail.com  
- **LinkedIn**: [linkedin.com/suraj-paul-1a559a199](https://www.linkedin.com/in/suraj-paul-1a559a199/)
