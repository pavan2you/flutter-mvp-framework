PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS NetRequest(
requestId TEXT PRIMARY KEY NOT NULL,
createdAt BIGINT,
delegateType TEXT,
endpoint_server TEXT,
endpoint_method TEXT,
endpoint_url TEXT,
payload_crudOperation TEXT,
payload_entityType TEXT,
payload_entityUuid TEXT,
payload_body TEXT,
payload_encrypted INTEGER,
requestPolicy_fireAs INTEGER,
requestPolicy_priority INTEGER,
requestPolicy_canOverwrite INTEGER,
requestPolicy_persistable INTEGER,
responsePolicy_serveAs TEXT,
responsePolicy_treatAnyResponseAsSuccess INTEGER,
responsePolicy_notifyErrors TEXT,
retryPolicy_limit INTEGER,
retryPolicy_currentAttempts INTEGER,
retryPolicy_retryAfterMillis INTEGER,
retryPolicy_sendAsDump INTEGER,
redirectPolicy_limit INTEGER,
redirectPolicy_allowRedirects INTEGER,
redirectPolicy_currentAttempts INTEGER,
pollingPolicy_intervalInMillis INTEGER
);

CREATE TABLE IF NOT EXISTS MqttMessage(
mqttMessageUuid TEXT PRIMARY KEY NOT NULL,
topic TEXT,
message BLOB,
qos INTEGER,
retained INTEGER,
duplicate INTEGER,
createdAt BIGINT
);

PRAGMA foreign_keys = OFF;