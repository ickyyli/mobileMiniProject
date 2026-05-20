# KindiSync — User Flow Diagrams

Three roles share a single Login screen. Credentials route the user to one of
three home dashboards.

## 1. Top-level routing

```mermaid
flowchart TD
    Start([App launch]) --> Login[Login Page]
    Login -->|admin@kindisync.com| Admin[Admin Dashboard]
    Login -->|teacher@kindisync.com| Teacher[Teacher Dashboard]
    Login -->|valid parent creds| Parent[Parent Dashboard]
    Login -->|invalid| Login
    Login -.->|Forgot Password| Forgot[Forgot Password Page] --> Login
```

## 2. Parent flow (User side)

```mermaid
flowchart TD
    Parent[Parent Dashboard] --> CP[Child Profile<br/>+ Attendance Summary calc]
    Parent --> Activity[Activity Timeline]
    Parent --> Att[Attendance Page<br/>logs list]
    Parent --> Settings[Parent Settings]
    Parent --> Notif[Notifications]
    Parent --> Logout([Logout → Login])

    Settings --> EditP[Edit Profile]
    Settings --> NotifSet[Notification Settings]
```

**Calculation surface:** Parent Dashboard → **Child Profile** → Attendance
Summary card displays Present, Absent, Rate % calculated from the last 30
days of `attendance` documents.

## 3. Teacher flow (Data input side)

```mermaid
flowchart TD
    Teacher[Teacher Dashboard] --> Mark[Mark Attendance<br/>tick-list checklist]
    Teacher --> SList[Student List]
    Teacher --> SSel[Student Selection] --> ALog[Activity Log Page]
    Teacher --> Bcast[Broadcast Page]
    Teacher --> TLogout([Logout → Login])

    Mark -->|batched write per ticked student| AttDB[(attendance collection)]
    ALog -->|writes| ActDB[(activities collection)]
    Bcast -->|writes| AnnDB[(announcements collection)]
```

Every teacher action writes structured data into Firestore — this is the
"Input data" requirement of the rubric.

## 4. Admin flow (CRUD side)

```mermaid
flowchart TD
    Admin[Admin Dashboard] --> Reg[Register Student]
    Admin --> QR[Student QR Page]
    Admin --> Msg[Broadcast Page]
    Admin --> Set[Settings Menu]
    Admin --> ALogout([Logout → Login])

    Set --> Edit[Edit Profile]
    Set --> UM[User Management<br/>view / update / delete]
    Set --> NS[Notification Settings]

    Reg -->|create| UsersDB[(users)]
    UM -->|read / update / delete| UsersDB
```

**Rubric mapping for admin:**

| Rubric item | Screen |
| --- | --- |
| Login (username + password) | Login Page |
| View all input data | User Management (lists all users) |
| Update data | User Management (edit action) |
| Delete data | User Management (delete action) |
| Logout | AppBar logout icon |

## 5. End-to-end happy path

```mermaid
sequenceDiagram
    participant Admin
    participant Teacher
    participant Parent
    participant FS as Firestore

    Admin->>FS: Register student (users.add)
    Note over FS: users.doc {student_id, name, email, parent uid}

    Teacher->>FS: Tick students and Save (attendance batch.set)
    Note over FS: attendance.doc {studentId, status:'Present', date}

    Teacher->>FS: Log daily activity (activities.add)

    Parent->>FS: Open Child Profile (users.get + attendance.stream)
    FS-->>Parent: Profile + computed Attendance Rate %
```

This sequence is the full Input → Calculation → Display Result loop the
rubric asks for, but spread across the three roles instead of one user.
