# ACLS Simulation Suite 🩺

A professional clinical training platform for ACLS (Advanced Cardiovascular Life Support) and BLS (Basic Life Support). This application features 14 emergency training modules, real-time decision branching, and AI-powered voice guidance.

---

## 🚀 Quick Start Guide

### 1. Prerequisites
Ensure you have the following installed:
- **Node.js** (v18 or higher)
- **Python** (v3.10 or higher)
- **MySQL Server**
- **Git**

---

## 2. Backend Setup (Django)
1. Navigate to the backend directory:
   ```bash
   cd acls-backend
   ```
2. Create and activate a Virtual Environment:
   ```bash
   python -m venv .venv
   # Windows
   .\.venv\Scripts\activate
   # Mac/Linux
   source .venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Configure Environment Variables:
   Create a file named `.env` in `acls-backend/` and add:
   ```env
   DEBUG=True
   DJANGO_SECRET_KEY=your_secret_key
   DB_NAME=ACLS_DB
   DB_USER=root
   DB_PASSWORD=your_mysql_password
   DB_HOST=localhost
   DB_PORT=3306
   ```
5. Setup the Database:
   - Create a database in MySQL named `ACLS_DB`.
   - Run migrations:
     ```bash
     python manage.py migrate
     ```
6. Start the Backend:
   ```bash
   python manage.py runserver 0.0.0.0:8002
   ```

---

## 3. Frontend Setup (React + Vite)
1. Open a new terminal and navigate to the frontend directory:
   ```bash
   cd acls-frontend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the Development Server:
   ```bash
   npm run dev
   ```
   The application will be accessible at: `http://localhost:3000`

---

## 4. Mobile App Setup (Flutter)
1. Ensure you have the **Flutter SDK** and **Android Studio** installed.
2. Navigate to the mobile directory:
   ```bash
   cd acls_mobile
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```
   *Note: Ensure the backend is running first so the app can detect the API.*

---

## 🛠️ Key Features
- **Interactive Interface**: Smooth, responsive UI for simulation navigation.
- **Natural Voice Guidance**: Automated audio instructions powered by standard TTS.
- **Workflow Branching**: Accurate decision trees based on AHA (American Heart Association) guidelines.
- **Secure Environment**: Configuration management via environment variables.

## 📁 Project Structure
- `acls-backend/`: Django REST Framework API, Translation Engine, and Workflow Data.
- `acls-frontend/`: React (Vite) application with responsive UI components.
- `acls_mobile/`: Flutter mobile application with offline-first synchronization.

## ⚖️ License
Protected content. Powered by **Bhavya**. &copy; 2025
