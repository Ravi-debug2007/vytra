# Strategic Implementation Roadmap: AI Health Screening Platform (SIH 2026)

This roadmap outlines a **14-day execution strategy** for a six-member team to build a validated health screening application. The plan emphasizes a lean, "Local-First" architecture and early validation logistics to ensure a stable, credible demo for the Smart India Hackathon 2026.

## Team Organization and Roles

The team is divided into two specialized groups to ensure parallel progress across technical implementation and operational excellence.

| Role | Designation | Primary Focus |
| :--- | :--- | :--- |
| **Tech 1** | Technical Lead | Flutter UI, Camera Streams, and Face Mesh Integration. |
| **Tech 2** | ML & Logic | CIELAB Heuristics, Image Processing, and Local Database. |
| **Tech 3** | Backend & Data | FastAPI Server, PDF Reporting, and Cloud Sync Path. |
| **Non-Tech 1** | Design & QA | UI/UX Assets, Wireframing, and Quality Assurance Testing. |
| **Non-Tech 2** | Strategy & Docs | Pitch Deck, Technical Documentation, and Future Roadmap. |
| **Non-Tech 3** | Media & Data | Volunteer Recruitment Logistics, Validation Study, and Demo Video. |

---

## Phase I: Vision, Design, and Validation Logistics (Days 1–4)

The initial phase focuses on establishing a "Single Source of Truth" through the refined PRD and technical blueprint. Beyond pitch preparation, this phase initiates critical logistical groundwork for the validation study.

### Strategic Foundation and Pitch Development
During the first two days, the Operational Group will conduct market research to solidify the problem statement, while the Technical Group will set up a standardized development environment. 

### Early Validation Logistics
To de-risk the Day 12 crunch, **volunteer recruitment logistics begin here in Days 1–4**. Non-Tech 3 will draft informed consent forms, establish data privacy protocols (ensuring volunteer health data is anonymized and scheduled for deletion post-study), and schedule volunteer slots. This ensures that when testing occurs, the team is executing data capture rather than handling initial paperwork.

---

## Phase II: Lean Technical Build and Validation (Days 5–14)

The build phase is a 10-day intensive cycle focused on a lean architecture. The team will prioritize a rock-solid core screening experience over secondary experimental features.

### Implementation Schedule

| Day | Technical Milestone | Operational Milestone | Key Deliverable |
| :--- | :--- | :--- | :--- |
| **5** | Project Scaffold & Local DB Setup. | User Manual Draft & Asset List. | Working App Framework. |
| **6** | Quality Gate (Blur/Exposure/EAR) Logic. | Collection of "Failure Case" Datasets. | Functional Quality Gating. |
| **7** | Face Mesh ROI Extraction. | Final UI Asset Handoff. | Precision Cropping Logic. |
| **8** | White Reference Calibration Logic. | Demo Video Scripting. | Calibrated Image Output. |
| **9** | CIELAB Heuristic Integration ($a^*$ and $b^*$). | Risk Communication Documentation. | Diagnostic Results Logic. |
| **10** | System Integration & Local History. | End-to-End User Testing. | Full-Stack Local Prototype. |
| **11** | PDF Reporting & Share Logic. | Demo Video Screen Recording. | Feature-Complete APK. |
| **12** | Cloud Sync Path & Admin View. | **Execute Volunteer Study (n=20)** using pre-scheduled logistics. | Validated Data Report. |
| **13** | Bug Squashing & Optimization. | Final Video Production. | Stable Release Candidate. |
| **14** | Final Review & Packaging. | Submission Bundle Finalization. | **Final Submission Package.** |

---

## Core Execution Strategies

1.  **Lean Architecture:** By focusing exclusively on **Face Mesh-based ROI extraction** and **CIELAB heuristics**, the team avoids the high failure risk of complex ML model conversions during a hackathon.
2.  **De-risked Validation:** By moving volunteer recruitment logistics into Days 1–4, Day 12 is dedicated purely to executing pre-scheduled data capture under strict informed consent and privacy protocols.
3.  **Local-First Resilience:** The app is engineered to work entirely offline, with cloud sync treated as a background enhancement. This ensures the demo never fails due to venue Wi-Fi issues.
4.  **Expert Defense:** The team will be equipped with a **Technical Defense Guide** to handle advanced questions about camera sensor variance and framework choices with professional transparency.
