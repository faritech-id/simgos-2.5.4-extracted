DELETE FROM aplikasi.pengguna_akses
 WHERE GROUP_PENGGUNA_AKSES_MODULE IN (
SELECT ID
  FROM aplikasi.group_pengguna_akses_module
 WHERE MODUL LIKE '2306%');
 
DELETE FROM aplikasi.group_pengguna_akses_module
 WHERE MODUL LIKE '2306%';
 
DELETE FROM aplikasi.modules WHERE ID LIKE '2306%';