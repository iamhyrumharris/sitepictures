<!--
Sync Impact Report
Version change: 1.0.0 → 1.0.1
Modified principles: None
Added sections: None
Removed sections: None
Templates requiring updates:
✅ .specify/memory/constitution.md (completed - installed from user-provided constitution)
✅ .specify/templates/plan-template.md (reviewed - already aligned with constitution check section)
✅ .specify/templates/spec-template.md (reviewed - already aligned with user scenarios and requirements)
✅ .specify/templates/tasks-template.md (reviewed - already aligned with phased task organization)
Follow-up TODOs: None
Rationale: PATCH version bump (1.0.0 → 1.0.1) - Constitution content installed into proper template location with no semantic changes. Project name remains "sitepictures" (official app name: FieldPhoto Pro).
-->

# FieldPhoto Pro Constitution

## Core Principles

### I. Field-First Architecture
Every feature MUST prioritize field worker efficiency over administrative convenience. The app is designed for industrial technicians working in challenging environments with limited connectivity and time constraints. All design decisions must optimize for:
- Quick photo capture and minimal friction workflows
- Offline-first functionality with seamless sync
- One-handed operation capability
- Clear visual hierarchy optimized for mobile screens
- Battery life preservation through efficient resource usage

*Rationale: Field workers operate under time pressure in environments where every second counts. The app must adapt to their workflow, not the reverse.*

### II. Offline Autonomy
The application MUST function completely offline with full feature parity. No feature shall require internet connectivity for core functionality. All data must be:
- Stored locally using SQLite or equivalent embedded database
- Accessible and modifiable without network connection
- Synchronized intelligently when connectivity returns
- Conflict-resolved through user choice rather than automatic overwriting

*Rationale: Industrial sites often have poor or no cellular coverage. Workers cannot be dependent on internet connectivity to perform their duties.*

### III. Data Integrity Above All
No photo or annotation shall ever be lost due to technical failure. The system must implement:
- Automatic local backups before any destructive operation
- Immutable photo storage (originals never modified)
- Transaction-based operations for all data modifications
- Comprehensive error logging and recovery mechanisms
- Multiple conflict resolution strategies that preserve all data

*Rationale: Photos represent critical documentation for safety, compliance, and liability purposes. Data loss is never acceptable.*

### IV. Hierarchical Consistency
The four-level folder structure MUST be enforced consistently across all features. All functionality must respect the hierarchy:
- Client → Main Site → Sub Site → Equipment/Panel
- Navigation must maintain consistent breadcrumb patterns
- Search results must show full hierarchical context
- Permissions and organization follow hierarchy boundaries
- Data export preserves hierarchical relationships

*Rationale: The folder structure mirrors real-world industrial organization and enables consistent mental models for users.*

### V. Privacy and Security by Design
All data handling MUST assume operation in sensitive industrial environments. Security requirements:
- No telemetry or analytics without explicit opt-in
- Self-hosted deployment options mandatory
- Company data isolation enforced at database level
- GPS coordinates stored with user consent only
- Photo metadata scrubbed before external sharing

*Rationale: Industrial sites may involve proprietary processes, security-sensitive locations, or regulated environments requiring strict data control.*

### VI. Performance Primacy
Application responsiveness MUST never degrade below field-usable thresholds. Performance standards:
- Photo capture: < 2 seconds from launch to save
- Navigation: < 500ms between screens
- Search: < 1 second for results display
- Sync: Background processing that never blocks UI
- Battery usage: < 5% drain per hour of active use

*Rationale: Slow software creates safety risks and reduces productivity in time-critical industrial environments.*

### VII. Intuitive Simplicity
Every interaction MUST be learnable within 30 seconds of first encounter. User experience principles:
- No feature requires training or documentation to use
- Visual cues clearly indicate all available actions
- Error messages provide actionable recovery steps
- Consistent interaction patterns across all screens
- Graceful degradation when features are unavailable

*Rationale: Field workers may use the app infrequently and cannot be expected to remember complex procedures.*

### VIII. Modular Independence
Each major feature MUST be implementable as a standalone, testable module. Architecture requirements:
- Camera functionality independent of organization system
- GPS services separable from photo management
- Sync engine isolated from local storage
- Search functionality decoupled from hierarchy navigation
- Each module testable in isolation

*Rationale: Modular design enables targeted testing, easier maintenance, and reduced complexity in debugging field issues.*

### IX. Collaborative Transparency
All team collaboration features MUST maintain clear audit trails and attribution. Collaboration standards:
- Every photo edit traceable to specific user and timestamp
- Conflict resolution maintains record of all versions
- Team member actions logged for accountability
- Data ownership clearly defined and transferable
- Export capabilities preserve collaboration metadata

*Rationale: Industrial documentation often requires legal traceability and accountability for compliance and liability purposes.*

## Constitutional Enforcement

### Violation Protocol
When any proposed feature or implementation conflicts with constitutional principles:

**Immediate Halt**: Stop development of conflicting feature
**Root Cause Analysis**: Identify why the conflict exists
**Constitutional Review**: Determine if principle applies or requires clarification
**Resolution Path**: Either modify implementation or formally amend constitution
**Documentation**: Record decision rationale for future reference

### Implementation Guidelines
Every development phase must include:
- **Constitutional Compliance Check**: Verify alignment with all nine articles
- **Field Impact Assessment**: Evaluate effect on primary user workflow
- **Offline Functionality Test**: Confirm feature works without connectivity
- **Performance Validation**: Measure against established thresholds
- **Security Review**: Assess data handling and privacy implications

## Success Metrics

The constitution succeeds when:
- Field workers adopt the app voluntarily without mandate
- Zero critical data loss incidents reported
- Application performance remains within constitutional thresholds
- Feature requests align with constitutional principles
- New team members implement compliant features without additional guidance

## Governance

### Amendment Process
Constitutional amendments require:
- Clear articulation of why existing principle is insufficient
- Evidence that proposed change serves field worker interests
- Review of impact on existing implementations
- Unanimous agreement from all active project stakeholders
- Update of all affected documentation and templates

### Versioning Policy
Constitution versioning follows semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Backward incompatible governance/principle removals or redefinitions
- **MINOR**: New principle/section added or materially expanded guidance
- **PATCH**: Clarifications, wording, typo fixes, non-semantic refinements

### Compliance Review
- All PRs/reviews must verify constitutional compliance
- Complex features require explicit constitutional justification
- Deviations must be documented and approved through amendment process

This constitution serves as the immutable foundation for all technical and product decisions. When in doubt, optimize for the field worker using the app in challenging conditions with critical documentation needs.

**Version**: 1.0.1 | **Ratified**: 2025-09-28 | **Last Amended**: 2025-10-11
