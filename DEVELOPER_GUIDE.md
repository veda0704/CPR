# Developer Guide: ACLS Simulation Suite

This document provides a technical overview of the ACLS Simulation Suite, designed for training 108 emergency services personnel.

## 1. System Architecture

The application follows a distributed architecture consisting of three main components:

- **Backend (Django/DRF)**: The "Source of Truth" for all clinical workflows, translations, and media routing.
- **Web Frontend (React)**: A visual-first training interface for desktop/tablet use.
- **Mobile App (Flutter)**: A portable, offline-capable version for responders in the field.

---

## 2. Dynamic Workflow Engine

Workflows are defined in a **declarative format** within `acls-backend/acls/workflows/`. Each module is a Python dictionary containing step definitions.

### Step structure:
```python
"step_id": {
    "title": _("Human Readable Title"),
    "question": _("Instructions or question for the user"),
    "video": "/static/videos/filename.mp4",        # Optional video/image
    "interactive_component": "ecg_monitor",       # Optional specialized UI
    "interactive_props": {"rhythms": ["vfib"]},  # Component data
    "choices": [                                  # Navigation options
        {"label": _("YES"), "next": "next_step_id", "color": "primary"},
        {"label": _("NO"), "next": "fail_step_id", "color": "danger"}
    ]
}
```

**Key Files:**
- `bls.py`: Basic Life Support logic.
- `acls_sim.py`: Advanced Cardiac simulator with 2-minute loops.
- `scene_safety.py`: EMS-specific safety protocols.

---

## 3. Localization & Translation Pipeline

The app uses a **Hybrid Localization Model** to support English and Telugu parity.

### Backend Translation Service (`translation_service.py`):
1. **Hardcoded Mappings**: Critical UI labels are stored in `TELUGU_MAPPINGS`.
2. **Dynamic JSON Lookup**: The engine loads `po_translations.json` which contains thousands of clinical strings translated via the deep-learning pipeline.
3. **Recursive Translation**: The `translate_dict` utility automatically traverses API payloads and localizes every user-facing string before it leaves the server.

### Maintenance Tools:
- `extract_all_strings.py`: Scans all workflow files for `_("...")` markers.
- `translate_missing_v2.py`: Automatically translates new strings and updates the master JSON database.

---

## 4. Multi-Platform Synchronization

The **Bulk Sync System** allows the mobile app to work efficiently:
- **Endpoint**: `/api/acls/sync-all/`
- **Function**: Bundles every single workflow, translation key, and metadata field into a single atomic JSON payload.
- **Offline Cache**: The Flutter app stores this payload locally, allowing responders to practice even in areas with no internet.

---

## 5. Media & TTS Service

- **Streaming**: The `stream_video` view handles partial content (HTTP Range) requests, ensuring smooth video playback on mobile devices with low memory.
- **TTS Engine**: The `TTSService` generates bilingual audio guidance (English instruction followed by Telugu translation) on-the-fly and caches them for performance.

---

## 6. Frontend Integration (Web & Mobile)

### Language Detection:
The frontend must send the `Accept-Language` header (e.g., `te` for Telugu).
- **Web**: Managed via `localStorage.getItem('i18nextLng')`.
- **Mobile**: Scoped via `languageProvider` (Riverpod) and passed to API requests via the Dio interceptor.

### Interactive Components:
Specialized widgets are mapped to backend identifiers:
- `ecg_monitor`: Renders real-time animated heart rhythms.
- `choice_cards`: Uses images to represent patient types (Adult vs. Infant).

---

## 7. Build Commands

### Backend:
```bash
python manage.py runserver 0.0.0.0:8002
```

### Web:
```bash
npm run dev
npm run build
```

### Mobile:
```bash
flutter build apk --release
```

---

## 8. Directory Structure Notes
- `/acls-backend/acls/`: Core logic and API views.
- `/acls-backend/static/`: Videos, SVG icons, and TTS cache.
- `/acls_mobile/lib/`: Flutter logic (Clean Architecture).
- `/acls-frontend/src/`: React components and hooks.
