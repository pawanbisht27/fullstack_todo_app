Full Stack To-Do App

A complete Full Stack To-Do Application built with Flutter (Frontend) and Node.js + Express + MongoDB (Backend).
Includes email-based OTP authentication, secure APIs, and a beautiful Flutter UI for managing daily tasks.


Feature

- Gmail-based Authentication (OTP shown in terminal)
- Add, update, and delete To-Do tasks
- Task persistence with MongoDB
- Smart and responsive Flutter UI
- RESTful Node.js + Express backend
- Works seamlessly across Android, iOS, and web


Tech Stack

Layer| Technology
Frontend| Flutter, Dart
Backend| Node.js, Express.js
Database| MongoDB (Mongoose)
Authentication| Gmail OTP (via Nodemailer console log)
Tools| VS Code, Android Studio, Git & GitHub


Folder Structure

fullstack_todo_app/
│
├── frontend/                   # Flutter frontend app
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── backend/                    # Node.js backend app
   ├── routes/
   ├── models/
   ├── controllers/
   ├── server.js
   ├── package.json
   └── .env (local only)




Installation & Setup

Backend Setup

1. Navigate to the backend folder:
cd backend
2. Install dependencies:
npm install
3. Create a ".env" file in backend directory:
MONGO_URI=your_mongodb_connection_string
PORT=5000
EMAIL=your_gmail@gmail.com
PASSWORD=your_app_password
4. Start the backend server:
npm start
5. On registration/login, an OTP will appear in the terminal, enter it in the app to verify.


Frontend Setup (Flutter)

1. Navigate to the frontend folder:
cd frontend
2. Get Flutter dependencies:
flutter pub get
3. Run the app:
flutter run
4. Update the API base URL in your Flutter code if needed (to match your backend port).


Authentication Flow

1. User enters their Gmail address.
2. Backend generates a random OTP and logs it in the terminal.
3. User enters OTP in the app.
4. On successful verification, JWT token/session created.


Future Enhancements

- Real email OTP (via Gmail API or SendGrid)
- Push notifications for task reminders
- Dark mode support
- Cloud sync for multi-device support
- 

Author

Pawan Bisht
B.Tech | Flutter & Full Stack Developer
"pawangbisht@gmail.com" (mailto:pawangbisht@gmail.com)


License

This project is licensed under the MIT License – feel free to use and modify with attribution.


If you like this project, give it a star on GitHub!

"Full Stack To-Do App" (https://github.com/pawanbisht27/fullstack_todo_app)


