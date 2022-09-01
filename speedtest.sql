/* Track speedtest results */
/* SQLite3 database */

CREATE TABLE results(
  "Server ID" TEXT,
  "Sponsor" TEXT,
  "Server Name" TEXT,
  "Timestamp" TEXT,
  "Distance" TEXT,
  "Ping" TEXT,
  "Download" TEXT,
  "Upload" TEXT,
  "Share" TEXT,
  "IP Address" TEXT
);

CREATE VIEW data as
    select
        rowid,
        *,
        "Download"/1024/1024 as DownloadResults,
        "Upload"/1024/1024 as UploadResults,
        datetime(Timestamp,'localtime') as localtime
    from results;



