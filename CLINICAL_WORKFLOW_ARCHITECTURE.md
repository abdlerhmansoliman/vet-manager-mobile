# VetManager Mobile — Clinical Hierarchy & Workflow Architecture

> **Notice for Developers & AI Agents**:
> This document specifies the canonical architectural standard and UI/UX hierarchy for **VetManager Mobile**. Any future changes, features, or AI assistants modifying clinical features MUST strictly adhere to the contracts defined herein. Do not merge screens, flatten the hierarchy, or bypass any level.

---

## 1. The Real-World Clinical Hierarchy (`Patient -> Case -> Visit`)

Veterinary clinical workflow mirrors human medical records. An animal patient does not have a chaotic stream of unrelated visits; rather, medical care is strictly structured into three distinct relational levels:

```
Level 1: Patient Profile (المريض)
   │
   └── Level 2: Clinical Case (الحالة المرضية / مظلة المرض)
         │
         ├── Level 3: Visit 1 (Initial Consultation - الكشف المبدئي)
         │     ├── SOAP Physical Exam & Vitals
         │     ├── Diagnostic Media / Photos (X-Rays, Ultrasound, Cytology)
         │     ├── Medication Doses Administered
         │     └── Immutable Medical Addenda
         │
         ├── Level 3: Visit 2 (Follow-up Checkup - زيارة المتابعة)
         │     ├── Follow-up SOAP & Progress Vitals
         │     ├── Post-treatment Media (e.g. Suture site, cast removal)
         │     └── Treatment Plan Adjustments
         │
         └── Level 3: Visit N (Discharge & Final Checkup)
```

---

## 2. Screen Contracts & Strict Invariants

### 2.1 Screen 1: Patient Profile (`PatientDetailScreen`)
- **Location**: `lib/features/clients_patients/presentation/screens/patient_detail_screen.dart`
- **Purpose**: Represents the animal's permanent medical identity (Species, Breed, Age, Weight, Microchip, Owner contact, and High-Risk Allergies alert).
- **Content Contract**:
  - The Clinical Records section displays **ONLY `Clinical Cases`** for this patient (e.g., "Right Hindlimb Fracture", "Canine Parvovirus", "Allergic Dermatitis").
  - **STRICT PROHIBITION**: Zero visits, zero SOAP progress notes, and zero media galleries are allowed on the Patient Profile screen. Visits must never be listed on the patient level because multiple diseases would create an uninterpretable, dangerous clinical mess.
- **Primary Action**: Prominent **`"Create New Case"`** button (`_showStartCaseSheet`).
- **Edit Capabilities**: Animal profile details (name, breed, date of birth, weight, allergies JSON, microchip) and owner phone/contact are fully editable via `EditPatientScreen` / dialog (`PUT /api/v1/patients/{patient}`).

---

### 2.2 Screen 2: Case Detail Screen (`CaseDetailScreen`)
- **Location**: `lib/features/clinical_cases/presentation/screens/case_detail_screen.dart`
- **Purpose**: Represents the medical umbrella for one specific clinical condition or episode of illness.
- **Header Elements**:
  - Patient Hero Card (Name, species, breed, age, weight, owner phone).
  - Triage Priority Selector (`Routine`, `Urgent`, `Critical`).
  - Encounter Status Selector (`Open`, `In Progress`, `Under Observation`, `Closed`).
  - Chief Complaint Card with dedicated **"Edit"** button (`Key('edit_chief_complaint_button')` -> `_showEditChiefComplaintDialog`).
  - Diagnoses Card with dedicated **"Edit"** button (`Key('edit_diagnoses_button')` -> `_showEditDiagnosesDialog`).
- **Visits Section**:
  - Displays the chronological timeline of **`VisitCard`** widgets belonging strictly to this case.
  - **Streamlined Title-Focused Design**: Because a single case naturally holds multiple visits over time (e.g., Initial Consultation, Day 3 check, Day 7 cast removal), each visit is represented as a clean, sleek list tile showcasing the **Visit Title**, date, and status with a chevron arrow. No bulky preview clutter is shown on the case level.
  - Tapping **any** visit immediately opens that specific encounter's `VisitDetailScreen`.
  - **STRICT PROHIBITION**: **Zero Diagnostic Media galleries** on the Case Screen! Diagnostic imaging (radiographs, ultrasound, wound photos) does NOT belong to the general case umbrella; it belongs strictly inside the specific visit where the imaging was performed.
- **Primary Action**: Prominent **`"Start New Visit"`** button (opens `StartVisitSheet` to record follow-up encounters).
- **Edit Capabilities**:
  - Chief Complaint can be edited at any time (`PUT /api/v1/cases/{case}`).
  - Provisional & Final diagnoses can be refined as diagnostic results arrive (`PUT /api/v1/cases/{case}`).
  - Triage priority and case encounter status can be toggled in real time.

---

### 2.3 Screen 3: Visit Detail Screen (`VisitDetailScreen`)
- **Location**: `lib/features/clinical_cases/presentation/screens/visit_detail_screen.dart`
- **Purpose**: Represents the actual clinical examination in the exam room on a specific date and time with an attending clinician.
- **Content Contract** (This is the **EXCLUSIVE** home of clinical examination data):
  1. **Visit Header**: Title (e.g. "Initial Consultation", "Follow-up Visit"), Attending Veterinarian, Date & Time, and Status Badge (`OPEN` vs `SIGNED & LOCKED`).
  2. **SOAP Physical Examination (`SoapProgressCard`)**:
     - Subjective: Owner observations and history.
     - Objective: Clinical findings and vital signs (Temperature in °C, Heart Rate in bpm, Respiratory Rate, Body Condition Score 1-9, Pain Score 0-4).
     - Assessment: Clinical impression.
     - Plan: Diagnostic and therapeutic plan.
     - Action: **"Record SOAP Exam"** / "Update Exam Findings".
  3. **Diagnostic Media & Radiographs (`DiagnosticMediaGallery`)**:
     - Scoped to `imageableType: 'visit'`, `imageableId: visit.id`.
     - Direct binary streaming to **MinIO S3** using Presigned URLs (`PUT` stream with progress callback).
     - Action: **"Upload Media"** (Camera / Photo Library).
  4. **Administered Medications (`DoseAdministrationCard`)**:
     - Medication name, high-precision `Decimal` dosage, unit (mg, ml, etc.), route (IV, IM, SC, PO), waste tracking, and administering clinician.
     - Action: **"Administer Dose"**.
  5. **Immutable Medical Addenda (`ImmutableAddendumCard`)**:
     - Append-only legal progress notes added after an encounter is signed.
  6. **Legal Closing Action**:
     - **"Sign & Lock Visit Record"** (permanently locks the visit and its SOAP notes against retrospective tampering).
- **Edit Capabilities**:
  - Visit title, visit type, and reason for visit can be edited via the AppBar **"Edit Visit"** button (`_showEditVisitDialog`) as long as the visit is not signed & locked (`!visit.isLocked`) (`PUT /api/v1/visits/{visit}`).
  - Once signed, the record is legally frozen; amendments must be made via append-only medical addenda.

---

## 3. Real-World Clinical Workflows

### Scenario A: Brand New Medical Issue (الطريق الأول: مشكلة طبية جديدة)
1. Animal arrives at clinic with acute limping.
2. Vet navigates to `PatientDetailScreen` and taps **"Create New Case"**.
3. Vet fills in Chief Complaint: *"Right foreleg fracture after jump"*, Triage: *Urgent*.
4. **Automatic Background Process**:
   - SQLite atomic transaction inserts the new `ClinicalCase` row.
   - **Immediately and automatically**, the transaction inserts the first `Visit` attached to that case:
     - `title: 'Initial Consultation'`
     - `status: 'open'`
     - `visit_date: now()`
5. **Navigation Flow**:
   - The app navigates to `CaseDetailScreen`.
   - The vet immediately sees the case overview (patient info, chief complaint, triage priority) and the auto-created `Initial Consultation` visit displayed as a clean, compact `VisitCard` tile.
   - The vet can:
     - Tap the `Initial Consultation` visit tile to enter `VisitDetailScreen` (to record SOAP examination, upload diagnostic media, administer medications).
     - Or tap **"Start New Visit"** to schedule or record a separate follow-up or surgical encounter.
6. **Back Navigation**:
   - Tapping Back from `VisitDetailScreen` returns directly to `CaseDetailScreen`.
   - Tapping Back from `CaseDetailScreen` returns to `PatientDetailScreen`, where the newly opened Case is listed in the patient's medical history.
7. **Zero-Empty Resilience (DAO Self-Healing)**:
   - If any legacy or externally synced case in SQLite has 0 visits, `ClinicalCaseDao.getCaseDetailBundle` automatically initializes an `Initial Consultation` visit on-the-fly. Clinicians will **never** see an empty "No Visits Recorded Yet" state.

### Scenario B: Follow-up for the Same Issue (الطريق الثاني: زيارة متابعة)
1. Animal returns one week later for splint/cast removal.
2. Vet navigates to `PatientDetailScreen`.
3. **Vet does NOT create a new case.** Vet taps the existing case: *"Right foreleg fracture after jump"*.
4. `CaseDetailScreen` opens:
   - Displays the past `Initial Consultation` visit in the timeline.
   - Shows the top **`"Start New Visit"`** button.
5. Vet taps **"Start New Visit"**:
   - Sheet prompts for title (e.g. *"Follow-up & Cast Removal"*).
   - The follow-up visit is recorded and opens immediately.
6. Vet records follow-up exam, uploads healing X-Rays, and signs the record.

---

## 4. Local Database Relational Schema (Drift SQLite)

```sql
-- 1. Patients Table
CREATE TABLE patients (
    id TEXT PRIMARY KEY NOT NULL,
    tenant_id TEXT NOT NULL,
    client_id TEXT NOT NULL,
    name_or_tag TEXT NOT NULL,
    species TEXT NOT NULL,
    breed TEXT,
    date_of_birth DATETIME,
    current_weight_kg REAL,
    allergies TEXT, -- JSON array
    deleted_at DATETIME
);

-- 2. Clinical Cases Table (Medical Umbrella)
CREATE TABLE clinical_cases (
    id TEXT PRIMARY KEY NOT NULL,
    tenant_id TEXT NOT NULL,
    case_number TEXT NOT NULL,
    patient_id TEXT NOT NULL REFERENCES patients(id),
    primary_veterinarian_id TEXT NOT NULL,
    primary_veterinarian_name TEXT,
    case_type TEXT NOT NULL DEFAULT 'outpatient',
    status TEXT NOT NULL DEFAULT 'open',
    priority TEXT NOT NULL DEFAULT 'routine',
    chief_complaint TEXT NOT NULL,
    provisional_diagnosis TEXT,
    final_diagnosis TEXT,
    admitted_at DATETIME NOT NULL,
    discharged_at DATETIME,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    deleted_at DATETIME
);

-- 3. Visits Table (Clinical Encounters)
CREATE TABLE visits (
    id TEXT PRIMARY KEY NOT NULL,
    tenant_id TEXT NOT NULL,
    case_id TEXT NOT NULL REFERENCES clinical_cases(id),
    patient_id TEXT NOT NULL REFERENCES patients(id),
    veterinarian_id TEXT NOT NULL,
    veterinarian_name TEXT NOT NULL,
    title TEXT NOT NULL,
    visit_type TEXT NOT NULL DEFAULT 'consultation',
    status TEXT NOT NULL DEFAULT 'open', -- 'open' | 'completed' | 'cancelled'
    is_signed BOOLEAN NOT NULL DEFAULT FALSE,
    signed_at DATETIME,
    signed_by TEXT,
    visit_date DATETIME NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    deleted_at DATETIME
);

-- 4. Clinical Progress Notes (SOAP & Immutable Addenda)
CREATE TABLE clinical_progress_notes (
    id TEXT PRIMARY KEY NOT NULL,
    case_id TEXT NOT NULL REFERENCES clinical_cases(id),
    visit_id TEXT REFERENCES visits(id), -- Scoped to visit encounter
    patient_id TEXT NOT NULL,
    veterinarian_id TEXT NOT NULL,
    veterinarian_name TEXT NOT NULL,
    note_type TEXT NOT NULL, -- 'soap' | 'addendum'
    subjective TEXT,
    objective TEXT,
    assessment TEXT,
    plan TEXT,
    temperature_celsius REAL,
    heart_rate_bpm INTEGER,
    respiratory_rate_bpm INTEGER,
    body_condition_score INTEGER,
    pain_score INTEGER,
    recorded_at DATETIME NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);

-- 5. Dose Administrations Table (Decimal Precision Pharmacy Stock Usage)
CREATE TABLE dose_administrations (
    id TEXT PRIMARY KEY NOT NULL,
    tenant_id TEXT NOT NULL,
    visit_id TEXT NOT NULL REFERENCES visits(id),
    case_id TEXT NOT NULL REFERENCES clinical_cases(id),
    patient_id TEXT NOT NULL REFERENCES patients(id),
    medicine_name TEXT NOT NULL,
    dose_quantity TEXT NOT NULL, -- Stored as Decimal string (e.g. '2.5')
    unit TEXT NOT NULL,
    route TEXT NOT NULL,
    clinical_notes TEXT,
    veterinarian_id TEXT NOT NULL,
    veterinarian_name TEXT NOT NULL,
    administered_at DATETIME NOT NULL,
    created_at DATETIME NOT NULL
);

-- 6. Media Upload Queue Table (Offline-First MinIO S3 Queue)
CREATE TABLE media_upload_queue (
    id TEXT PRIMARY KEY NOT NULL,
    tenant_id TEXT NOT NULL,
    case_id TEXT,
    visit_id TEXT,
    patient_id TEXT,
    local_file_path TEXT NOT NULL,
    remote_url TEXT,
    mime_type TEXT DEFAULT 'image/webp',
    file_size_bytes INTEGER DEFAULT 0,
    checksum_sha256 TEXT,
    title TEXT,
    status TEXT NOT NULL DEFAULT 'uploading', -- 'uploading' | 'completed' | 'pending' | 'failed'
    error_message TEXT,
    uploaded_at DATETIME,
    created_at DATETIME NOT NULL
);
```

---

## 5. MinIO S3 Media Direct Upload Pipeline

```
Mobile Client (Flutter)               Laravel API Backend              MinIO S3 Bucket (vet-media)
      │                                       │                                     │
      ├── 1. Request Presigned URL ──────────>│                                     │
      │   POST /cases/{caseId}/media/         │                                     │
      │        presigned-url                  │                                     │
      │   (Authorized by Case ID)             │                                     │
      │                                       ├── 2. Generate S3 v4 Signature ─────>│
      │                                       │   Storage::disk('s3')               │
      │                                       │   ->temporaryUploadUrl()            │
      │<── 3. Return {upload_url, headers} ───┤                                     │
      │                                                                             │
      ├── 4. Direct HTTP PUT Binary Stream ────────────────────────────────────────>│
      │   Content-Type: image/webp                                                  │
      │   Stream with onSendProgress                                                │
      │<── 5. HTTP 200 OK ──────────────────────────────────────────────────────────┤
      │                                       │                                     │
      ├── 6. Confirm Upload ─────────────────>│                                     │
      │   POST /cases/{caseId}/media/confirm  │                                     │
      │                                       ├── 7. Insert Image Metadata in MySQL │
      │                                       │   (imageable_type = 'visits')       │
      │<── 8. Return Image Entity ────────────┤                                     │
```

- **Resilience Invariant**: If the mobile device is offline or the backend is temporarily unreachable, the photo is stored in local app storage and recorded in SQLite `media_upload_queue` with `status: 'pending'`. The background sync engine automatically retries presigned upload when network connectivity restores. Zero clinical photos are ever lost.

---

## 6. Testing & Quality Verification Rules

1. **Every clinical screen must have dedicated widget tests** verifying:
   - Correct navigation targets (`Patient -> Case -> Visit`).
   - Absence of duplicate or confusing action buttons.
   - Proper state transitions (In-Flight loading, Success snackbars, Friendly clinical error shielding).
2. **Never commit without running**:
   ```bash
   flutter analyze  # Must report: No issues found!
   flutter test     # All 270+ tests must pass!
   ```
