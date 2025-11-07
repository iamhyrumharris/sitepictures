# Sitepictures Serverpod Backend

This directory contains the Serverpod backend for the Sitepictures Flutter application.

## Project Structure

```
sitepictures_server/
├── sitepictures_server_server/      # Backend server code
│   ├── lib/src/
│   │   ├── models/                  # Protocol definition files (*.yaml)
│   │   ├── generated/               # Auto-generated Dart code from protocols
│   │   └── endpoints/               # API endpoints (TODO)
│   ├── docker-compose.yaml          # PostgreSQL + Redis setup
│   └── migrations/                  # Database migrations
├── sitepictures_server_client/      # Generated Dart client library
│   └── lib/src/protocol/            # Client-side protocol classes
└── sitepictures_server_flutter/     # Sample Flutter app (not used)
```

## Data Models

The following models have been defined and generated:

- **User**: Authentication and user management
- **Company** (renamed from Client): Client/company management
- **MainSite**: Main site/location management
- **SubSite**: Sub-site with flexible hierarchy support
- **Equipment**: Equipment tracking with flexible placement
- **Photo**: Photo metadata with sync status
- **PhotoFolder**: Photo folder organization
- **FolderPhoto**: Junction table for folder-photo relationships
- **SyncQueueItem**: Offline sync queue management
- **ImportBatch**: Gallery import tracking

## Key Design Decisions

### ID Strategy
- **Database IDs**: Auto-increment `int?` for Serverpod database operations
- **UUID Fields**: Separate `uuid: String` field on all models for compatibility with the existing Flutter app's SQLite schema
- This dual-ID approach allows seamless integration while maintaining Serverpod best practices

### Model Changes from Flutter App
- **Client → Company**: Renamed to avoid Serverpod reserved name conflict
- **Index Naming**: All indexes prefixed with model name to avoid global conflicts (e.g., `user_email_idx`, `photo_uuid_idx`)

## Getting Started

### Prerequisites
- Docker and Docker Compose
- Dart SDK 3.8+
- Serverpod CLI (`dart pub global activate serverpod_cli`)

### Start the Development Environment

1. **Start Docker services** (PostgreSQL + Redis):
   ```bash
   cd sitepictures_server/sitepictures_server_server
   docker compose up --build --detach
   ```

2. **Apply database migrations**:
   ```bash
   dart bin/main.dart --apply-migrations
   ```

3. **Start the server**:
   ```bash
   dart bin/main.dart
   ```

The server will be available at `http://localhost:8080`

### Generate Code

After modifying protocol files in `lib/src/models/`:

```bash
cd sitepictures_server/sitepictures_server_server
serverpod generate
```

## Database Configuration

- **Development Database**:
  - Host: localhost
  - Port: 8090
  - Database: sitepictures_server
  - User: postgres
  - Password: (see docker-compose.yaml)

- **Test Database**:
  - Host: localhost
  - Port: 9090
  - Database: sitepictures_server_test

- **Redis**:
  - Port: 8091 (dev), 9091 (test)

## Next Steps

The following tasks remain to complete the backend integration:

1. ✅ Install Serverpod CLI and create project
2. ✅ Define all protocol files
3. ✅ Generate server and client code
4. ⏳ Implement authentication endpoint
5. ⏳ Implement CRUD endpoints (Company, Site, Equipment, Folder)
6. ⏳ Implement photo upload endpoint with Serverpod file storage
7. ⏳ Implement sync endpoint with conflict resolution
8. ⏳ Update Flutter app to use Serverpod client
9. ⏳ Create database migrations
10. ⏳ Testing and deployment

## File Storage

Photo files will be stored using Serverpod's built-in file storage system in the `server/files/` directory. This can be upgraded to cloud storage (S3, etc.) in the future without code changes.

## Documentation

- [Serverpod Documentation](https://docs.serverpod.dev/)
- [Protocol Files](https://docs.serverpod.dev/concepts/protocols)
- [Endpoints](https://docs.serverpod.dev/concepts/endpoints)
