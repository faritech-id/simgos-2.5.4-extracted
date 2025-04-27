DELETE  
  FROM aplikasi.pengguna_akses
 WHERE GROUP_PENGGUNA_AKSES_MODULE IN (SELECT ID FROM aplikasi.group_pengguna_akses_module gp WHERE gp.MODUL = '2102');

DELETE
  FROM aplikasi.group_pengguna_akses_module WHERE MODUL = '2102';
  
DELETE
  FROM aplikasi.modules WHERE ID = '2102';