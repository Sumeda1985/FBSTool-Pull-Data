psql
CREATE DATABASE suafbsdata;
psql suafbsdata
CREATE SCHEMA core;
CREATE USER suafbsdbuser WITH PASSWORD 'XXXXXXXXXXXX';
GRANT ALL PRIVILEGES ON DATABASE suafbsdata TO suafbsdbuser;
GRANT ALL ON SCHEMA public TO suafbsdbuser;
GRANT ALL ON SCHEMA core TO suafbsdbuser;
