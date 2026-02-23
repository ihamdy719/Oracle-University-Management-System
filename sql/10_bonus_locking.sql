-- 10_bonus_locking.sql
-- Run as SYSDBA (after setting container)
-- Shows sessions and blockers for USER1/USER2

SELECT sid, serial#, username, status, blocking_session, event, seconds_in_wait
FROM v$session
WHERE username IN ('USER1','USER2')
ORDER BY username;

SELECT
  s.sid AS waiting_sid,
  s.serial# AS waiting_serial,
  s.username AS waiting_user,
  s.blocking_session AS blocker_sid,
  bs.serial# AS blocker_serial,
  bs.username AS blocker_user,
  s.event,
  s.seconds_in_wait
FROM v$session s
LEFT JOIN v$session bs
  ON bs.sid = s.blocking_session
WHERE s.username = 'USER2';
