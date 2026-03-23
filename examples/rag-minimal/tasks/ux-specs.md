# tasks/ux-specs.md -- DocAsk

## Purpose

UX writes interaction specs here. Junior Dev builds exactly to these specs.
Cleared at end of sprint after tasks are archived.

---

## Session 1 — File Upload UI

### Upload Zone Component

- Large drag-and-drop area (min-height 200px), centered on the page
- Idle state: dashed border, upload icon, text "Drag a PDF or Word document here, or click to browse"
- Drag-over state: solid border (brand colour), background tint, text changes to "Drop to upload"
- Accepted types shown below zone: "PDF and DOCX only · Max 10 MB"
- File picker opens on click (accept=".pdf,.docx")

### Upload Progress State

- On file selection: zone is replaced by a progress bar with filename and file size
- Progress bar animates from 0% to 100% as the upload completes
- Cancel button visible during upload (cancels the request, resets to idle state)

### Post-Upload State

- On success: document appears immediately in the Document List below with status badge `uploaded`
- Upload zone resets to idle — user can upload another document
- On error (type not allowed): inline red text below zone — "Only PDF and DOCX files are accepted"
- On error (file too large): "This file exceeds the 10 MB limit"
- On error (network/API): "Upload failed — please try again"
- Errors do not leave the zone in a broken or spinner state

### Document List

- Table below the upload zone: Filename | Status | Uploaded at | Actions
- Status rendered as colour-coded badge: uploaded (grey), processing (amber), ready (green), failed (red)
- Empty state: "No documents yet — upload your first file above"
- List auto-refreshes every 5 seconds to pick up status changes (processing → ready)

### Mobile (375px)

- Upload zone fills full width with 12px padding
- Progress bar stacks below filename (no side-by-side layout)
- Document list switches to card layout (one card per document, stacked vertically)

## Accessibility Notes

- Drag-and-drop zone has keyboard focus and can be activated with Enter/Space
- Status badges have text labels (not colour-only indicators)
- Upload errors announced via aria-live region
