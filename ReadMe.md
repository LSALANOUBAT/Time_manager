# Documentation for TimeManager Project

## Overview

TimeManager is a web application designed to manage working hours for users, providing functionalities for tracking time, managing teams, and generating reports. The application is built using Elixir with the Phoenix framework for the backend and Vue.js for the frontend.

## Table of Contents

1. [Technologies Used](#technologies-used)
2. [Project Structure](#project-structure)
3. [Setup Instructions](#setup-instructions)
   - [Backend Setup](#backend-setup)
   - [Frontend Setup](#frontend-setup)
4. [Docker Usage](#docker-usage)
5. [Database Migrations and Seeding](#database-migrations-and-seeding)
6. [Running the Application](#running-the-application)
7. [API Endpoints](#api-endpoints)
8. [Frontend Components](#frontend-components)


## Technologies Used

- **Backend**: Elixir, Phoenix Framework, PostgreSQL
- **Frontend**: Vue.js, Ionic Framework
- **Containerization**: Docker
- **Build Tool**: Makefile

## Project Structure

```
time_manager/
├── backend/                # Backend code
│   ├── priv/               # Database seeds and migrations
│   ├── lib/                # Elixir application code
│   ├── mix.exs             # Elixir project configuration
│   └── ...
├── frontend/               # Frontend code
│   ├── src/                # Vue.js components and views
│   ├── public/             # Static files
│   ├── package.json        # Node.js project configuration
│   └── ...
├── .docker/                # Docker configuration files
├── Makefile                # Build and deployment commands
└── README.md               # Project documentation
```

## Setup Instructions

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd time_manager
   ```

2. Install dependencies:
   ```bash
   mix deps.get
   ```

3. Create and migrate the database:
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

## Docker Usage

The project uses Docker for containerization. The following commands are available in the Makefile:

- **Build the Docker images**:
  ```bash
  make build
  ```

- **Start the services**:
  ```bash
  make up
  ```

- **Stop the services**:
  ```bash
  make down
  ```

- **View logs**:
  ```bash
  make logs
  ```

- **Open a shell in the web container**:
  ```bash
  make web_shell
  ```

## Database Migrations and Seeding

After setting up the backend, you need to run the database migrations and seed the database with initial data.

1. **enter web container**:
   ```bash
   make web_shell
   ```

2. **Seed the database**:
   ```bash
   mix ecto.migrate
   mix run priv/repo/seeds.exs
   ```

## Running the Application

1. Start the Docker containers:
   ```bash
   make up
   ```

2. Access the application in your browser at:
   ```
   http://localhost:4000
   ```

3. For the frontend, access it at:
   ```
   http://localhost:8080
   ```

## API Endpoints

The backend exposes several API endpoints for managing users, working times, and teams. Here are some key endpoints:

- **User Authentication**:
  - `POST /sign_in`: Log in a user.
  
- **Working Times**:
  - `GET /workingtime`: Retrieve all working times.
  - `POST /workingtime/:userId`: Create a new working time for a user.
  - `PUT /workingtime/:id`: Update an existing working time.
  - `DELETE /workingtime/:id`: Delete a working time.

- **Teams**:
  - `GET /teams`: Retrieve all teams.
  - `POST /teams`: Create a new team.
  - `PUT /teams/:id`: Update an existing team.
  - `DELETE /teams/:id`: Delete a team.

## Frontend Components

The frontend is built using Vue.js and consists of several components, including:

- **UserLogin**: Handles user authentication.
- **UserDashboard**: Displays user-specific data and metrics.
- **WorkingTimesGrid**: Displays a grid of working times.
- **TeamManager**: Manages teams and their members.
