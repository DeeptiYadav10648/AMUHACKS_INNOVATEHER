-- Initial SQL seed for Community Commons (Postgres compatible)

CREATE TABLE IF NOT EXISTS player_profiles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    background VARCHAR(255),
    avatar VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS civic_scores (
    id SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES player_profiles(id),
    community_harmony INTEGER DEFAULT 0,
    personal_integrity INTEGER DEFAULT 0,
    social_capital INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS scenarios (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    environment VARCHAR(255),
    description TEXT,
    unlock_score INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS choices (
    id SERIAL PRIMARY KEY,
    scenario_id INTEGER REFERENCES scenarios(id),
    text VARCHAR(1024),
    effect JSONB
);

CREATE TABLE IF NOT EXISTS decisions_history (
    id SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES player_profiles(id),
    scenario_id INTEGER REFERENCES scenarios(id),
    choice_id INTEGER REFERENCES choices(id),
    note TEXT
);

CREATE TABLE IF NOT EXISTS badges (
    id SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES player_profiles(id),
    name VARCHAR(255),
    description VARCHAR(512)
);

-- NPCs and relationships
CREATE TABLE IF NOT EXISTS npcs (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    role VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS npc_relationships (
    id SERIAL PRIMARY KEY,
    player_id INTEGER REFERENCES player_profiles(id),
    npc_id INTEGER REFERENCES npcs(id),
    relationship_score INTEGER DEFAULT 0,
    note TEXT
);

-- Environment state per scenario
CREATE TABLE IF NOT EXISTS environment_state (
    id SERIAL PRIMARY KEY,
    scenario_id INTEGER REFERENCES scenarios(id),
    state JSONB DEFAULT '{}'
);
