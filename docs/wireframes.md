# KindiSync — Low-Fidelity Wireframes

These four wireframes cover the rubric's four roles of a User Page (Info,
Input, Calculation, Display Result) plus the Admin CRUD page. Numbered
annotations explain the purpose and function of each element.

---

## Wireframe 1 — Login Page

```
+--------------------------------------+
|                                      |
|                                      |
|              [child_care]            |  (1)
|                                      |
|             K I N D I S Y N C        |  (2)
|                                      |
|  +--------------------------------+  |
|  | [@] Email                      |  |  (3)
|  +--------------------------------+  |
|                                      |
|  +--------------------------------+  |
|  | [#] Password                   |  |  (4)
|  +--------------------------------+  |
|                                      |
|                  Forgot Password? -> |  (5)
|                                      |
|  +--------------------------------+  |
|  |            L O G I N           |  |  (6)
|  +--------------------------------+  |
|                                      |
+--------------------------------------+
```

### Annotations

1. **App icon** — `Icons.child_care` in teal; brand recognition + visual
   anchor for the screen.
2. **App title** — "KindiSync" 32 px bold; confirms the user is on the
   correct app before logging in.
3. **Email field** — `TextField` with email icon. Acts as the *username*
   half of the rubric's "username and password" requirement.
4. **Password field** — `obscureText: true`. The *password* half. Both
   fields are required before the Login button does anything.
5. **Forgot Password link** — secondary navigation to
   `forgot_password.dart`. Right-aligned so it doesn't compete with the
   primary CTA.
6. **Login button** — full-width 48 dp tap target (meets accessibility
   guidelines). Routes to Parent / Teacher / Admin dashboard based on
   credentials.

**Role in user flow:** Entry point for *all three* roles. Every other
screen below sits behind this one.

---

## Wireframe 2 — Parent Dashboard  *(User page — navigation hub)*

```
+--------------------------------------+
|  Parent Dashboard      [bell] [out]  |  (1)
+--------------------------------------+
|                                      |
|  Main Menu                           |  (2)
|                                      |
|  +-----------------+  +------------+ |
|  | [face] Child    |  | [time]     | |  (3a)(3b)
|  |        Profile  |  |  Activity  | |
|  +-----------------+  +------------+ |
|                                      |
|  +-----------------+  +------------+ |
|  | [cal]           |  | [cog]      | |  (3c)(3d)
|  |  Attendance     |  |  Settings  | |
|  +-----------------+  +------------+ |
|                                      |
|                                      |
+--------------------------------------+
```

### Annotations

1. **AppBar** — title left, **bell icon** (notifications) + **logout icon**
   right. Logout is always reachable from the dashboard.
2. **Section header** — "Main Menu" anchors the grid below.
3. **Grid of action cards** — `GridView.count(crossAxisCount: 2)`. Wide
   horizontal cards keep targets thumb-reachable.
   - **3a — Child Profile** opens the Info + Calculation screen (Wireframe 4).
   - **3b — Activity** opens the timeline of teacher-logged activities.
   - **3c — Attendance** opens the parent's read-only attendance log.
   - **3d — Settings** opens Edit Profile, Notification Settings, Logout.

**Role in user flow:** First screen the Parent sees after login. Every
parent-facing feature is at most one tap away from here.

---

## Wireframe 3 — Mark Attendance  *(Input Data screen — Teacher)*

```
+--------------------------------------+
|  < Mark Attendance                   |  (1)
+--------------------------------------+
|  Today                               |  (2)
|  Wednesday, 21 May 2026              |
+--------------------------------------+
|  6 student(s)        Present: 4      |  (3)
+--------------------------------------+
|  +--------------------------------+  |
|  | [@] Aisyah  • Class A   [v] X  |  |  (4)
|  |     Class: A   ID: S001        |  |
|  +--------------------------------+  |
|  +--------------------------------+  |
|  | [@] Bilal   • Class A   [ ]    |  |
|  |     Class: A   ID: S002        |  |
|  +--------------------------------+  |
|  +--------------------------------+  |
|  | [@] Citra   • Class A   [v] X  |  |
|  |     Class: A   ID: S003        |  |
|  +--------------------------------+  |
|  +--------------------------------+  |
|  | [@] Danish  • Class B   [v] X  |  |
|  +--------------------------------+  |
|                                      |
|  +--------------------------------+  |
|  | [check]   Save Attendance      |  |  (5)
|  +--------------------------------+  |
+--------------------------------------+
```

### Annotations

1. **AppBar with back arrow** — Material's default back navigation;
   returns to Teacher Dashboard without confirmation (no destructive state).
2. **Today banner** — teal background, two-line date display. Shows the
   teacher *which day* the ticks will be saved under (matches the
   `date` field written to Firestore).
3. **Live count header** — `N student(s)` left, **Present: X** right
   (bold teal). Updates every time a checkbox toggles.
4. **Student row** — `CheckboxListTile` with:
   - left avatar (turns green when ticked, grey when not)
   - student name (bold) + class + student_id
   - trailing checkbox
   The whole row is tappable, not just the box.
5. **Save button** — full-width 50 dp, teal. On tap: batched write of
   one `attendance` document per ticked student (deterministic doc id =
   `{studentId}_{date}`) **and** delete docs for unticked students.
   After save, the snackbar confirms and the ticks stay in place.

**Role in user flow:** This is the *Input data* screen of the rubric.
Every tick + Save here is what the Parent's Calculation screen
(Wireframe 4) reads from.

---

## Wireframe 4 — Child Profile  *(Info + Calculation + Display Result)*

```
+--------------------------------------+
|  < Child Profile                     |  (1)
+--------------------------------------+
|                                      |
|              .--------.              |  (2)
|             |          |             |
|             |  [photo] |             |
|             |          |             |
|              `--------'              |
|                                      |
|  +--------------------------------+  |
|  | Full Name                      |  |  (3a)
|  | Aisyah binti Ali               |  |
|  +--------------------------------+  |
|  +--------------------------------+  |
|  | Age                            |  |  (3b)
|  | 5 Years Old                    |  |
|  +--------------------------------+  |
|  +--------------------------------+  |
|  | Class                          |  |  (3c)
|  | Class A                        |  |
|  +--------------------------------+  |
|  +--------------------------------+  |
|  | Assigned Teacher               |  |  (3d)
|  | Teacher Bunga                  |  |
|  +--------------------------------+  |
|                                      |
|  +--------------------------------+  |
|  | Attendance Summary (Last 30 d) |  |  (4)
|  |                                |  |
|  |    18         12       60.0%   |  |  (5)
|  |  Present    Absent     Rate    |  |
|  +--------------------------------+  |
+--------------------------------------+
```

### Annotations

1. **AppBar with back arrow** — returns to Parent Dashboard.
2. **Profile photo** — `CircleAvatar` 60 px radius; reads
   `profileImageUrl` from Firestore. Falls back to a person icon if none.
3. **Info cards** — four read-only `ListTile` cards. This is the
   "Info page" half of the rubric.
   - 3a Full name, 3b Age, 3c Class, 3d Assigned teacher.
4. **Attendance Summary card** — the calculation surface. Title row says
   *Last 30 Days* to make the window explicit.
5. **Three live stat tiles** — the *Display Result*:
   - **Present** (green) — `COUNT(DISTINCT date)` from `attendance`
     where `status == 'Present'` and `timestamp >= today - 30 days`.
   - **Absent** (red) — `30 - present`.
   - **Rate** (purple) — `(present / 30) * 100`, formatted to 1 d.p.
   The tiles re-render automatically when the teacher saves on
   Wireframe 3, because both share the same `attendance` collection.

**Role in user flow:** Closes the Input → Calculation → Display Result
loop the rubric asks for. Same data the teacher writes is consumed and
displayed here for the parent.

---

## How these four wireframes satisfy the rubric

| Rubric requirement | Covered by |
| --- | --- |
| Info page | Wireframe 4 (cards 3a–3d) |
| Input data | Wireframe 3 (tick + Save) |
| Calculation | Wireframe 4 (card 4–5) |
| Display result | Wireframe 4 (stat tiles 5) |
| Admin Login | Wireframe 1 (same login screen, admin credentials) |
| Admin View / Update / Delete | User Management page — Edit & Delete icons per row, dialog overlays |
| Admin Logout | AppBar logout icon on every dashboard |
| Navigation | Back-arrow + Logout consistent across screens |
| Responsive | All screens use scrollable bodies; cards expand to width |
