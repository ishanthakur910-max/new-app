CREATE TABLE IF NOT EXISTS tasks (
 id SERIAL PRIMARY KEY,
 title VARCHAR(180) NOT NULL,
 description TEXT DEFAULT '',
 status VARCHAR(30) NOT NULL DEFAULT 'Pending'
   CHECK (status IN ('Pending','In Progress','Completed')),
 priority VARCHAR(20) NOT NULL DEFAULT 'Medium'
   CHECK (priority IN ('Low','Medium','High')),
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
