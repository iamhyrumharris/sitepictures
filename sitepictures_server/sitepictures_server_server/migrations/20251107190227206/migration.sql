BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "equipment_records" (
    "id" bigserial PRIMARY KEY,
    "equipmentId" text NOT NULL,
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
CREATE UNIQUE INDEX "equipment_record_equipment_id" ON "equipment_records" USING btree ("equipmentId");
CREATE INDEX "equipment_record_client_id" ON "equipment_records" USING btree ("clientId");
CREATE INDEX "equipment_record_main_site_id" ON "equipment_records" USING btree ("mainSiteId");
CREATE INDEX "equipment_record_sub_site_id" ON "equipment_records" USING btree ("subSiteId");


--
-- MIGRATION VERSION FOR sitepictures_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('sitepictures_server', '20251107190227206', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251107190227206', "timestamp" = now();

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
