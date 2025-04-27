Name: simgos
Version: VERSION
Release: RELEASE
Summary: Sistem Informasi Manajemen Generik Open Source
License: Kementerian Kesehatan RI
URL: https://simgos.kemkes.go.id
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-buildroot
%description
SIMGOS Ver. %{version}-%{release}
%prep
%setup -q
%install
mkdir -p "/root/rpmbuild/BUILDROOT/simgos-VERSION-RELEASE.x86_64"
cp -R * "/root/rpmbuild/BUILDROOT/simgos-VERSION-RELEASE.x86_64"
%files
%defattr(-,simgos,simgos,-)
/var/www/html/*
/var/tmp/simgos2
%pre
rpm -qa simgos | sed 's/simgos-//' | sed 's/.x86_64//' > /var/log/simgos-latest.txt
userexists=`sed -n "/^simgos/p" /etc/passwd`
if [ "$userexists" = "" ]; then
   sudo adduser simgos
   echo "51MG052" | sudo passwd simgos --stdin
fi
%post
chmod 755 -Rf /var/www/html/
chmod 777 -Rf /var/www/html/production/webapps/webservice/logs
chmod 777 -Rf /var/www/html/production/webapps/webservice/data/cache
chmod 777 -Rf /var/www/html/production/webapps/webservice/serial
chmod 777 -Rf /var/www/html/production/webapps/webservice/reports/output

rm -Rf /var/www/html/production/webapps/webservice/data/cache/*

if [ -f /var/run/yum.pid ]; then
   sudo kill `cat /var/run/yum.pid`
   sudo rm -rf /var/run/yum.pid
   sudo rm -rf /var/lib/rpm/.rpm.lock
   sudo yum-complete-transaction --cleanup-only 
fi

cd /var/tmp/simgos2/install
sudo chmod +x install.sh
sudo ./install.sh
exit 0

%changelog
* Tue Jul 9 2024 Team SIMGOS2 <teams@simgos.kemkes.go.id>
- Add: Form BarthelIndex
- Update: Penambahan property config untuk pembatalan kunjungan setalah gabung tagihan
- Add: Penambahan form observasi transfusi darah
- Add: Tombol cetak triage
- Add: Checklist untuk menampilkan history daftar dokumen pada pencetakan
- Update: Penambahan Paging List Kunjungan Retur Farmasi
- Update: Pengembangan menu paket tindakan farmasi
- Update: Penambahan validasi Status Barang di Mappingan barang Ruangan
- Update: Perbaikan order by history yang terlimit
- Add: Penamabahan inputan komponen darah pada saat order lab
- Update: Penambahan status verifikasi rm di grouping
- Update: Penyesuaian cetakan pengkajian awal untuk variabel keperawatan
- Fix: Perbaikan encounter untuk validasi final tampa diagnosis
- Update: Menampilkan umur menggunakan tanggal server di dashboard pasien
- Update: Proses Perhitungan BPJS Mode5
- Fix: Perbaikan filter tanggal buat pada monitoring jadwal kontrol
- Fix: Penerbitan surat kontrol berulang
- Fix: Perbaikan bug validasi status menyusui
- Update: Penambahan info alamat pemberi resep di layanan farmasi
- Fix: Perbaikan bug list obat diorder layanan farmasi
- Update: Menampilkan nomor antrian di dashbord pengunjung
