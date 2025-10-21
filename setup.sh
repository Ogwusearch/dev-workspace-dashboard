#!/bin/bash

# =========================================================
# 🧰 dev-workspace-dashboard Setup Script
# Author: EiGol
# Description: Scaffolds a Vite + React + TypeScript workspace
# =========================================================

# 1️⃣ Create project
echo "🚀 Creating Vite React TypeScript app..."
npm create vite@latest dev-workspace-dashboard -- --template react-ts
cd dev-workspace-dashboard || exit

# 2️⃣ Install dependencies
echo "📦 Installing dependencies..."
npm install axios react-router-dom zustand framer-motion react-icons

# 3️⃣ Create folder structure
echo "📁 Creating folders..."
mkdir -p src/{components/{Navbar,Sidebar,Stats,ProjectCard},pages/{Dashboard,Projects,Tasks,Automation,Git,Notes,Profile},providers,services,utils}

# 4️⃣ Generate boilerplate files
echo "🪄 Generating TypeScript/React files..."

# --- Components ---
touch src/components/Navbar/Navbar.tsx
touch src/components/Sidebar/Sidebar.tsx
touch src/components/Stats/Stats.tsx
touch src/components/ProjectCard/ProjectCard.tsx

# --- Pages ---
for page in Dashboard Projects Tasks Automation Git Notes Profile
do
cat <<EOF > "src/pages/$page/${page}Page.tsx"
import React from 'react';

const ${page}Page: React.FC = () => {
  return (
    <div className="${page.toLowerCase()}-page">
      <h1>${page} Page</h1>
    </div>
  );
};

export default ${page}Page;
EOF
done

# --- Providers ---
cat <<EOF > src/providers/AuthProvider.tsx
import React, { createContext, useContext, useState, ReactNode } from 'react';

interface AuthContextType {
  user: string | null;
  login: (user: string) => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<string | null>(null);
  const login = (username: string) => setUser(username);
  const logout = () => setUser(null);

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};
EOF

cat <<EOF > src/providers/ThemeProvider.tsx
import React, { createContext, useContext, useState, ReactNode } from 'react';

interface ThemeContextType {
  darkMode: boolean;
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider = ({ children }: { children: ReactNode }) => {
  const [darkMode, setDarkMode] = useState(false);
  const toggleTheme = () => setDarkMode((prev) => !prev);

  return (
    <ThemeContext.Provider value={{ darkMode, toggleTheme }}>
      <div className={darkMode ? 'dark' : ''}>{children}</div>
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
};
EOF

cat <<EOF > src/providers/APIProvider.tsx
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8000/api',
});

export default api;
EOF

# --- Services ---
cat <<EOF > src/services/api.ts
import api from '../providers/APIProvider';
export const fetchData = async (endpoint: string) => {
  const res = await api.get(endpoint);
  return res.data;
};
EOF

cat <<EOF > src/services/auth.ts
import api from '../providers/APIProvider';
export const loginUser = async (username: string, password: string) => {
  const res = await api.post('/auth/login', { username, password });
  return res.data;
};
EOF

cat <<EOF > src/services/git.ts
import api from '../providers/APIProvider';
export const getRepos = async () => {
  const res = await api.get('/git/repos');
  return res.data;
};
EOF

cat <<EOF > src/services/system.ts
export const getSystemInfo = () => ({
  os: navigator.platform,
  userAgent: navigator.userAgent,
  time: new Date().toLocaleString(),
});
EOF

# --- Main entry files ---
cat <<EOF > src/App.tsx
import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './providers/AuthProvider';
import { ThemeProvider } from './providers/ThemeProvider';
import DashboardPage from './pages/Dashboard/DashboardPage';
import ProjectsPage from './pages/Projects/ProjectsPage';
import TasksPage from './pages/Tasks/TasksPage';
import AutomationPage from './pages/Automation/AutomationPage';
import GitPage from './pages/Git/GitPage';
import NotesPage from './pages/Notes/NotesPage';
import ProfilePage from './pages/Profile/ProfilePage';

const App: React.FC = () => {
  return (
    <ThemeProvider>
      <AuthProvider>
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<DashboardPage />} />
            <Route path="/projects" element={<ProjectsPage />} />
            <Route path="/tasks" element={<TasksPage />} />
            <Route path="/automation" element={<AutomationPage />} />
            <Route path="/git" element={<GitPage />} />
            <Route path="/notes" element={<NotesPage />} />
            <Route path="/profile" element={<ProfilePage />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  );
};

export default App;
EOF

cat <<EOF > src/main.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# --- index.css ---
cat <<EOF > src/index.css
:root {
  font-family: 'Inter', sans-serif;
  background-color: #f8f9fb;
  color: #222;
}
.dark {
  background-color: #111;
  color: #fff;
}
EOF

# 5️⃣ Final message
echo "✅ dev-workspace-dashboard setup complete!"
echo "👉 Next steps:"
echo "   cd dev-workspace-dashboard"
echo "   npm run dev"
