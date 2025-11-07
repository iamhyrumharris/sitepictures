BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "folder_photo_records" (
    "id" bigserial PRIMARY KEY,
    "folderId" text NOT NULL,
    "photoId" text NOT NULL,
    "beforeAfter" text NOT NULL,
    "addedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "folder_photo_record_folder_id" ON "folder_photo_records" USING btree ("folderId");
CREATE INDEX "folder_photo_record_photo_id" ON "folder_photo_records" USING btree ("photoId");
CREATE UNIQUE INDEX "folder_photo_record_folder_photo" ON "folder_photo_records" USING btree ("folderId", "photoId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "photo_folder_records" (
    "id" bigserial PRIMARY KEY,
    "folderId" text NOT NULL,
    "equipmentId" text NOT NULL,
    "name" text NOT NULL,
    "workOrder" text NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "isDeleted" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "photo_folder_record_folder_id" ON "photo_folder_records" USING btree ("folderId");
CREATE INDEX "photo_folder_record_equipment_id" ON "photo_folder_records" USING btree ("equipmentId");


--
-- MIGRATION VERSION FOR sitepictures_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('sitepictures_server', '20251107190959922', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251107190959922', "timestamp" = now();

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
