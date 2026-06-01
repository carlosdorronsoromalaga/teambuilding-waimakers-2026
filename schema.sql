-- ============================================================
-- WORLD CUP 2026 PREDICTOR — DATABASE SCHEMA
-- Run this in Supabase SQL Editor for each new company deployment
-- ============================================================

-- Participants
CREATE TABLE participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Predictions (one row per participant + match)
CREATE TABLE predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_name TEXT NOT NULL REFERENCES participants(name) ON DELETE CASCADE,
  match_id INTEGER NOT NULL,
  home_score INTEGER,
  away_score INTEGER,
  pick TEXT,
  tiebreak TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(participant_name, match_id)
);

-- Results + metadata
-- Special match_ids: 1001=champion pick, 1002=runner-up pick,
--   8888=blocked users (JSON), 9997=PINs (JSON), 9999=deadline (ISO string)
CREATE TABLE results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id INTEGER UNIQUE NOT NULL,
  home_score INTEGER,
  away_score INTEGER,
  pick TEXT,
  tiebreak TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat messages
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_name TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ── Indexes ────────────────────────────────────────────────────
CREATE INDEX idx_predictions_participant ON predictions(participant_name);
CREATE INDEX idx_predictions_match ON predictions(match_id);
CREATE INDEX idx_chat_created ON chat_messages(created_at);

-- ── Row Level Security ──────────────────────────────────────────
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE results ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Allow all operations via anon key (app controls auth via PIN + admin password)
CREATE POLICY "anon_all" ON participants FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON predictions FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON results FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON chat_messages FOR ALL TO anon USING (true) WITH CHECK (true);
