BEGIN;

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
