-- Initial schema for FieldPhoto Pro API
-- PostgreSQL database schema

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Companies table
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Clients table
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Sites table
CREATE TABLE sites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    parent_site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    center_latitude DECIMAL(10, 7),
    center_longitude DECIMAL(10, 7),
    boundary_radius DECIMAL(10, 2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Equipment table
CREATE TABLE equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    equipment_type VARCHAR(50),
    serial_number VARCHAR(100),
    model VARCHAR(100),
    manufacturer VARCHAR(100),
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Revisions table
CREATE TABLE revisions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    equipment_id UUID NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- Photos table
CREATE TABLE photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    equipment_id UUID NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
    revision_id UUID REFERENCES revisions(id) ON DELETE SET NULL,
    file_name VARCHAR(255) NOT NULL,
    file_hash CHAR(64) NOT NULL,
    file_url TEXT,
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    captured_at TIMESTAMP NOT NULL,
    notes TEXT,
    device_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_synced BOOLEAN DEFAULT false
);

-- Users (devices) table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_name VARCHAR(50) NOT NULL,
    company_id UUID REFERENCES companies(id) ON DELETE SET NULL,
    preferences JSONB DEFAULT '{}',
    first_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- GPS Boundaries table
CREATE TABLE gps_boundaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    center_latitude DECIMAL(10, 7) NOT NULL CHECK (center_latitude >= -90 AND center_latitude <= 90),
    center_longitude DECIMAL(10, 7) NOT NULL CHECK (center_longitude >= -180 AND center_longitude <= 180),
    radius_meters DECIMAL(10, 2) NOT NULL CHECK (radius_meters > 0 AND radius_meters <= 10000),
    priority INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Sync Packages table
CREATE TABLE sync_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('Photo', 'Client', 'Site', 'Equipment', 'Revision', 'GPSBoundary')),
    entity_id UUID NOT NULL,
    operation VARCHAR(10) NOT NULL CHECK (operation IN ('CREATE', 'UPDATE', 'DELETE')),
    data JSONB NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    device_id UUID NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SYNCING', 'SYNCED', 'FAILED')),
    retry_count INTEGER DEFAULT 0 CHECK (retry_count >= 0 AND retry_count <= 10),
    last_attempt TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX idx_photo_equipment_captured ON photos(equipment_id, captured_at DESC);
CREATE INDEX idx_photo_device_timestamp ON photos(device_id, created_at DESC);
CREATE INDEX idx_photo_gps_location ON photos(latitude, longitude) WHERE latitude IS NOT NULL;
CREATE INDEX idx_site_parent ON sites(parent_site_id, name);
CREATE INDEX idx_equipment_site ON equipment(site_id, name);
CREATE INDEX idx_sync_status ON sync_packages(status, timestamp);
CREATE INDEX idx_sync_device ON sync_packages(device_id, status);
CREATE INDEX idx_boundaries_location ON gps_boundaries(center_latitude, center_longitude);

-- Full-text search index (using GIN for JSONB searching)
CREATE INDEX idx_equipment_search ON equipment USING GIN(to_tsvector('english', name || ' ' || COALESCE(equipment_type, '') || ' ' || COALESCE(manufacturer, '')));
CREATE INDEX idx_photo_notes_search ON photos USING GIN(to_tsvector('english', COALESCE(notes, '')));

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply update trigger to all tables with updated_at
CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sites_updated_at BEFORE UPDATE ON sites FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_equipment_updated_at BEFORE UPDATE ON equipment FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_photos_updated_at BEFORE UPDATE ON photos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_gps_boundaries_updated_at BEFORE UPDATE ON gps_boundaries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();