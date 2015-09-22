SET @databasename = "sample";

SELECT CONCAT("ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN DROP FOREIGN KEY ",constraint_name)
INTO @sqlst
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
where TABLE_SCHEMA = @databasename and TABLE_NAME = "IDN_OAUTH1A_REQUEST_TOKEN"
and referenced_column_name is not NULL limit 1;

PREPARE stmt FROM @sqlst;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
SET @sqlstr = NULL;

SELECT CONCAT("ALTER TABLE IDN_OAUTH1A_ACCESS_TOKEN DROP FOREIGN KEY ",constraint_name)
INTO @sqlst
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
where TABLE_SCHEMA = @databasename and TABLE_NAME = "IDN_OAUTH1A_ACCESS_TOKEN"
and referenced_column_name is not NULL limit 1;

PREPARE stmt FROM @sqlst;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
SET @sqlstr = NULL;

SELECT CONCAT("ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP FOREIGN KEY ",constraint_name)
INTO @sqlst
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
where TABLE_SCHEMA = @databasename and TABLE_NAME = "IDN_OAUTH2_ACCESS_TOKEN"
and referenced_column_name is not NULL limit 1;

PREPARE stmt FROM @sqlst;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
SET @sqlstr = NULL;

SELECT CONCAT("ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE DROP FOREIGN KEY ",constraint_name)
INTO @sqlst
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
where TABLE_SCHEMA = @databasename and TABLE_NAME = "IDN_OAUTH2_AUTHORIZATION_CODE"
and referenced_column_name is not NULL limit 1;

PREPARE stmt FROM @sqlst;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
SET @sqlstr = NULL;

ALTER TABLE IDN_OAUTH_CONSUMER_APPS DROP PRIMARY KEY;
ALTER TABLE IDN_OAUTH_CONSUMER_APPS ADD ID INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE IDN_OAUTH_CONSUMER_APPS MODIFY COLUMN CONSUMER_KEY VARCHAR (255)  NOT NULL;
ALTER TABLE IDN_OAUTH_CONSUMER_APPS ADD CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY);

ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN ADD CONSUMER_KEY_ID INTEGER;
UPDATE IDN_OAUTH1A_REQUEST_TOKEN REQUEST_TOKEN set REQUEST_TOKEN.CONSUMER_KEY_ID = (select CONSUMER_APPS.ID from IDN_OAUTH_CONSUMER_APPS CONSUMER_APPS where CONSUMER_APPS.CONSUMER_KEY = REQUEST_TOKEN.CONSUMER_KEY);
ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN DROP COLUMN CONSUMER_KEY;
ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN ADD FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE;

ALTER TABLE IDN_OAUTH1A_ACCESS_TOKEN ADD CONSUMER_KEY_ID INTEGER;
UPDATE IDN_OAUTH1A_ACCESS_TOKEN ACCESS_TOKEN set ACCESS_TOKEN.CONSUMER_KEY_ID = (select CONSUMER_APPS.ID from IDN_OAUTH_CONSUMER_APPS CONSUMER_APPS where CONSUMER_APPS.CONSUMER_KEY = ACCESS_TOKEN.CONSUMER_KEY);
ALTER TABLE IDN_OAUTH1A_ACCESS_TOKEN DROP COLUMN CONSUMER_KEY;
ALTER TABLE IDN_OAUTH1A_ACCESS_TOKEN ADD FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE;

ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP PRIMARY KEY;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD TOKEN_ID VARCHAR (255);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD CONSUMER_KEY_ID INTEGER;
UPDATE IDN_OAUTH2_ACCESS_TOKEN ACCESS_TOKEN set ACCESS_TOKEN.CONSUMER_KEY_ID = (select CONSUMER_APPS.ID from IDN_OAUTH_CONSUMER_APPS CONSUMER_APPS where CONSUMER_APPS.CONSUMER_KEY = ACCESS_TOKEN.CONSUMER_KEY);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP INDEX CON_APP_KEY;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP INDEX IDX_AT_CK_AU;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP COLUMN CONSUMER_KEY;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD TENANT_ID INTEGER;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD USER_DOMAIN VARCHAR(50);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD REFRESH_TOKEN_TIME_CREATED TIMESTAMP DEFAULT 0;
UPDATE IDN_OAUTH2_ACCESS_TOKEN SET REFRESH_TOKEN_TIME_CREATED = TIME_CREATED;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD REFRESH_TOKEN_VALIDITY_PERIOD BIGINT;
UPDATE IDN_OAUTH2_ACCESS_TOKEN SET REFRESH_TOKEN_VALIDITY_PERIOD = 84600000;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD TOKEN_SCOPE_HASH VARCHAR (32);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN MODIFY COLUMN TOKEN_STATE_ID VARCHAR (128) DEFAULT 'NONE' NOT NULL;
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TENANT_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,TOKEN_STATE,TOKEN_STATE_ID);
CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_STATE, USER_TYPE);
ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE;

ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD CONSUMER_KEY_ID INTEGER;
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD TENANT_ID INTEGER;
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD USER_DOMAIN VARCHAR(50);
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD STATE VARCHAR (25) DEFAULT 'ACTIVE';
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD TOKEN_ID VARCHAR(255);
UPDATE IDN_OAUTH2_AUTHORIZATION_CODE AUTHORIZATION_CODE set AUTHORIZATION_CODE.CONSUMER_KEY_ID = (select CONSUMER_APPS.ID from IDN_OAUTH_CONSUMER_APPS CONSUMER_APPS where CONSUMER_APPS.CONSUMER_KEY = AUTHORIZATION_CODE.CONSUMER_KEY);
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE DROP COLUMN CONSUMER_KEY;
ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE ADD FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE;

DROP TABLE IF EXISTS IDN_SCIM_PROVIDER;
ALTER TABLE IDN_IDENTITY_USER_DATA  MODIFY COLUMN DATA_VALUE VARCHAR(255) NULL;
ALTER TABLE IDN_ASSOCIATED_ID MODIFY COLUMN IDP_ID INTEGER;
ALTER TABLE IDN_ASSOCIATED_ID ADD DOMAIN_NAME VARCHAR(255);
ALTER TABLE IDN_ASSOCIATED_ID ADD FOREIGN KEY (IDP_ID )  REFERENCES IDP (ID) ON DELETE CASCADE;
ALTER TABLE IDN_AUTH_SESSION_STORE ALTER COLUMN SESSION_ID DROP DEFAULT;
ALTER TABLE IDN_AUTH_SESSION_STORE MODIFY COLUMN SESSION_ID VARCHAR (100) NOT NULL;
ALTER TABLE IDN_AUTH_SESSION_STORE ALTER COLUMN SESSION_TYPE DROP DEFAULT;
ALTER TABLE IDN_AUTH_SESSION_STORE MODIFY COLUMN SESSION_TYPE VARCHAR(100) NOT NULL;
ALTER TABLE SP_APP ADD IS_USE_TENANT_DOMAIN_SUBJECT CHAR(1) DEFAULT '1' NOT NULL;
ALTER TABLE SP_APP ADD IS_USE_USER_DOMAIN_SUBJECT CHAR(1) DEFAULT '1' NOT NULL;
INSERT INTO IDP_AUTHENTICATOR (TENANT_ID, IDP_ID, NAME) VALUES (-1234, 1, 'IDPProperties');

CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE_ASSOCIATION (
  TOKEN_ID VARCHAR (255),
  TOKEN_SCOPE VARCHAR (60),
  PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS IDN_USER_ACCOUNT_ASSOCIATION (
  ASSOCIATION_KEY VARCHAR(255) NOT NULL,
  TENANT_ID INTEGER,
  DOMAIN_NAME VARCHAR(255) NOT NULL,
  USER_NAME VARCHAR(255) NOT NULL,
  PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS FIDO_DEVICE_STORE (
  TENANT_ID INTEGER,
  DOMAIN_NAME VARCHAR(255) NOT NULL,
  USER_NAME VARCHAR(45) NOT NULL,
  TIME_REGISTERED TIMESTAMP,
  KEY_HANDLE VARCHAR(200) NOT NULL,
  DEVICE_DATA VARCHAR(2048) NOT NULL,
  PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME, KEY_HANDLE)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS WF_REQUEST (
  UUID VARCHAR (45),
  CREATED_BY VARCHAR (255),
  TENANT_ID INTEGER DEFAULT -1,
  OPERATION_TYPE VARCHAR (50),
  CREATED_AT TIMESTAMP,
  UPDATED_AT TIMESTAMP,
  STATUS VARCHAR (30),
  REQUEST BLOB,
  PRIMARY KEY (UUID)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS WF_BPS_PROFILE (
  PROFILE_NAME VARCHAR(45),
  HOST_URL VARCHAR(45),
  USERNAME VARCHAR(45),
  PASSWORD VARCHAR(255),
  CALLBACK_HOST VARCHAR (45),
  CALLBACK_USERNAME VARCHAR (45),
  CALLBACK_PASSWORD VARCHAR (255),
  TENANT_ID VARCHAR (45),
  PRIMARY KEY (PROFILE_NAME, TENANT_ID)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS WF_WORKFLOW(
  ID VARCHAR (45),
  WF_NAME VARCHAR (45),
  DESCRIPTION VARCHAR (255),
  TEMPLATE_ID VARCHAR (45),
  IMPL_ID VARCHAR (45),
  TENANT_ID VARCHAR (45),
  PRIMARY KEY (ID)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS WF_WORKFLOW_ASSOCIATION(
  ID INTEGER NOT NULL AUTO_INCREMENT,
  ASSOC_NAME VARCHAR (45),
  EVENT_ID VARCHAR(45),
  ASSOC_CONDITION VARCHAR (2000),
  WORKFLOW_ID VARCHAR (45),
  IS_ENABLED CHAR (1) DEFAULT '1',
  PRIMARY KEY(ID),
  FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS WF_WORKFLOW_CONFIG_PARAM(
  WORKFLOW_ID VARCHAR (45),
  PARAM_NAME VARCHAR (45),
  PARAM_VALUE VARCHAR (1000),
  PRIMARY KEY (WORKFLOW_ID, PARAM_NAME),
  FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
)ENGINE INNODB;



CREATE TABLE IF NOT EXISTS WF_REQUEST_ENTITY_RELATIONSHIP(
  REQUEST_ID VARCHAR (45),
  ENTITY_NAME VARCHAR (255),
  ENTITY_TYPE VARCHAR (50),
  TENANT_ID INTEGER DEFAULT -1,
  PRIMARY KEY(REQUEST_ID, ENTITY_NAME, ENTITY_TYPE, TENANT_ID),
  FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS WORKFLOW_REQUEST_RELATION(
  RELATIONSHIP_ID VARCHAR (45),
  WORKFLOW_ID VARCHAR (45),
  REQUEST_ID VARCHAR (45),
  UPDATED_AT TIMESTAMP,
  STATUS VARCHAR (30),
  PRIMARY KEY (RELATIONSHIP_ID),
  FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE,
  FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
)ENGINE INNODB;