# SimpleMeals

A cross-platform application for mid-day meal management programs, built with FLutter, Firebase and powered by the Gemini API.

## About the project

SimpleMeals is an AI-powered mobile app designed to revolutionize midday meal tracking in schools by replacing outdated manual systems, SimpleMeals digitizes record keeping, enables nutrition analysis, and ensures real-time inventory tracking and automated reporting.

## Key Features
The app features three distinct user roles, each with a tailored dashboard and functionalities to manage their part of the meal distribution process.

#### Dynamic Inventory & Menu Planning:
Allows providers to manage their food inventory in real-time, which institutions can then use to plan and save daily menus for their students.

#### AI-Powered Nutritional Analysis:
Integrates the Gemini API to offer institutions a brief nutritional analysis based on the selected menu items.

#### Student Feedback Loop:
Enables students to confirm daily meal receipt and submit qualitative feedback, giving institutions valuable insights into the program's effectiveness.

##  How to run it locally

To get a local copy up and running, follow these simple steps.

### Prerequisites

* Flutter SDK installed.
* A Firebase project created.
* A Gemini API key from [Google AI Studio](https://aistudio.google.com/).

### Installation

1.  **Clone the repo:**
    ```bash
    git clone [https://github.com/your_username/simplemeals.git](https://github.com/your_username/simplemeals.git)
    ```
2.  **Set up your Firebase project** by adding `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) to the appropriate directories.

3.  **Create a `.env` file** in the root directory and add your Gemini API key:
    ```
    GEMINI_API_KEY=YOUR_KEY_HERE
    ```
4.  **Install packages:**
    ```bash
    flutter pub get
    ```
5.  **Run the app:**
    ```bash
    flutter run
    ```
