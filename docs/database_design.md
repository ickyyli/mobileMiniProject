# KindiSync — Database Design

## 1. Database Choice

**Cloud Firestore (Firebase)** — NoSQL document store. Chosen because:

- Real-time `StreamBuilder` updates without polling
- Free tier covers the kindergarten's traffic
- Same backend serves Web (admin) and Mobile (parent/teacher) clients

## 2. Collections (Tables)

KindiSync uses **4 primary related collections** + 2 supporting collections.

### 2.1 `users` — primary entity

Stores all account holders (parents, teachers, admins). Document ID = Firebase Auth UID.

| Field | Type | Notes |
| --- | --- | --- |
| `student_id` | string | Short human-readable ID (e.g. `STU001`). FK target. |
| `student_name` | string | Child's full name (for parent accounts) |
| `email` | string | Login email |
| `role` | string | `'parent'`, `'teacher'`, `'admin'` |
| `age` | string | Child's age (parent role only) |
| `className` | string | Class assignment |
| `teacherName` | string | Assigned teacher's display name |
| `profileImageUrl` | string | Firebase Storage URL |
| `fcmToken` | string | Device push-notification token |

### 2.2 `attendance` — child entity of `users`

One document per student per school day. Document ID is deterministic:
`{studentId}_{yyyy-MM-dd}` — ticking the same student twice overwrites
instead of duplicating.

| Field | Type | Notes |
| --- | --- | --- |
| `studentId` | string | **FK → users.student_id** |
| `status` | string | `'Present'` |
| `date` | string | `yyyy-MM-dd` of the school day |
| `timestamp` | timestamp | Server-set when teacher saves |

### 2.3 `activities` — child entity of `users`

Daily activity logbook entry written by teachers.

| Field | Type | Notes |
| --- | --- | --- |
| `student_id` | string | **FK → users.student_id** |
| `student_name` | string | Denormalised for fast list display |
| `activity_details` | string | Free-text description |
| `emotion_label` | string | e.g. `'Happy'`, `'Calm'` |
| `emotion_emoji` | string | Visual cue rendered on parent timeline |
| `image_url` | string | Optional photo evidence |
| `teacher_name` | string | Who logged it |
| `timestamp` | timestamp | Server-set |

### 2.4 `announcements` — broadcast messages

| Field | Type | Notes |
| --- | --- | --- |
| `title` | string |  |
| `message` | string |  |
| `timestamp` | timestamp |  |

### 2.5 Supporting collections

**`notifications`** — per-parent push records (linked by `studentId` / `parentEmail`)
**`logs`** — audit trail of login actions (`action`, `email`, `timestamp`)

## 3. Relationships (ERD)

```
                ┌─────────────────────┐
                │       users         │
                │  (uid as doc id)    │
                │  student_id  ◄──────┼─────────┐
                │  role               │         │
                │  email              │         │
                │  fcmToken           │         │
                └─────────────────────┘         │
                                                │
        ┌──────────────────┬───────────────────┤
        │                  │                   │
        ▼ FK studentId     ▼ FK student_id     ▼ FK studentId
┌──────────────┐   ┌──────────────────┐   ┌────────────────────┐
│  attendance  │   │    activities    │   │   notifications    │
│  - studentId │   │  - student_id    │   │  - studentId       │
│  - status    │   │  - activity_…    │   │  - parentEmail     │
│  - timestamp │   │  - emotion_label │   │  - title / body    │
└──────────────┘   │  - image_url     │   │  - createdAt       │
                   │  - teacher_name  │   └────────────────────┘
                   │  - timestamp     │
                   └──────────────────┘

  ┌──────────────────┐        ┌─────────────────┐
  │  announcements   │        │      logs       │
  │  (broadcast,     │        │  (audit only,   │
  │   no FK)         │        │   no FK)        │
  └──────────────────┘        └─────────────────┘
```

## 4. CRUD Operation Map

| Operation | Where it happens | Acting role |
| --- | --- | --- |
| **C**reate user | `register_student_page.dart` → `users.add` | Admin |
| **C**reate attendance | `mark_attendance_page.dart` → batched `attendance.set` per ticked student | Teacher |
| **C**reate activity | `activity_log_page.dart` → `activities.add` | Teacher |
| **C**reate announcement | `broadcast_page.dart` → `announcements.add` | Admin / Teacher |
| **R**ead profile | `child_profile_page.dart` → `users.doc(uid).get` | Parent |
| **R**ead attendance + calc | `child_profile_page.dart` → attendance stream + count | Parent |
| **R**ead all users | `user_management_page.dart` → `users.snapshots` | Admin |
| **R**ead activity feed | `activity_timeline_page.dart` → `activities.snapshots` | Parent |
| **U**pdate user | `user_management_page.dart` → `users.doc().update` | Admin |
| **U**pdate own profile | `edit_profile_page.dart` → `users.doc(uid).update` | Parent |
| **D**elete user | `user_management_page.dart` → `users.doc().delete` | Admin |

## 5. Sample Calculation

The Attendance Summary card on Child Profile computes:

```
present_days  = COUNT(DISTINCT date(timestamp))
                FROM attendance
                WHERE studentId = <user.student_id>
                  AND status    = 'Present'
                  AND timestamp >= today - 30 days

attendance_rate = (present_days / 30) * 100
absent_days     = 30 - present_days
```

Result rendered as three live stat tiles — Present, Absent, Rate.
