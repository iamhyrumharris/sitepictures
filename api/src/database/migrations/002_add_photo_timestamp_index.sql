-- Add descending timestamp index to optimize newest-first photo queries
CREATE INDEX IF NOT EXISTS idx_photos_captured_desc
ON photos (captured_at DESC);
