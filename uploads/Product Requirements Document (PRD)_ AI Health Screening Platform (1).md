# Product Requirements Document (PRD): AI Health Screening Platform
## Version 1.4 – Final Synchronized Version for SIH 2026

| | |
|---|---|
| **Version** | 1.4 |
| **Status** | **Ready for Submission** |
| **Owner** | Ravikiran Allampalli (MRCET) |
| **Project** | Smart India Hackathon (SIH) 2026 |
| **Document Type** | Comprehensive PRD for 6-Person Team |

---

## 1. Executive Summary
This platform is an AI-powered smartphone application designed for non-invasive health screening. By analyzing the **palpebral conjunctiva** (inner eyelid) and the **sclera** (white of the eye), the app screens for **anemia** and **jaundice** risks. The system leverages **MediaPipe Face Mesh** for precise AR guidance and CIELAB color analysis for diagnostic heuristics. Designed for rural use, the app operates on a "local-first" principle with an optional sync path to a FastAPI backend.

---

## 2. Problem Statement
In low-resource settings, screening for anemia and jaundice is hindered by the need for invasive blood tests and lab infrastructure. This project provides a low-cost, smartphone-based alternative that enables early detection and nudges users toward professional medical consultation.

---

## 3. Success Metrics & Validation Plan
*   **Validation Study (Volunteer-Based):** The team shall recruit **15–20 volunteers** to establish a correlation baseline. Informed consent will be collected prior to participation, and all volunteer health data will be strictly anonymized and securely deleted immediately following the study.
*   **Proxy Limitations:** Pulse oximetry was used as an accessible proxy given hackathon constraints (measuring blood oxygen saturation rather than direct hemoglobin concentration, thus primarily flagging severe cases); clinic hemoglobin/bilirubin records were utilized where available.
*   **Technical Accuracy:** Target >85% correlation with CIELAB $a^*$ and $b^*$ thresholds derived from peer-reviewed literature [1] and supported by contemporaneous prototype methodologies [2].
*   **Performance:** AR guidance and quality gating must run at **>20 FPS** on mid-range Android devices.
*   **Clinical Safety:** 100% display rate for medical disclaimers on all result screens.

---

## 4. Functional Requirements

### 4.1 AR-Guided Capture & Quality Gating
*   **FR-1.1: Face Mesh Tracking.** Use `google_mlkit_face_mesh_detection` to monitor eye indices (Left: 33, 133, 159, 145; Right: 362, 263, 386, 374) for precise region-of-interest (ROI) extraction.
*   **FR-1.2: Real-time Quality Gate.** The capture button is disabled unless:
    *   **Blur Detection:** Laplacian variance > 100.
    *   **Exposure:** Mean pixel intensity between 40 and 200.
    *   **Occlusion:** Eye Aspect Ratio (EAR) > 0.2 (eyes open).
*   **FR-1.3: Calibration & Sensor Variance.** Requires a separate "White Reference" photo to normalize ambient lighting via white-patch gains. 
    *   *Note:* While white-patch gain corrects for ambient light, cross-device sensor variance (e.g., Pixel vs. Xiaomi) is a known limitation that would be addressed with device-specific calibration profiles in a production version.

### 4.2 AI Analysis & Heuristics
*   **FR-2.1: Anemia Screening.** Analyze the lower palpebral conjunctiva area. Convert to CIELAB color space and classify risk based on **a* (redness)** [1]:
    *   High Risk: $a^* < 5$
    *   Moderate Risk: $5 \le a^* < 10$
    *   Low Risk: $a^* \ge 10$
*   **FR-2.2: Jaundice Screening.** Analyze the scleral region in CIELAB color space, focusing on the **b* (yellowness)**, drawing supporting context from contemporaneous prototype methodologies [2]:
    *   High Risk: $b^* \ge 15$
    *   Moderate Risk: $10 \le b^* < 15$
    *   Low Risk: $b^* < 10$

### 4.3 Backend & Reporting
*   **FR-3.1: Local-First Storage.** All screenings are saved immediately to a local `sqflite` database. 
*   **FR-3.2: Cloud Sync Path.** The system architecture supports a sync path to a FastAPI backend for centralized monitoring, though the demo focuses on stable local operation.
*   **FR-3.3: PDF Report Generation.** Generate a shareable PDF including date, risk levels, and a mandatory medical disclaimer.

---

## 5. Technical Stack
| Layer | Technology |
|---|---|
| **Mobile** | Flutter (Dart) |
| **Vision** | Google ML Kit Face Mesh |
| **Backend** | FastAPI (Python) |
| **Database** | SQLite (Local) + PostgreSQL (Cloud Sync Path) |

---

## 6. Phased Implementation Roadmap (14 Days)

### Phase 1: Pitch, Design & Validation Logistics (Days 1–4)
*   **Focus:** Pitch Deck, UI Wireframes, and early volunteer recruitment logistics (consent forms, scheduling).

### Phase 2: Core Build & Validation (Days 5–14)
*   **Focus:** AR Capture, Quality Gating, CIELAB Heuristics, and Volunteer Study execution.
*   **Deliverable:** Validated APK, Demo Video, and Technical Documentation.

---

## 7. Future Roadmap (Out of Scope for v1)
*   **Experimental Modules:** Skin lesion analysis (EfficientNet) and Teeth wellness (YOLOv8).
*   **Advanced Segmentation:** RITnet-based sclera segmentation for improved jaundice accuracy.
*   **Device Profiles:** Custom calibration for specific smartphone camera sensors.

---

## 8. References
[1] Tamir, A., et al. (2017). *Detection of anemia from image of the anterior conjunctiva of the eye by image processing and thresholding*. IEEE Region 10 Symposium.  
[2] Skinopathy AI. (2026). *Smartphone-Based Ophthalmic Screening and Longitudinal Tracking Using Lightweight Computer Vision*. arXiv:2603.00161. *(Note: Cited as a contemporaneous prototype utilizing similar LAB-based methodology; non-peer-reviewed preprint).*
