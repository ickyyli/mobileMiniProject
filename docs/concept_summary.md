# KindiSync — Concept Summary

## 1. Scenario

Tadika Doa Ibu Cilik Minda currently runs parent–teacher communication through
informal WhatsApp groups and paper logbooks. Messages get buried, daily
attendance records can be lost, and teachers spend extra hours answering
repetitive parent questions. KindiSync replaces both with a structured mobile
+ admin-web portal: teachers scan a student QR for attendance, parents view
real-time status, and the admin manages users from one dashboard.

## 2. Design Decisions

### 2.1 Role-based entry points
A single login screen routes to one of three home screens — **Parent**,
**Teacher**, **Admin** — based on credentials. This avoids "mode switching"
and gives each role only the menu items they actually need (Hick's law:
fewer choices, faster decisions).

### 2.2 Grid dashboards over deep menus
Each role lands on a **2-column grid of action cards** (Material 3
`GridView.count`). On a phone, this keeps every primary action within
thumb-reach and one tap deep — preferred over hamburger menus which hide
navigation and add friction.

### 2.3 Tick-list attendance, not manual roll-call
Replacing the paper logbook with a one-screen **checklist**: the teacher
sees today's class list, ticks the students who are present, and taps Save.
A batched write stores one document per ticked student in the `attendance`
collection. Document IDs are deterministic (`{studentId}_{yyyy-MM-dd}`)
so re-saving the same day overwrites instead of duplicating. This keeps
the interaction at one tap per student — simpler than scanning, no camera
permission required, works offline-friendly with Firestore caching.

### 2.4 Calculation surface on Child Profile
The Child Profile screen now includes a small **Attendance Summary** card
that computes Present days, Absent days, and Attendance Rate (%) over the
last 30 days — driven directly off the same `attendance` documents the
teacher creates. This turns raw scan events into a parent-meaningful number
without adding any new collection.

### 2.5 Colour and contrast
Material 3 with a teal seed colour. Each dashboard tile uses a coloured icon
chip on a white card for visual scannability while keeping AA contrast on
text. Status colours (green = present / check-in, red = absent / check-out)
are consistent across screens.

### 2.6 Firestore over a SQL backend
Real-time `StreamBuilder` widgets re-render the moment a teacher's scan
hits Firestore — no manual refresh required. Firestore's free tier also
keeps the project on a **zero-cost** budget as planned.

## 3. Mobile UX / UI Best Practices Applied

| Practice | Where it shows up |
| --- | --- |
| Single-purpose screens | Each tile opens one focused screen, not a multi-tab page |
| Thumb-reach for primary actions | Bottom-half action grid, logout in AppBar |
| Real-time feedback | `StreamBuilder` for attendance/announcements |
| Loading and empty states | Each list page handles `waiting`, `hasError`, empty |
| Minimum tap-target ≥ 48 dp | `ElevatedButton(minimumSize: Size(double.infinity, 48))` |
| Consistent navigation pattern | `Navigator.push` everywhere, AppBar back-arrow on detail screens |
| Visible system status | `CircularProgressIndicator` on login + every async fetch |

## 4. Mapping to the Mini-Project Rubric

| Rubric item | KindiSync implementation |
| --- | --- |
| Login (username/password) | `main.dart` LoginPage — Firebase Auth + hard-coded admin/teacher fallback |
| Info page | Child Profile (parent) / Student List (teacher, admin) |
| Input data | Teacher ticks students on checklist → writes `attendance` docs; Daily Activity logging |
| Calculation | Attendance Summary card — computes attendance rate % over 30 days |
| Display result | Same card renders Present / Absent / Rate stats live |
| Admin view all data | User Management page lists all parents and teachers |
| Admin update / delete | Edit + delete actions on User Management |
| Admin logout | AppBar logout icon on `admin_dashboard.dart` |
| 2–4 related tables | `users`, `attendance`, `activities`, `announcements` |
| CRUD | Create (Register Student) / Read (lists) / Update + Delete (User Mgmt) |

## 5. SDG Alignment

- **SDG 4 — Quality Education:** structured tracking of attendance and daily
  activities raises the standard of early-childhood record-keeping.
- **SDG 8 — Decent Work and Economic Growth:** automating attendance and
  parent comms reduces the unpaid admin overhead teachers carry today.
