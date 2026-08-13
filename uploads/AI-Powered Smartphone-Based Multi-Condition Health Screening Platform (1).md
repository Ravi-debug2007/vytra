# AI-Powered Smartphone-Based Multi-Condition Health Screening Platform  
## Optimized Technical Implementation Guide (v2.2)

| | |
|---|---|
| **Version** | 2.2 (Final Synchronized for SIH 2026) |
| **Owner** | Ravikiran Allampalli (MRCET) |
| **Project** | Smart India Hackathon (SIH) 2026 |
| **Document Type** | Streamlined Technical Build Guide for 6‑Person Team |

---

## 1. Architectural Overview & Efficiency Audit

Version 2.2 establishes a **Lean Architecture** optimized for a high-impact, bug-free demo within a 10-day build window (following a 4-day pitch and validation logistics phase). All non-essential modules (Skin/Teeth analysis) and complex RITnet conversions have been moved to the future roadmap. The architecture focuses strictly on **Face Mesh-based ROI extraction** and **CIELAB color analysis**.

The platform utilizes a **Local-First Architecture**. All diagnostic logic and data persistence occur on-device to ensure reliability in rural settings. A sync path to a FastAPI backend is defined for report generation and administrative monitoring.

---

## 2. Streamlined Tech Stack

| Layer | Technology | Justification |
|---|---|---|
| **Mobile Framework** | Flutter (Dart) | Single codebase, high-performance camera bindings. |
| **Vision** | Google ML Kit Face Mesh | 468-point tracking for precise conjunctiva/sclera isolation. |
| **Diagnostics** | CIELAB Color Analysis | Device-independent color space for biological pallor detection. |
| **Backend API** | FastAPI (Python) | Fast, asynchronous API for PDF reporting and sync. |
| **Storage** | SQLite (`sqflite`) | Robust local persistence for offline-first operation. |

---

## 3. Core Component Implementation

### 3.1 AR-Guided Capture & Quality Gating
The system enforces three real-time quality checks before enabling the capture button:
1. **Blur Detection:** Laplacian variance $\sigma^2 > 100$.
2. **Exposure Control:** Mean pixel intensity $\mu \in [40, 200]$.
3. **Occlusion Check:** Eye Aspect Ratio (EAR) $> 0.2$ via Face Mesh landmarks.

### 3.2 CIELAB Diagnostic Heuristics
The app extracts the lower eyelid (conjunctiva) and white of the eye (sclera) using Face Mesh indices. The ROIs are converted to CIELAB space to isolate biological biomarkers:
*   **Anemia ($a^*$ channel):** Measures redness, referenced from clinical literature [1]. Thresholds: High ($< 5$), Moderate ($[5, 10)$), Low ($\ge 10$).
*   **Jaundice ($b^*$ channel):** Measures yellowness, supported by contemporaneous prototype methodologies [2]. Thresholds: High ($\ge 15$), Moderate ($[10, 15)$), Low ($< 10$).

### 3.3 Color Calibration & Sensor Variance
Users capture a "White Reference" to calculate RGB gains, normalizing ambient lighting. 
> **Technical Note:** While white-patch calibration corrects for ambient light, cross-device sensor variance (e.g., Pixel vs. Xiaomi) is a known limitation. In a production environment, this would be mitigated through device-specific calibration profiles.

---

## 4. Simplified Storage & Sync
The demo focuses on **Local-First Storage** using SQLite (`sqflite`). 
*   **Local:** Every screening record is saved immediately to local storage.
*   **Sync Path:** A background process is designed to sync local records to a FastAPI/PostgreSQL backend when internet is available, but the core demo operates entirely offline for stability.

---

## 5. References
[1] Tamir, A., et al. (2017). *Detection of anemia from image of the anterior conjunctiva of the eye by image processing and thresholding*. IEEE Region 10 Symposium.  
[2] Skinopathy AI. (2026). *Smartphone-Based Ophthalmic Screening and Longitudinal Tracking Using Lightweight Computer Vision*. arXiv:2603.00161. *(Note: Cited as a contemporaneous prototype utilizing similar LAB-based methodology; non-peer-reviewed preprint).*
