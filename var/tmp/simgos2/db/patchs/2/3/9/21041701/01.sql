USE inventory;
DROP PROCEDURE IF EXISTS `cetakPengembalianBarang`;
DELIMITER //
CREATE PROCEDURE `cetakPengembalianBarang`(
	IN `PID` INT
)
BEGIN
	SELECT 
		inst.NAMA NAMAINST
		, inst.ALAMAT ALAMATINST
		, r.DESKRIPSI RUANGAN
		, py.NAMA NAMA_PENYEDIA
		, `master`.getNamaLengkapPegawai(p.NIP) USER
		, DATE_FORMAT(pb.TANGGAL, '%d-%m-%Y') TANGGAL
		, b.NAMA NAMA_BARANG
		, pbd.JUMLAH
	FROM
		inventory.pengembalian_barang_detil pbd
	LEFT JOIN inventory.pengembalian_barang pb ON pb.ID = pbd.PENGEMBALIAN
	LEFT JOIN inventory.barang b ON b.ID = pbd.BARANG
	LEFT JOIN `master`.ruangan r ON r.ID = pb.RUANGAN
	LEFT JOIN inventory.penyedia py ON py.ID = pb.REKANAN
	LEFT JOIN aplikasi.pengguna p ON p.ID = pb.OLEH
	, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
	WHERE 
		pb.ID = PID;

END//
DELIMITER ;