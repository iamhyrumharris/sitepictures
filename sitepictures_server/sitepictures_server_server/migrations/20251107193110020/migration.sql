BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "duplicate_registry_records" (
    "id" bigserial PRIMARY KEY,
    "duplicateId" text NOT NULL,
    "photoId" text NOT NULL,
    "sourceAssetId" text,
    "fingerprintSha1" text,
    "importedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "duplicate_registry_record_id" ON "duplicate_registry_records" USING btree ("duplicateId");
CREATE INDEX "duplicate_registry_record_photo_id" ON "duplicate_registry_records" USING btree ("photoId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "import_batch_records" (
    "id" bigserial PRIMARY KEY,
    "batchId" text NOT NULL,
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
    "deviceFreeSpaceBytes" bigint,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "import_batch_record_batch_id" ON "import_batch_records" USING btree ("batchId");


--
-- MIGRATION VERSION FOR sitepictures_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('sitepictures_server', '20251107193110020', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251107193110020', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20240520102713718', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240520102713718', "timestamp" = now();


COMMIT;
