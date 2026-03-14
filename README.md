# StylenCut
# BarberFlow

A modern, boutique grooming application built with Flutter. BarberFlow offers a seamless experience for clients to book appointments and for barbers/admins to manage their daily schedules.

## 🌟 Features

### Client Experience
- **Sleek Onboarding:** A welcoming introduction to the BarberFlow experience.
- **Home Dashboard:** Quick access to top barbers and featured services.
- **Salon Details:** View salon information, ratings, and available services.
- **Booking Flow:** Intuitive step-by-step process to select a barber, service, and time slot.
- **My Bookings:** Keep track of upcoming and past appointments.
- **Rate & Review:** Leave feedback after appointments to maintain high service quality.

### Admin Dashboard
- **Live Status Management:** Quickly update availability status (Free, Busy, Away).
- **Daily Schedule:** View and manage today's bookings.
- **At-a-Glance Stats:** Track total, completed, and remaining bookings for the day.

## 🎨 Theme & UI/UX

The app embraces a **Modern Boutique Grooming** aesthetic:
- **Primary Color:** Muted Gold (`#C19A6B`)
- **Backgrounds:** Pure White (`#FFFFFF`) with Light Grey (`#F5F5F5`) for sections
- **Typography:** Geometric sans-serif font (**Poppins**) for a clean, contemporary look.
- **Styling:** Soft box shadows, pill-shaped buttons, and consistent 20px border radii throughout.

## 🏗️ Architecture

BarberFlow follows the **MVVM (Model-View-ViewModel)** architectural pattern to ensure separation of concerns and maintainability.

- **Models:** Define the data structures (e.g., `BarberModel`, `BookingModel`).
- **Views:** The UI components (Screens and Widgets) built with Flutter.
- **ViewModels:** Handle the business logic and state management using the `provider` package.

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Typography:** [Google Fonts](https://pub.dev/packages/google_fonts)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version ^3.10.3 or higher)
- Dart SDK

### Installation

1. Clone the repository:
   ```bash
   git clone <repository_url>
   ```
2. Navigate to the project directory:
   ```bash
   cd barber_flow
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 🧪 Testing

The project includes basic widget testing to ensure the application builds successfully.

To run the tests:
```bash
flutter test
```
