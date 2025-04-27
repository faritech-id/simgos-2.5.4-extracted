UPDATE aplikasi.properti_config pc
   SET pc.DESKRIPSI = 'Mode: 1<br>
- Untuk pasien kelas 1 naik diatas kelas 1 harus membayar selisih biaya tarif INACBG kelas 1 dengan tarif kelas diatas kelas 1 paling banyak 75%<br>
- Untuk pasien kelas 2 naik diatas kelas 1 membayar selisih biaya tarif INACBG kelas 1 dikurang tarif INACBG kelas 2 ditambah paling banyak 75% dari tarif kelas 1 INACBG<br>
<br>
Mode: 2<br>
- Untuk pasien kelas 1 naik diatas kelas 1 harus membayar selisih biaya tarif INACBG kelas 1 dengan tarif kelas diatas kelas 1 (akomodasi+visite) atau paling banyak 75% dari tarif inacbg<br>
- Untuk pasien kelas 2 naik diatas kelas 1 membayar selisih biaya tarif INACBG kelas 1 dikurang tarif INACBG kelas 2 ditambah tarif kelas diatas kelas 1 (akomodasi+visite) atau paling banyak 75% dari tarif kelas 1 INACBG
Mode: 3<br>
Sesuai simulasi perhitungan bpjs
<br>
Mode: 4br>
Sesuai simulasi perhitungan E-Klaim'
 WHERE pc.ID = 60;