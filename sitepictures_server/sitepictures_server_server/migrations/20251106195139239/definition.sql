BEGIN;

--
-- Class Company as table clients
--
CREATE TABLE "clients" (
    "id" bigserial PRIMARY KEY,
    "uuid" text NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "isSystem" boolean NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "isActive" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "uuid_idx" ON "clients" USING btree ("uuid");
CREATE UNIQUE INDEX "name_idx" ON "clients" USING btree ("name");
CREATE INDEX "company_system_active_idx" ON "clients" USING btree ("isSystem", "isActive");

--
-- Class Equipment as table equipment
--
CREATE TABLE "equipment" (
    "id" bigserial PRIMARY KEY,
    "uuid" text NOT NULL,
    "clientId" text,
    "mainSiteId" text,
    "subSiteId" text,
    "name" text NOT NULL,
    "serialNumber" text,
    "manufacturer" text,
    "model" text,
    "createdBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "isActive" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "equipment_uuid_idx" ON "equipment" USING btree ("uuid");
CREATE INDEX "equipment_client_active_idx" ON "equipment" USING btree ("clientId", "isActive");
CREATE INDEX "equipment_mainsite_active_idx" ON "equipment" USING btree ("mainSiteId", "isActive");
CREATE INDEX "equipment_subsite_active_idx" ON "equipment" USING btree ("subSiteId", "isActive");

--
-- Class FolderPhoto as table folder_photos
--
CREATE TABLE "folder_photos" (
    "id" bigserial PRIMARY KEY,
    "folderId" text NOT NULL,
    "photoId" text NOT NULL,
    "beforeAfter" text NOT NULL,
    "addedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "folder_idx" ON "folder_photos" USING btree ("folderId");
CREATE INDEX "photo_idx" ON "folder_photos" USING btree ("photoId");
CREATE UNIQUE INDEX "folder_photo_idx" ON "folder_photos" USING btree ("folderId", "photoId");

--
-- Class ImportBatch as table import_batches
--
CREATE TABLE "import_batches" (
    "id" bigserial PRIMARY KEY,
    "uuid" text NOT NULL,
    "entryPoint" text NOT NULL,
    "equipmentId" text,
    "folderId" text,
    "destinationCategory" text NOT NULL,
    "selectedCount" bigint NOT NULL,
    "importedCount" bigint NOT NULL,
    "duplicateCount" bigint NOT NULL,
    "failedCount" bigint NOT NULL,
    "startedAt" timestamp without time zone NOT NULL,
    "completedAt" timestamp without time zone,
    "permissionState" text NOT NULL,
    "deviceFreeSpaceBytes" bigint
);

-- Indexes
CREATE UNIQUE INDEX "importbatch_uuid_idx" ON "import_batches" USING btree ("uuid");
CREATE INDEX "importbatch_started_idx" ON "import_batches" USING btree ("startedAt");
CREATE INDEX "importbatch_equipment_idx" ON "import_batches" USING btree ("equipmentId");

--
-- Class MainSite as table main_sites
--
CREATE TABLE "main_sites" (
    "id" bigserial PRIMARY KEY,
    "uuid" text NOT NULL,
    "clientId" text NOT NULL,
    "name" text NOT NULL,
    "address" text,
    "latitude" double precision,
    "longitude" double precision,
    "createdBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "isActive" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "mainsite_uuid_idx" ON "main_sites" USING btree ("uuid");
CREATE INDEX "mainsite_client_active_idx" ON "main_sites" USING btree ("clientId", "isActive");

--
-- Class PhotoFolder as table photo_folders
--
CREATE TABLE "photo_folders" (
    "id" bigserial PRIMARY KEY,
    "uuid" text NOT NULL,
    "equipmentId" text NOT NULL,
    "name" text NOT NULL,
    "workOrder" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "createdBy" text NOT NULL,
    "isDeleted" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "photofolder_uuid_idx" ON "photo_folders" USING btree ("uuid");
CREATE INDEX "photofolder_equipment_idx" ON "photo_folders" USING btree ("equipmentId");
CREATE INDEX "photofolder_equipment_created_idx" ON "photo_folders" USING btree ("equipmentId", "createdAt");

--
-- Class Photo as table photos
--
CREATE TABLE "photos" (
    "id" bigserial PRIMARY KEY,
    "uuid" text NOT NULL,
    "equipmentId" text NOT NULL,
    "filePath" text NOT NULL,
    "thumbnailPath" text,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "capturedBy" text NOT NULL,
    "fileSize" bigint NOT NULL,
    "isSynced" boolean NOT NULL,
    "syncedAt" timestamp without time zone,
    "remoteUrl" text,
    "sourceAssetId" text,
    "fingerprintSha1" text,
    "importBatchId" text,
    "importSource" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "photo_uuid_idx" ON "photos" USING btree ("uuid");
CREATE INDEX "photo_equipment_timestamp_idx" ON "photos" USING btree ("equipmentId", "timestamp");
CREATE INDEX "photo_sync_status_idx" ON "photos" USING btree ("isSynced", "createdAt");
CREATE INDEX "photo_timestamp_idx" ON "photos" USING btree ("timestamp");
CREATE INDEX "photo_source_asset_idx" ON "photos" USING btree ("sourceAssetId");
CREATE INDEX "photo_fingerprint_idx" ON "photos" USING btree ("fingerprintSha1");
CREATE INDEX "photo_import_batch_idx" ON "photos" USING btree ("importBatchId");

--
-- Class SubSite as table sub_sites
--
CREATE TABLE "sub_sites" (
    "id" bigserial PRIMARY KEY,
    "uuid" text NOT NULL,
    "clientId" text,
    "mainSiteId" text,
    "parentSubSiteId" text,
    "name" text NOT NULL,
    "description" text,
    "createdBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "isActive" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "subsite_uuid_idx" ON "sub_sites" USING btree ("uuid");
CREATE INDEX "subsite_client_active_idx" ON "sub_sites" USING btree ("clientId", "isActive");
CREATE INDEX "subsite_mainsite_active_idx" ON "sub_sites" USING btree ("mainSiteId", "isActive");
CREATE INDEX "subsite_parent_active_idx" ON "sub_sites" USING btree ("parentSubSiteId", "isActive");

--
-- Class SyncQueueItem as table sync_queue
--
CREATE TABLE "sync_queue" (
    "id" bigserial PRIMARY KEY,
    "uuid" text NOT NULL,
    "entityType" text NOT NULL,
    "entityId" text NOT NULL,
    "operation" text NOT NULL,
    "payload" text NOT NULL,
    "retryCount" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "lastAttempt" timestamp without time zone,
    "error" text,
    "isCompleted" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "syncqueue_uuid_idx" ON "sync_queue" USING btree ("uuid");
CREATE INDEX "syncqueue_pending_idx" ON "sync_queue" USING btree ("isCompleted", "createdAt");
CREATE INDEX "syncqueue_entity_idx" ON "sync_queue" USING btree ("entityType", "entityId");

--
-- Class User as table users
--
CREATE TABLE "users" (
    "id" bigserial PRIMARY KEY,
    "uuid" text NOT NULL,
    "email" text NOT NULL,
    "name" text NOT NULL,
    "role" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "lastSyncAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "user_uuid_idx" ON "users" USING btree ("uuid");
CREATE UNIQUE INDEX "user_email_idx" ON "users" USING btree ("email");

--
-- Class CloudStorageEntry as table serverpod_cloud_storage
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "addedTime" timestamp without time zone NOT NULL,
    "expiration" timestamp without time zone,
    "byteData" bytea NOT NULL,
    "verified" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" USING btree ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" USING btree ("expiration");

--
-- Class CloudStorageDirectUploadEntry as table serverpod_cloud_storage_direct_upload
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" USING btree ("storageId", "path");

--
-- Class FutureCallEntry as table serverpod_future_call
--
CREATE TABLE "serverpod_future_call" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "serializedObject" text,
    "serverId" text NOT NULL,
    "identifier" text
);

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" USING btree ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" USING btree ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" USING btree ("identifier");

--
-- Class ServerHealthConnectionInfo as table serverpod_health_connection_info
--
CREATE TABLE "serverpod_health_connection_info" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "active" bigint NOT NULL,
    "closing" bigint NOT NULL,
    "idle" bigint NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_connection_info_timestamp_idx" ON "serverpod_health_connection_info" USING btree ("timestamp", "serverId", "granularity");

--
-- Class ServerHealthMetric as table serverpod_health_metric
--
CREATE TABLE "serverpod_health_metric" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "isHealthy" boolean NOT NULL,
    "value" double precision NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_metric_timestamp_idx" ON "serverpod_health_metric" USING btree ("timestamp", "serverId", "name", "granularity");

--
-- Class LogEntry as table serverpod_log
--
CREATE TABLE "serverpod_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "reference" text,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "logLevel" bigint NOT NULL,
    "message" text NOT NULL,
    "error" text,
    "stackTrace" text,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId");

--
-- Class MessageLogEntry as table serverpod_message_log
--
CREATE TABLE "serverpod_message_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "serverId" text NOT NULL,
    "messageId" bigint NOT NULL,
    "endpoint" text NOT NULL,
    "messageName" text NOT NULL,
    "duration" double precision NOT NULL,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

--
-- Class MethodInfo as table serverpod_method
--
CREATE TABLE "serverpod_method" (
    "id" bigserial PRIMARY KEY,
    "endpoint" text NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" USING btree ("endpoint", "method");

--
-- Class DatabaseMigrationVersion as table serverpod_migrations
--
CREATE TABLE "serverpod_migrations" (
    "id" bigserial PRIMARY KEY,
    "module" text NOT NULL,
    "version" text NOT NULL,
    "timestamp" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_migrations_ids" ON "serverpod_migrations" USING btree ("module");

--
-- Class QueryLogEntry as table serverpod_query_log
--
CREATE TABLE "serverpod_query_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "query" text NOT NULL,
    "duration" double precision NOT NULL,
    "numRows" bigint,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId");

--
-- Class ReadWriteTestEntry as table serverpod_readwrite_test
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" bigserial PRIMARY KEY,
    "number" bigint NOT NULL
);

--
-- Class RuntimeSettings as table serverpod_runtime_settings
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" bigserial PRIMARY KEY,
    "logSettings" json NOT NULL,
    "logSettingsOverrides" json NOT NULL,
    "logServiceCalls" boolean NOT NULL,
    "logMalformedCalls" boolean NOT NULL
);

--
-- Class SessionLogEntry as table serverpod_session_log
--
CREATE TABLE "serverpod_session_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "module" text,
    "endpoint" text,
    "method" text,
    "duration" double precision,
    "numQueries" bigint,
    "slow" boolean,
    "error" text,
    "stackTrace" text,
    "authenticatedUserId" bigint,
    "isOpen" boolean,
    "touched" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_session_log_serverid_idx" ON "serverpod_session_log" USING btree ("serverId");
CREATE INDEX "serverpod_session_log_touched_idx" ON "serverpod_session_log" USING btree ("touched");
CREATE INDEX "serverpod_session_log_isopen_idx" ON "serverpod_session_log" USING btree ("isOpen");

--
-- Foreign relations for "serverpod_log" table
--
ALTER TABLE ONLY "serverpod_log"
    ADD CONSTRAINT "serverpod_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_message_log" table
--
ALTER TABLE ONLY "serverpod_message_log"
    ADD CONSTRAINT "serverpod_message_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_query_log" table
--
ALTER TABLE ONLY "serverpod_query_log"
    ADD CONSTRAINT "serverpod_query_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR sitepictures_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('sitepictures_server', '20251106195139239', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251106195139239', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
