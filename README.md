# Personal Finance Manager

A comprehensive web-based personal finance management system built with Spring Boot 3.x that enables users to track income, expenses, savings goals, and generate detailed financial reports.

## Table of Contents

- [Features](#features)
- [Technology Stack](#technology-stack)
- [System Architecture](#system-architecture)
- [Prerequisites](#prerequisites)
- [Installation and Setup](#installation-and-setup)
- [API Documentation](#api-documentation)
- [Design Decisions](#design-decisions)

## Features

### User Management
- **User Registration**: Create new accounts with secure password handling
- **User Login**: Authenticate with email and password credentials
- **Session Management**: Secure session-based authentication with cookies
- **Data Isolation**: Complete data segregation between user accounts
- **Logout**: Proper session invalidation

### Transaction Management
- **Create Transactions**: Add income and expense transactions with categorization
- **View Transactions**: List all transactions sorted by date (newest first)
- **Filter Transactions**: Filter by date range, category, and transaction type
- **Update Transactions**: Modify transaction details (except date)
- **Delete Transactions**: Remove transactions from records

### Category Management
- **Default Categories**:
  - Income: Salary
  - Expenses: Food, Rent, Transportation, Entertainment, Healthcare, Utilities
- **Custom Categories**: Create user-specific income and expense categories
- **Category Validation**: Ensure all transactions reference valid categories
- **Unique Names**: Category names must be unique per user

### Savings Goals
- **Create Goals**: Set financial targets with name, amount, and dates
- **Progress Tracking**: Monitor progress based on income minus expenses since goal start date
- **Update Goals**: Modify target amount and dates
- **View Goals**: Display all goals with progress percentage and remaining amounts
- **Delete Goals**: Remove goals as needed

### Financial Reports
- **Monthly Reports**: Analyze spending patterns for specific months
  - Income by category
  - Expenses by category
  - Net savings calculation
- **Yearly Reports**: Aggregate data for entire years with comprehensive overview

## Technology Stack

| Component | Technology |
|-----------|-----------|
| Language | Java 17 |
| Framework | Spring Boot 3.2.1 |
| Security | Spring Security with BCrypt |
| Database | H2 (in-memory for development) |
| ORM | Spring Data JPA / Hibernate |
| Build Tool | Maven |
| Testing | JUnit 5, Mockito |
| Code Coverage | JaCoCo |

## System Architecture

```
┌─────────────────────────────────────────────────┐
│           REST API Controllers                   │
│  (Auth, Transaction, Category, Goal, Report)    │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│           Service Layer                          │
│  (Authentication, Transaction, Category,        │
│   SavingsGoal, Report Services)                 │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│       Repository Layer (JPA)                    │
│  (User, Category, Transaction, SavingsGoal)    │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│          H2 Database                            │
└─────────────────────────────────────────────────┘
```

### Layered Architecture
- **Controllers**: Handle HTTP requests/responses and validation
- **Services**: Implement business logic and data processing
- **Repositories**: Manage database operations using Spring Data JPA
- **Entities**: Define domain models
- **DTOs**: Separate request/response objects from entities

## Prerequisites

- Java Development Kit (JDK) 17 or higher
- Maven 3.6 or higher
- Git

## Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/VishakhaGupta1/Personal_Finance_Manager.git
cd Personal_Finance_Manager
```

### 2. Build the Project

```bash
mvn clean install
```

### 3. Run the Application

```bash
mvn spring-boot:run
```

The application will start on `http://localhost:8080`. API endpoints are available under the `/api` base path (for example `http://localhost:8080/api/auth/login`).

### 4. Run Tests

```bash
mvn -DskipTests=false test
```

Optional coverage report will be generated under `target/site/jacoco/index.html`.

### 5. Access H2 Console (Optional)

```
http://localhost:8080/h2-console
```

**JDBC URL**: `jdbc:h2:mem:financedb`  
**Username**: `sa`  
**Password**: (leave blank)

## API Documentation

### Authentication Endpoints

#### Register User
```
POST /api/auth/register
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password123",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890"
}

Response: 201 Created
{
  "message": "User registered successfully",
  "userId": 1
}
```

#### Login
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password123"
}

Response: 200 OK
{
  "message": "Login successful"
}
```

#### Logout
```
POST /api/auth/logout

Response: 200 OK
{
  "message": "Logout successful"
}
```

### Transaction Endpoints

#### Create Transaction
```
POST /api/transactions
Content-Type: application/json

{
  "amount": 50000.00,
  "date": "2024-01-15",
  "category": "Salary",
  "description": "January Salary"
}

Response: 201 Created
{
  "id": 1,
  "amount": 50000.00,
  "date": "2024-01-15",
  "category": "Salary",
  "description": "January Salary",
  "type": "INCOME"
}
```

#### Get Transactions
```
GET /api/transactions?startDate=2024-01-01&endDate=2024-01-31&categoryId=1&type=INCOME

Response: 200 OK
{
  "transactions": [
    {
      "id": 1,
      "amount": 50000.00,
      "date": "2024-01-15",
      "category": "Salary",
      "description": "January Salary",
      "type": "INCOME"
    }
  ]
}
```

Supported filters:
- `startDate`, `endDate`: ISO date range (YYYY-MM-DD)
- `category`: category name (default or custom)
- `categoryId`: category identifier
- `type`: `INCOME` or `EXPENSE`

#### Update Transaction
```
PUT /api/transactions/{id}
Content-Type: application/json

{
  "amount": 60000.00,
  "description": "Updated January Salary"
}

Response: 200 OK
{
  "id": 1,
  "amount": 60000.00,
  "date": "2024-01-15",
  "category": "Salary",
  "description": "Updated January Salary",
  "type": "INCOME"
}
```

#### Delete Transaction
```
DELETE /api/transactions/{id}

Response: 200 OK
{
  "message": "Transaction deleted successfully"
}
```

### Category Endpoints

#### Get All Categories
```
GET /api/categories

Response: 200 OK
{
  "categories": [
    {
      "name": "Salary",
      "type": "INCOME",
      "isCustom": false
    },
    {
      "name": "Food",
      "type": "EXPENSE",
      "isCustom": false
    }
  ]
}
```

#### Create Custom Category
```
POST /api/categories
Content-Type: application/json

{
  "name": "SideBusinessIncome",
  "type": "INCOME"
}

Response: 201 Created
{
  "name": "SideBusinessIncome",
  "type": "INCOME",
  "isCustom": true
}
```

#### Delete Custom Category
```
DELETE /api/categories/{name}

Response: 200 OK
{
  "message": "Category deleted successfully"
}
```

### Savings Goals Endpoints

#### Create Goal
```
POST /api/goals
Content-Type: application/json

{
  "goalName": "Emergency Fund",
  "targetAmount": 5000.00,
  "targetDate": "2026-01-01",
  "startDate": "2025-01-01"
}

Response: 201 Created
{
  "id": 1,
  "goalName": "Emergency Fund",
  "targetAmount": 5000.00,
  "targetDate": "2026-01-01",
  "startDate": "2025-01-01",
  "currentProgress": 1000.00,
  "progressPercentage": 20.0,
  "remainingAmount": 4000.00
}
```

#### Get All Goals
```
GET /api/goals

Response: 200 OK
{
  "goals": [
    {
      "id": 1,
      "goalName": "Emergency Fund",
      "targetAmount": 5000.00,
      "targetDate": "2026-01-01",
      "startDate": "2025-01-01",
      "currentProgress": 1000.00,
      "progressPercentage": 20.0,
      "remainingAmount": 4000.00
    }
  ]
}
```

#### Get Single Goal
```
GET /api/goals/{id}

Response: 200 OK
{
  "id": 1,
  "goalName": "Emergency Fund",
  "targetAmount": 5000.00,
  "targetDate": "2026-01-01",
  "startDate": "2025-01-01",
  "currentProgress": 1000.00,
  "progressPercentage": 20.0,
  "remainingAmount": 4000.00
}
```

#### Update Goal
```
PUT /api/goals/{id}
Content-Type: application/json

{
  "targetAmount": 6000.00,
  "targetDate": "2026-02-01"
}

Response: 200 OK
{
  "id": 1,
  "goalName": "Emergency Fund",
  "targetAmount": 6000.00,
  "targetDate": "2026-02-01",
  "startDate": "2025-01-01",
  "currentProgress": 1000.00,
  "progressPercentage": 16.67,
  "remainingAmount": 5000.00
}
```

#### Delete Goal
```
DELETE /api/goals/{id}

Response: 200 OK
{
  "message": "Goal deleted successfully"
}
```

### Report Endpoints

#### Monthly Report
```
GET /api/reports/monthly/{year}/{month}

Example: GET /api/reports/monthly/2024/1

Response: 200 OK
{
  "month": 1,
  "year": 2024,
  "totalIncome": {
    "Salary": 3000.00,
    "Freelance": 500.00
  },
  "totalExpenses": {
    "Food": 400.00,
    "Rent": 1200.00,
    "Transportation": 200.00
  },
  "netSavings": 1700.00
}
```

#### Yearly Report
```
GET /api/reports/yearly/{year}

Example: GET /api/reports/yearly/2024

Response: 200 OK
{
  "year": 2024,
  "totalIncome": {
    "Salary": 36000.00,
    "Freelance": 6000.00
  },
  "totalExpenses": {
    "Food": 4800.00,
    "Rent": 14400.00,
    "Transportation": 2400.00
  },
  "netSavings": 20400.00
}
```
## Design Decisions

```text
1. Layered Architecture
   - Controllers -> Services -> Repositories
   - Ensures separation of concerns and maintainability

2. DTO-Based API Contracts
   - RequestDTOs and ResponseDTOs
   - Decouples API from persistence models

3. Global Exception Handling
   - Centralized error handling
   - Implemented using @ControllerAdvice

4. Session-Based Authentication
   - Stateful authentication model
   - Implemented with Spring Security sessions

5. H2 In-Memory Database
   - Zero-configuration development setup
   - Faster testing and prototyping

6. Data Isolation
   - User reference in all entities
   - Prevents cross-user data access

7. Savings Goal Progress Calculation
   - Income minus expenses since goal start date
   - Provides real-time progress updates

8. Transaction Date Validation
   - Prevents future-dated transactions
   - Enforced at service layer
```
