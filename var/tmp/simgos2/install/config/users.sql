#Alter password
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'S!MGos2R00T@kemkes.go.id';
CREATE USER 'root'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY 'S!MGos2R00T@kemkes.go.id';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;

#Create User simgos
CREATE USER 'simgos'@'localhost' IDENTIFIED WITH mysql_native_password BY 'S!MGos2@kemkes.go.id';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON *.* TO 'simgos'@'localhost' WITH GRANT OPTION;

CREATE USER 'simgos'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY 'S!MGos2@kemkes.go.id';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON *.* TO 'simgos'@'127.0.0.1' WITH GRANT OPTION;

#Create Remote User admin
CREATE USER 'admin'@'%' IDENTIFIED WITH mysql_native_password BY 'S!MGos2@kemkes.go.id';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
