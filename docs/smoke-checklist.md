# Import Feature Smoke Test

- [ ] First-time permission request from home: approve access, use the destination picker to send three photos to a selected equipment/folder, verify placement.
- [ ] Denied permission path: decline, receive guidance, open settings, retry without restarting app.
- [ ] Equipment folder Before tab: choose Import to Before and ensure photos land only in that folder's Before gallery.
- [ ] Duplicate detection: import the same photo twice via the picker; second attempt warns and logs duplicate.
- [ ] Large batch (20 photos): progress indicator updates smoothly, completion <30s.
- [ ] Offline mode: disable network, import, confirm success and queued sync entries.
- [ ] Permission limited mode (iOS): select a subset, verify limited selection works and the Manage Selection shortcut appears.
- [ ] Failure handling: simulate storage-full, ensure clear error messaging and partial success summary on the progress sheet.
