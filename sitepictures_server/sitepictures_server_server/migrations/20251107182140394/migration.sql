BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "client_records" (
    "id" bigserial PRIMARY KEY,
    "clientId" text NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "isSystem" boolean NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "isActive" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "client_record_client_id" ON "client_records" USING btree ("clientId");


--
-- MIGRATION VERSION FOR sitepictures_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('sitepictures_server', '20251107182140394', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251107182140394', "timestamp" = now();

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
