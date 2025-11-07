BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "main_site_records" (
    "id" bigserial PRIMARY KEY,
    "mainSiteId" text NOT NULL,
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
CREATE UNIQUE INDEX "main_site_record_main_site_id" ON "main_site_records" USING btree ("mainSiteId");
CREATE INDEX "main_site_record_client_id" ON "main_site_records" USING btree ("clientId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sub_site_records" (
    "id" bigserial PRIMARY KEY,
    "subSiteId" text NOT NULL,
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
CREATE UNIQUE INDEX "sub_site_record_sub_site_id" ON "sub_site_records" USING btree ("subSiteId");
CREATE INDEX "sub_site_record_client_id" ON "sub_site_records" USING btree ("clientId");
CREATE INDEX "sub_site_record_main_site_id" ON "sub_site_records" USING btree ("mainSiteId");
CREATE INDEX "sub_site_record_parent_id" ON "sub_site_records" USING btree ("parentSubSiteId");


--
-- MIGRATION VERSION FOR sitepictures_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('sitepictures_server', '20251107184336416', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251107184336416', "timestamp" = now();

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
