PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS Contact(
contactId TEXT PRIMARY KEY NOT NULL,
fullName TEXT,
email TEXT
);

PRAGMA foreign_keys = OFF;