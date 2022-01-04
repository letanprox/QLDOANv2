-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 04, 2022 at 03:16 PM
-- Server version: 10.4.18-MariaDB
-- PHP Version: 7.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `qldoanv4`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Add_DA` (IN `idDA` CHAR(7), IN `ten` VARCHAR(255), IN `idCN` CHAR(2), IN `idGV` CHAR(7), IN `t` DATETIME, IN `file` VARCHAR(255), IN `details` VARCHAR(255))  begin
	if length(ten)<>0 THEN
        if length(file)<>0 then
        	
            select count(*) into @dem from phienbanhuongdan;
            if @dem=0 then 

                SET @maxid=1;
            else
                set @maxid=(select Max(MaCT)+1 from phienbanhuongdan);
            end if;
            insert into doan(MaDA,TenDA,MaCN) value(idDA,ten, idCN);
    
            insert into chitietchinhsuadoan(MaDA,MaGV,ThoiGian) value(idDA,idGV, t);
            insert into phienbanhuongdan(MaCT, Tep, MoTa, TrangThai, MaDA, MaGV, ThoiGian) 
            value(@maxid,file, details,0, idDA, idGV, t);
        end if;
    end if;
	

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AfterInsert_NV` (IN `idNV` VARCHAR(7))  begin
    declare tk char(6);
    declare dob date;
    DECLARE tmpquyen char(2);
    select MaTK into tk from NhanVien where MaNV=idNV;
    select NgaySinh into dob from NhanVien where MaNV=idNV;
    SELECT left(MaNV,2) into tmpquyen from NhanVien where MaNV=idNV;
    SET SQL_SAFE_UPDATES = 0;
    update TaiKhoan
    set TenDangNhap=idNV,
		Matkhau=Auto_PasswordSV(idNV, dob),
        Quyen=tmpquyen
    where maTK=tk;
    SET SQL_SAFE_UPDATES = 1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AfterInsert_QL` (`ID` CHAR(8), `tk` CHAR(5))  begin
    update TaiKhoan
    set TenDangNhap=ID,
		Mathau=ID,
        Quyen='QL'
    where maTK=tk;
	
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ChamDiem_HD` (IN `idPC` CHAR(7), IN `idGV` CHAR(7), IN `d` FLOAT)  BEGIN
select count(*) into @demDiem
from `chamdiemhd-pb`
where MaPhanCong=idPC; -- and Diem is not null;

if @demDiem=2 then 
	select 0 as status;
else 
	SELECT MaBC INTO @tmpIDBC
    FROM phancongdoan
    WHERE MaPhanCong=idPC;
	IF(d>=4 && @tmpIDBC is null) THEN
    	SELECT -1 as status;
    ELSE 
    	SET SQL_SAFE_UPDATES = 0;
        update `chamdiemhd-pb`
        set Diem=d
        where MaPhanCong=idPC and MaGV=idGV;
        SET SQL_SAFE_UPDATES = 1;
        select 1 as status;
    END if;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ChamDiem_PB` (IN `idPC` CHAR(7), IN `idGV` CHAR(7), IN `d` FLOAT)  BEGIN
select MaphanCong, count(*) into @tmpidPC, @demDiem
from chamdiemtb
where MaPhanCong=idPC;

if @demDiem<>0 then 
	select 0 as status;
else 
	SET SQL_SAFE_UPDATES=0;
	update `chamdiemhd-pb`
    set Diem=d
    where MaPhanCong=idPC and MaGV=idGV;
    SET SQL_SAFE_UPDATES=1;
    select 1 as status;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ChamDiem_TB` (IN `idPC` CHAR(7), IN `idTB` CHAR(6), IN `idGV` CHAR(7), IN `d` FLOAT)  BEGIN
select Ngay, Ca into @ngay, @ca
from tieuban
where MaTB=idTB;

select date(now()), time(now()) into @curDate, @curTime;
if DATEDIFF(@curDate,@ngay)=0 then 
	if @ca='SA' then 
		if TIMEDIFF(@curTime,'07:00:00')>0 then 
        	SET SQL_SAFE_UPDATES=0;
			update chamdiemtb
            set Diem=d
            where MaPhanCong=idPC and MaGV=idGV;
            SET SQL_SAFE_UPDATES=1;
            SELECT 1 as status;
		else
			SELECT 0 as status;
		end if;
	else
		if TIMEDIFF(@curTime,'12:00:00')>0  then 
        	SET SQL_SAFE_UPDATES=0;
			update chamdiemtb
            set Diem=d
            where MaPhanCong=idPC and MaGV=idGV;
            SET SQL_SAFE_UPDATES=1;
            SELECT 1 as status;
		else
			SELECT 0 as status;
		end if;
	end if;
else 

	SELECT 0 as status;
end if; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ChangePassword` (IN `idTK` CHAR(6), IN `oldPass` VARCHAR(255), IN `newPass` VARCHAR(255))  BEGIN
select MatKhau into @tmpPass
from taikhoan 
where MaTK=idTK;

if md5(oldPass)=@tmpPass then
	update taikhoan
    set MatKhau=md5(newPass)
    where MaTk=idTK;
    select 1 as status;
else 
	select 0 as status;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckLogin` (IN `username` VARCHAR(255), IN `pass` VARCHAR(255))  BEGIN
    
    select count(*) into @dem
    from taikhoan
    where TenDangNhap=upper(username) and md5(pass)=MatKhau;
    
    if @dem=0 then 
    select null;
    else
    	select DISTINCT(Quyen) into @tmpQuyen
        from taikhoan
        where TenDangNhap=upper(username) and md5(pass)=MatKhau;
        
        if @tmpQuyen='SV' then
			set @tmpTbl='sinhvien';
		else
            set @tmpTbl='nhanvien';
            set @tmpQuyen='NV';
		end if;
        
        set @sql= concat('select ',@tmpTbl,'.Ten',@tmpQuyen,'  as user,tk.Quyen\r\n\t\t\t\t\t\t\tfrom taikhoan tk, ',@tmpTbl,'\r\n\t\t\t\t\t\t\twhere tk.MaTK=',@tmpTbl,'.MaTK and TenDangNhap=upper(?) and md5(?)=MatKhau;');
		prepare stmt from @sql;                
		execute stmt using username, pass;   
        deallocate prepare stmt;
    end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_CN` (IN `idNganh` CHAR(2))  begin 
	SELECT TenCN, MaCN
    FROM chuyennganh
    where MaNganh=idNganh
    ORDER by TenCN ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_CN_GV` (IN `idGV` CHAR(7))  begin 
	SELECT TenCN, MaCN
    FROM chuyennganh
    where MaNganh=substring(idGV,3,2)
    ORDER by TenCN ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_HoiDong` ()  BEGIN
select MaHD, TenHD 
from hoidong;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_Khoa` (IN `idNganh` CHAR(2))  BEGIN
	
    
    SELECT COUNT(*) INTO @dem
    FROM(SELECT kh.namBD ,nganh.SoNam
    from DiemSang kh, nganh
    where kh.MaNganh=nganh.MaNganh and kh.MaNganh=idNganh) tmp;
    
    if @dem =0 then
    
		select SoNam into @tmp
        from nganh
        where MaNganh=idNganh;
		select Nienkhoahientai(idNganh) as namBD,  @tmp as SoNam;
     ELSE
     	SELECT kh.namBD ,nganh.SoNam
        from DiemSang kh, nganh
        where kh.MaNganh=nganh.MaNganh and kh.MaNganh=idNganh
        ORDER by namBD DESC;
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_Khoa_TK` (IN `idHD` INT)  BEGIN
select distinct(d.NamBD)
from diemsang d, nganh, hoidong hd
where d.MaNganh=nganh.MaNganh and nganh.MaHD=hd.MaHD and hd.MaHD=idHD
ORDER BY d.NamBD;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_Lop` (IN `khoa` YEAR, IN `idCN` CHAR(2))  BEGIN
	SELECT MaLop
	from lop
    where MaCN=idCN and SUBSTRING(MaLop, 2,2)=RIGHT(khoa,2);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_Nganh` ()  begin
	select TenNganh, MaNganh
    from nganh
	order by TenNganh ASC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_PhanCongDATB` (IN `khoa` YEAR, IN `idNganh` CHAR(2))  begin
select tblTB.MaTB, count(tblDATB.MaPhanCong) as total
from (
	select tmp1.MaTB, tb.ngay, tb.ca
	from (
		select MaTB, count(MaTB) as dem 
		from phanconggvtb group by MaTB
	) tmp1, tieuban tb
	where tmp1.MaTB=tb.MaTB and tb.MaNganh=idNganh and (tmp1.dem=3 or tmp1.dem=5) 
    and SUBSTRING(tmp1.MaTB, 3,2)=right(khoa, 2) 
    and (tb.ngay>curdate() or (tb.ngay=curdate() and tb.ca='CH' and CURTIME()<'12:00:00'))
) tblTB
LEFT JOIN
	(
		select distinct MaPhanCong, MaTB
		from chamdiemtb
    ) tblDATB
on tblTB.MaTB=tblDATB.MaTB
group by MaTB
order by `total` ASC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_PhanCongGVHD` (IN `khoa` YEAR, IN `idNganh` CHAR(2))  begin
select MaGV, TenGV, sum(dem) as total
from (
	select gv.MaNV as MaGV, gv.TenNV as TenGV, tmp.dem
	from nhanvien gv, 
		(select pc.MaGVHD as MaGV, count(pc.MaGVHD) as dem 
		from phancongdoan pc, taikhoan tk
		where pc.MaGVHD=tk.TenDangNhap and substring(pc.MaPhanCong,3,2)=right(khoa,2)
        group by pc.MaGVHD) as tmp
	where gv.MaNV=tmp.MaGV and gv.MaNganh=idNganh
	union 
	select gv.MaNV as MaGV, gv.TenNV as TenGV, 0
	from nhanvien gv, taikhoan tk
	where gv.MaNV=tk.TenDangNhap and gv.MaNganh=idNganh 
) temp
group by MaGV, TenGV
order by total ASC, MaGV ASC;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_PhanCongGVPB` (IN `idNganh` CHAR(2), IN `idSV` CHAR(10))  begin
select MaGVHD into @idGVHD
from phancongdoan
where MaSV=idSV;
select MaGV, TenGV, sum(dem) as total
from (
	select gv.MaNV as MaGV, gv.TenNV as TenGV, tmp.dem
	from nhanvien gv, 
		(select pc.MaGVPB as MaGV, count(pc.MaGVPB) as dem 
		from phancongdoan pc, taikhoan tk
		where pc.MaGVPB=tk.TenDangNhap
        group by pc.MaGVPB) as tmp
	where gv.MaNV=tmp.MaGV and gv.MaNganh=idNganh
	union 
	select gv.MaNV as MaGV, gv.TenNV as TenGV, 0
	from nhanvien gv, taikhoan tk
	where gv.MaNV=tk.TenDangNhap and gv.MaNganh=idNganh 
) temp
where MaGV<>@idGVHD
group by MaGV, TenGV
order by MaGV;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_PhanCongGVTB` (IN `idNganh` CHAR(2), IN `idTB` CHAR(6), IN `n` DATE, IN `g` TIME(2))  begin
select MaGV, gv.TenNV, count(MaTB) total 
	from phanconggvtb, nhanvien gv
	where MaGV in (
		select distinct (gv.MaNV)
		from tieuban tb, phanconggvtb pc, nhanvien gv
		where tb.MaTB=pc.MaTB and pc.MaGV=gv.MaNV  and gv.MaNganh=idNganh and (tb.ngay<>n or  (tb.ngay=n and tb.ca<>g))
	) and MaGV=gv.MaNV
	group by MaGV
    union
	select MaNV, TenNV,0
	from nhanvien, taikhoan
	where MaNganh=idNganh and MaNV=TenDangNhap 
	and MaNV not in (
		select distinct(MaGV) from phanconggvtb)
union
SELECT tmp.MaNV, tmp.TenNV, COUNT(tmp.MaNV)
FROM (SELECT nv.MaNV, nv.TenNV
    from nhanvien nv, phanconggvtb pc
    where nv.MaNV=pc.MaGV and pc.MaTB=idTB)tmp, phanconggvtb pc
WHERE tmp.MaNV=pc.MaGV
group by tmp.MaNV
	order by total asc, MaGV asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_SV` (IN `idGV` CHAR(7), IN `idCN` CHAR(2))  BEGIN
    select pc.MaSV, sv.tenSV, pc.MaDA
    from phancongdoan pc, sinhvien sv, lop, chuyennganh cn
    where pc.MaSV=sv.MaSV and sv.maLop=lop.MaLop and lop.MaCN=cn.MaCN and pc.MaGVHD=idGV and cn.MaCN=idCN;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CREATE_TKforSV` (`diem` FLOAT, `khoa` YEAR)  BEGIN
   	DECLARE demSV int;
    Declare demTK int;
    Declare ma char(10);
    Declare maTKTemp char(5);
    Declare dob date;
    DECLARE xSV int;
    declare xTK int;
    
    -- Xóa hết tất cả tài khoản SV của khóa hiện tại có GPA nhỏ hơn điểm
    
    update taikhoan
    set TenDangNhap='',
		MatKhau='',
        QUyen=''
	where TenDangNhap in (select MaSV from sinhvien where SUBSTRING(TenDangNhap, 2,2)=right(khoa, 2) and GPA<diem);
    
    
    
    drop temporary table if exists tmp ;
    create temporary table tmp (id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY) 
    select MaSV, NgaySinh from SinhVien where SUBSTRING(MaSV, 2,2)=right(khoa, 2) and GPA>=diem and MaTK is null;
    set demSV=(SELECT COUNT(*) FROM tmp );
    set demTK=(SELECT COUNT(*) FROM TaiKhoan where quyen='');
    set xSV=1;
    set xTK=1;
    loop_label:  LOOP
		IF  xSV > demSV THEN 
			LEAVE  loop_label;
		END  IF;
		
        if demTK<1 then
			INSERT INTO `taikhoan` (`MaTK`, `TenDangNhap`, `MatKhau`, `Quyen`) VALUES ('','', '', ''); 
		end if;
            set ma= (select MaSV from tmp where id=xSV);
            set dob=(select ngaySinh from tmp where id=xSV);
            set maTKTemp=(select min(MaTK)from TaiKhoan where quyen='');
			update SinhVien 
				set MaTK= maTKTemp
				where MaSV=ma;
            update TaiKhoan
				set TenDangNhap=ma,
					-- Matkhau=Auto_PasswordSV(ID, dob),
					MatKhau=Auto_PasswordSV(ma, dob),
                    Quyen='SV'
				where MaTK=maTKTemp;
			insert into doan(MaSV) value(ma);
		SET  xSV = xSV + 1;
        set demTK=demTK-1;
-- 		else
-- 			set xTK=xTK+1;
--             set ID= (select min(MaSV) from (select MaSV from SinhVien where GPA>=diem)as temp);
--             set ngaySinh=(select ngaySinh from SinhVien where MaSV=ID);
--             set maTKTemp=(select min(MaTK)from (select MaTK from TaiKhoan where quyen='')as temp);
-- 			update SinhVien 
-- 				set MaTK=maTKTemp
-- 				where MaSV=ID;
-- 			update TaiKhoan
-- 				set TenDangNhap=ID,
-- 					MaKhau=Auto_PasswordSV(ID, ngaySinh)
-- 				where MaTK=maTKTemp;
--             
-- 		end IF;
	END LOOP;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteSV` (IN `idSV` CHAR(10))  BEGIN
SELECT MaPhanCong into @idPC
FROM phancongdoan
WHERE MaSV=idSV;
SET SQL_SAFE_UPDATES=0;
DELETE FROM `chamdiemhd-pb` WHERE MaPhanCong=@idPC;
DELETE from baocao where LEFT(Tep, CHAR_LENGTH(idSV))=idSV;
 DELETE from phancongdoan where MaSV=idSV;
 
DELETE FROM `SinhVien` WHERE `MaSV` = idSV;
SET SQL_SAFE_UPDATES=1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_DA` (IN `idDA` CHAR(7))  BEGIN
SET SQL_SAFE_UPDATES = 0;
	delete from phienbanhuongdan where MaDA=idDA;
    delete from chitietchinhsuadoan where MaDA=idDA;
    delete from doan where MaDA=idDA;
SET SQL_SAFE_UPDATES = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_FileBC` (IN `idPC` CHAR(7))  BEGIN
select MaBC into @idBC
from phancongdoan
where MaPhanCong=idPC;

update baocao
set TrangThai=2
where MaBC=@idBC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_FileHD` (IN `idCT` INT)  BEGIN
    update phienbanhuongdan
    set TrangThai=2
    where MaCT=idCT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_TK` (IN `id` VARCHAR(10))  begin
		
		declare tbl char(2);
        declare idTK char(6);
        
		select Quyen into tbl
        from taikhoan 
        where TenDangNhap=id;
        
        select MaTK into idTK
        from taikhoan 
        where TenDangNhap=id;
        SET SQL_SAFE_UPDATES = 0;
        if tbl='SV' then
			update sinhvien
            set MaTK=null
            where MaSV=id;
		elseif tbl='GV' or tbl='QL' then
			update nhanvien
            set MaTK=null
            where MaNV=id;
		end if;
        update TaiKhoan
        set TenDangNhap=null,
			MatKhau=null,
            Quyen=null
		where MaTK=idTK;
        SET SQL_SAFE_UPDATES = 1;
	end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_TKSV` (IN `idNganh` CHAR(2))  BEGIN
update taikhoan
set quyen=null 
where substring(TenDangNhap,6,2)=idNganh;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Insert_ChamDiemTB` (`maDA` CHAR(5), `maTB` CHAR(4))  BEGIN
	DECLARE x  INT;
        
	SET x = 1;
	
    CREATE TEMPORARY TABLE tmp (id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY) 
	SELECT MaGV AS MaGV FROM phanconggvtb
	WHERE phanconggvtb.maTB=maTB;    
	loop_label:  LOOP
		IF  x > 5 THEN 
			LEAVE  loop_label;
		END  IF;
            
		SET  x = x + 1;
		insert into ChamDiemTB (MaDA, MaGV, MaTB) values(maDA, (select maGV from tmp where id=x), maTB);
	END LOOP;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Insert_SV` (IN `khoa` YEAR, IN `idNganh` CHAR(2), IN `idLop` CHAR(11), IN `idSV` CHAR(10), IN `ten` VARCHAR(50), IN `dob` DATE, IN `gpa` FLOAT, IN `sdt` CHAR(10))  begin
                declare demKhoa int;
                declare demLop int;
                select count(*) into demKhoa from DiemSang where MaNganh=idNganh and NamBD=khoa;
                if demKhoa=0 then
                    INSERT INTO `DiemSang` (`MaNganh`, `NamBD`) VALUES (idNganh,khoa);
                end if;
                select count(*) into demLop from Lop where MaLop=idLop;
                if(demLop=0) then
                    INSERT INTO `lop` (`Malop`, `MaCN`) VALUES (idLop,substring(idLop, 6,2));
                end if;
                INSERT INTO `sinhvien` (`MaSV`, `TenSV`, `NgaySinh`, `MaLop`, `GPA`,`SDT`, `Email`) VALUES (idSV,ten,dob,idLop,gpa,sdt,Auto_EmailSV(idSV));
            end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `NopBaoCao` (IN `idPC` CHAR(7), IN `diemArray` VARCHAR(50), IN `file` VARCHAR(255), IN `details` VARCHAR(255), IN `t` DATETIME)  BEGIN
-- declare flag int;
set @flag=1;
set @count=0;
myloop: WHILE (LOCATE('-', diemArray) > 0)
DO
    SET @diem = substring(diemArray, 1, LOCATE('-',diemArray)-1);
    SET diemArray= SUBSTRING(diemArray, LOCATE('-',diemArray) + 1);
    if @diem<4 then 
		set @flag=0;
        LEAVE myloop;
	end if;
    set @count=@count+1;
END WHILE;
if @flag=0 then
	select -1 as STATUS; -- Bạn không thể nộp báo cáo
else
 	SET SQL_SAFE_UPDATES = 0;
	if @count=0 then 
		select MaBC, MaSV into @idBC, @idSV from phancongdoan 
		where MaPhanCong=idPC; 
        if @idBC is null then 
			select count(*)+1 into @maxIDBC from baocao;
            UPDATE baocao
            	SET trangthai=2
            where LEFT(Tep, CHAR_LENGTH(@idSV))=@idSV;
			insert baocao(MaBC, Tep, MoTa, TrangThai, ThoiGian) value(@maxIDBC, file, details, 1, t);
           
            update phancongdoan
            set MaBC=@maxIDBC
            where MaPhanCong=idPC;
            
			select 1 as STATUS; -- Thành công
		else 
			update baocao
            set 
				Tep=file,
                MoTa=details,
                TrangThai=1
			where MaBC=@idBC;
            select 1 as STATUS; -- Thành công
		end if;
    elseif @count=3 then 
		select distinct(cd.MaTB), tb.Ngay into @tmp, @ngay 
        from chamdiemtb cd, tieuban tb
        where cd.MaTB=tb.MaTB and cd.MaPhanCong=idPC;
        
        if date(now())<@ngay then
			select MaBC into @idBC from  phancongdoan 
            where MaPhanCong=idPC;
            update baocao
            set 
				Tep=file,
                MoTa=details,
                TrangThai=1
			where MaBC=@idBC;
            select 1 as STATUS; -- Thành công
		else 
			select 0 as STATUS; -- 'Đã quá hạn báo cáo'
		end if;
	else
		select MaBC into @idBC from phancongdoan 
		where MaPhanCong=idPC; 
        update baocao
            set 
				Tep=file,
                MoTa=details,
                TrangThai=1
			where MaBC=@idBC;
        select 1 as STATUS; -- Thành công
	end if;
    SET SQL_SAFE_UPDATES = 1;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PhanCong_DA` (IN `idGV` CHAR(7), IN `idSV` CHAR(10), IN `idDA` CHAR(7), IN `idCT` INT)  BEGIN
	SELECT NgayPhanCong into @tmpDate
    from phancongdoan
    where MaSV=idSV and MaGVHD=idGV;
    SET SQL_SAFE_UPDATES=0;
    if @tmpDate is not null THEN
		if date(now())<=(@tmpDate+INTERVAL 7 DAY) then
        	SELECT COUNT(MaDA) INTO @tmpDemDA
            from phancongdoan
            WHERE MaDA=idDA and MaSV<>idSV;
            IF @tmpDemDA=0 THEN
                update phancongdoan
                set MaDA=idDA,
                    MaCt=idCT
                where MaSV=idSV and MaGVHD=idGV;
                select 1 as status;
            ELSE
            	SELECT 2 AS status;
            END if;
		else
			select -1 as status;
		end if;
	else
		update phancongdoan
		set MaDA=idDA,
			MaCt=idCT,
			NgayPhanCong=date(now())
		where MaSV=idSV and MaGVHD=idGV;
        select 1 as status;
    end if;
    SET SQL_SAFE_UPDATES=1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PhanCong_DATB` (IN `idSV` CHAR(10), IN `idTB` CHAR(6))  BEGIN
	declare dem int;
    SELECT MaPhanCong into @idPC
    from phancongdoan
    where MaSV=idSV;
    select count(MaPhanCong) into dem 
    from chamdiemtb
    where MaPhanCong=@idPC;
    if dem=0 then
        insert into chamdiemtb(MaGV, MaTB, MaPhanCong)
        select *,@idPC
        from phanconggvtb
        where MaTB=idTB;
    else 
		
        
         /*insert into chamdiemtb(MaPhanCong, MaGV, MaTB)
		select tmp.MaPhanCong, tmp.MaGV, tmp.MaTB from
        (select idPC as MaPhanCong, MaGV, idTB as MaTB
		from phanconggvtb
		where MaTB=idTB) as tmp
		on duplicate key update MaPhanCong=tmp.MaPhanCong,tmp.MaGV=tmp.MaGV, MaTB=tmp.MaTB;
    delete from chamdiemtb where MaPhanCong=idPC and MaTB<>idTB;*/
    
    
    
		delete from chamdiemtb where MaPhanCong=@idPC;
        insert into chamdiemtb(MaGV, MaTB,MaPhanCong)
        select *,@idPC
			from phanconggvtb
			where MaTB=idTB;
    end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PhanCong_GVHD` (IN `idSV` CHAR(10), IN `idGV` CHAR(7))  begin
			declare demTK int;
            -- declare tmpTK char(5);
            declare tmpIDPC char(7);
            declare isExitPC int; 
            declare tmpIDGVHD char(8);
            select count(*) into isExitPC from phancongdoan where MaSV=idSV;
            SET FOREIGN_KEY_CHECKS=0;
            SET SQL_SAFE_UPDATES = 0;
            if isExitPC= 0 then
            select NgaySInh into @dob from sinhvien where MaSV=idSV;
				select AUTO_GetMaTK() into @tmpTK;
                
                
				update TaiKhoan
				set TenDangNhap=idSV,
					MatKhau=Auto_PasswordSV(idSV, @dob),
                    Quyen='SV'
				where MaTK=@tmpTK;
                
                update SinhVien
                set MaTK=@tmpTK
                where MaSV=idSV;
                
                select AUTO_IDPC(idSV) into tmpIDPC;
				INSERT INTO `phancongdoan` (`MaPhanCong`,`MaSV`, `MaGVHD`) VALUES (tmpIDPC,idSV, idGV);
                insert into `chamdiemhd-pb`(MaPhanCong, MaGV) values (tmpIDPC, idGV);
			else 
				select MaPhanCong, MaGVHD into tmpIDPC, tmpIDGVHD from phancongdoan where MaSV=idSV;
                
                update `phancongdoan`
                    set
                        MaGVHD=idGV
                    where MaPhanCOng=tmpIDPC;

                    update `chamdiemhd-pb`
                    set
                        MaGV=idGV
                    where MaPhanCong=tmpIDPC;
            end if;
            SET FOREIGN_KEY_CHECKS=1;
            SET SQL_SAFE_UPDATES = 1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PhanCong_GVPB` (IN `idSV` CHAR(10), IN `idGV` CHAR(7))  BEGIN
	declare dem int;
    declare oldGV char(7);
    declare tmpIDPC char(7);
	SELECT MaPhanCong into tmpIDPC from phancongdoan where MaSV=idSV;
    select count(*) INTO dem from `chamdiemhd-pb` where MaPhanCong=tmpIDPC;
	/*UPDATE doan
    SET
    	MaGVPB=idGV
    where MaPhanCong=idPC;
    SELECT COUNT(*) into dem 
    from `chamdiemhd-pb` 
    where MaPhanCong=idPC;
    select MaGVPB into tmpGV from doan where MaPhanCong=idPC;*/
    SET SQL_SAFE_UPDATES=0;
    if dem=2 THEN
		select MaGVPB into oldGV
        from phancongdoan
        where MaPhanCong=tmpIDPC;
        
        insert into `chamdiemhd-pb`(MaPhanCong, MaGV) values (tmpIDPC, idGV);
        delete from `chamdiemhd-pb` where MaPhanCong=tmpIDPC and MaGV=oldGV;
        /*UPDATE `chamdiemhd-pb`
        SET 
        	MaGV=idGV,
            diem=null
        where MaPhanCong=idPC and MaGV=oldGV;*/
    ELSE
     	insert into `chamdiemhd-pb`(MaPhanCong, MaGV) values (tmpIDPC, idGV);
    end if;
    UPDATE phancongdoan
    SET
    	MaGVPB=idGV
    where MaPhanCong=tmpIDPC;
    SET SQL_SAFE_UPDATES=1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PhanCong_GVTB` (`GVArray` VARCHAR(255), `idTB` CHAR(6))  BEGIN
	DROP TEMPORARY TABLE IF EXISTS temp_table;
	CREATE TEMPORARY TABLE temp_table (MaGV char(7), MaTB char(6));
	WHILE (LOCATE(',', GVArray) > 0)
	DO
		SET @value = left(GVArray,LOCATE(',',GVArray)-1);
		SET GVArray= SUBSTRING(GVArray, LOCATE(',',GVArray) + 1);
		INSERT INTO `temp_table` VALUES(@value, idTB);
	END WHILE;
		
	select count(*) into @dem from phanconggvtb where MaTB=idTB;
	SET FOREIGN_KEY_CHECKS=0;
	SET SQL_SAFE_UPDATES = 0;
	delete from phanconggvtb where MaTB=idTB;
	insert into phanconggvtb (MaGV,MaTB)
	select * from temp_table;
	SET SQL_SAFE_UPDATES = 1;
	SET FOREIGN_KEY_CHECKS=1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShonInfor_DA_Update` (IN `idDA` CHAR(7), IN `idGV` INT(7))  BEGIN
    select pb.MaCT, tmp.TenDA, tmp.MaCN, pb.MoTa, substring(pb.Tep,char_length(concat(pb.MaDA, pb.MaGV,pb.ThoiGian))-5+1) as 'Tep_Goc', pb.Tep
from (select MaDA, TenDA, MaCN
		from doan da
		where MaDA=idDA)tmp
left join phienbanhuongdan pb
on pb.MaDA=tmp.MaDA and pb.MaGV=idGV and pb.TrangThai=0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowDiem` (IN `idPC` CHAR(7), IN `idGV` CHAR(7))  BEGIN
select Diem
from (select MaPhanCong
	from phancongdoan 
	where MaPhanCong=idPC) tmp
LEFT JOIN chamdiemtb cd
on tmp.MaPhanCong=cd.MaPhanCong and cd.MaGV=idGV;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowFile_BaoCao` (IN `idPC` CHAR(7))  BEGIN
select bc.MaBC, substring(bc.tep, 10+7+8+6+1) as Tep_Goc, bc.Tep, bc.MoTa, bc.ThoiGian 
from (select MaBC 
		from phancongdoan 
		where MaPhanCong=idPC) tmp
left join baocao bc
on tmp.MaBC=bc.MaBC and bc.TrangThai=1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowFullDiem` (IN `idSV` CHAR(10))  BEGIN
select tmp1.MaPhanCong, tmp1.MaGVHD, tmp1.TenGVHD, tmp1.DiemHD, tmp1.MaGVPB, tmp1.TenGVPB, tmp1.DiemPB, tmp2.MaTB, tmp2.DiemTB, tmp2.soLuongDiem, tmp2.soLuongGV
from (select tmp.MaPhanCong, tmp.MaGVHD, tmp.TenGVHD, tmp.DiemHD, tmp.MaGVPB, gv.TenNV as TenGVPB, tmp.DiemPB
		from (select tmp.MaPhanCong, tmp.MaGVHD, tmp.TenGVHD, tmp.DiemHD, tmp.MaGVPB, cdpb.Diem as DiemPB
				from (select pc.MaPhanCong, pc.MaGVHD, gv.tenNV as TenGVHD, cdhd.Diem as DiemHD, pc.MaGVPB
						from phancongdoan pc, `chamdiemhd-pb` cdhd, nhanvien gv
						where pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV and cdhd.MaGV=gv.MaNV and pc.MaSV=idSV) tmp
				left join `chamdiemhd-pb` cdpb
				on tmp.MaPhanCong=cdpb.MaPhanCong and tmp.MaGVPB=cdpb.MaGV) tmp
                left join nhanvien gv
		on tmp.MaGVPB=gv.MaNV) tmp1
left join (select cd.MaPhanCong, cd.MaTB,AVG(cd.Diem) as DiemTB, count(cd.Diem) as soLuongDiem, count(*) as soLuongGV
			from chamdiemtb cd
			group by cd.MaPhanCong, cd.MaTB) tmp2
on tmp1.MaPhanCong=tmp2.MaPhanCong;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowInfor_ChamDiem` (IN `idSV` CHAR(10))  BEGIN
select tmp1.MaPhanCong, tmp1.MaSV, tmp1.TenSV, tmp1.SDT, tmp1.Email, tmp1.GPA, tmp1.MaLop, tmp1.TenNganh, tmp1.TenCN, tmp1.MaDA, tmp1.TenDA, tmp1.`Tep_HDGoc`, tmp1.TepHD, tmp2.MoTa as MoTaHD, tmp2.Tep_BCGoc, tmp2.TepBC, tmp2.MoTa as MoTaBC, tmp2.DiemHD, tmp2.DiemPB, tmp2.DiemTB, tmp2.slDiem
from (select tmp1.MaPhanCong, tmp1.MaSV, tmp1.TenSV, tmp1.SDT, tmp1.Email, tmp1.GPA, tmp1.MaLop, tmp1.TenNganh, tmp1.TenCN, tmp2.MaDA, tmp2.TenDA, tmp2.`Tep_Goc` as 'Tep_HDGoc', tmp2.Tep as TepHD, tmp2.MoTa
		from (select pc.MaPhanCong, sv.MaSV, sv.TenSV, sv.SDT, sv.Email, sv.GPA, sv.MaLop, nganh.TenNganh, cn.TenCN
				from sinhvien sv, lop, chuyennganh cn, nganh, phancongdoan pc
				where pc.MaSV=sv.MaSV and sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and sv.MaSV=idSV) tmp1
		left join (select pc.MaPhanCong, pc.MaDA, da.TenDA, substring(pb.Tep,char_length(concat(pb.MaDA, pb.MaGV,pb.ThoiGian))-5+1) as 'Tep_Goc', pb.Tep, pb.MoTa
					from phancongdoan pc, doan da, phienbanhuongdan pb
					where pc.MaDA=da.MaDA and pc.MaCT=pb.MaCT) tmp2
		on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp1
left join (select tmp1.MaPhanCong, tmp1.Tep_BCGoc, tmp1.TepBC, tmp1.MoTa, tmp1.DiemHD, tmp1.Diem as DiemPB, tmp2.DiemTB, tmp2.slDiem
from (select tmp.MaPhanCong,tmp.Tep_BCGoc, tmp.TepBC, tmp.MoTa, tmp.DiemHD, cdpb.Diem
		from (select tmp1.MaPhanCong, tmp1.`Tep_Goc` as Tep_BCGoc, tmp1.Tep as TepBC, tmp1.MoTa, tmp2.Diem as DiemHD, tmp2.MaGVPB
				from (select pc.MaPhanCong, substring(bc.Tep,char_length(pc.MaPhanCong)+1) as 'Tep_Goc', bc.Tep, bc.MoTa
						from phancongdoan pc, baocao bc
						where pc.MaBC=bc.MaBC) tmp1
					left join (select pc.MaPhanCong, cdhd.Diem, pc.MaGVPB
								from phancongdoan pc, `chamdiemhd-pb` cdhd
								where pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV) tmp2
					on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp 
			left join `chamdiemhd-pb` cdpb
			on tmp.MaPhanCong=cdpb.MaPhanCong and tmp.MaGVPB=cdpb.MaGV ) tmp1
	left join (select tmp.MaPhanCong,AVG(cd.diem) as DiemTB, tmp.slDiem
				from (select MaPhanCong, count(*) as slDiem 
						from chamdiemtb where diem is not null
						group by MaPhanCong) as tmp, chamdiemtb cd
				where cd.MaPhanCong=tmp.MaPhanCong) tmp2
	on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp2
on tmp1.MaPhanCong=tmp2.MaPhanCong;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowInfor_DA` (IN `idGV` CHAR(7), IN `idDA` CHAR(7), IN `idCT` INT)  BEGIN
select tmp1.MaDA, tmp1.TenDA, tmp1.MaCN, tmp1.tenCN, tmp1.`MaNguoiTaoDA`, tmp1.`TenNguoiTaoDA`, tmp1.NgayTao, tmp1.`Tep_Goc`, tmp1.MaNguoiCapNhat, tmp1.TenNguoiCapNhat, tmp1.NgayCapNhat, tmp1.Tep, tmp1.MoTa, tmp2.MaSV 
from (select tmp1.MaDA, tmp1.TenDA, tmp1.MaCN, tmp1.tenCN, tmp1.MaGV as 'MaNguoiTaoDA', tmp1.TenGV as 'TenNguoiTaoDA', tmp1.minThoiGian as 'NgayTao', tmp2.`Tep_Goc`, tmp2.MaGV as 'MaNguoiCapNhat', tmp2.TenNV as 'TenNguoiCapNhat', tmp2.ThoiGian as 'NgayCapNhat', tmp2.Tep, tmp2.MoTa
		from (select tmp.MaDA, da.TenDA, da.MaCN, cn.tenCN, tmp.MaGV, gv.TenNV as TenGV, date(tmp.minThoiGian) as minThoiGian
				from (select tmp.MaDA, ct.MaGV, tmp.minThoiGian
						from (select MaDA, min(ThoiGian) as minThoiGian
								from chitietchinhsuadoan 
								where MaDA=idDA
								group by MaDA) tmp, chitietchinhsuadoan ct
						where tmp.MaDA=ct.MaDA and tmp.minthoiGian=ct.ThoiGian) tmp, doan da, chuyennganh cn, nhanvien gv
				where tmp.MaDA=da.MaDA and cn.MaCN=da.MaCN and tmp.MaGV=gv.MaNV) tmp1
		left join (select pb.MaDA, substring(pb.Tep,char_length(concat(pb.MaDA, pb.MaGV,pb.ThoiGian))-5+1) as 'Tep_Goc', pb.MaGV, gv.TenNV, date(pb.ThoiGian) as ThoiGian, pb.Tep, pb.MoTa
				from phienbanhuongdan pb, nhanvien gv
				where pb.MaGV=gv.MaNV and pb.MaCT=idCT) tmp2
		on tmp1.MaDA=tmp2.MaDA) tmp1
left join (select MaDA, MaSV 
			from phancongdoan 
			where MaGVHD=idGV and MaDA=idDA and MaCT=idCT and substring(MaPhanCong,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2)) tmp2
on tmp1.MaDA=tmp2.MaDA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowInfor_GV` (IN `idGV` CHAR(7))  BEGIN 
SELECT gv.MaNV, gv.TenNV, gv.NgaySinh, gv.MaNganh, nganh.TenNganh, gv.SDT, gv.Email
from nhanvien gv, nganh
where gv.MaNganh=nganh.MaNganh and MaNV=idGV;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowInfor_SV` (IN `idSV` CHAR(10))  BEGIN
select sv.MaSV, sv.TenSV,sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop,sv.SDT, sv.Email, sv.GPA
        from sinhvien sv, lop, chuyennganh cn, nganh 
        WHERE sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and MaSV=idSV;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowInfor_SVHD` (IN `idSV` CHAR(10))  begin
    SELECT COUNT(*) INTO @isExit 
    FROM phancongdoan 
    where MaSV=idSV;
    select MaDA into @tmpDA from phancongdoan where MaSV=idSV;
    if @isExit=0 THEN
    	select sv.MaSV, sv.TenSV,sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop,sv.SDT, sv.Email, sv.GPA, '' as 'MaDA', '' as 'TenDA', '' as Diem, null as MaGVHD
        from sinhvien sv, lop, chuyennganh cn, nganh 
        WHERE sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and MaSV=idSV;
    ELSE
    	IF(@tmpDA is null) THEN
        	select sv.MaSV, sv.TenSV,sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop,sv.SDT, sv.Email, sv.GPA,  '' as 'MaDA', '' as 'TenDA', '' as Diem, pc.MaGVHD
        	from SinhVien sv, lop, chuyennganh cn, nganh, PhanCongDoAn pc
            WHERE sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and sv.MASV=pc.MaSV and sv.MaSV=idSV;
        ELSE   
            select sv.MaSV, sv.TenSV,sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop,sv.SDT, sv.Email, sv.GPA,  pc.MaDA, da.TenDA, cd.Diem, pc.MaGVHD
            from SinhVien sv, lop, chuyennganh cn, nganh, PhanCongDoAn pc,Doan da, `chamdiemhd-pb` cd
            where sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and sv.MASV=pc.MaSV and pc.MaDA=da.MaDA and pc.MaPhanCong=cd.MaPhanCong and pc.MaGVHD=cd.MaGV and sv.MaSV=idSV;
        END if;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowInfor_SVPB` (IN `idSV` CHAR(10))  begin
    SELECT COUNT(*) INTO @isExit 
    FROM PhanCongdoan pc, `chamdiemhd-pb` cd
    where pc.MaPhanCong=cd.MaPhanCong and MaSV=idSV;
    if @isExit=1 THEN
    	select sv.MaSV, sv.TenSV, sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop, sv.SDT, sv.Email, sv.GPA, pc.MaDA, da.TenDA,pc.MaGVHD,gvhd.TenNV as 'TenGVHD', cdhd.Diem as 'DiemHD', '' as 'DiemPB', pc.MaGVPB
        from sinhvien sv, lop, chuyennganh cn, nganh, PhanCongdoan pc, doan da,nhanvien gvhd,`chamdiemhd-pb` cdhd
        WHERE sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and sv.MaSV=pc.MaSV and pc.MaDA=da.MaDA and pc.MaGVHD=gvhd.MaNV and pc.MaPhanCong=cdhd.MaPhanCong and sv.MaSV=idSV;
    ELSE
		select tmp.MaSV, tmp.TenSV, tmp.NgaySinh, tmp.TenNganh, tmp.TenCN, tmp.MaLop, tmp.SDT, tmp.Email, tmp.GPA, tmp.MaDA, tmp.TenDA,tmp.MaGVHD,tmp.TenGVHD, tmp.DiemHD, tmp.MaGVPB, ifnull(cdpb.Diem,'') as 'DiemPB'
from(select distinct tmp.*
        from (select sv.MaSV, sv.TenSV, sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop, sv.SDT, sv.Email, sv.GPA, pc.MaDA, da.TenDA,pc.MaGVHD,gvhd.TenNV as 'TenGVHD', cdhd.Diem as 'DiemHD', ifnull(pc.MaGVPB,'') as MaGVPB, pc.MaPhanCong
                from sinhvien sv, lop, chuyennganh cn, nganh, PhanCongdoan pc, doan da ,nhanvien gvhd,`chamdiemhd-pb` cdhd
                where sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and sv.MaSV=pc.MaSV and pc.MaGVHD=gvhd.MaNV and pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV and pc.MaDA=da.MaDA and sv.MaSV=idSV) tmp
        left join nhanvien gvpb
        on MaGVPB=gvpb.MaNV) tmp
left join `chamdiemhd-pb` cdpb
on tmp.MaPhanCong=cdpb.MaPhanCong and tmp.MaGVPB=cdpb.MaGV ;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowInfor_SVTB` (IN `idSV` CHAR(10))  BEGIN
SELECT COUNT(*) INTO @isExit 
    FROM PhanCongdoan pc, `chamdiemtb` cd
    where pc.MaPhanCong=cd.MaPhanCong and MaSV=idSV;
    if @isExit=0 THEN
		select sv.MaSV, sv.TenSV,sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop,sv.SDT, sv.Email, sv.GPA, pc.MaPhanCong, da.TenDA,pc.MaGVHD,gvhd.TenNV as 'TenGVHD', cdhd.Diem as 'DiemHD', pc.MaGVPB,gvpb.TenNV as 'TenGVPB', cdpb.Diem as 'DiemPB', '' as DiemTB, 0 as slDiem, null as MaTB
        from sinhvien sv, lop, chuyennganh cn, nganh, phancongdoan pc, doan da,nhanvien gvhd,`chamdiemhd-pb` cdhd, nhanvien gvpb,`chamdiemhd-pb` cdpb
        where sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and sv.MaSV=pc.MaSV and pc.MaDA=da.MaDA and pc.MaGVHD=gvhd.MaNV and pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV
        and pc.MaGVPB=gvpb.MaNV and pc.MaPhanCong=cdpb.MaPhanCong and pc.MaGVPB=cdpb.MaGV and sv.MaSV=idSV;
    else
	select sv.MaSV, sv.TenSV,sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop,sv.SDT, sv.Email, sv.GPA, pc.MaPhanCong, da.TenDA,pc.MaGVHD,gvhd.TenNV as 'TenGVHD', cdhd.Diem as 'DiemHD', pc.MaGVPB,gvpb.TenNV as 'TenGVPB', cdpb.Diem as 'DiemPB', tempDiem.DiemTB, tempDiem.slDiem, tempDiem.MaTB
	from sinhvien sv, lop, chuyennganh cn, nganh, phancongdoan pc, doan da,nhanvien gvhd,`chamdiemhd-pb` cdhd, nhanvien gvpb,`chamdiemhd-pb` cdpb,
			(
				select tmp.MaPhanCong, tmp.MaTB,AVG(cd.diem) as DiemTB, tmp.slDiem
				from (
					select tmp.MaPhanCong, tmp.MaTB, count(*) as slDiem 
                    from ( select DISTINCT(MaPhanCong), MaTB
							from chamdiemtb ) tmp
					left join chamdiemtb cd
                    on tmp.MaPhanCong=cd.MaPhanCong 
                    group by cd.MaPhanCong
				) as tmp left join chamdiemtb cd
				on cd.MaPhanCong=tmp.MaPhanCong
                group by cd.MaPhanCong
            ) tempDiem
        where sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and sv.MaSV=pc.MaSV and pc.MaDA=da.MaDA and pc.MaGVHD=gvhd.MaNV and pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV
        and pc.MaPhanCong=tempDiem.MaPhanCong
        and pc.MaGVPB=gvpb.MaNV and pc.MaPhanCong=cdpb.MaPhanCong and pc.MaGVPB=cdpb.MaGV and sv.MaSV=idSV;
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowInfor_TB` (IN `idTB` CHAR(6))  BEGIN
    select tb.MaTB, tb.Ngay, tb.Ca, pc.MaGV, gv.TenNV as TenGV
from tieuban tb, phanconggvtb pc, nhanvien gv
where tb.MaTB=pc.MaTB and pc.MaGV=gv.MaNV and tb.MaTB=idTB;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowInfor_User` (IN `id` VARCHAR(10))  BEGIN
select count(*) into @dem
from sinhvien where MaSV=id;
if @dem =0 then 
	set @tbl='nhanvien';
    set @tmp='NV';
else 
	set @tbl='sinhvien';
    set @tmp='SV';
end if;

set @sql= concat('select *\r\n\t\t\t\tfrom ',@tbl,'\r\n\t\t\t\twhere Ma',@tmp,'=?');

prepare stmt from @sql; 
execute stmt using id;
deallocate prepare stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_DA` (IN `idCN` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
select *
from (select tmp.MaDA, tmp.TenDA, tmp.MaCN, tmp.tenCN, tmp.MaGV, tmp.TenGV, tmp.minThoiGian, tmp.maxThoiGian, IFNULL(tmp1.MaSV,'') AS MaSV , IFNULL(tmp1.TenSV,'') AS TenSV, tmp1.NgayPhanCong, tmp1.MaCT
		from (select tmp.MaDA, da.TenDA, da.MaCN, cn.tenCN, tmp.MaGV, gv.TenNV as TenGV, date(tmp.minThoiGian) as minThoiGian, date(tmp.maxThoiGian) as maxThoiGian
				from (select tmp.MaDA, ct.MaGV, tmp.minThoiGian, tmp.maxThoiGian
						from (select MaDA, min(ThoiGian) as minThoiGian, max(ThoiGian) as maxThoiGian
								from chitietchinhsuadoan 
								group by MaDA) tmp, chitietchinhsuadoan ct
						where tmp.MaDA=ct.MaDA and tmp.minthoiGian=ct.ThoiGian) tmp, doan da, chuyennganh cn, nhanvien gv
				where tmp.MaDA=da.MaDA and cn.MaCN=da.MaCN and tmp.MaGV=gv.MaNV and da.MaCN=idCN GROUP by da.TenDA) tmp
		left join (select pc.MaDA, pc.MaSV, sv.TenSV, pc.NgayPhanCong, pc.MaCT
				from phancongdoan pc, sinhvien sv
				where pc.MaSV=sv.MaSV and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(@idNganh),2)) tmp1
		on tmp1.MaDA= tmp.MaDA
		group by tmp.MaDA) tmp 
where concat('.', MaDA, '.', TenDA, '.', MaCN, '.', tenCN, '.', MaGV, '.', TenGV, '.', minThoiGian, '.', maxThoiGian, '.', MaSV, '.', TenSV, '.') like concat('%',tukhoa,'%')
order by maxThoiGian DESC, MaDA ASC
limit 10 offset  os;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_DAofGV` (IN `idGV` CHAR(7), IN `idCN` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
select *
from (select tmp.MaDA, tmp.TenDA, tmp.TenCN, tmp.ThoiGian, tmp.pbFileKhac, tmp.totalPC, IFNULL(tmp1.MaSV,'') AS MaSV , IFNULL(tmp1.TenSV,'') AS TenSV, tmp1.NgayPhanCong, tmp1.MaCT
		from (select tmp.MaDA, tmp.TenDA, tmp.TenCN, date(tmp.ThoiGian) as ThoiGian, tmp.pbFileKhac, count(pc.MaDA) as totalPC
				from (select tmp.MaDA, da.TenDA, cn.TenCN, tmp.ThoiGian, tmp.pbFileKhac
						from (SELECT tmp.MaDA,tmp.ThoiGian,COUNT(pb.MaDA) as pbFileKhac
								FROM (select tmp.MaDA, tmp.ThoiGian
										from (select MaDA, min(ThoiGian) as ThoiGian
												from chitietchinhsuadoan
												group by MaDA) tmp, chitietchinhsuadoan ct
										where tmp.MaDA=ct.MaDA and tmp.ThoiGian=ct.ThoiGian and MaGV=idGV) tmp
								LEFT JOIN phienbanhuongdan pb
								ON  tmp.MaDA = pb.MaDA
								and pb.MaGV<>idGV
								group by tmp.MaDA) tmp, doan da, chuyennganh cn
						where tmp.MaDA=da.MaDA and da.MaCN=cn.MaCN and da.MaCN=idCN) tmp
				LEFT JOIN phancongdoan pc
				on pc.MaDA=tmp.MaDA
				group by tmp.MaDA) tmp
		LEFT JOIN (select pc.MaDA, pc.MaSV, sv.TenSV, pc.NgayPhanCong, pc.MaCT
					from phancongdoan pc, sinhvien sv
					where pc.MaSV=sv.MaSV and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2)) tmp1
		on tmp1.MaDA=tmp.MaDA   
		group by tmp.MaDA) tmp
where concat('.', MaDA, '.', TenDA, '.', ThoiGian, '.', MaSV, '.', TenSV, '.') like concat('%',tukhoa,'%')
order by MaDA ASC
limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_Files` (IN `idDA` CHAR(7), IN `idGV` CHAR(7), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
select *
from (select tmp.MaCT, tmp.`Tep_Goc`, tmp.MoTa, tmp.MaGV, tmp.TenNV, tmp.ThoiGian, tmp.Tep, tmp.Loai,  count(pc.MaPhanCong) as TrangThai
		from
			(select pb.MaCT, substring(pb.Tep,char_length(concat(pb.MaDA, pb.MaGV,pb.ThoiGian))-5+1) as 'Tep_Goc', pb.MoTa, pb.MaGV, gv.TenNV, date(pb.ThoiGian) as ThoiGian, pb.Tep, pb.TrangThai as Loai
			from phienbanhuongdan pb, nhanvien gv
			where pb.MaGV=gv.MaNV and pb.MaDA=idDA and TrangThai<>2) tmp
		Left join phancongdoan pc
		on tmp.MaCT=pc.MaCT
		group by tmp.MaCT) tmp
where concat('.', `Tep_Goc`, '.', MaGV, '.', TenNV, '.', ThoiGian, '.') like concat('%',tukhoa,'%')
order by TrangThai DESC,Loai ASC, field(MaGV, idGV) ASC, ThoiGian DESC
limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_GV` (IN `idNganh` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  begin  
select nv.MaNV, nv.TenNV, nv.NgaySinh, nv.SDT, nv.Email
from nhanvien nv, taikhoan tk
where nv.MaTK=tk.MaTK and nv.MaNganh=idNganh
and concat('.', MaNV, '.', TenNV, '.', NgaySinh, '.', SDT, '.', Email, '.') like concat('%',tukhoa,'%')
limit 10 offset os;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SV` (IN `khoa` YEAR, IN `idNganh` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  begin
		select MaSV, TenSV, NgaySinh, MaLop, SUBSTRING(MaLop, 6,2) as MaCN, TenCN, SDT, Email, GPA
		from SinhVien sv, ChuyenNganh cn where 
        SUBSTRING(MaLop, 6,2)=MaCN and
        SUBSTRING(MaSV, 2,2)=right(khoa, 2) 
        and 
        SUBSTRING(MaSV, 6,2)=idNganh
        and concat('.', MaSV, '.', TenSV, '.', NgaySinh, '.', MaLop, '.', MaCN, '.', TenCN, '.', SDT, '.', Email, '.', GPA, '.') like concat('%',tukhoa,'%')
        limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SVBaoCao` (IN `idTB` CHAR(6), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
select DISTINCT(cd.MaPhanCong), pc.MaSV, sv.TenSV, sv.MaLop, sv.SDT, sv.Email  
from chamdiemtb cd, phancongdoan pc, sinhvien sv
where cd.MaPhanCong=pc.MaPhanCong and pc.MaSV=sv.MaSV and cd.MaTB=idTB 
and concat('.', pc.MaSV, '.', sv.TenSV, '.', sv.MaLop, '.', sv.SDT, '.', sv.Email , '.') like concat('%',tukhoa,'%')
order by cd.MaPhanCong
limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SvDAHD` (IN `khoa` YEAR, IN `idNganh` CHAR(2), IN `diem` FLOAT, IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
-- select Diem into diem from DiemSang where NamBD=khoa and MaNGanh=idNganh;
select count(*) into @demPCPB
from phancongdoan
where SUBSTRING(MaSV, 2,2)=right('2017', 2) and SUBSTRING(MaSV, 6,2)='AT' and MaGVPB is null;

if @demPCPB=0 then 
	select *
	from (
            -- select Diem into diem from DiemSang where NamBD='2018' and MaNGanh='CN';
			select MaSV,TenSV, Email,GPA,'' as MaGVHD,'' as TenGVHD,'' as Diem
			from SinhVien
			where SUBSTRING(MaSV, 2,2)=right(khoa, 2)
			and SUBSTRING(MaSV, 6,2)= idNganh
			and GPA>=diem 
			and MaSV not in (
						select sv.MaSV
						from SinhVien sv, PhanCongDoAn pc
						where SUBSTRING(sv.MaSV, 2,2)=right(khoa, 2)
						and SUBSTRING(sv.MaSV, 6,2)=idNganh
						and sv.MaSV=pc.MaSV)
			union
            select sv.MaSV, sv.TenSV, sv.Email, sv.GPA, tmp.MaGVHD, tmp.TenGVHD, ifnull(tmp.diem,'') as Diem
			from sinhvien sv, 
				(select pc.MaSV, pc.MaDA, pc.MaGVHD, gv.TenNV as TenGVHD,cd.diem
				from phancongdoan pc, `chamdiemhd-pb` cd, nhanvien gv 
				where 
				SUBSTRING(pc.MaSV, 2,2)=right(khoa, 2) 
				and SUBSTRING(MaSV, 6,2)=idNganh
				and pc.MaPhanCong=cd.MaPhanCong and pc.MaGVHD=cd.MaGV and pc.MaGVHD=gv.MaNV and (cd.diem <4 or cd.diem is null))
				tmp
			where sv.MaSV=tmp.MaSV
			) tmp
	where concat('.', MaSV, '.', TenSV, '.', Email, '.', GPA, '.', MaGVHD, '.', diem, '.') like concat('%',tukhoa,'%')
	order by MaSV ASC
	limit 10 offset os;
else
	select *
	from (select sv.MaSV, sv.TenSV, sv.Email, sv.GPA, tmp.MaGVHD, tmp.TenGVHD, ifnull(tmp.diem,'') as Diem, sv.MaTK
			from sinhvien sv, 
				(select pc.MaSV, pc.MaDA, pc.MaGVHD, gv.TenNV as TenGVHD,cd.diem
				from phancongdoan pc, `chamdiemhd-pb` cd, nhanvien gv 
				where 
				SUBSTRING(pc.MaSV, 2,2)=right(2017, 2) 
				and SUBSTRING(MaSV, 6,2)='AT'
				and pc.MaPhanCong=cd.MaPhanCong and pc.MaGVHD=cd.MaGV and pc.MaGVHD=gv.MaNV and (cd.diem <4 or cd.diem is null))
				tmp
			where sv.MaSV=tmp.MaSV
			union
			-- select Diem into diem from DiemSang where NamBD='2018' and MaNGanh='CN';
			select MaSV,TenSV, Email,GPA,'','','', MaTK
			from SinhVien
			where SUBSTRING(MaSV, 2,2)=right(khoa, 2)
			and SUBSTRING(MaSV, 6,2)= idNganh
			and GPA>=diem 
			and MaSV not in (
						select sv.MaSV
						from SinhVien sv, PhanCongDoAn pc
						where SUBSTRING(sv.MaSV, 2,2)=right(khoa, 2)
						and SUBSTRING(sv.MaSV, 6,2)=idNganh
						and sv.MaSV=pc.MaSV)) tmp
	where MaTK is not null and concat('.', tmp.MaSV, '.', tmp.TenSV, '.', tmp.Email, '.', tmp.GPA, '.', tmp.MaGVHD, '.', tmp.diem, '.') like concat('%',tukhoa,'%')
	order by MaSV ASC
	limit 10 offset os;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SvDAPB` (IN `khoa` YEAR, IN `idNganh` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  begin
select *
from (select sv.MaSV, sv.TenSV, sv.Email, cdhd.Diem as DiemHD,pc.MaGVPB, gv.TenNV as TenGVPB, ifnull(cdpb.Diem,'') as DiemPB
		from sinhvien sv, phancongdoan pc, `chamdiemhd-pb` cdhd, `chamdiemhd-pb` cdpb, nhanvien gv 
		where SUBSTRING(sv.MaSV, 2,2)=right(khoa, 2)
		 and SUBSTRING(sv.MaSV, 6,2)=idNganh
		 and sv.MaSV=pc.MaSV 
		 and pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV 
		 and pc.MaPhanCong=cdpb.MaPhanCong and pc.MaGVPB=cdpb.MaGV
         and pc.MaGVPB=gv.MaNV
		 and (cdpb.Diem<4 or cdpb.Diem is null)
		 union 
		 select sv.MaSV, sv.TenSV, sv.Email, cdhd.Diem as DiemHD,'','', ''
		 from sinhvien sv, phancongdoan pc, `chamdiemhd-pb` cdhd
		 where SUBSTRING(sv.MaSV, 2,2)=right(khoa, 2)
		 and SUBSTRING(sv.MaSV, 6,2)=idNganh
		 and sv.MaSV=pc.MaSV 
		 and pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV and cdhd.diem>=4 and pc.MaGVPB is null) tmp
where   concat('.', MaSV, '.', TenSV, '.', Email, '.', DiemHD, '.', MaGVPB, '.', TenGVPB, '.', DiemPB, '.') like concat('%',tukhoa,'%')
order by MaSV ASC
limit 10 offset os;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SvDATB` (IN `khoa` YEAR, IN `idNganh` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  begin
select *
from (select tmp1.MaSV, tmp1.TenSV, tmp1.Email, tmp1.DiemPB, ifnull(tmp2.MaTB,'') as MaTB, ifnull(tmp2.Diemtb,'') as Diemtb, tmp2.slDiem, tmp2.slGV
		from (select sv.MaSV, sv.TenSV, sv.Email, cdpb.Diem as DiemPB, pc.MaPhanCong
				from sinhvien sv, phancongdoan pc, `chamdiemhd-pb` cdpb
				where pc.MaSV=sv.MaSV and pc.MaPhanCong=cdpb.MaPhanCong and pc.MaGVPB=cdpb.MaGV and cdpb.Diem>=4 and SUBSTRING(pc.MaPhanCong, 3,2)=right(khoa, 2) and SUBSTRING(pc.MaSV, 6,2)=idNganh
				) tmp1
		left join (select MaPhanCong, MaTB, AVG(Diem) as Diemtb, count(Diem) as slDiem, count(MaGV) as slGV
					from chamdiemtb
					where SUBSTRING(MaPhanCong, 3,2)=right(khoa, 2)
					group by MaPhanCong, MaTB) tmp2
		on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp
where concat('.', MaSV, '.', TenSV, '.', Email, '.', DiemPB, '.', MaTB, '.', Diemtb, '.') like concat('%',tukhoa,'%')
order by MaSV ASC
limit 10 offset os;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SVHD_GV` (IN `idGV` CHAR(7), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
select * 
from (select tmp1.MaPhanCong, tmp1.MaSV, tmp1.TenSV, tmp1.MaLop, tmp2.MaDA, tmp2.TenDA, ifnull(tmp2.Diem,'') as Diem, tmp2.MaCT
		from (select pc.MaPhanCong, sv.MaSV, sv.TenSV, sv.MaLop
				from sinhvien sv, phancongdoan pc
				where pc.MaSV=sv.MaSV and pc.MaGVHD=idGV and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2)) tmp1
		left join (select pc.MaPhanCong, pc.MaDA, da.TenDA, pc.MaCT, cdhd.Diem
					from phancongdoan pc, doan da, `chamdiemhd-pb` cdhd
					where pc.MaDA=da.MaDA and pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV ) tmp2
		on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp 
where concat('.', MaSV, '.', TenSV, '.', MaLop, '.', MaDA, '.', TenDA, '.', Diem, '.') like concat('%',tukhoa,'%')
order by MaSV
limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SVPB_GV` (IN `idGV` CHAR(7), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
SELECT *
FROM (select pc.MaPhanCong, sv.MaSV, sv.TenSV, sv.MaLop, pc.MaDA, da.TenDA, ifnull(cd.Diem,'') as Diem, pc.MaCT
from sinhvien sv, phancongdoan pc, doan da, `chamdiemhd-pb` cd
where pc.MaSV=sv.MaSV and pc.MaDA=da.MaDA and cd.MaPhanCong=pc.MaPhanCong and cd.MaGV=pc.MaGVPB and pc.MaGVPB=idGV and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2))tmp
WHERE concat('.', MaSV, '.', TenSV, '.', MaLop, '.', MaDA, '.', TenDA, '.', Diem, '.') like concat('%',tukhoa,'%')
order by MaSV
limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SVTB_GV` (IN `idGV` CHAR(7), IN `idTB` CHAR(6), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
select pc.MaPhanCong, cd.MaTB, sv.MaSV, sv.TenSV, sv.MaLop, da.MaDA, da.TenDA, cd.Diem, pc.MaCT
from sinhvien sv, phancongdoan pc, doan da, chamdiemtb cd
where pc.MaSV=sv.MaSV and pc.MaDA=da.MaDA and pc.MaPhanCong=cd.MaPhanCong and cd.MaGV=idGV and cd.MaTB=idTB
and concat('.', sv.MaSV, '.', sv.TenSV, '.', sv.MaLop, '.', da.MaDA, '.', da.TenDA, '.') like concat('%',tukhoa,'%')
order by MaSV
limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_TB` (IN `khoa` YEAR, IN `idNganh` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  begin
    select *
    from (select tb.MaTB, tb.Ngay, tb.Ca, count(pc.MaGV) as sum
		from (select MaTB, Ngay, Ca
				from tieuban
				where MaNganh=idNganh and substring(MaTB,3,2)=right(khoa,2)) tb
		left join phanconggvtb pc 
		on tb.MaTB=pc.MaTB
		group by tb.MaTB,tb.Ngay, tb.Ca) tmp
	where concat('.', MaTB, '.', Ngay, '.', Ca, '.', sum, '.') like concat('%',tukhoa,'%')
    ORDER by Ngay DESC, MaTB ASC
	limit 10 offset os;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_TB_GV` (IN `idGV` CHAR(7), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
	select pc.MaTB, tb.Ngay, tb.Ca
    from phanconggvtb pc, tieuban tb
    where pc.MaTB=tb.MaTB and substring(pc.MaTB,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2) and MaGV=idGV
    and concat('.', pc.MaTB, '.', tb.Ngay, '.', tb.Ca, '.') like concat('%',tukhoa,'%')
	order by MaTB
    limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowOriginalFiles` (IN `idDA` CHAR(7), IN `idGV` CHAR(7))  BEGIN
select MaGV, tmp.ThoiGian into @tmpGV, @tmpThoiGian
from(select ct.MaDa, min(ct.ThoiGian) as ThoiGian 
	from chitietchinhsuadoan ct, phienbanhuongdan pb
	where ct.MaDA=pb.MaDA and ct.MaGV=pb.MaGV and ct.ThoiGian=pb.ThoiGian and ct.MaDA=idDA
	group by ct.MaDA) tmp, phienbanhuongdan pb
where tmp.MaDa=pb.MaDA and tmp.ThoiGian=pb.ThoiGian;

if @tmpGV<>idGV then
	select 'Không có tài liệu hướng dẫn gốc';
elseif @tmpGV=idGV then
	select substring(TepVB,char_length(concat(MaDA, MaGV,ThoiGian))-5+1) as 'TepVB_Goc', TepVB, substring(TepKhac,char_length(concat(MaDA, MaGV,ThoiGian))-5+1) as 'TepKhac_Goc', TepKhac
    from phienbanhuongdan
    where MaDA=idDA and MaGV=idGV and ThoiGian=@tmpThoiGian;
else 
	select 'Chưa có tài liệu';
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ThongKe5Nam` (IN `options` VARCHAR(255))  BEGIN
set @count=0;

WHILE (LOCATE(',', options) > 0)
DO
	set @count=@count+1;
	if @count=1 then 
		set  @nganh=left(options,2);
		SET options= SUBSTRING(options, LOCATE(',',options) + 1);
	elseif @count=2 then
		set  @CN=left(options,2);
		SET options= SUBSTRING(options, LOCATE(',',options) + 1);
	end if;
END WHILE;
DROP TEMPORARY TABLE IF EXISTS TatCaDATrong5Nam;
CREATE TEMPORARY TABLE IF NOT EXISTS TatCaDATrong5Nam AS 
    (select tmp1.MaPhanCong, tmp1.NamBD, tmp1.Diem as DiemSang, tmp1.MaSV, tmp1.GPA, tmp1.MaCN, tmp2.DiemHD, tmp2.DiemPB, tmp2.DiemTB
		from (select pc.MaPhanCong,tmp.NamBD, tmp.Diem, sv.MaSV, sv.GPA, cn.MaCN   
				from phancongdoan pc, sinhvien sv, lop, chuyennganh cn,
					(select MaNganh, NamBD, Diem 
						from DiemSang 
						where MaNganh =@nganh
						order by NamBD DESC
						limit 5 )tmp
				where pc.MaSV= sv.MaSV and sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=tmp.MaNganh and substring(pc.MaPhanCong,3,2)=right(tmp.NamBD,2)) tmp1,
			(select tmp1.MaPhanCong, tmp1.DiemHD, tmp1.DiemPB, tmp2.DiemTB
				from (select tmp.MaPhanCong, tmp.DiemHD, cdpb.Diem as DiemPB
						from (select pc.MaPhanCong, cdhd.Diem as DiemHD, pc.MaGVPB
								from phancongdoan pc, `chamdiemhd-pb` cdhd
								where pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV) tmp
						left join  `chamdiemhd-pb` cdpb
						on tmp.MaPhanCong=cdpb.MaPhanCOng and tmp.MaGVPB=cdpb.MaGV) tmp1
				left join (select MaPhanCong, AVG(Diem) as DiemTB
							from chamdiemtb
							group by MaPhanCong) tmp2
				on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp2
		where tmp1.MaPhanCong=tmp2.MaPhanCong);
if @count=1 then 
	-- thống kê điểm sàng, số lượng SV báo cáo, số lượng đậu rớt của các ngành, các chuyên ngành trong năm

select tmp1.NamBD, tmp1.Diem, tmp1.totalDA, tmp1.totalDAPass, count(tmp.NamBD) as  totalDAFail, (tmp1.totalDA - tmp1.totalDAPass - count(tmp.NamBD)) as totalDAReporting
from (select tmp1.NamBD, tmp1.Diem, tmp1.totalDA, count(tmp.NamBD) as  totalDAPass
		from (select tmp1.NamBD, tmp1.Diem, count(tmp.NamBD) as totalDA
				from (select NamBD, Diem
						from DiemSang 
						where MaNganh =@nganh
						order by NamBD DESC
						limit 5 ) tmp1
				left join TatCaDATrong5Nam tmp
				on tmp1.NamBD=tmp.NamBD
				group by tmp1.NamBD) tmp1
		left join TatCaDATrong5Nam tmp
		on tmp.NamBD=tmp1.NamBD and tmp.DiemTB>=4
		group by tmp1.NamBD) tmp1
left join TatCaDATrong5Nam tmp 
on tmp.NamBD=tmp1.NamBD and tmp.DiemHD<4 or tmp.DiemPB<4 or tmp.DiemTB<4
group by tmp1.NamBD;
    
elseif @count=2 then
   select tmp1.NamBD, tmp1.Diem, tmp1.totalDA, tmp1.totalDAPass, count(tmp.NamBD) as  totalDAFail, (tmp1.totalDA - tmp1.totalDAPass - count(tmp.NamBD)) as totalDAReporting
	from (select tmp1.NamBD, tmp1.Diem, tmp1.totalDA, count(tmp.NamBD) as  totalDAPass
			from (select tmp1.NamBD, min(tmp.GPA) as Diem, count(tmp.NamBD) as totalDA
					from (select NamBD
							from DiemSang 
							where MaNganh =@nganh
							order by NamBD DESC
							limit 5 ) tmp1
					left join TatCaDATrong5Nam tmp
					on tmp1.NamBD=tmp.NamBD and tmp.MaCN=@CN
					group by tmp1.NamBD) tmp1
			left join TatCaDATrong5Nam tmp
			on tmp.NamBD=tmp1.NamBD and tmp.MaCN=@CN and tmp.DiemTB>=4
			group by tmp1.NamBD) tmp1
	left join TatCaDATrong5Nam tmp 
	on tmp.NamBD=tmp1.NamBD and tmp.MaCN=@CN and tmp.DiemHD<4 or tmp.DiemPB<4 or tmp.DiemTB<4
	group by tmp1.NamBD;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ThongKePhoDiem` (IN `nam` YEAR, IN `options` VARCHAR(255))  BEGIN
set @count=0;

WHILE (LOCATE(',', options) > 0)
DO
	set @count=@count+1;
    if @count=1 then 
		set @giaiDoan=left(options,2);
		SET options= SUBSTRING(options, LOCATE(',',options) + 1);
	elseif @count=2 then 
		set  @khoa=left(options,1);
		SET options= SUBSTRING(options, LOCATE(',',options) + 1);
	elseif @count=3 then
		set  @nganh=left(options,2);
		SET options= SUBSTRING(options, LOCATE(',',options) + 1);
	elseif @count=4 then
		set  @CN=left(options,2);
		SET options= SUBSTRING(options, LOCATE(',',options) + 1);
	end if;
END WHILE;
DROP TEMPORARY TABLE IF EXISTS TatCaDATrongNam;
CREATE TEMPORARY TABLE IF NOT EXISTS TatCaDATrongNam AS 
    (select tmp1.MaPhanCong, tmp1.MaSV, tmp1.GPA, tmp1.MaNganh, tmp1.MaCN, tmp2.DiemHD, tmp2.DiemPB, tmp2.DiemTB
		from (select pc.MaPhanCong, sv.MaSV, sv.GPA, nganh.MaNganh, cn.MaCN
				from phancongdoan pc, sinhvien sv, lop, chuyennganh cn, nganh, hoidong hd, DiemSang d
				where pc.MaSV= sv.MaSV and sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and d.MaNganh=nganh.MaNGanh and nganh.MaHD=hd.MaHD and d.NamBD=nam and hd.MaHD=@khoa and substring(pc.MaPhanCong,3,2)=right(nam,2)) tmp1,
			(select tmp1.MaPhanCong, tmp1.DiemHD, tmp1.DiemPB, tmp2.DiemTB
				from (select tmp.MaPhanCong, tmp.DiemHD, cdpb.Diem as DiemPB
						from (select pc.MaPhanCong, cdhd.Diem as DiemHD, pc.MaGVPB
								from phancongdoan pc, `chamdiemhd-pb` cdhd
								where pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV) tmp
						left join  `chamdiemhd-pb` cdpb
						on tmp.MaPhanCong=cdpb.MaPhanCOng and tmp.MaGVPB=cdpb.MaGV) tmp1
				left join (select MaPhanCong, AVG(Diem) as DiemTB
							from chamdiemtb
							group by MaPhanCong) tmp2
				on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp2
		where tmp1.MaPhanCong=tmp2.MaPhanCong);

if @count=3 then 
	set @sql= concat('select * \r\nfrom (select tmp.MaNganh, tmp.`[0,4)`, tmp.`[4,5.5)`, tmp.`[5.5,7)`, tmp.`[7,8.5)`, count(tmp1.MaPhanCong) as `[8.5,10)`\r\n\t\tfrom (select tmp.MaNganh, tmp.`[0,4)`, tmp.`[4,5.5)`, tmp.`[5.5,7)`, count(tmp1.MaPhanCong) as `[7,8.5)`\r\n\t\t\t\tfrom (select tmp.MaNganh, tmp.`[0,4)`, tmp.`[4,5.5)`, count(tmp1.MaPhanCong) as `[5.5,7)`\r\n\t\t\t\t\t\tfrom (select tmp.MaNganh, tmp.`[0,4)`, count(tmp1.MaPhanCong) as `[4,5.5)`\r\n\t\t\t\t\t\t\t\tfrom (select distinct(tmp.MaNganh),  tmp1.`[0,4)`\r\n\t\t\t\t\t\t\t\t\t\tfrom TatCaDATrongNam tmp\r\n\t\t\t\t\t\t\t\t\t\tleft join(select MaNganh, count(MaPhanCong) as `[0,4)`\r\n\t\t\t\t\t\t\t\t\t\t\t\t\tfrom TatCaDATrongNam\r\n\t\t\t\t\t\t\t\t\t\t\t\t\twhere Diem',@giaiDoan,'<4) tmp1\r\n\t\t\t\t\t\t\t\t\t\ton tmp.MaNganh=tmp1.MaNganh\r\n\t\t\t\t\t\t\t\t\t\tgroup by tmp.MaNganh) tmp\r\n\t\t\t\t\t\t\t\tleft join TatCaDATrongNam tmp1\r\n\t\t\t\t\t\t\t\ton tmp.maNganh=tmp1.MaNganh and Diem',@giaiDoan,'>=4 and Diem',@giaiDoan,'<5.5\r\n\t\t\t\t\t\t\t\tgroup by tmp.MaNganh) tmp\r\n\t\t\t\t\t\tleft join TatCaDATrongNam tmp1\r\n\t\t\t\t\t\ton tmp.maNganh=tmp1.MaNganh and Diem',@giaiDoan,'>=5.5 and Diem',@giaiDoan,'<7\r\n\t\t\t\t\t\tgroup by tmp.MaNganh) tmp\r\n\t\t\t\tleft join TatCaDATrongNam tmp1\r\n\t\t\t\ton tmp.maNganh=tmp1.MaNganh and Diem',@giaiDoan,'>=7 and Diem',@giaiDoan,'<8.5\r\n\t\t\t\tgroup by tmp.MaNganh)  tmp\r\n\t\tleft join TatCaDATrongNam tmp1\r\n\t\ton tmp.maNganh=tmp1.MaNganh and Diem',@giaiDoan,'>=8.5\r\n\t\tgroup by tmp.MaNganh) tmp\r\nwhere MaNganh=?'
);
prepare stmt from @sql;                
execute stmt using @nganh;    
elseif @count=4 then
   set @sql= concat(
   'select *\r\n\tfrom (select tmp.MaCN, tmp.`[0,4)`, tmp.`[4,5.5)`, tmp.`[5.5,7)`, tmp.`[7,8.5)`, count(tmp1.MaPhanCong) as `[8.5,10)`\r\n\t\t\tfrom (select tmp.MaCN, tmp.`[0,4)`, tmp.`[4,5.5)`, tmp.`[5.5,7)`, count(tmp1.MaPhanCong) as `[7,8.5)`\r\n\t\t\t\t\tfrom (select tmp.MaCN, tmp.`[0,4)`, tmp.`[4,5.5)`, count(tmp1.MaPhanCong) as `[5.5,7)`\r\n\t\t\t\t\t\t\tfrom (select tmp.MaCN, tmp.`[0,4)`, count(tmp1.MaPhanCong) as `[4,5.5)`\r\n\t\t\t\t\t\t\t\t\tfrom (select tmp.MaCN,  IFNULL(tmp1.`[0,4)`,0) as `[0,4)`\r\n\t\t\t\t\t\t\t\t\t\t\tfrom TatCaDATrongNam tmp\r\n\t\t\t\t\t\t\t\t\t\t\tleft join(select MaCN, count(MaPhanCong) as `[0,4)`\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tfrom TatCaDATrongNam\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\twhere Diem',@giaiDoan,'<4 group by MaCN) tmp1\r\n\t\t\t\t\t\t\t\t\t\t\ton tmp.MaCN=tmp1.MaCN\r\n\t\t\t\t\t\t\t\t\t\t\tgroup by tmp.MaCN) tmp\r\n\t\t\t\t\t\t\t\t\tleft join TatCaDATrongNam tmp1\r\n\t\t\t\t\t\t\t\t\ton tmp.MaCN=tmp1.MaCN and Diem',@giaiDoan,'>=4 and Diem',@giaiDoan,'<5.5\r\n\t\t\t\t\t\t\t\t\tgroup by tmp.MaCN) tmp\r\n\t\t\t\t\t\t\tleft join TatCaDATrongNam tmp1\r\n\t\t\t\t\t\t\ton tmp.MaCN=tmp1.MaCN and Diem',@giaiDoan,'>=5.5 and Diem',@giaiDoan,'<7\r\n\t\t\t\t\t\t\tgroup by tmp.MaCN) tmp\r\n\t\t\t\t\tleft join TatCaDATrongNam tmp1\r\n\t\t\t\t\ton tmp.MaCN=tmp1.MaCN and Diem',@giaiDoan,'>=7 and Diem',@giaiDoan,'<8.5\r\n\t\t\t\t\tgroup by tmp.MaCN)  tmp\r\n\t\t\tleft join TatCaDATrongNam tmp1\r\n\t\t\ton tmp.MaCN=tmp1.MaCN and Diem',@giaiDoan,'>=8.5\r\n\t\t\tgroup by tmp.MaCN) tmp\r\n\twhere MaCN=?');
    
    prepare stmt from @sql; 
	execute stmt using @CN;
end if;


deallocate prepare stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ThongKeTheoNam` (IN `nam` YEAR, IN `options` VARCHAR(255))  BEGIN
set @count=0;

WHILE (LOCATE(',', options) > 0)
DO
	set @count=@count+1;
	if @count=1 then 
		set  @khoa=left(options,1);
		SET options= SUBSTRING(options, LOCATE(',',options) + 1);
	elseif @count=2 then
		set  @nganh=left(options,2);
		SET options= SUBSTRING(options, LOCATE(',',options) + 1);
	end if;
END WHILE;
DROP TEMPORARY TABLE IF EXISTS TatCaDATrongNam;
CREATE TEMPORARY TABLE IF NOT EXISTS TatCaDATrongNam AS 
    (select tmp1.MaPhanCong, tmp1.MaSV, tmp1.GPA, tmp1.MaNganh, tmp1.MaCN, tmp2.DiemHD, tmp2.DiemPB, tmp2.DiemTB
		from (select pc.MaPhanCong, sv.MaSV, sv.GPA, nganh.MaNganh, cn.MaCN
				from phancongdoan pc, sinhvien sv, lop, chuyennganh cn, nganh, hoidong hd, DiemSang d
				where pc.MaSV= sv.MaSV and sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and d.MaNganh=nganh.MaNGanh and nganh.MaHD=hd.MaHD and d.NamBD=nam and hd.MaHD=@khoa and substring(pc.MaPhanCong,3,2)=right(nam,2)) tmp1,
			(select tmp1.MaPhanCong, tmp1.DiemHD, tmp1.DiemPB, tmp2.DiemTB
				from (select tmp.MaPhanCong, tmp.DiemHD, cdpb.Diem as DiemPB
						from (select pc.MaPhanCong, cdhd.Diem as DiemHD, pc.MaGVPB
								from phancongdoan pc, `chamdiemhd-pb` cdhd
								where pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV) tmp
						left join  `chamdiemhd-pb` cdpb
						on tmp.MaPhanCong=cdpb.MaPhanCOng and tmp.MaGVPB=cdpb.MaGV) tmp1
				left join (select MaPhanCong, AVG(Diem) as DiemTB
							from chamdiemtb
							group by MaPhanCong) tmp2
				on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp2
		where tmp1.MaPhanCong=tmp2.MaPhanCong);

if @count=1 then 
	-- thống kê điểm sàng, số lượng SV báo cáo, số lượng đậu rớt của các ngành, các chuyên ngành trong năm
        
    
    
    select tmp1.MaNganh, tmp1.Diem, tmp2.totalDA, tmp2.totalDAPass, tmp2.totalDAFail,tmp2.totalDAReporting
    from (select d.MaNganh, d.Diem
			from DiemSang d, nganh, hoidong hd
			where d.MaNganh=nganh.MaNganh and hd.MaHD= nganh.MaHD and d.NamBD=nam and hd.MaHD=@khoa) tmp1
	left join (select tmp1.MaNganh, tmp1.totalDA, tmp1.totalDAPass, count(tmp.MaNganh) as  totalDAFail, (tmp1.totalDA - tmp1.totalDAPass - count(tmp.MaNganh)) as totalDAReporting
				from (select tmp1.MaNganh, tmp1.totalDA, count(tmp.MaNganh) as  totalDAPass
						from (select MaNganh, count(*) as totalDA
								from TatCaDATrongNam
								group by MaNganh) tmp1
						left join TatCaDATrongNam tmp
						on tmp.MaNganh=tmp1.MaNganh and tmp.DiemTB>=4
						group by tmp1.MaNganh) tmp1
				left join TatCaDATrongNam tmp 
				on tmp.MaNganh=tmp1.MaNganh and tmp.DiemHD<4 or tmp.DiemPB<4 or tmp.DiemTB<4
				group by tmp1.MaNganh) tmp2
	on tmp1.MaNganh=tmp2.MaNganh;
    
elseif @count=2 then
   
        select tmp1.MaCN, tmp1.minGPA, tmp1.totalDA, tmp1.totalDAPass, count(tmp.MaCN) as totalDAFail, (tmp1.totalDA - tmp1.totalDAPass - count(tmp.MaCN)) as totalDAReporting
from (select tmp1.MaCN, tmp1.minGPA, tmp1.totalDA, count(tmp.MaCN) as totalDAPass
		from (select MaCN, min(GPA) as minGPA, count(*) as totalDA
				from TatCaDATrongNam
				where MaNganh=@nganh
				group by MaCN, MaNganh) tmp1
		left join TatCaDATrongNam tmp
		on tmp1.MaCN=tmp.MaCN and tmp.DiemTB>=4 
		group by tmp1.MaCN, tmp.MaNganh ) tmp1
left join TatCaDATrongNam tmp
on tmp1.MaCN=tmp.MaCN and (tmp.DiemHD<4 or tmp.DiemPB<4 or tmp.DiemTB<4)
group by tmp1.MaCN, tmp.MaNganh;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Update_DA` (IN `idDA` CHAR(7), IN `ten` VARCHAR(255), IN `idCN` CHAR(2), IN `idGV` CHAR(7), IN `t` DATETIME, IN `FileArray` VARCHAR(255))  BEGIN
	insert into chitietchinhsuadoan(MaDA,MaGV,ThoiGian) value(idDA,idGV, t);
    set @maxid=(select Max(MaCT)+1 from phienbanhuongdan);
    
	set @demFile=   LENGTH(FileArray) - LENGTH( REPLACE ( FileArray, ',', '') ) ;
	
    if @demFile=1 then
		SET @value = left(FileArray,LOCATE(',',FileArray)-1);
        if right(@value,3)='doc' or right(@value,3)='pdf' or right(@value,4)='docx' then
			insert into phienbanhuongdan(MaCT, TepVB, MaDA, MaGV, ThoiGian) 
            value(@maxid, replace(replace(replace(lower(concat(idDA,idGV,t,@value)),':',''),'-',''),' ',''), idDA, idGV, t);
		else
			insert into phienbanhuongdan(MaCT, TepKhac, MaDA, MaGV, ThoiGian) 
            value(@maxid, replace(replace(replace(lower(concat(idDA,idGV,t,@value)),':',''),'-',''),' ',''), idDA, idGV, t);
		end if;
	else
		WHILE (LOCATE(',', FileArray) > 0)
		DO
			SET @value = left(FileArray,LOCATE(',',FileArray)-1);
			SET FileArray= SUBSTRING(FileArray, LOCATE(',',FileArray) + 1);
			if right(@value,3)='doc' or right(@value,3)='pdf' or right(@value,4)='docx' then
				set @fileVB=@value;
			else
				set @fileKhac=@value;
			end if;
		END WHILE;
        insert into phienbanhuongdan(MaCT, TepVB, TepKhac, MaDA, MaGV, ThoiGian) 
        value(@maxid, replace(replace(replace(lower(concat(idDA,idGV,t,@fileVB)),':',''),'-',''),' ',''), replace(replace(replace(lower(concat(idDA,idGV,t,@fileKhac)),':',''),'-',''),' ',''), idDA, idGV, t);
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Update_DAFull` (IN `idDA` CHAR(7), IN `ten` VARCHAR(255), IN `idCN` CHAR(2), IN `idGV` CHAR(7), IN `idGVTaoDA` CHAR(7), IN `t` DATETIME, IN `details` VARCHAR(255), IN `file` VARCHAR(255))  BEGIN
	SET SQL_SAFE_UPDATES = 0;
	update doan
    set TenDA=ten,
		MaCN=idCN
	where MaDA=idDA;
    insert into chitietchinhsuadoan(MaDA,MaGV,ThoiGian) value(idDA,idGV, t);
	
	set @maxid=(select Max(MaCT)+1 from phienbanhuongdan);
    if length(file)<>0 then 
    	IF(idGV=idGVTaoDA) THEN
            insert into phienbanhuongdan(MaCT, Tep, MoTa, TrangThai, MaDA, MaGV, ThoiGian) 
            value(@maxid, file, details, 0, idDA, idGV, t);
        ELSE
        	insert into phienbanhuongdan(MaCT, Tep, MoTa, TrangThai, MaDA, MaGV, ThoiGian) 
            value(@maxid, file, details, 1, idDA, idGV, t);
        END IF;
    else
		update phienbanhuongdan
        set
			MoTa=details
		where MaDA=idDA and MaGV=idGV and TrangThai=0;
    end if;

    SET SQL_SAFE_UPDATES = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Update_SV` (IN `idLop` CHAR(11), IN `idSV` CHAR(10), IN `name` VARCHAR(50), IN `dob` DATE, IN `diem` FLOAT, IN `phone` CHAR(10))  begin
	declare demLop int;
	select count(*) into demLop from Lop where MaLop=idLop;
    if(demLop=0) then
		INSERT INTO `lop` (`Malop`, `MaCN`) VALUES (idLop,substring(idLop, 6,2));
	end if;
    /*INSERT INTO `sinhvien` (`MaSV`, `TenSV`, `NgaySinh`, `MaLop`, `GPA`,`SDT`, `Email`) VALUES (idSV,ten,dob,idLop,gpa,sdt,AutoEmailSV(idSV));*/
    update `sinhvien`
    set 
		TenSV=name,
        NgaySinh=dob,
        MaLop=idLop,
        GPA=diem, 
        SDT=phone
	where MaSV=idSV;
end$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `AUTO_EmailSV` (`maSV` CHAR(10)) RETURNS VARCHAR(50) CHARSET utf8 BEGIN
	DECLARE email varCHAR(50);
    set email=concat(maSV,'@student.ptithcm.edu.vn');
	RETURN (email);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `AUTO_GetMaTK` () RETURNS CHAR(6) CHARSET utf8 BEGIN
	Declare ID char(6);
    DECLARE dem int;
    SELECT COUNT(*) into dem from taikhoan where quyen is null;
    if dem<1 then
	INSERT INTO `taikhoan` (`TenDangNhap`, `MatKhau`, `quyen`) VALUES (null, null,null); 
    end if;
	set ID=(select min(MaTK)from TaiKhoan where quyen is null);
return (ID);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `AUTO_IDDA` () RETURNS CHAR(7) CHARSET utf8 BEGIN
	DECLARE ID CHAR(7);
   	DECLARE temp int;
    Declare maxid int;
    DECLARE tmpid char(7);
    /*DECLARE khoaDA int;
    SET khoaDA=(select SUBSTRING(MaSV, 2,2));*/
    set temp=(SELECT COUNT(*) FROM DoAn where SUBSTRING(MaDA, 3,2)=right(year(now()),2));
	IF temp = 0 THEN
		SET ID = concat('DA',right(year(now()),2),'001');
        
	ELSE
    	set tmpid=(select max(MaDA) from doan where SUBSTRING(MaDA, 3,2)=right(year(now()),2));
    
		set maxid= (select right(tmpid,3));
		if (maxid > 0 and maxid < 9) THEN 
			set ID= concat('DA',right(year(now()),2),'00',convert(maxid + 1 ,CHAR));
		elseif (maxid >= 9 and maxid <99) THEN 
			set ID =concat('DA',right(year(now()),2),'0',convert(maxid + 1 ,CHAR));
        elseif (ID >= 99) THEN 
			set ID= concat('DA',right(year(now()),2),convert(maxid + 1 ,CHAR));
		end if;
    end if;   
	RETURN (ID);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `AUTO_IDGV` (`idNganh` CHAR(2)) RETURNS VARCHAR(7) CHARSET utf8 BEGIN 
	DECLARE ID VARCHAR(7);
   	DECLARE temp int;
    Declare maxid int;
    set temp=(SELECT COUNT(*) FROM NhanVien where MaNV like concat('GV',idNganh,'%'));
	IF temp = 0 THEN
		SET ID = concat('GV',idNganh,'001');
	ELSE
		SELECT MAX(RIGHT(MaNV, 3)) into maxid  FROM NhanVien where MaNV like concat('GV',idNganh,'%');
		if maxid > 0 and maxid < 9 THEN 
        
			set ID=concat('GV',idNganh,'00',maxid + 1);
		elseif maxid >= 9 and maxid <99 THEN 
        	set ID=concat('GV',idNganh,'0',maxid + 1);
        elseif ID >= 99 THEN 
			set ID=concat('GV',idNganh, maxid + 1);
		end if;
    end if;        
	
	RETURN (ID);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Auto_IDLop` (`khoa` YEAR, `maCN` CHAR(2)) RETURNS CHAR(11) CHARSET utf8mb4 begin
	declare ID char(11);
	declare khoaHoc int;
    declare dem int;
    declare dauMa char(7);
    declare cuoiMa char(2);
    declare tmpid char(11);
    declare maxid int;
    set khoaHoc=right(khoa,2);
    set dauMa= concat('D',khoaHoc,'CQ',maCN);
    set cuoiMa='-N';
    set dem=(SELECT COUNT(*) FROM Lop where left(MaLop,7)=dauMa);
    IF dem = 0 THEN
		SET ID = concat(dauMa,'01',cuoiMa);
        
	ELSE
    	set tmpid=(select max(MaLop) from Lop where left(MaLop,7)=dauMa);
		set maxid= (select substring(tmpid,8,2)); 
		if (maxid > 0 and maxid < 9) THEN 
			set ID= concat(dauMa,'0',maxid+1,cuoiMa);
		elseif (maxid >= 9 and maxid <99) THEN 
			set ID =concat(dauMa,maxid+1,cuoiMa);
		end if;
    end if; 
    return(ID);
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Auto_IDPC` (`idSV` CHAR(10)) RETURNS CHAR(11) CHARSET utf8mb4 BEGIN
	DECLARE ID CHAR(7);
   	DECLARE dem int;
    Declare maxid int;
    DECLARE tmpid char(7);
    DECLARE khoaDA int;
    SET khoaDA=(select SUBSTRING(idSV, 2,2));
    set dem=(SELECT COUNT(*) FROM PhanCongDoAn where SUBSTRING(MaPhanCong, 3,2)=khoaDA);
	IF dem = 0 THEN
		SET ID = concat('PC',khoaDA,'001');
        
	ELSE
    	set tmpid=(select max(MaPhanCong) from phancongdoan where SUBSTRING(MaPhanCong, 3,2)=khoaDA);
    
		set maxid= (select right(tmpid,3));
		if (maxid > 0 and maxid < 9) THEN 
			set ID= concat('PC',khoaDA,'00',maxid + 1);
		elseif (maxid >= 9 and maxid <99) THEN 
			set ID =concat('PC',khoaDA,'0',maxid + 1);
        elseif (ID >= 99) THEN 
			set ID= concat('PC',khoaDA,maxid + 1);
		end if;
    end if;   
	RETURN (ID);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `AUTO_IDQL` () RETURNS CHAR(3) CHARSET utf8 BEGIN
	DECLARE ID CHAR(3);
   	DECLARE temp int;
    Declare max int;
    set temp=(SELECT COUNT(*) FROM QuanLy);
	IF temp = 0 THEN
		SET ID = 'QL1';
	ELSE
		SELECT MAX(RIGHT(maQL, 1)) into max  FROM QuanLy;
		
			set ID=concat('QL',convert(max + 1 ,CHAR));       
            
	end if;
	RETURN (ID);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `AUTO_IDSV` (`khoa` YEAR, `maNganh` CHAR(2)) RETURNS CHAR(10) CHARSET utf8 BEGIN
	DECLARE ID CHAR(10);
   	DECLARE temp int;
    Declare maxid int;
    DECLARE tmpid char(10);
    Declare khoaSV int;
    Declare dauMa char(7);
    SET khoaSV=(select RIGHT(khoa,2));
    set dauMa=concat('N',khoaSV,'DC',maNganh);
    set temp=(SELECT COUNT(*) FROM SinhVien where left(MaSV, 7)=dauMa);
	IF temp = 0 THEN
    
		SET ID = concat(dauMa,'001');
	ELSE
    	set tmpid=(select max(MaSV) from sinhvien where left(MaSV, 7)=dauMa);
		set maxid= (select right(tmpid,3));
		if maxid > 0 and maxid < 9 THEN 
			set ID=concat(dauMa,'00',maxid + 1);
		elseif maxid >= 9 and maxid <99 THEN 
			set ID =concat(dauMa,'0',maxid + 1);
        elseif ID >= 99 THEN 
			set ID=concat(dauMa,maxid);
		end if;
    end if;        
	
	RETURN (ID);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `AUTO_IDTB` (`khoa` YEAR) RETURNS CHAR(6) CHARSET utf8 BEGIN
	DECLARE ID CHAR(6);
   	DECLARE temp int;
    Declare maxid int;
    DECLARE khoaTB int;
    DECLARE tmpid char(6);
    SET khoaTB=(select right (khoa,2));
    set temp=(SELECT COUNT(*) FROM TieuBan where SUBSTRING(MaTB, 3,2)=khoaTB);
	IF temp = 0 THEN
		SET ID = concat('TB',khoaTB,'01');
        
	ELSE
        set tmpid=(select max(MaTB) from tieuban where SUBSTRING(MaTB, 3,2)=khoaTB);
		set maxid= (select right(tmpid,2));
		/*SELECT MAX(RIGHT(maTB, 2)) into maxid  FROM TieuBan;*/
		if maxid > 0 and maxid < 9 THEN 
			set ID=concat('TB',khoaTB,'0',convert(maxid + 1 ,CHAR));
		elseif maxid >= 9 and maxid <99 THEN 
			set ID =concat('TB',khoaTB,convert(maxid + 1 ,CHAR));
		end if;
    end if;    
	RETURN (ID);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `AUTO_IDTK` () RETURNS CHAR(6) CHARSET utf8 BEGIN
	DECLARE ID CHAR(6);
   	DECLARE temp int;
    Declare maxid int;
    -- DECLARE curYear int;
    -- SET curYear=(select right (year(now()),2));
    set temp=(SELECT COUNT(*) FROM TaiKhoan);
	IF temp = 0 THEN
		SET ID = 'TK0001';
	ELSE
    	
		set maxid=(SELECT MAX(RIGHT(MaTK, 3)) FROM TaiKhoan);
		if (maxid > 0 and maxid < 9) THEN 
			set ID= concat('TK000',convert(maxid + 1 ,CHAR));
		elseif (maxid >= 9 and maxid <99) THEN 
			set ID =concat('TK00',convert(maxid + 1 ,CHAR));
        elseif (maxid >= 99 and maxid <999) THEN 
			set ID= concat('TK0',convert(maxid + 1 ,CHAR));
        ELSEif (maxid >= 999) THEN 
			set ID= concat('TK',convert(maxid + 1 ,CHAR));
		end if;
    end if;        
	
	RETURN (ID);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `AUTO_PasswordGV` (`maGV` CHAR(10), `ngaySinh` DATE) RETURNS VARCHAR(50) CHARSET utf8 BEGIN
	DECLARE pass varCHAR(50);
    declare ngay char(2);
    declare thang char(2);
    declare nam char(2);
    if(Day(ngaysinh)<=9) then 
		set ngay=concat('0', Day(ngaySinh));
    else
		set ngay=Day(ngaySinh);
	end if;
    if(Month(ngaysinh)<=9) then 
		set thang=concat('0', Month(ngaySinh));
	else
		set thang=Month(ngaySinh);
	end if;
    if(right(Year(ngaysinh),2)<=9) then 
		set nam=concat('0', right(Year(ngaysinh),1));
	else
		set nam=right(Year(ngaysinh),2);
        
	end if;
    set pass=concat(maGV,'#',ngay, thang, nam);
	RETURN (pass);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `AUTO_PasswordSV` (`maSV` VARCHAR(10), `ngaySinh` DATE) RETURNS VARCHAR(50) CHARSET utf8 BEGIN
	DECLARE pass varCHAR(50);
    declare ngay char(2);
    declare thang char(2);
    declare nam char(2);
    if(Day(ngaysinh)<=9) then 
		set ngay=concat('0', Day(ngaySinh));
    else
		set ngay=Day(ngaySinh);
	end if;
    if(Month(ngaysinh)<=9) then 
		set thang=concat('0', Month(ngaySinh));
	else
		set thang=Month(ngaySinh);
	end if;
    if(right(Year(ngaysinh),2)<=9) then 
		set nam=concat('0', right(Year(ngaysinh),1));
	else
		set nam=right(Year(ngaysinh),2);
        
	end if;
    set pass=concat(maSV,'#',ngay, thang, nam);
    set pass=(select MD5(pass));
	RETURN (pass);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CheckEditTB` (`idTB` CHAR(6), `ngay` DATE, `ca` CHAR(2)) RETURNS INT(11) BEGIN
select count(*) INTO @result
from (select pc.MaGV, pc.MaTB, tb.Ngay, tb.Ca
		from phanconggvtb pc, tieuban tb
		where pc.MaTB=tb.MaTB and MaGV in (select MaGV
						from phanconggvtb
						where MaTB=idTB) 
					and pc.MaTB<>idTB) tmp
where tb.Ngay=ngay and tb.Ca=ca;
RETURN (@return);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `checkFilterGPA` (`khoa` YEAR, `idNganh` CHAR(2), `diem` FLOAT) RETURNS INT(11) BEGIN
select count(sv.MaSV) INTO @result
from phancongdoan pc, sinhvien sv 
where pc.MaSV=sv.MaSV and SUBSTRING(pc.MaPhanCong, 3,2)=right(khoa, 2) and substring(sv.MaSV, 6, 2)= idNganh and  sv.GPA<diem;
RETURN(@result);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_DA` (`idCN` CHAR(2), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
		DECLARE demHang int;
        select MaNganh into @idNganh
from chuyennganh
where MaCN=idCN;
        SELECT COUNT(*) into demHang FROM(
            select *
from (select tmp.MaDA, tmp.TenDA, tmp.MaCN, tmp.tenCN, tmp.MaGV, tmp.TenGV, tmp.minThoiGian, tmp.maxThoiGian, IFNULL(tmp1.MaSV,'') AS MaSV , IFNULL(tmp1.TenSV,'') AS TenSV, tmp1.NgayPhanCong, tmp1.MaCT
		from (select tmp.MaDA, da.TenDA, da.MaCN, cn.tenCN, tmp.MaGV, gv.TenNV as TenGV, date(tmp.minThoiGian) as minThoiGian, date(tmp.maxThoiGian) as maxThoiGian
				from (select tmp.MaDA, ct.MaGV, tmp.minThoiGian, tmp.maxThoiGian
						from (select MaDA, min(ThoiGian) as minThoiGian, max(ThoiGian) as maxThoiGian
								from chitietchinhsuadoan 
								group by MaDA) tmp, chitietchinhsuadoan ct
						where tmp.MaDA=ct.MaDA and tmp.minthoiGian=ct.ThoiGian) tmp, doan da, chuyennganh cn, nhanvien gv
				where tmp.MaDA=da.MaDA and cn.MaCN=da.MaCN and tmp.MaGV=gv.MaNV and da.MaCN=idCN GROUP by da.TenDA) tmp
		left join (select pc.MaDA, pc.MaSV, sv.TenSV, pc.NgayPhanCong, pc.MaCT
				from phancongdoan pc, sinhvien sv
				where pc.MaSV=sv.MaSV and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(@idNganh),2)) tmp1
		on tmp1.MaDA= tmp.MaDA
		group by tmp.MaDA) tmp 
where concat('.', MaDA, '.', TenDA, '.', MaCN, '.', tenCN, '.', MaGV, '.', TenGV, '.', minThoiGian, '.', maxThoiGian, '.', MaSV, '.', TenSV, '.') like concat('%',tukhoa,'%')
            ) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_DAofGV` (`idGV` CHAR(7), `idCN` CHAR(2), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang FROM(
            select *
from (select tmp.MaDA, tmp.TenDA, tmp.TenCN, tmp.ThoiGian, tmp.pbFileKhac, tmp.totalPC, IFNULL(tmp1.MaSV,'') AS MaSV , IFNULL(tmp1.TenSV,'') AS TenSV, tmp1.NgayPhanCong, tmp1.MaCT
		from (select tmp.MaDA, tmp.TenDA, tmp.TenCN, date(tmp.ThoiGian) as ThoiGian, tmp.pbFileKhac, count(pc.MaDA) as totalPC
				from (select tmp.MaDA, da.TenDA, cn.TenCN, tmp.ThoiGian, tmp.pbFileKhac
						from (SELECT tmp.MaDA,tmp.ThoiGian,COUNT(pb.MaDA) as pbFileKhac
								FROM (select tmp.MaDA, tmp.ThoiGian
										from (select MaDA, min(ThoiGian) as ThoiGian
												from chitietchinhsuadoan
												group by MaDA) tmp, chitietchinhsuadoan ct
										where tmp.MaDA=ct.MaDA and tmp.ThoiGian=ct.ThoiGian and MaGV=idGV) tmp
								LEFT JOIN phienbanhuongdan pb
								ON  tmp.MaDA = pb.MaDA
								and pb.MaGV<>idGV
								group by tmp.MaDA) tmp, doan da, chuyennganh cn
						where tmp.MaDA=da.MaDA and da.MaCN=cn.MaCN and da.MaCN=idCN) tmp
				LEFT JOIN phancongdoan pc
				on pc.MaDA=tmp.MaDA
				group by tmp.MaDA) tmp
		LEFT JOIN (select pc.MaDA, pc.MaSV, sv.TenSV, pc.NgayPhanCong, pc.MaCT
					from phancongdoan pc, sinhvien sv
					where pc.MaSV=sv.MaSV and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2)) tmp1
		on tmp1.MaDA=tmp.MaDA   
		group by tmp.MaDA) tmp
where concat('.', MaDA, '.', TenDA, '.', ThoiGian, '.', MaSV, '.', TenSV, '.') like concat('%',tukhoa,'%')
            ) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_Files` (`idDA` CHAR(7), `idGV` CHAR(7)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang 
        FROM(
            select tmp.`Tep_Goc`, tmp.MaGV, tmp.TenNV, tmp.ThoiGian, tmp.Tep, tmp.Loai, count(pc.MaPhanCong) as TrangThai
from
	(select pb.MaCT, substring(pb.Tep,char_length(concat(pb.MaDA, pb.MaGV,pb.ThoiGian))-5+1) as 'Tep_Goc', pb.MaGV, gv.TenNV, date(pb.ThoiGian) as ThoiGian, pb.Tep, pb.TrangThai as Loai
	from phienbanhuongdan pb, nhanvien gv
	where pb.MaGV=gv.MaNV and pb.MaDA=idDA and TrangThai<>2 GROUP BY pb.Tep) tmp
Left join phancongdoan pc
on tmp.MaCT=pc.MaCT
group by tmp.MaCT
            ) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_FindDA` (`idCN` CHAR(2), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
	DECLARE dem int;
    SELECT COUNT(*) into dem 
    from(
        	select MaDA, TenDA, NgayTao, TepVB, TepKhac, sum(TrangThai) as TrangThai 
    from(
		select da.MaDA, TenDA, NgayTao, substring(TepVB,char_length(da.MaDA)+1) as TepVB, substring(TepKhac,char_length(da.MaDA)+1) as TepKhac, 1 as Trangthai
		from doan da, chitiethuongdan ct, phancongdoan pc
		where pc.MaDA=da.MaDA and da.MaCT=ct.MaCT and da.MaCN=idCN and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(),2)
		union
		select da.MaDA, TenDA, NgayTao, substring(TepVB,char_length(da.MaDA)+1), substring(TepKhac,char_length(da.MaDA)+1), 0
		from doan da, chitiethuongdan ct
		where  da.MaCT=ct.MaCT and da.MaCN=idCN
	) tmp
    where (MaDA like concat('%',tukhoa,'%') or TenDA like concat('%',tukhoa,'%') or NgayTao like concat('%',tukhoa,'%') or TepVB like concat('%',tukhoa,'%') or TepKhac like concat('%',tukhoa,'%'))
        ) tmp;
    RETURN(dem);
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_GV` (`idNganh` CHAR(2), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang 
        FROM(
            select nv.MaNV, nv.TenNV, nv.NgaySinh, nv.SDT, nv.Email
from nhanvien nv, taikhoan tk
where nv.MaTK=tk.MaTK and nv.MaNganh=idNganh
and concat('.', MaNV, '.', TenNV, '.', NgaySinh, '.', SDT, '.', Email, '.') like concat('%',tukhoa,'%')
		) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SV` (`khoa` YEAR, `idNganh` CHAR(2), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang FROM(
            select MaSV, TenSV, NgaySinh, MaLop, SUBSTRING(MaLop, 6,2) as MaCN, TenCN, SDT, Email, GPA
		from SinhVien sv, ChuyenNganh cn where 
        SUBSTRING(MaLop, 6,2)=MaCN and
        SUBSTRING(MaSV, 2,2)=right(khoa, 2) 
        and 
        SUBSTRING(MaSV, 6,2)=idNganh
        and concat('.', MaSV, '.', TenSV, '.', NgaySinh, '.', MaLop, '.', MaCN, '.', TenCN, '.', SDT, '.', Email, '.', GPA, '.') like concat('%',tukhoa,'%')
		) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SVBaoCao` (`idTB` CHAR(6), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang 
        FROM(
			select DISTINCT(cd.MaPhanCong), pc.MaSV, sv.TenSV, sv.MaLop, sv.SDT, sv.Email  
from chamdiemtb cd, phancongdoan pc, sinhvien sv
where cd.MaPhanCong=pc.MaPhanCong and pc.MaSV=sv.MaSV and cd.MaTB=idTB 
and concat('.', pc.MaSV, '.', sv.TenSV, '.', sv.MaLop, '.', sv.SDT, '.', sv.Email , '.') like concat('%',tukhoa,'%')
        ) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SVDAHD` (`khoa` YEAR, `idNganh` CHAR(2), `diem` FLOAT, `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
select count(*) into @demPCPB
from phancongdoan
where SUBSTRING(MaSV, 2,2)=right(khoa, 2) and SUBSTRING(MaSV, 6,2)=idNganh and MaGVPB is null;

if @demPCPB=0 then 
	select COUNT(*) into @demHang
from (select *
	from (select sv.MaSV, sv.TenSV, sv.Email, sv.GPA, tmp.MaGVHD, tmp.TenGVHD, ifnull(tmp.diem,'') as Diem
			from sinhvien sv, 
				(select pc.MaSV, pc.MaDA, pc.MaGVHD, gv.TenNV as TenGVHD,cd.diem
				from phancongdoan pc, `chamdiemhd-pb` cd, nhanvien gv 
				where 
				SUBSTRING(pc.MaSV, 2,2)=right(khoa, 2) 
				and SUBSTRING(MaSV, 6,2)=idNganh
				and pc.MaPhanCong=cd.MaPhanCong and pc.MaGVHD=cd.MaGV and pc.MaGVHD=gv.MaNV and (cd.diem <4 or cd.diem is null))
				tmp
			where sv.MaSV=tmp.MaSV
			union
			-- select Diem into @diem from DiemSang where NamBD='2018' and MaNGanh='CN';
			select MaSV,TenSV, Email,GPA,'','',''
			from SinhVien
			where SUBSTRING(MaSV, 2,2)=right(khoa, 2)
			and SUBSTRING(MaSV, 6,2)= idNganh
			and GPA>=@diem 
			and MaSV not in (
						select sv.MaSV
						from SinhVien sv, PhanCongDoAn pc
						where SUBSTRING(sv.MaSV, 2,2)=right(khoa, 2)
						and SUBSTRING(sv.MaSV, 6,2)=idNganh
						and sv.MaSV=pc.MaSV)) tmp
	where concat('.', MaSV, '.', TenSV, '.', Email, '.', GPA, '.', MaGVHD, '.', diem, '.') like concat('%',tukhoa,'%')) tmp;
else
select COUNT(*) into @demHang
from (select *
	from (select sv.MaSV, sv.TenSV, sv.Email, sv.GPA, tmp.MaGVHD, tmp.TenGVHD, ifnull(tmp.diem,'') as Diem, sv.MaTK
			from sinhvien sv, 
				(select pc.MaSV, pc.MaDA, pc.MaGVHD, gv.TenNV as TenGVHD,cd.diem
				from phancongdoan pc, `chamdiemhd-pb` cd, nhanvien gv 
				where 
				SUBSTRING(pc.MaSV, 2,2)=right(khoa, 2) 
				and SUBSTRING(MaSV, 6,2)=idNganh
				and pc.MaPhanCong=cd.MaPhanCong and pc.MaGVHD=cd.MaGV and pc.MaGVHD=gv.MaNV and (cd.diem <4 or cd.diem is null))
				tmp
			where sv.MaSV=tmp.MaSV
			union
			-- select Diem into @diem from DiemSang where NamBD='2018' and MaNGanh='CN';
			select MaSV,TenSV, Email,GPA,'','','', MaTK
			from SinhVien
			where SUBSTRING(MaSV, 2,2)=right(khoa, 2)
			and SUBSTRING(MaSV, 6,2)= idNganh
			and GPA>=@diem 
			and MaSV not in (
						select sv.MaSV
						from SinhVien sv, PhanCongDoAn pc
						where SUBSTRING(sv.MaSV, 2,2)=right(khoa, 2)
						and SUBSTRING(sv.MaSV, 6,2)=idNganh
						and sv.MaSV=pc.MaSV)) tmp
	where MaTK is not null and concat('.', tmp.MaSV, '.', tmp.TenSV, '.', tmp.Email, '.', tmp.GPA, '.', tmp.MaGVHD, '.', tmp.diem, '.') like concat('%',tukhoa,'%')) tmp;
	
END IF;
			
		RETURN (@demHang);
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SVDAPB` (`khoa` INT, `tukhoa` VARCHAR(255), `idNganh` CHAR(2)) RETURNS INT(11) begin
DECLARE dem int;
	select count(*) INTO dem
    from
    (
      select *
from (select sv.MaSV, sv.TenSV, sv.Email, cdhd.Diem as DiemHD,pc.MaGVPB, gv.TenNV as TenGVPB, cdpb.Diem as DiemPB
		from sinhvien sv, phancongdoan pc, `chamdiemhd-pb` cdhd, `chamdiemhd-pb` cdpb, nhanvien gv 
		where SUBSTRING(sv.MaSV, 2,2)=right(khoa, 2)
		 and SUBSTRING(sv.MaSV, 6,2)=idNganh
		 and sv.MaSV=pc.MaSV 
		 and pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV 
		 and pc.MaPhanCong=cdpb.MaPhanCong and pc.MaGVPB=cdpb.MaGV
         and pc.MaGVPB=gv.MaNV
		 and (cdpb.Diem<4 or cdpb.Diem is null)
		 union 
		 select sv.MaSV, sv.TenSV, sv.Email, cdhd.Diem as DiemHD,'','', null
		 from sinhvien sv, phancongdoan pc, `chamdiemhd-pb` cdhd
		 where SUBSTRING(sv.MaSV, 2,2)=right(khoa, 2)
		 and SUBSTRING(sv.MaSV, 6,2)=idNganh
		 and sv.MaSV=pc.MaSV 
		 and pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV and cdhd.diem>=4 and pc.MaGVPB is null) tmp
where   concat('.', MaSV, '.', TenSV, '.', Email, '.', DiemHD, '.', MaGVPB, '.', TenGVPB, '.', DiemPB, '.') like concat('%',tukhoa,'%')
	) tmp;
RETURN(dem);
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SVDATB` (`khoa` YEAR, `idNganh` CHAR(2), `tukhoa` VARCHAR(255)) RETURNS INT(11) BEGIN
DECLARE demHang int;
select count(*) into demHang
from
(
    select *
from (select tmp1.MaSV, tmp1.TenSV, tmp1.Email, tmp1.DiemPB, ifnull(tmp2.MaTB,'') as MaTB, ifnull(tmp2.Diemtb,'') as Diemtb, tmp2.slDiem
		from (select sv.MaSV, sv.TenSV, sv.Email, cdpb.Diem as DiemPB, pc.MaPhanCong
				from sinhvien sv, phancongdoan pc, `chamdiemhd-pb` cdpb
				where pc.MaSV=sv.MaSV and pc.MaPhanCong=cdpb.MaPhanCong and pc.MaGVPB=cdpb.MaGV and cdpb.Diem>=4 and SUBSTRING(pc.MaPhanCong, 3,2)=right(khoa, 2) and SUBSTRING(pc.MaSV, 6,2)=idNganh
				) tmp1
		left join (select MaPhanCong, MaTB, AVG(Diem) as Diemtb, count(Diem) as slDiem
					from chamdiemtb
					where SUBSTRING(MaPhanCong, 3,2)=right(khoa, 2)
					group by MaPhanCong, MaTB) tmp2
		on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp
where concat('.', MaSV, '.', TenSV, '.', Email, '.', DiemPB, '.', MaTB, '.', Diemtb, '.') like concat('%',tukhoa,'%')
) lastList;
RETURN(demHang);
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SVHD_GV` (`idGV` CHAR(7), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang FROM(
            select * 
from (select tmp1.MaPhanCong, tmp1.MaSV, tmp1.TenSV, tmp1.MaLop, tmp2.MaDA, tmp2.TenDA, tmp2.Diem, tmp2.MaCT
		from (select pc.MaPhanCong, sv.MaSV, sv.TenSV, sv.MaLop
				from sinhvien sv, phancongdoan pc
				where pc.MaSV=sv.MaSV and pc.MaGVHD=idGV and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2)) tmp1
		left join (select pc.MaPhanCong, pc.MaDA, da.TenDA, pc.MaCT, cdhd.Diem
					from phancongdoan pc, doan da, `chamdiemhd-pb` cdhd
					where pc.MaDA=da.MaDA and pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV ) tmp2
		on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp 
where concat('.', MaSV, '.', TenSV, '.', MaLop, '.', MaDA, '.', TenDA, '.', Diem, '.') like concat('%',tukhoa,'%')
		) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SVPB_GV` (`idGV` CHAR(7), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang FROM(
            SELECT *
FROM (select pc.MaPhanCong, sv.MaSV, sv.TenSV, sv.MaLop, pc.MaDA, da.TenDA, ifnull(cd.Diem,'') as Diem, pc.MaCT
from sinhvien sv, phancongdoan pc, doan da, `chamdiemhd-pb` cd
where pc.MaSV=sv.MaSV and pc.MaDA=da.MaDA and cd.MaPhanCong=pc.MaPhanCong and cd.MaGV=pc.MaGVPB and pc.MaGVPB=idGV and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2))tmp
WHERE concat('.', MaSV, '.', TenSV, '.', MaLop, '.', MaDA, '.', TenDA, '.', Diem, '.') like concat('%',tukhoa,'%')
            ) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SVTB_GV` (`idGV` CHAR(7), `idTB` CHAR(6), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang FROM(
		SELECT * FROM
(select pc.MaPhanCong, cd.MaTB, sv.MaSV, sv.TenSV, sv.MaLop, da.MaDA, da.TenDA, ifnull(cd.Diem,'') as Diem, pc.MaCT
from sinhvien sv, phancongdoan pc, doan da, chamdiemtb cd
where pc.MaSV=sv.MaSV and pc.MaDA=da.MaDA and pc.MaPhanCong=cd.MaPhanCong and cd.MaGV=idGV and cd.MaTB=idTB) tmp
where concat('.', MaSV, '.', TenSV, '.', MaLop, '.', MaDA, '.', TenDA, '.', Diem, '.') like concat('%',tukhoa,'%')
        ) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_TB` (`khoa` YEAR, `idNganh` CHAR(2), `tukhoa` VARCHAR(255)) RETURNS INT(11) BEGIN
	declare demHang int;
	SELECT COUNT(*) into demHang FROM
    (
      select *
    from (select tb.MaTB, tb.Ngay, tb.Ca, count(pc.MaGV) as sum
		from (select MaTB, Ngay, Ca
				from tieuban
				where MaNganh=idNganh and substring(MaTB,3,2)=right(khoa,2)) tb
		left join phanconggvtb pc 
		on tb.MaTB=pc.MaTB
		group by tb.MaTB,tb.Ngay, tb.Ca) tmp
	where concat('.', MaTB, '.', Ngay, '.', Ca, '.', sum, '.') like concat('%',tukhoa,'%')
     )tmplist;
    RETURN(demHang);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_TB_GV` (`idGV` CHAR(7), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang 
        FROM(
            select pc.MaTB, tb.Ngay, tb.Ca
    from phanconggvtb pc, tieuban tb
    where pc.MaTB=tb.MaTB and substring(pc.MaTB,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2) and MaGV=idGV
    and concat('.', pc.MaTB, '.', tb.Ngay, '.', tb.Ca, '.') like concat('%',tukhoa,'%')
           ) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `DeleteFile` (`idCT` INT) RETURNS INT(11) BEGIN
select count(*) into @demFile
from phancongdoan
where MaCT=idCT;

if @demFile=0 then
	select MaDA into @idDA
    from phienbanhuongdan
    where MaCT=idCT;
    
	SELECT COUNT(*) into @mainFile
    FROM phienbanhuongdan
    where MaDA=@idDA and TrangThai=0;
    
    if @mainFile=1 then
		return (-1); -- Không thể xoá file này
	else
		delete from phienbanhuongdan where MaCT=idCT;
		return (1); -- Thành công
	end if;
else
	return (-1); -- Không thể xoá file này
END if;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Delete_GV` (`idGV` CHAR(7)) RETURNS INT(11) begin
select count(*) into @isHaveDA
from (select MaPhanCOng
		from phancongdoan pc
		where MaGVHD=idGV or MaGVPB=idGV and substring(MaPhanCong, 3,2)=right(2017,2)
		union
		select MaPhanCong
		from chamdiemtb
		where MaGV=idGV and substring(MaPhanCong, 3,2)=right(2017,2)
        union 
        select MaDA
        from chitietchinhsuadoan
        where MaGV=idGV
        ) tmp;

select count(*) into @isHadDA
from (select MaPhanCOng
		from phancongdoan pc
		where MaGVHD=idGV or MaGVPB=idGV and substring(MaPhanCong, 3,2)<>right(2017,2)
		union
		select MaPhanCong
		from chamdiemtb
		where MaGV=idGV and substring(MaPhanCong, 3,2)<>right(2017,2)) tmp;

if  @isHaveDA<>0 then
	return (-1); -- Không thể xoá GV này
elseif @isHadDA<>0 then
	-- SET SQL_SAFE_UPDATES=0;
	call Delete_TK(idGV);
    -- SET SQL_SAFE_UPDATES=1;
    return (1); -- Thành công
else 
	
	call Delete_TK(idGV);
    -- SET SQL_SAFE_UPDATES=0;
	-- delete from nhanvien where MaNV=idGV;
    -- SET SQL_SAFE_UPDATES=1;
    return (2); -- Thành công
    
end if;
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `DiemSang` (`khoa` YEAR, `idNganh` CHAR(2)) RETURNS FLOAT BEGIN
	select Diem into @result from diemsang where NamBD=khoa and MaNganh=idNganh;
    if @result is null THEN
    	RETURN(0);
  	end if;
    	RETURN(@result);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `isDeleteSV` (`idSV` CHAR(10)) RETURNS INT(11) BEGIN
	SELECT MaPhanCong into @idPC from phancongdoan
    where MaSV=idSV;
    SELECT COUNT(Diem) into @isExitScore from `chamdiemhd-pb` WHERE MaPhanCong=@idPC;
    IF @isExitScore<>0 THEN
    	return 0;
    ELSE
    	return 1;
    END if;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `IsEditTB` (`idTB` CHAR(6)) RETURNS INT(11) BEGIN
select count(MaPhanCong) INTO @result
from chamdiemtb
where MaTB=idTB and Diem is not null;
RETURN(@result);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `IsExitFileHD` (`idDA` CHAR(7), `idGV` CHAR(7)) RETURNS INT(11) BEGIN
select MaCT into @idCT
from phienbanhuongdan
where MaDA=idDA and MaGV=idGV and TrangThai=1;
select count(MaPhanCong) into @isUsed from phancongdoan where MaCT=@idCT;
if @isUsed=0 THEN
	if @idCT is not null THEN
    	set @result= @idCT;
    	-- RETURN (@idCT);
    else 
    	set @result=0;
    	-- RETURN(0);
   	end if;
else
	set @result=0;
	-- RETURN(0);
end if;
RETURN(@result);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `IsGotDA` (`idSV` CHAR(10)) RETURNS INT(11) BEGIN
SELECT COUNT(*) into @result from phancongdoan
where MaSV=idSV;
RETURN(@result);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `NienKhoaHienTai` (`idNganh` CHAR(2)) RETURNS YEAR(4) begin
select SoNam into @tmp from nganh where MaNganh=idNganh;
select count(*) into @demTK
from taikhoan
where quyen='SV' and substring(TenDangNhap,6,2)=idNganh;
if @demTK<>0 then
	select concat('20',substring(min(TenDangNhap),2,2)) into @now
	from taikhoan
	where Quyen='SV' and substring(TenDangNhap,6,2)=idNganh;
else
	set @now =year(curdate())-floor(@tmp);
end if;    
return(@now);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `TrangThai_MoKhoaMoi` (`idNganh` CHAR(2)) RETURNS INT(11) BEGIN
select count(*) into @demNganh
from diemsang 
where MaNganh=idNganh;

if @demNganh=0 then
	set @result=1;
else
	select count(*) into @demDA
	from chamdiemtb cd, tieuban tb
	where cd.MaTB=tb.MaTB and tb.MaNganh=idNganh and substring(cd.MaPhanCong,3,2)=right(nienkhoahientai(idNganh),2);

	if @demDA=0 or @demDA is null then 
		set @result=0;
	else 
		select count(*) into @demDABC
		from chamdiemtb cd, tieuban tb
		where cd.MaTB=tb.MaTB and tb.MaNganh=idNganh and cd.Diem is null;
		
		if @demDABC=0 then set @result=1;
		else set @result=0;
		end if;
	end if;
end if;
RETURN(@result);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `TrangThai_NutLoc` (`khoa` YEAR, `idNganh` CHAR(2)) RETURNS INT(11) BEGIN
SELECT COUNT(Diem) INTO @demDiem
FROM `chamdiemhd-pb`
WHERE substring(MaPhanCong, 3,2)=RIGHT(khoa,2) and substring(MaGV, 3,2)=idNganh;
RETURN(@demDiem);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `TrangThai_UpTaiLieuHDCaNhan` (`idDA` CHAR(7), `idGV` CHAR(7), `idGVTaoDA` CHAR(7)) RETURNS INT(11) BEGIN
IF idGV=idGVTaoDA THEN
    select MaCT into @idCT
    from phienbanhuongdan
    where MaDA=idDA and MaGV=idGV and TrangThai=0;

    select count(*) into @result
    from phancongdoan
    where MaCT=@idCT;
    RETURN(@result);
ELSE
	select MaCT into @idCT
    from phienbanhuongdan
    where MaDA=idDA and MaGV=idGV and TrangThai=1;
	IF @idCT is null then
    	RETURN 1;
    ELSE
        select count(*) into @result
        from phancongdoan
        where MaCT=@idCT;
        RETURN(@result);
    end if;
END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `baocao`
--

CREATE TABLE `baocao` (
  `MaBC` int(11) NOT NULL,
  `Tep` varchar(100) NOT NULL,
  `MoTa` varchar(255) DEFAULT NULL,
  `ThoiGian` datetime NOT NULL,
  `TrangThai` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `baocao`
--

INSERT INTO `baocao` (`MaBC`, `Tep`, `MoTa`, `ThoiGian`, `TrangThai`) VALUES
(1, 'N17DCCN018DA2102320210805003759Mang-may-tinh_2-Thầy-Toản.doc', 'Tệp văn bản,Tệp trình chiếu,', '2021-08-05 00:15:35', 1),
(2, 'N17DCCN019DA2102720210805092248Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,', '2021-08-05 09:22:48', 2),
(3, 'N17DCCN019DA2102720210805092258Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,', '2021-08-05 09:22:58', 2),
(4, 'N17DCCN019DA2102720210805092323Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,Tệp trình chiếu,', '2021-08-05 09:23:23', 2),
(5, 'N17DCCN019DA2102720210805092405Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,Tệp trình chiếu,', '2021-08-05 09:24:05', 2),
(6, 'N17DCCN019DA2102720210805092413Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,Tệp trình chiếu,', '2021-08-05 09:24:13', 2),
(7, 'N17DCCN019DA2102720210805093059Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,Tệp trình chiếu,', '2021-08-05 09:30:59', 2),
(8, 'N17DCCN019DA2102720210805093102Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,Tệp trình chiếu,', '2021-08-05 09:31:02', 2),
(9, 'N17DCCN019DA2102720210805093115Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,', '2021-08-05 09:31:15', 2),
(10, 'N17DCCN019DA2102720210805093116Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,', '2021-08-05 09:31:15', 2),
(11, 'N17DCCN019DA2102720210805102026Account.txt', 'Tệp văn bản,', '2021-08-05 09:31:15', 1),
(12, 'N17DCCN021DA2102820210805132005Account.txt', 'Tệp văn bản,', '2021-08-05 13:06:08', 1),
(13, 'N17DCCN022DA2102920210805133312BAOCAO.docx', 'Tệp văn bản,', '2021-08-05 13:33:12', 1),
(14, 'N17DCCN020DA2103020210805145154Account.txt', 'Tệp văn bản,', '2021-08-05 14:51:54', 1),
(15, 'N17DCAT001DA2100420210806115431Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,', '2021-08-06 11:54:31', 2),
(16, 'N17DCAT001DA2100420210806144514Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,', '2021-08-06 14:45:14', 1),
(17, 'N17DCAT002DA2100520210814110621trainingset.csv', 'Tệp trình chiếu,', '2021-08-13 23:00:26', 1),
(18, 'N17DCAT003DA2100620210814235743trainingset.csv', 'Tệp văn bản,', '2021-08-14 23:57:43', 1);

-- --------------------------------------------------------

--
-- Table structure for table `chamdiemhd-pb`
--

CREATE TABLE `chamdiemhd-pb` (
  `MaPhanCong` char(7) NOT NULL,
  `MaGV` varchar(7) NOT NULL,
  `Diem` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `chamdiemhd-pb`
--

INSERT INTO `chamdiemhd-pb` (`MaPhanCong`, `MaGV`, `Diem`) VALUES
('PC17001', 'GVCN001', 8),
('PC17001', 'GVCN002', 7),
('PC17003', 'GVPT002', 4),
('PC17004', 'GVCN001', 7),
('PC17004', 'GVCN002', 7),
('PC17005', 'GVCN001', 7),
('PC17005', 'GVCN002', 7.4),
('PC17005', 'GVCN010', NULL),
('PC17006', 'GVCN001', NULL),
('PC17006', 'GVCN002', 6.8),
('PC17006', 'GVCN004', 7),
('PC17007', 'GVCN002', 5),
('PC17007', 'GVCN004', NULL),
('PC17007', 'GVCN005', NULL),
('PC17007', 'GVCN006', 1),
('PC17008', 'GVCN001', 6.5),
('PC17008', 'GVCN006', 5),
('PC17009', 'GVCN006', 1),
('PC17010', 'GVCN004', 5.4),
('PC17010', 'GVCN006', 7),
('PC17011', 'GVCN003', 7),
('PC17011', 'GVCN005', 7),
('PC17012', 'GVCN005', 8),
('PC17012', 'GVCN014', 6.4),
('PC17013', 'GVCN006', 2),
('PC17013', 'GVCN012', 6.5),
('PC17014', 'GVCN007', 7.4),
('PC17014', 'GVCN008', 7.2),
('PC17015', 'GVCN011', 3),
('PC17016', 'GVCN006', 4),
('PC17016', 'GVCN015', 7),
('PC17017', 'GVCN003', 8.4),
('PC17017', 'GVCN012', 8.5),
('PC17021', 'GVPT001', NULL),
('PC17022', 'GVPT001', NULL),
('PC17023', 'GVPT004', NULL),
('PC17024', 'GVCN009', 5),
('PC17024', 'GVCN011', 8),
('PC17025', 'GVCN010', NULL),
('PC17026', 'GVCN001', 5),
('PC17026', 'GVCN008', 7),
('PC17027', 'GVCN012', 5),
('PC17028', 'GVCN002', 7),
('PC17028', 'GVCN007', 8.5),
('PC17029', 'GVCN012', 7),
('PC17030', 'GVAT001', 8),
('PC17030', 'GVAT002', 7),
('PC17031', 'GVAT005', 8),
('PC17031', 'GVAT007', 8),
('PC17032', 'GVAT001', 6),
('PC17032', 'GVAT002', 8);

-- --------------------------------------------------------

--
-- Table structure for table `chamdiemtb`
--

CREATE TABLE `chamdiemtb` (
  `MaPhanCong` char(7) NOT NULL,
  `MaGV` varchar(7) NOT NULL,
  `MaTB` char(6) NOT NULL,
  `Diem` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `chamdiemtb`
--

INSERT INTO `chamdiemtb` (`MaPhanCong`, `MaGV`, `MaTB`, `Diem`) VALUES
('PC17001', 'GVCN007', 'TB1708', 7),
('PC17001', 'GVCN008', 'TB1708', 8),
('PC17001', 'GVCN010', 'TB1708', 9),
('PC17004', 'GVCN004', 'TB1720', 7),
('PC17004', 'GVCN005', 'TB1720', 6.4),
('PC17004', 'GVCN006', 'TB1720', 4),
('PC17005', 'GVCN009', 'TB1717', 8),
('PC17005', 'GVCN011', 'TB1717', 7.5),
('PC17005', 'GVCN012', 'TB1717', 6),
('PC17006', 'GVCN004', 'TB1720', 7.5),
('PC17006', 'GVCN005', 'TB1720', 7.2),
('PC17006', 'GVCN006', 'TB1720', 8),
('PC17008', 'GVCN013', 'TB1718', 6.8),
('PC17008', 'GVCN014', 'TB1718', 4),
('PC17008', 'GVCN015', 'TB1718', 4.5),
('PC17010', 'GVCN009', 'TB1717', 8.5),
('PC17010', 'GVCN011', 'TB1717', 4.5),
('PC17010', 'GVCN012', 'TB1717', 7),
('PC17011', 'GVCN001', 'TB1719', 7.5),
('PC17011', 'GVCN002', 'TB1719', 8),
('PC17011', 'GVCN003', 'TB1719', 7),
('PC17012', 'GVCN007', 'TB1721', 2),
('PC17012', 'GVCN008', 'TB1721', 3),
('PC17012', 'GVCN009', 'TB1721', 2.5),
('PC17014', 'GVCN001', 'TB1722', 6.5),
('PC17014', 'GVCN002', 'TB1722', 6),
('PC17014', 'GVCN010', 'TB1722', 6.5),
('PC17016', 'GVCN006', 'TB1728', NULL),
('PC17016', 'GVCN014', 'TB1728', NULL),
('PC17016', 'GVCN015', 'TB1728', NULL),
('PC17024', 'GVCN011', 'TB1726', 8),
('PC17024', 'GVCN012', 'TB1726', NULL),
('PC17024', 'GVCN013', 'TB1726', NULL),
('PC17028', 'GVCN012', 'TB1730', 7),
('PC17028', 'GVCN013', 'TB1730', 8),
('PC17028', 'GVCN014', 'TB1730', 6),
('PC17030', 'GVAT004', 'TB1734', NULL),
('PC17030', 'GVAT005', 'TB1734', NULL),
('PC17030', 'GVAT006', 'TB1734', NULL),
('PC17031', 'GVAT003', 'TB1735', NULL),
('PC17031', 'GVAT005', 'TB1735', NULL),
('PC17031', 'GVAT007', 'TB1735', NULL),
('PC17032', 'GVAT001', 'TB1737', 7),
('PC17032', 'GVAT005', 'TB1737', 3),
('PC17032', 'GVAT006', 'TB1737', 7);

-- --------------------------------------------------------

--
-- Table structure for table `chitietchinhsuadoan`
--

CREATE TABLE `chitietchinhsuadoan` (
  `MaDA` char(7) NOT NULL,
  `MaGV` varchar(7) NOT NULL,
  `ThoiGian` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `chitietchinhsuadoan`
--

INSERT INTO `chitietchinhsuadoan` (`MaDA`, `MaGV`, `ThoiGian`) VALUES
('DA21001', 'GVCN001', '2021-06-15 15:43:11'),
('DA21001', 'GVCN001', '2021-06-15 16:03:07'),
('DA21001', 'GVCN001', '2021-06-17 16:45:15'),
('DA21001', 'GVCN001', '2021-06-22 14:34:19'),
('DA21001', 'GVCN001', '2021-06-22 14:34:29'),
('DA21002', 'GVCN001', '2021-06-15 15:54:59'),
('DA21002', 'GVCN001', '2021-06-17 16:46:23'),
('DA21002', 'GVCN001', '2021-08-05 03:00:31'),
('DA21002', 'GVCN001', '2021-08-05 08:11:06'),
('DA21003', 'GVCN001', '2021-06-15 15:57:03'),
('DA21003', 'GVCN001', '2021-06-15 15:58:21'),
('DA21003', 'GVCN001', '2021-06-17 16:46:37'),
('DA21004', 'GVAT001', '2021-06-15 16:06:09'),
('DA21004', 'GVAT001', '2021-08-06 11:50:08'),
('DA21005', 'GVAT001', '2021-06-15 16:06:41'),
('DA21006', 'GVAT001', '2021-06-15 16:08:13'),
('DA21007', 'GVCN001', '2021-06-17 16:02:57'),
('DA21007', 'GVCN001', '2021-06-17 16:04:12'),
('DA21007', 'GVCN001', '2021-06-17 16:41:46'),
('DA21007', 'GVCN001', '2021-06-17 16:42:30'),
('DA21007', 'GVCN011', '2021-08-02 17:43:33'),
('DA21007', 'GVCN011', '2021-08-03 14:46:28'),
('DA21008', 'GVCN001', '2021-06-17 16:39:38'),
('DA21008', 'GVCN001', '2021-06-17 16:41:48'),
('DA21008', 'GVCN001', '2021-06-17 16:42:43'),
('DA21009', 'GVCN001', '2021-06-17 16:47:47'),
('DA21010', 'GVCN002', '2021-06-18 17:19:51'),
('DA21010', 'GVCN007', '2021-08-02 17:31:13'),
('DA21011', 'GVCN006', '2021-06-19 17:34:05'),
('DA21012', 'GVCN007', '2021-06-20 14:55:40'),
('DA21013', 'GVCN001', '2021-06-22 14:35:58'),
('DA21014', 'GVCN001', '2021-06-22 14:37:11'),
('DA21015', 'GVCN001', '2021-08-05 03:00:05'),
('DA21015', 'GVCN006', '2021-08-02 16:17:17'),
('DA21015', 'GVCN006', '2021-08-02 16:17:26'),
('DA21016', 'GVCN003', '2021-08-02 17:20:27'),
('DA21016', 'GVCN005', '2021-08-03 14:55:46'),
('DA21017', 'GVCN005', '2021-08-02 17:29:16'),
('DA21017', 'GVCN005', '2021-08-03 14:55:24'),
('DA21017', 'GVCN012', '2021-08-02 17:48:06'),
('DA21018', 'GVCN014', '2021-08-03 15:27:51'),
('DA21019', 'GVPT002', '2021-08-03 15:31:52'),
('DA21020', 'GVCN015', '2021-08-03 15:35:20'),
('DA21021', 'GVCN001', '2021-08-05 07:47:41'),
('DA21021', 'GVCN009', '2021-08-04 12:32:42'),
('DA21021', 'GVCN010', '2021-08-05 03:39:24'),
('DA21022', 'GVPT001', '2021-08-04 20:02:17'),
('DA21023', 'GVCN001', '2021-08-05 08:33:58'),
('DA21023', 'GVCN010', '2021-08-04 21:02:35'),
('DA21023', 'GVCN010', '2021-08-05 03:08:34'),
('DA21024', 'GVPT001', '2021-08-04 22:39:28'),
('DA21025', 'GVCN011', '2021-08-05 03:03:40'),
('DA21026', 'GVCN008', '2021-08-05 09:16:00'),
('DA21027', 'GVCN008', '2021-08-05 09:16:50'),
('DA21028', 'GVCN012', '2021-08-05 12:52:27'),
('DA21028', 'GVCN012', '2021-08-05 14:35:18'),
('DA21029', 'GVCN007', '2021-08-05 12:23:41'),
('DA21030', 'GVCN012', '2021-08-05 14:44:21'),
('DA21031', 'GVAT006', '2021-08-15 13:13:14'),
('DA21031', 'GVAT006', '2021-08-15 13:13:26');

-- --------------------------------------------------------

--
-- Table structure for table `chuyennganh`
--

CREATE TABLE `chuyennganh` (
  `MaCN` char(2) NOT NULL,
  `TenCN` varchar(50) NOT NULL,
  `MaNganh` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `chuyennganh`
--

INSERT INTO `chuyennganh` (`MaCN`, `TenCN`, `MaNganh`) VALUES
('AT', 'An toàn thông tin', 'AT'),
('CP', 'Công Nghệ Phần Mềm', 'CN'),
('CS', 'Khoa học máy tính', 'CN'),
('IS', 'Hệ Thống Thông Tin', 'CN'),
('MT', 'Mạng Máy Tính và Truyền Thông', 'CN'),
('PU', 'Phát Triển Ứng Dụng', 'PT'),
('TK', 'Thiết Kế', 'PT');

-- --------------------------------------------------------

--
-- Table structure for table `diemsang`
--

CREATE TABLE `diemsang` (
  `MaNganh` char(2) NOT NULL,
  `NamBD` year(4) NOT NULL,
  `Diem` float NOT NULL DEFAULT 2.5
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `diemsang`
--

INSERT INTO `diemsang` (`MaNganh`, `NamBD`, `Diem`) VALUES
('AT', 2017, 2.5),
('CN', 2016, 3),
('CN', 2017, 3),
('CN', 2018, 3),
('PT', 2016, 2),
('PT', 2017, 3);

-- --------------------------------------------------------

--
-- Table structure for table `doan`
--

CREATE TABLE `doan` (
  `MaDA` char(7) NOT NULL,
  `TenDA` varchar(255) NOT NULL,
  `MaCN` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `doan`
--

INSERT INTO `doan` (`MaDA`, `TenDA`, `MaCN`) VALUES
('DA21001', 'Phần mềm quản lý KTX', 'CP'),
('DA21002', 'Phần mềm quản lý đồ án ', 'CP'),
('DA21003', 'Phần mềm quản lý bãi giữ xe', 'CP'),
('DA21004', 'Nghiên cứu kỹ thuật trích xuất firmware và ứng dụng trong phân tích mã độc', 'AT'),
('DA21005', 'Phân tích giao thức an toàn mạng không dây', 'AT'),
('DA21006', 'Nghiên cứu hệ mật mã khối hạng nhẹ', 'AT'),
('DA21007', 'Công nghệ LTE và LTE phát triển', 'IS'),
('DA21008', 'Phân tích và thiết kế HTTT', 'IS'),
('DA21009', 'Phân tích thiết kế Hệ thống thông tin quản lí bán hàng', 'IS'),
('DA21010', 'Phần mềm chơi game', 'CP'),
('DA21011', 'Quản lý mạng máy tính', 'MT'),
('DA21012', 'Xây Dựng Một Phòng Internet Game', 'MT'),
('DA21013', 'Hướng  dẫn', 'CP'),
('DA21014', 'Đồ án khoa học máy tính', 'CS'),
('DA21015', 'Thiết kế web bán đồng hồ', 'CP'),
('DA21016', 'Xây dựng website thương mại điện tử', 'CP'),
('DA21017', 'Quản Lý Nguyên Liệu, Sản Phẩm Và Hợp Đồng Xuất Khẩu', 'CP'),
('DA21018', 'Quản Lý Nhà Hàng Khách Sạn', 'CP'),
('DA21019', 'Tìm hiểu môi trường phát triển di động', 'PU'),
('DA21020', 'Quản Lý Khách Hàng Đăng Ký Sử Dụng Internet', 'CP'),
('DA21021', 'DoAn thu nghiem', 'CP'),
('DA21022', 'Đồ án phát triển ứng dụng', 'PU'),
('DA21023', 'Test', 'CP'),
('DA21024', 'Đồ án Thiết kế', 'TK'),
('DA21025', 'Test', 'CP'),
('DA21026', 'Test ', 'IS'),
('DA21027', 'TestCP', 'CP'),
('DA21028', 'Đồ án tốt nghiệp ', 'CP'),
('DA21029', 'Đồ án CNPM', 'CP'),
('DA21030', 'DA', 'CP'),
('DA21031', 'Đồ án ATTT', 'AT');

-- --------------------------------------------------------

--
-- Table structure for table `hoidong`
--

CREATE TABLE `hoidong` (
  `MaHD` int(11) NOT NULL,
  `TenHD` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `hoidong`
--

INSERT INTO `hoidong` (`MaHD`, `TenHD`) VALUES
(1, 'Khoa Công nghệ thông tin');

-- --------------------------------------------------------

--
-- Table structure for table `lop`
--

CREATE TABLE `lop` (
  `MaLop` char(11) NOT NULL,
  `MaCN` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `lop`
--

INSERT INTO `lop` (`MaLop`, `MaCN`) VALUES
('D17CQAT01-N', 'AT'),
('D17CQAT02-N', 'AT'),
('D16CQCP01-N', 'CP'),
('D17CQCP01-N', 'CP'),
('D17CQCP02-N', 'CP'),
('D18CQCP01-N', 'CP'),
('D16CQCS01-N', 'CS'),
('D17CQCS01-N', 'CS'),
('D17CQCS02-N', 'CS'),
('D16CQIS01-N', 'IS'),
('D17CQIS01-N', 'IS'),
('D17CQIS02-N', 'IS'),
('D17CQMT01-N', 'MT'),
('D17CQMT02-N', 'MT'),
('D17CQPU01-N', 'PU'),
('D17CQPU02-N', 'PU'),
('D16CQTK01-N', 'TK'),
('D17CQTK01-N', 'TK'),
('D17CQTK02-N', 'TK');

-- --------------------------------------------------------

--
-- Table structure for table `nganh`
--

CREATE TABLE `nganh` (
  `MaNganh` char(2) NOT NULL,
  `TenNganh` varchar(50) NOT NULL,
  `SoNam` float NOT NULL DEFAULT 4.5,
  `MaHD` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `nganh`
--

INSERT INTO `nganh` (`MaNganh`, `TenNganh`, `SoNam`, `MaHD`) VALUES
('AT', 'An toàn thông tin', 4.5, 1),
('CN', 'Công nghệ thông tin', 4.5, 1),
('PT', 'Công nghệ đa phương tiện', 4.5, 1);

-- --------------------------------------------------------

--
-- Table structure for table `nhanvien`
--

CREATE TABLE `nhanvien` (
  `MaNV` varchar(7) NOT NULL,
  `TenNV` varchar(50) NOT NULL,
  `NgaySinh` date DEFAULT NULL,
  `MaNganh` char(2) NOT NULL,
  `SDT` char(10) DEFAULT NULL,
  `Email` varchar(50) NOT NULL,
  `MaTK` char(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `nhanvien`
--

INSERT INTO `nhanvien` (`MaNV`, `TenNV`, `NgaySinh`, `MaNganh`, `SDT`, `Email`, `MaTK`) VALUES
('GVAT001', 'Huỳnh Văn Nhứt', '1978-12-23', 'AT', '0903007234', 'vannhut2312@ptithcm.edu.vn', 'TK0050'),
('GVAT002', 'Nguyễn Văn Tài', '1989-02-19', 'AT', '0567744713', 'vantai1989@ptithcm.edu.vn', 'TK0051'),
('GVAT003', 'Trần Ngọc Long', '1991-02-19', 'AT', '0815870819', 'longdragon91@ptithcm.edu.vn', 'TK0052'),
('GVAT004', 'Huỳnh Trấn Thành', '1987-02-05', 'AT', '0934253518', 'tranthanh1987@ptithcm.edu.vn', 'TK0053'),
('GVAT005', 'Võ Vũ Trường Giang', '1983-04-20', 'AT', '0901777214', 'truonggiangvo@ptithcm.edu.vn', 'TK0054'),
('GVAT006', 'Trần Văn A', '1989-03-06', 'AT', '0123456789', 'tva@ptithcm.edu.vn', 'TK0044'),
('GVAT007', 'Trần Văn A', '1986-06-13', 'AT', '0354920370', 'tva@ptithcm.edu.vn', 'TK0045'),
('GVCN001', 'NGUYỄN PHÚ ĐỒNG', '1967-11-23', 'CN', '0899525546', 'phudong2311@ptithcm.edu.vn', 'TK0055'),
('GVCN002', 'TRẦN THỊ THANH HẢO', '1996-12-11', 'CN', '0376699418', 'ThanhHao@ptithcm.edu.vn', 'TK0056'),
('GVCN003', 'HỒ THỊ QUỲNH GIANG', '1987-11-14', 'CN', '0903014589', 'quynhgiang1511@ptithcm.edu.vn', 'TK0057'),
('GVCN004', 'LƯƠNG THỊ PHƯƠNG', '1981-08-07', 'CN', '0902152421', 'thiphuong1918@ptithcm.edu.vn', 'TK0058'),
('GVCN005', 'HỒ THỊ QUỲNH GIANG', '1989-12-11', 'CN', '0894098770', 'quynhgiang1989@ptithcm.edu.vn', 'TK0059'),
('GVCN006', 'NGUYỄN THỊ THANH VÂN', '1978-12-01', 'CN', '0896426195', 'thanhvan1989@ptithcm.edu.vn', 'TK0060'),
('GVCN007', 'TẠ THỊ HIỆP', '1997-03-10', 'CN', '373891916', 'hiepga1979@ptithcm.edu.vn', 'TK0061'),
('GVCN008', 'VÕ THỊ MINH THỦY', '1992-11-11', 'CN', '0935048741', 'minhthuy1992@ptithcm.edu.vn', 'TK0062'),
('GVCN009', 'NGUYỄN TRƯỜNG AN', '1993-03-16', 'CN', '0894871525', 'truonganan@ptithcm.edu.vn', 'TK0063'),
('GVCN010', 'VÕ THỊ MINH THỦY', '1992-06-17', 'CN', '0902801702', 'thuyngok1992@ptithcm.edu.vn', 'TK0064'),
('GVCN011', 'TRẦN THANH LONG', '1967-02-14', 'CN', '0938142487', 'Thanhlong67@ptithcm.edu.vn', 'TK0065'),
('GVCN012', 'NGUYỄN LONG NHẬT', '1981-05-10', 'CN', '0378246204', 'Nhatlong0105@ptithcm.edu.vn', 'TK0066'),
('GVCN013', 'NGUYỄN VĂN TẤN', '1979-06-01', 'CN', '0902555857', 'Vantan0106@ptithcm.edu.vn', 'TK0067'),
('GVCN014', 'ĐỖ TRẦN THIỆN BÌNH', '1972-07-12', 'CN', '0856135263', 'Binhbong1972@ptithcm.edu.vn', 'TK0068'),
('GVCN015', 'NGUYỄN TRÍ BÁCH', '1978-08-12', 'CN', '0906521164', 'Bachrau78@ptithcm.edu.vn', 'TK0069'),
('GVCN016', 'Nguyễn Thị Thanh', '1968-10-10', 'CN', '0123456781', 'thanh1968@ptithcm.edu.vn', 'TK0093'),
('GVPT001', 'Nguyễn Thị Minh Hằng', '1975-10-25', 'PT', '0937563052', 'minhhang2510@ptithcm.edu.vn', 'TK0070'),
('GVPT002', 'Trần Thị Nhã Phương', '1990-05-20', 'PT', '0855012340', 'nhaphuong2005@ptithcm.edu.vn', 'TK0071'),
('GVPT003', 'Ninh Dương Lan Ngọc', '1990-04-04', 'PT', '0815870819', 'ngocninh0404@ptithcm.edu.vn', 'TK0072'),
('GVPT004', 'Nguyễn Quang Hải', '1987-04-12', 'PT', '0901777714', 'quanghai1987@ptithcm.edu.vn', 'TK0073'),
('GVPT005', 'Nguyễn Công Phượng', '1988-11-12', 'PT', '0385555311', 'phuongcong12@ptithcm.edu.vn', 'TK0074'),
('QL001', 'Chiến', '2021-08-01', '', '0123456789', 'xxxxx', 'TK0075');

--
-- Triggers `nhanvien`
--
DELIMITER $$
CREATE TRIGGER `TgA_Insert_NV` AFTER INSERT ON `nhanvien` FOR EACH ROW BEGIN
	CALL AfterInsert_NV(new.MaNV);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `TgB_Insert_NV` BEFORE INSERT ON `nhanvien` FOR EACH ROW begin
     set new.MaTK=(SELECT AUTO_GetMaTK());
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `phancongdoan`
--

CREATE TABLE `phancongdoan` (
  `MaPhanCong` char(7) NOT NULL,
  `MaDA` char(7) DEFAULT NULL,
  `MaSV` char(10) NOT NULL,
  `MaGVHD` varchar(7) NOT NULL,
  `MaGVPB` varchar(7) DEFAULT NULL,
  `NgayPhanCong` date DEFAULT NULL,
  `MaBC` int(11) DEFAULT NULL,
  `MaCT` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `phancongdoan`
--

INSERT INTO `phancongdoan` (`MaPhanCong`, `MaDA`, `MaSV`, `MaGVHD`, `MaGVPB`, `NgayPhanCong`, `MaBC`, `MaCT`) VALUES
('PC17001', 'DA21001', 'N17DCCN001', 'GVCN001', 'GVCN002', '0000-00-00', NULL, 20),
('PC17003', 'DA21019', 'N17DCPT001', 'GVPT002', NULL, '0000-00-00', NULL, 33),
('PC17004', 'DA21008', 'N17DCCN002', 'GVCN002', 'GVCN001', '0000-00-00', NULL, 11),
('PC17005', 'DA21014', 'N17DCCN003', 'GVCN001', 'GVCN002', '0000-00-00', NULL, 22),
('PC17006', 'DA21002', 'N17DCCN005', 'GVCN004', 'GVCN002', '0000-00-00', NULL, 13),
('PC17007', 'DA21010', 'N17DCCN007', 'GVCN002', 'GVCN006', '0000-00-00', NULL, 16),
('PC17008', 'DA21013', 'N17DCCN006', 'GVCN006', 'GVCN001', '0000-00-00', NULL, 21),
('PC17009', 'DA21015', 'N17DCCN008', 'GVCN006', NULL, '0000-00-00', NULL, 23),
('PC17010', 'DA21003', 'N17DCCN010', 'GVCN006', 'GVCN004', '0000-00-00', NULL, 14),
('PC17011', 'DA21017', 'N17DCCN009', 'GVCN005', 'GVCN003', '0000-00-00', NULL, 30),
('PC17012', 'DA21018', 'N17DCCN011', 'GVCN014', 'GVCN005', '0000-00-00', NULL, 32),
('PC17013', 'DA21017', 'N17DCCN012', 'GVCN012', 'GVCN006', '0000-00-00', NULL, 28),
('PC17014', 'DA21012', 'N17DCCN013', 'GVCN007', 'GVCN008', '0000-00-00', NULL, 18),
('PC17015', 'DA21007', 'N17DCCN014', 'GVCN011', NULL, '0000-00-00', NULL, 27),
('PC17016', 'DA21020', 'N17DCCN015', 'GVCN015', 'GVCN006', '0000-00-00', NULL, 34),
('PC17017', 'DA21016', 'N17DCCN016', 'GVCN003', 'GVCN012', '0000-00-00', NULL, 24),
('PC17021', NULL, 'N17DCPT002', 'GVPT001', NULL, '0000-00-00', NULL, 0),
('PC17022', NULL, 'N17DCPT004', 'GVPT001', NULL, '0000-00-00', NULL, 0),
('PC17023', NULL, 'N17DCPT005', 'GVPT004', NULL, '0000-00-00', NULL, 0),
('PC17024', 'DA21021', 'N17DCCN017', 'GVCN009', 'GVCN011', '2021-08-04', NULL, 35),
('PC17025', 'DA21023', 'N17DCCN018', 'GVCN010', NULL, '2021-08-04', 1, 46),
('PC17026', 'DA21027', 'N17DCCN019', 'GVCN008', 'GVCN001', '2021-08-05', 11, 48),
('PC17027', 'DA21028', 'N17DCCN021', 'GVCN012', NULL, '2021-08-05', 12, 49),
('PC17028', 'DA21029', 'N17DCCN022', 'GVCN007', 'GVCN002', '2021-08-05', 13, 50),
('PC17029', 'DA21030', 'N17DCCN020', 'GVCN012', NULL, '2021-08-05', 14, 52),
('PC17030', 'DA21004', 'N17DCAT001', 'GVAT001', 'GVAT002', '2021-08-06', 16, 53),
('PC17031', 'DA21005', 'N17DCAT002', 'GVAT007', 'GVAT005', '2021-08-13', 17, 6),
('PC17032', 'DA21006', 'N17DCAT003', 'GVAT002', 'GVAT001', '2021-08-14', 18, 7);

--
-- Triggers `phancongdoan`
--
DELIMITER $$
CREATE TRIGGER `TgB_checkMaDA` BEFORE UPDATE ON `phancongdoan` FOR EACH ROW BEGIN
	
	if old.MaDA is not null THEN
    	if new.MaDA is null then
        	signal sqlstate '45000' set message_text = 'Mã đồ án không được rỗng';
		END if;
    END if;
    SELECT COUNT(*) INTO @dem
            from phancongdoan
            WHERE MaDA=new.MaDA and substring(new.MaPhanCong,3,2)=RIGHT(nienkhoahientai(substring(new.MaSV,6,2)),2);
        	if @dem<>0 and old.MaPhanCong<>new.MaPhanCong THEN
            signal sqlstate '45000' set message_text = 'Mã đồ án này đã được sử dụng';
            END if;
   	IF new.MaGVPB=old.MaGVHD then 
    	signal sqlstate '45000' set message_text = 'GVPB không được trùng vs GVHD';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `phanconggvtb`
--

CREATE TABLE `phanconggvtb` (
  `MaGV` varchar(7) NOT NULL,
  `MaTB` char(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `phanconggvtb`
--

INSERT INTO `phanconggvtb` (`MaGV`, `MaTB`) VALUES
('GVAT001', 'TB1732'),
('GVAT001', 'TB1733'),
('GVAT001', 'TB1737'),
('GVAT002', 'TB1732'),
('GVAT002', 'TB1733'),
('GVAT003', 'TB1732'),
('GVAT003', 'TB1735'),
('GVAT004', 'TB1733'),
('GVAT004', 'TB1734'),
('GVAT005', 'TB1734'),
('GVAT005', 'TB1735'),
('GVAT005', 'TB1737'),
('GVAT006', 'TB1734'),
('GVAT006', 'TB1737'),
('GVAT007', 'TB1735'),
('GVCN001', 'TB1710'),
('GVCN001', 'TB1719'),
('GVCN001', 'TB1722'),
('GVCN002', 'TB1710'),
('GVCN002', 'TB1719'),
('GVCN002', 'TB1722'),
('GVCN003', 'TB1710'),
('GVCN003', 'TB1719'),
('GVCN003', 'TB1736'),
('GVCN004', 'TB1720'),
('GVCN004', 'TB1736'),
('GVCN005', 'TB1720'),
('GVCN005', 'TB1736'),
('GVCN006', 'TB1720'),
('GVCN006', 'TB1728'),
('GVCN007', 'TB1708'),
('GVCN007', 'TB1721'),
('GVCN008', 'TB1708'),
('GVCN008', 'TB1721'),
('GVCN009', 'TB1717'),
('GVCN009', 'TB1721'),
('GVCN010', 'TB1708'),
('GVCN010', 'TB1722'),
('GVCN011', 'TB1717'),
('GVCN011', 'TB1726'),
('GVCN012', 'TB1717'),
('GVCN012', 'TB1726'),
('GVCN012', 'TB1730'),
('GVCN013', 'TB1718'),
('GVCN013', 'TB1726'),
('GVCN013', 'TB1730'),
('GVCN014', 'TB1718'),
('GVCN014', 'TB1728'),
('GVCN014', 'TB1730'),
('GVCN015', 'TB1718'),
('GVCN015', 'TB1728');

--
-- Triggers `phanconggvtb`
--
DELIMITER $$
CREATE TRIGGER `TgBI_checkGVinTB` BEFORE INSERT ON `phanconggvtb` FOR EACH ROW BEGIN
SELECT COUNT(*) INTO @dem
from phanconggvtb
WHERE MaTB=new.MaTB and MaGV=new.MaGV;
if @dem<>0 THEN
	signal sqlstate '45000' set message_text = 'Giảng viên này đã có trong tiểu ban';
END if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `TgBU_CheckGVinTB` BEFORE UPDATE ON `phanconggvtb` FOR EACH ROW BEGIN
SELECT COUNT(*) INTO @dem
from phanconggvtb
WHERE MaTB=new.MaTB and MaGV=new.MaGV;
if @dem<>0  and old.MaGV<>new.MaGV THEN
	signal sqlstate '45000' set message_text = 'Giảng viên này đã có trong tiểu ban';
END if;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `phienbanhuongdan`
--

CREATE TABLE `phienbanhuongdan` (
  `MaCT` int(11) NOT NULL,
  `Tep` varchar(100) DEFAULT NULL,
  `MoTa` varchar(255) DEFAULT NULL,
  `TrangThai` int(11) NOT NULL DEFAULT 1 COMMENT '1=Còn tồn tại\\\\\\\\n0=Đã huỷ',
  `MaDA` char(7) NOT NULL,
  `MaGV` varchar(7) NOT NULL,
  `ThoiGian` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `phienbanhuongdan`
--

INSERT INTO `phienbanhuongdan` (`MaCT`, `Tep`, `MoTa`, `TrangThai`, `MaDA`, `MaGV`, `ThoiGian`) VALUES
(1, 'GVCN001DA210012021061515431118_05Querỵ.txt', 'Tệp văn bản,', 0, 'DA21001', 'GVCN001', '2021-06-15 15:43:11'),
(2, 'GVCN001DA2100220210615155458Hướng dẫn đồ án quản lý đồ án.docx', 'Tệp văn bản,', 2, 'DA21002', 'GVCN001', '2021-06-15 15:54:59'),
(3, 'GVCN001DA2100320210615155703Hướng dẫn đồ án bãi giữ xe.docx', 'Tệp văn bản,', 2, 'DA21003', 'GVCN001', '2021-06-15 15:57:03'),
(4, 'GVCN001DA2100120210615160307Hướng dẫn quản lý ktx.docx', 'Tệp văn bản,', 2, 'DA21001', 'GVCN001', '2021-06-15 16:03:07'),
(6, 'GVAT001DA2100520210615160640Hướng dẫn phân tích giao thức an toàn mạng không dây.docx', 'Tệp văn bản,', 0, 'DA21005', 'GVAT001', '2021-06-15 16:06:41'),
(7, 'GVAT001DA2100620210615160813Hướng dẫn Nghiên cứu hệ mật mã khối hạng nhẹ.docx', 'Tệp văn bản,', 0, 'DA21006', 'GVAT001', '2021-06-15 16:08:13'),
(8, 'GVCN001DA2100720210617160257Hệ thống thông tin di động thế hệ thứ 4 theo công nghệ LTE và LTE phát t', 'Tệp văn bản,Hướng dẫn,', 2, 'DA21007', 'GVCN001', '2021-06-17 16:02:57'),
(9, 'GVCN001DA2100820210617163937Hướng dẫn phân tích và thiết kế HTTT.docx', 'Tệp văn bản,', 2, 'DA21008', 'GVCN001', '2021-06-17 16:39:38'),
(10, 'GVCN001DA2100720210617164229Hệ thống thông tin di động thế hệ thứ 4 theo công nghệ LTE và LTE phát t', 'Tệp văn bản,Hướng dẫn,', 0, 'DA21007', 'GVCN001', '2021-06-17 16:42:30'),
(11, 'GVCN001DA2100820210617164242Hướng dẫn phân tích và thiết kế HTTT.docx', 'Tệp văn bản,Hướng dẫn,', 0, 'DA21008', 'GVCN001', '2021-06-17 16:42:43'),
(12, 'GVCN001DA2100120210617164515Hướng dẫn quản lý ktx 2.docx', 'Tệp văn bản,', 2, 'DA21001', 'GVCN001', '2021-06-17 16:45:15'),
(13, 'GVCN001DA2100220210617164623Hướng dẫn đồ án quản lý đồ án.docx', 'Tệp văn bản,Tệp văn bản,', 0, 'DA21002', 'GVCN001', '2021-06-17 16:46:23'),
(14, 'GVCN001DA2100320210617164637Hướng dẫn đồ án bãi giữ xe.docx', 'Tệp văn bản,Tệp văn bản,', 0, 'DA21003', 'GVCN001', '2021-06-17 16:46:37'),
(15, 'GVCN001DA2100920210617164746Phân tích thiết kế Hệ thống thông tin quản lí bán hàng.docx', 'Tệp văn bản,Tệp văn bản,Hướng dẫn,', 0, 'DA21009', 'GVCN001', '2021-06-17 16:47:47'),
(16, 'GVCN002DA2101020210618171950abcd.docx', 'Tệp văn bản,', 0, 'DA21010', 'GVCN002', '2021-06-18 17:19:51'),
(17, 'GVCN006DA2101120210619173404abcd.docx', 'Tệp văn bản,', 0, 'DA21011', 'GVCN006', '2021-06-19 17:34:05'),
(18, 'GVCN007DA2101220210620145539Đồ án mạng máy tính Xây Dựng Một Phòng Internet Game.docx', 'Tệp văn bản,Hướng dẫn,', 0, 'DA21012', 'GVCN007', '2021-06-20 14:55:40'),
(19, 'GVCN001DA2100120210622143419Hướng dẫn text.txt', 'Tệp văn bản,', 2, 'DA21001', 'GVCN001', '2021-06-22 14:34:19'),
(20, 'GVCN001DA2100120210622143428Hướng dẫn quản lý ktx 2.docx', 'Tệp văn bản,', 1, 'DA21001', 'GVCN001', '2021-06-22 14:34:29'),
(21, 'GVCN001DA2101320210622143558Hướng dẫn text.txt', 'Tệp văn bản,text,', 0, 'DA21013', 'GVCN001', '2021-06-22 14:35:58'),
(22, 'GVCN001DA2101420210622143710Hướng dẫn text.txt', 'Tệp văn bản,', 0, 'DA21014', 'GVCN001', '2021-06-22 14:37:11'),
(23, 'GVCN006DA2101520210802161716Hướng dẫn Thiết kế web bán đồng hồ.docx', 'Tệp văn bản,Word,', 0, 'DA21015', 'GVCN006', '2021-08-02 16:17:17'),
(24, 'GVCN003DA2101620210802172027Đề tài xây dựng website thương mại điện tử.docx', 'Tệp văn bản,', 0, 'DA21016', 'GVCN003', '2021-08-02 17:20:27'),
(25, 'GVCN005DA2101720210802172916QUẢN LÝ NGUYÊN LIỆU, SẢN PHẨM VÀ HỢP ĐỒNG XUẤT KHẨU.docx', 'Tệp văn bản,', 0, 'DA21017', 'GVCN005', '2021-08-02 17:29:16'),
(26, 'GVCN007DA2101020210802173112Hướng dẫn text.txt', 'Tệp văn bản,', 0, 'DA21010', 'GVCN007', '2021-08-02 17:31:13'),
(27, 'GVCN011DA2100720210802174333Hướng dẫn text.txt', '', 0, 'DA21007', 'GVCN011', '2021-08-02 17:43:33'),
(28, 'GVCN012DA2101720210802174805Hướng dẫn text.txt', 'Tệp văn bản,Hướng dẫn GVCN012,', 0, 'DA21017', 'GVCN012', '2021-08-02 17:48:06'),
(29, 'GVCN011DA2100720210803144627Hướng dẫn text.txt', 'Tệp văn bản,', 0, 'DA21007', 'GVCN011', '2021-08-03 14:46:28'),
(30, 'GVCN005DA2101720210803145524Hướng dẫn GVCN005.txt', 'Tệp văn bản,', 0, 'DA21017', 'GVCN005', '2021-08-03 14:55:24'),
(31, 'GVCN005DA2101620210803145546Hướng dẫn GVCN005.txt', '', 0, 'DA21016', 'GVCN005', '2021-08-03 14:55:46'),
(32, 'GVCN014DA2101820210803152750Quản Lý Nhà Hàng Khách Sạn.docx', 'Tệp văn bản,chương trình ,', 0, 'DA21018', 'GVCN014', '2021-08-03 15:27:51'),
(33, 'GVPT002DA2101920210803153152Tìm hiểu môi trường phát triển di động.docx', 'Tệp văn bản,Huong dan,', 0, 'DA21019', 'GVPT002', '2021-08-03 15:31:52'),
(34, 'GVCN015DA2102020210803153519QUẢN LÝ KHÁCH HÀNG ĐĂNG KÝ SỬ DỤNG INTERNET.docx', 'Tệp văn bản,chương trình,', 0, 'DA21020', 'GVCN015', '2021-08-03 15:35:20'),
(35, 'GVCN009DA2102120210804123242THUTUCKhang.txt', 'Tệp văn bản,', 0, 'DA21021', 'GVCN009', '2021-08-04 12:32:42'),
(36, 'GVPT001DA2102220210804200217F9.2021.1080p.AMZN.WEB-DL.DDP5.1.H.264-EVO.srt', ',', 0, 'DA21022', 'GVPT001', '2021-08-04 20:02:17'),
(37, 'GVCN010DA2102320210804210234Mang-may-tinh_2-Thầy-Toản.doc', 'Tệp văn bản,', 0, 'DA21023', 'GVCN010', '2021-08-04 21:02:35'),
(38, 'GVPT001DA2102420210804223928hamTan.txt', 'Tệp văn bản,', 0, 'DA21024', 'GVPT001', '2021-08-04 22:39:28'),
(39, 'GVCN001DA2101520210805030004Mang-may-tinh_2-Thầy-Toản (1).doc', '', 0, 'DA21015', 'GVCN001', '2021-08-05 03:00:05'),
(40, 'GVCN001DA2100220210805030030Mang-may-tinh_2-Thầy-Toản.doc', 'Tệp văn bản,Tệp trình chiếu,', 0, 'DA21002', 'GVCN001', '2021-08-05 03:00:31'),
(41, 'GVCN011DA2102520210805030340quanlydoan.sql', '', 0, 'DA21025', 'GVCN011', '2021-08-05 03:03:40'),
(42, 'GVCN010DA2102320210805030834quanlydoan.sql', 'Tệp chương trình,', 0, 'DA21023', 'GVCN010', '2021-08-05 03:08:34'),
(43, 'GVCN010DA2102120210805033923hamTan.txt', 'Tệp văn bản,', 0, 'DA21021', 'GVCN010', '2021-08-05 03:39:24'),
(44, 'GVCN001DA2102120210805074740Account.txt', 'Tệp văn bản,Tệp âm thanh,', 0, 'DA21021', 'GVCN001', '2021-08-05 07:47:41'),
(46, 'GVCN001DA2102320210805083357hamTan.txt', 'Tệp văn bản,', 1, 'DA21023', 'GVCN001', '2021-08-05 08:33:58'),
(47, 'GVCN008DA2102620210805091600Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,', 0, 'DA21026', 'GVCN008', '2021-08-05 09:16:00'),
(48, 'GVCN008DA2102720210805091650Account.txt', 'Tệp văn bản,', 0, 'DA21027', 'GVCN008', '2021-08-05 09:16:50'),
(49, 'GVCN012DA2102820210805125226Đồ án word test.docx', 'Tệp văn bản,Word,', 0, 'DA21028', 'GVCN012', '2021-08-05 12:52:27'),
(50, 'GVCN007DA2102920210805122341GVCN012DA2102820210805125226Đồ án word test (1).docx', 'Tệp văn bản,', 0, 'DA21029', 'GVCN007', '2021-08-05 12:23:41'),
(51, 'GVCN012DA2102820210805143517GVCN012DA2102820210805125226Đồ án word test (1).docx', 'Tệp văn bản,', 0, 'DA21028', 'GVCN012', '2021-08-05 14:35:18'),
(52, 'GVCN012DA2103020210805144421HAMKhang.txt', 'Tệp văn bản,', 0, 'DA21030', 'GVCN012', '2021-08-05 14:44:21'),
(53, 'GVAT001DA2100420210806115007Mang-may-tinh_2-Thầy-Toản (1).doc', 'Tệp văn bản,', 0, 'DA21004', 'GVAT001', '2021-08-06 11:50:08'),
(54, 'GVAT006DA2103120210815131314code_dongho.txt', 'Tệp văn bản,Tệp trình chiếu,', 0, 'DA21031', 'GVAT006', '2021-08-15 13:13:14');

-- --------------------------------------------------------

--
-- Table structure for table `sinhvien`
--

CREATE TABLE `sinhvien` (
  `MaSV` char(10) NOT NULL,
  `TenSV` varchar(100) NOT NULL,
  `NgaySinh` date DEFAULT NULL,
  `MaLop` char(11) NOT NULL,
  `GPA` float NOT NULL DEFAULT 0,
  `SDT` char(10) DEFAULT NULL,
  `Email` varchar(50) NOT NULL,
  `MaTK` char(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `sinhvien`
--

INSERT INTO `sinhvien` (`MaSV`, `TenSV`, `NgaySinh`, `MaLop`, `GPA`, `SDT`, `Email`, `MaTK`) VALUES
('N16DCCN001', 'Trương Uyển Nhi', '1999-11-30', 'D16CQCS01-N', 3.2, '0906083580', 'N16DCCN001@student.ptithcm.edu.vn', NULL),
('N16DCCN002', 'HOÀNG THỊ HƯƠNG GIANG', '1998-11-05', 'D16CQCP01-N', 3.1, '0935574979', 'N16DCCN002@student.ptithcm.edu.vn', NULL),
('N16DCCN003', 'CHẾ CÔNG HẢI', '1998-12-08', 'D16CQCP01-N', 2.9, '0562137394', 'N16DCCN003@student.ptithcm.edu.vn', NULL),
('N16DCCN004', 'HOÀNG PHAN MINH ĐỨC', '1998-05-11', 'D16CQCP01-N', 3, '0817317098', 'N16DCCN004@student.ptithcm.edu.vn', NULL),
('N17DCAT001', 'Trần Minh Chiến', '2000-12-05', 'D17CQAT01-N', 2.7, '0354920370', 'N17DCAT001@student.ptithcm.edu.vn', 'TK0023'),
('N17DCAT002', 'Nguyễn Thị Phong', '1999-06-13', 'D17CQAT02-N', 2.7, '0968050037', 'N17DCAT002@student.ptithcm.edu.vn', 'TK0046'),
('N17DCAT003', 'Lê Quốc Tấn', '2000-01-01', 'D17CQAT01-N', 2.7, '0123456789', 'N17DCAT003@student.ptithcm.edu.vn', 'TK0094'),
('N17DCCN001', 'NGUYỄN VĨNH AN', '1999-02-16', 'D17CQCP01-N', 3.1, '0814865424', 'N17DCCN001@student.ptithcm.edu.vn', 'TK0022'),
('N17DCCN002', 'PHAN TUẤN AN ', '1999-07-10', 'D17CQIS02-N', 3.1, '0931739491', 'N17DCCN002@student.ptithcm.edu.vn', 'TK0025'),
('N17DCCN003', 'HÀ THỊ MAI ANH', '1999-11-24', 'D17CQCS02-N', 3.3, '0902433976', 'N17DCCN003@student.ptithcm.edu.vn', 'TK0026'),
('N17DCCN005', 'LÊ TUẤN ANH', '1999-01-09', 'D17CQCP01-N', 3.5, '0938170578', 'N17DCCN005@student.ptithcm.edu.vn', 'TK0027'),
('N17DCCN006', 'VŨ HOÀNG VIỆT ANH', '1999-10-18', 'D17CQCP01-N', 3, '0906635555', 'N17DCCN006@student.ptithcm.edu.vn', 'TK0029'),
('N17DCCN007', 'ĐINH NGUYỄN THIÊN ÂN ', '1999-03-30', 'D17CQCP02-N', 3.2, '0817091424', 'N17DCCN007@student.ptithcm.edu.vn', 'TK0028'),
('N17DCCN008', 'DIÊU GIA BẢO', '1999-12-09', 'D17CQCP02-N', 3.2, '0902483967', 'N17DCCN008@student.ptithcm.edu.vn', NULL),
('N17DCCN009', 'HỒ MINH QUỐC BẢO', '1999-03-13', 'D17CQCP02-N', 3.4, '0817091424', 'N17DCCN009@student.ptithcm.edu.vn', 'TK0037'),
('N17DCCN010', 'NGUYỄN THÁI BẢO', '1998-12-31', 'D17CQCP02-N', 3.4, '0891823268', 'N17DCCN010@student.ptithcm.edu.vn', 'TK0031'),
('N17DCCN011', 'NGUYỄN THÁI BẢO', '1999-01-01', 'D17CQCP01-N', 3.3, '0906351322', 'N17DCCN011@student.ptithcm.edu.vn', NULL),
('N17DCCN012', 'BÙI BÁ BÌNH', '1999-11-19', 'D17CQCP02-N', 3, '0701891723', 'N17DCCN012@student.ptithcm.edu.vn', 'TK0039'),
('N17DCCN013', 'NGUYỄN MẠNH BÌNH ', '1999-12-30', 'D17CQMT01-N', 2.9, '0936722055', 'N17DCCN013@student.ptithcm.edu.vn', 'TK0040'),
('N17DCCN014', 'MAI TRÍ CƯỜNG', '1999-05-11', 'D17CQIS01-N', 3.1, '0902892656', 'N17DCCN014@student.ptithcm.edu.vn', 'TK0041'),
('N17DCCN015', 'NGUYỄN CHÍ CƯỜNG', '1999-12-28', 'D17CQCP01-N', 2.4, '0898345113', 'N17DCCN015@student.ptithcm.edu.vn', 'TK0042'),
('N17DCCN016', 'ĐỖ VĂN THÁNH', '1998-06-03', 'D17CQCP01-N', 2.1, '0852799241', 'N17DCCN016@student.ptithcm.edu.vn', 'TK0043'),
('N17DCCN017', 'A', '2021-04-15', 'D17CQCP01-N', 3.9, '8654123089', 'N17DCCN017@student.ptithcm.edu.vn', 'TK0083'),
('N17DCCN018', 'B', '2017-07-26', 'D17CQCP01-N', 3.5, '0123456789', 'N17DCCN018@student.ptithcm.edu.vn', 'TK0084'),
('N17DCCN019', 'Lương Đình Khang', '2000-11-15', 'D17CQCP01-N', 3, '0932177044', 'N17DCCN019@student.ptithcm.edu.vn', NULL),
('N17DCCN020', 'Lê Quốc Tấn', '1999-10-10', 'D17CQCP01-N', 3.5, '0123456456', 'N17DCCN020@student.ptithcm.edu.vn', 'TK0085'),
('N17DCCN021', 'Lâm Đình Khoa', '1999-02-19', 'D17CQCP01-N', 3.2, '0123456456', 'N17DCCN021@student.ptithcm.edu.vn', 'TK0030'),
('N17DCCN022', 'ABC', '2020-12-12', 'D17CQCP01-N', 3.2, '0123456789', 'N17DCCN022@student.ptithcm.edu.vn', 'TK0038'),
('N17DCCN023', 'fgsdg', '2021-07-07', 'D17CQCP01-N', 3.5, '5464354546', 'N17DCCN023@student.ptithcm.edu.vn', NULL),
('N17DCCN024', 'Lương Đình Khang', '1999-11-15', 'D17CQCP01-N', 3, '0123456789', 'N17DCCN024@student.ptithcm.edu.vn', NULL),
('N17DCPT001', 'LA HOÀNG PHƯƠNG ANH', '1999-06-06', 'D17CQPU02-N', 3.2, '0902433976', 'N17DCPT001@student.ptithcm.edu.vn', 'TK0024'),
('N17DCPT002', 'PHAN HUẾ ANH', '1999-07-14', 'D17CQTK02-N', 3, '0931739491', 'N17DCPT002@student.ptithcm.edu.vn', 'TK0047'),
('N17DCPT003', 'TRẦN THỊ PHƯƠNG ANH', '1999-01-17', 'D17CQPU02-N', 2.9, '0909609517', 'N17DCPT003@student.ptithcm.edu.vn', NULL),
('N17DCPT004', 'TRẦN THỤC ANH', '1999-10-11', 'D17CQPU01-N', 3.3, '0565237142', 'N17DCPT004@student.ptithcm.edu.vn', 'TK0048'),
('N17DCPT005', 'LÊ GIA CƯỜNG', '1999-06-07', 'D17CQPU01-N', 3.3, '0375364650', 'N17DCPT005@student.ptithcm.edu.vn', 'TK0049'),
('N18DCCN001', 'Lương Đình Khang', '2000-11-15', 'D18CQCP01-N', 3, '0932177451', 'N18DCCN001@student.ptithcm.edu.vn', NULL),
('N18DCCN002', 'NGUYỄN LONG NHẬT', '2000-01-15', 'D18CQCP01-N', 2.7, '0925411547', 'N18DCCN002@student.ptithcm.edu.vn', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `taikhoan`
--

CREATE TABLE `taikhoan` (
  `MaTK` char(6) NOT NULL,
  `TenDangNhap` varchar(15) DEFAULT NULL,
  `MatKhau` varchar(100) DEFAULT NULL,
  `Quyen` char(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `taikhoan`
--

INSERT INTO `taikhoan` (`MaTK`, `TenDangNhap`, `MatKhau`, `Quyen`) VALUES
('TK0001', 'GVAT001', '2ffb037705b48ab35fd49a7829ca56a6', 'GV'),
('TK0002', 'GVAT002', '778296dec796b017d12b593548882d5b', 'GV'),
('TK0003', 'GVAT003', 'cc5083529f7bd6a368438a16bda5e164', 'GV'),
('TK0004', 'GVAT004', 'c01ba9a1743020f631dbef8b420742b2', 'GV'),
('TK0005', 'GVAT005', '541b2b76302fbb935162affa0e1ff019', 'GV'),
('TK0006', 'GVCN001', 'aed54e90350a1c7f47deb5e8bb5f3c81', 'GV'),
('TK0007', 'GVCN002', 'f633985777b2d9c5802b0b2410223042', 'GV'),
('TK0008', 'GVCN003', '2e7d944a93df5b068b912a1e6db67a34', 'GV'),
('TK0009', 'GVCN004', 'd8ca97f228f0b63124f557a968526373', 'GV'),
('TK0010', 'GVCN005', '1261be1889cdf2176e3f0d16074027ac', 'GV'),
('TK0011', 'GVCN006', '936b8d46657d1dedb7184573e69baccc', 'GV'),
('TK0012', 'GVCN007', '45579779f037832ac20983d43c521a55', 'GV'),
('TK0013', 'GVCN008', '4a49cfe377f1299944b544560d3ae800', 'GV'),
('TK0014', 'GVCN009', '6e3ae4c771b98e78434b527c9c5c6b02', 'GV'),
('TK0015', 'GVCN010', '9e2c50e0cf290d59b6c8bbce6d4596ba', 'GV'),
('TK0016', 'GVPT001', 'd34b4dbfd5e48a83d565dbde394ae5ed', 'GV'),
('TK0017', 'GVPT002', '9ae8e3ad947c528f6cf50a6c08384eef', 'GV'),
('TK0018', 'GVPT003', '688913761c3b6e63b0fabb1a7f1fbd4c', 'GV'),
('TK0019', 'GVPT004', 'd4dbb10f3263a7eec26a6130013e6eec', 'GV'),
('TK0020', 'GVPT005', '80db80c460626810e09845475d10164c', 'GV'),
('TK0022', 'N17DCCN001', 'e4348d795160c4ea63d5fecad680f34c', 'SV'),
('TK0023', 'N17DCAT001', '1a9d27c6dbba7340c81550949fc8615e', 'SV'),
('TK0024', 'N17DCPT001', 'aebd15393c41414129282eecadaa6dc0', 'SV'),
('TK0025', 'N17DCCN002', 'e7c90b105f8db09b97c27d068c2d5496', 'SV'),
('TK0026', 'N17DCCN003', '10b3b9aa4d6551bb054b74f19efd55fc', 'SV'),
('TK0027', 'N17DCCN005', '7393c11747496ef9b14fd4a88e992eba', 'SV'),
('TK0028', 'N17DCCN007', '8c1e64e8f963f8b362eabea3093c0c39', 'SV'),
('TK0029', 'N17DCCN006', 'cf9f09afefd7b79ef54f92561b7b1940', 'SV'),
('TK0030', 'N17DCCN021', '3e9602af514e8c184741105e4ebf53cb', 'SV'),
('TK0031', 'N17DCCN010', '6baf2744a7d0115a4ba353c8763aee24', 'SV'),
('TK0032', 'GVCN011', '709275f18df0e2fe871f3d6d1722d4fb', 'GV'),
('TK0033', 'GVCN012', '071f61b6230a528f5df033f24e0e1ca7', 'GV'),
('TK0034', 'GVCN013', '9f206e19e6fb1d9dadba74efac272b6a', 'GV'),
('TK0035', 'GVCN014', '0fbd0ac71c5f7a167b458977270a18a2', 'GV'),
('TK0036', 'GVCN015', '7ce90ddc0973047f441dbada41f499bc', 'GV'),
('TK0037', 'N17DCCN009', '596bd70e751bf67eef6971a34a5921ee', 'SV'),
('TK0038', 'N17DCCN022', 'f98fc743e270e95e19dee0afeda1824e', 'SV'),
('TK0039', 'N17DCCN012', '48bc458c15e9692bf22a37ebad828b57', 'SV'),
('TK0040', 'N17DCCN013', '20f2fb31159f76ad04202f67d65c158c', 'SV'),
('TK0041', 'N17DCCN014', '3a96969d2e290043907520b10485d5e6', 'SV'),
('TK0042', 'N17DCCN015', '91fa1fdaec463e7e4cd34656b175c89a', 'SV'),
('TK0043', 'N17DCCN016', 'b5b9b798486922280c3b0e9210439b5c', 'SV'),
('TK0044', 'GVAT006', 'bcae4a01e2381791c66bff30a209c36d', 'GV'),
('TK0045', 'GVAT007', 'bb35657e0cc9f35edd6b9d714d9e8d4a', 'GV'),
('TK0046', 'N17DCAT002', '73e93635eeec9b62c59a6c7e44e8bf27', 'SV'),
('TK0047', 'N17DCPT002', '9c9f6d0346b720d1622bf2c9c7d8eef2', 'SV'),
('TK0048', 'N17DCPT004', '0ad8cff14a0d2c69c3782dc6b5051cd3', 'SV'),
('TK0049', 'N17DCPT005', '28c7e3749ffd754d1f14ba3b9793fd41', 'SV'),
('TK0050', 'GVAT001', '2ffb037705b48ab35fd49a7829ca56a6', 'GV'),
('TK0051', 'GVAT002', '778296dec796b017d12b593548882d5b', 'GV'),
('TK0052', 'GVAT003', 'cc5083529f7bd6a368438a16bda5e164', 'GV'),
('TK0053', 'GVAT004', 'c01ba9a1743020f631dbef8b420742b2', 'GV'),
('TK0054', 'GVAT005', '541b2b76302fbb935162affa0e1ff019', 'GV'),
('TK0055', 'GVCN001', 'aed54e90350a1c7f47deb5e8bb5f3c81', 'GV'),
('TK0056', 'GVCN002', 'f633985777b2d9c5802b0b2410223042', 'GV'),
('TK0057', 'GVCN003', '2e7d944a93df5b068b912a1e6db67a34', 'GV'),
('TK0058', 'GVCN004', 'd8ca97f228f0b63124f557a968526373', 'GV'),
('TK0059', 'GVCN005', '1261be1889cdf2176e3f0d16074027ac', 'GV'),
('TK0060', 'GVCN006', '936b8d46657d1dedb7184573e69baccc', 'GV'),
('TK0061', 'GVCN007', '45579779f037832ac20983d43c521a55', 'GV'),
('TK0062', 'GVCN008', '4a49cfe377f1299944b544560d3ae800', 'GV'),
('TK0063', 'GVCN009', '6e3ae4c771b98e78434b527c9c5c6b02', 'GV'),
('TK0064', 'GVCN010', '9e2c50e0cf290d59b6c8bbce6d4596ba', 'GV'),
('TK0065', 'GVCN011', '709275f18df0e2fe871f3d6d1722d4fb', 'GV'),
('TK0066', 'GVCN012', '071f61b6230a528f5df033f24e0e1ca7', 'GV'),
('TK0067', 'GVCN013', '9f206e19e6fb1d9dadba74efac272b6a', 'GV'),
('TK0068', 'GVCN014', '0fbd0ac71c5f7a167b458977270a18a2', 'GV'),
('TK0069', 'GVCN015', '7ce90ddc0973047f441dbada41f499bc', 'GV'),
('TK0070', 'GVPT001', 'd34b4dbfd5e48a83d565dbde394ae5ed', 'GV'),
('TK0071', 'GVPT002', '9ae8e3ad947c528f6cf50a6c08384eef', 'GV'),
('TK0072', 'GVPT003', '688913761c3b6e63b0fabb1a7f1fbd4c', 'GV'),
('TK0073', 'GVPT004', 'd4dbb10f3263a7eec26a6130013e6eec', 'GV'),
('TK0074', 'GVPT005', '80db80c460626810e09845475d10164c', 'GV'),
('TK0075', 'QL001', 'e10adc3949ba59abbe56e057f20f883e', 'QL'),
('TK0076', 'N17DCCN017', '6c06b9c2b3c0243fb9d476b1a7a6b032', 'SV'),
('TK0077', 'N17DCCN017', '6c06b9c2b3c0243fb9d476b1a7a6b032', 'SV'),
('TK0078', 'N17DCCN017', '6c06b9c2b3c0243fb9d476b1a7a6b032', 'SV'),
('TK0079', 'N17DCCN017', '6c06b9c2b3c0243fb9d476b1a7a6b032', 'SV'),
('TK0080', 'N17DCCN017', '6c06b9c2b3c0243fb9d476b1a7a6b032', 'SV'),
('TK0081', 'N17DCCN017', '6c06b9c2b3c0243fb9d476b1a7a6b032', 'SV'),
('TK0082', 'N17DCCN017', '6c06b9c2b3c0243fb9d476b1a7a6b032', 'SV'),
('TK0083', 'N17DCCN017', '6c06b9c2b3c0243fb9d476b1a7a6b032', 'SV'),
('TK0084', 'N17DCCN018', '9aa458c6409e161d91b37e98b32cf658', 'SV'),
('TK0085', 'N17DCCN020', 'e0ca72284bfb1af854132a334ba80282', 'SV'),
('TK0086', 'N17DCCN023', '27cd650596862607d8fbfab269ff290a', 'SV'),
('TK0087', 'N17DCCN023', 'bc929b74517b50b6188db77ed924d866', 'SV'),
('TK0088', 'N17DCCN023', 'cf36bcb7a259900671fc74e1aaa3a444', 'SV'),
('TK0089', 'N17DCCN023', '6562e295de9a053ce5b67b94a2e0b54e', 'SV'),
('TK0090', 'N17DCCN023', '6562e295de9a053ce5b67b94a2e0b54e', 'SV'),
('TK0091', 'N17DCCN023', '6562e295de9a053ce5b67b94a2e0b54e', 'SV'),
('TK0092', 'N17DCCN023', '6562e295de9a053ce5b67b94a2e0b54e', 'SV'),
('TK0093', 'GVCN016', '857aca6b1be4d3810c10937987ec06a0', 'GV'),
('TK0094', 'N17DCAT003', '4bffc10838f944c1bad59f221d81532d', 'SV');

--
-- Triggers `taikhoan`
--
DELIMITER $$
CREATE TRIGGER `Insert_TK` BEFORE INSERT ON `taikhoan` FOR EACH ROW BEGIN
    set new.MaTK=AUTO_IDTK();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `test`
--

CREATE TABLE `test` (
  `id` int(11) DEFAULT NULL,
  `v1` int(11) DEFAULT NULL,
  `v2` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `tieuban`
--

CREATE TABLE `tieuban` (
  `MaTB` char(6) NOT NULL,
  `MaNganh` char(2) NOT NULL,
  `Ngay` date NOT NULL,
  `Ca` char(2) NOT NULL DEFAULT 'SA' COMMENT 'SA or CH'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tieuban`
--

INSERT INTO `tieuban` (`MaTB`, `MaNganh`, `Ngay`, `Ca`) VALUES
('TB1601', 'CN', '2021-05-18', 'SA'),
('TB1602', 'AT', '2021-05-14', 'SA'),
('TB1603', 'PT', '2021-05-17', 'CH'),
('TB1704', 'PT', '2021-05-17', 'SA'),
('TB1708', 'CN', '2021-06-23', 'SA'),
('TB1710', 'CN', '2021-08-04', 'CH'),
('TB1712', 'PT', '2021-07-07', 'SA'),
('TB1713', 'PT', '2021-07-02', 'CH'),
('TB1714', 'CN', '2021-07-03', 'SA'),
('TB1715', 'CN', '2021-07-04', 'SA'),
('TB1716', 'CN', '2021-07-01', 'CH'),
('TB1717', 'CN', '2021-08-04', 'SA'),
('TB1718', 'CN', '2021-08-04', 'SA'),
('TB1719', 'CN', '2021-08-04', 'CH'),
('TB1720', 'CN', '2021-08-03', 'CH'),
('TB1721', 'CN', '2021-08-04', 'CH'),
('TB1722', 'CN', '2021-08-04', 'SA'),
('TB1724', 'CN', '2021-08-04', 'SA'),
('TB1726', 'CN', '2021-08-04', 'CH'),
('TB1727', 'CN', '2021-08-04', 'SA'),
('TB1728', 'CN', '2021-08-06', 'SA'),
('TB1730', 'CN', '2021-08-06', 'CH'),
('TB1731', 'CN', '2021-08-06', 'SA'),
('TB1732', 'AT', '2021-08-06', 'CH'),
('TB1733', 'AT', '2021-08-13', 'SA'),
('TB1734', 'AT', '2021-08-06', 'CH'),
('TB1735', 'AT', '2021-08-14', 'SA'),
('TB1736', 'CN', '2021-08-15', 'CH'),
('TB1737', 'AT', '2021-08-15', 'CH'),
('TB1801', 'PT', '2021-05-11', 'SA'),
('TB1802', 'CN', '2021-05-15', 'SA');

--
-- Triggers `tieuban`
--
DELIMITER $$
CREATE TRIGGER `TgBI_checkCa` BEFORE INSERT ON `tieuban` FOR EACH ROW BEGIN
	IF new.Ca<>'SA' and new.Ca<>'CH' THEN
    signal sqlstate '45000' set message_text = 'Ca chỉ có 2 giá trị SA hoặc CH';
    END if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `TgBU_CheckCa` BEFORE UPDATE ON `tieuban` FOR EACH ROW BEGIN
	IF new.Ca<>'SA' and new.Ca<>'CH' THEN
    signal sqlstate '45000' set message_text = 'Ca chỉ có 2 giá trị SA hoặc CH';
    END if;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `baocao`
--
ALTER TABLE `baocao`
  ADD PRIMARY KEY (`MaBC`),
  ADD UNIQUE KEY `TepVB_UNIQUE` (`Tep`);

--
-- Indexes for table `chamdiemhd-pb`
--
ALTER TABLE `chamdiemhd-pb`
  ADD PRIMARY KEY (`MaPhanCong`,`MaGV`),
  ADD KEY `fk_cham_diem_hd_pb_giang_vien1` (`MaGV`),
  ADD KEY `fk_chamdiemhd-pb_phancongdoan1_idx` (`MaPhanCong`);

--
-- Indexes for table `chamdiemtb`
--
ALTER TABLE `chamdiemtb`
  ADD PRIMARY KEY (`MaPhanCong`,`MaGV`,`MaTB`),
  ADD KEY `fk_de_tai_has_PHAN_CONG_GV_TB_PHAN_CONG_GV_TB1` (`MaGV`,`MaTB`),
  ADD KEY `fk_chamdiemtb_phancongdoan1_idx` (`MaPhanCong`);

--
-- Indexes for table `chitietchinhsuadoan`
--
ALTER TABLE `chitietchinhsuadoan`
  ADD PRIMARY KEY (`MaDA`,`MaGV`,`ThoiGian`),
  ADD KEY `fk_doan_has_nhanvien_nhanvien1_idx` (`MaGV`),
  ADD KEY `fk_doan_has_nhanvien_doan1_idx` (`MaDA`);

--
-- Indexes for table `chuyennganh`
--
ALTER TABLE `chuyennganh`
  ADD PRIMARY KEY (`MaCN`),
  ADD UNIQUE KEY `TenChuyenNganh_UNIQUE` (`TenCN`),
  ADD KEY `fk_CHUYENNGANH_NGANH1_idx` (`MaNganh`);

--
-- Indexes for table `diemsang`
--
ALTER TABLE `diemsang`
  ADD PRIMARY KEY (`MaNganh`,`NamBD`);

--
-- Indexes for table `doan`
--
ALTER TABLE `doan`
  ADD PRIMARY KEY (`MaDA`),
  ADD KEY `fk_doan_chuyennganh1_idx` (`MaCN`);

--
-- Indexes for table `hoidong`
--
ALTER TABLE `hoidong`
  ADD PRIMARY KEY (`MaHD`),
  ADD UNIQUE KEY `TenHD_UNIQUE` (`TenHD`);

--
-- Indexes for table `lop`
--
ALTER TABLE `lop`
  ADD PRIMARY KEY (`MaLop`),
  ADD UNIQUE KEY `MaLop_UNIQUE` (`MaLop`),
  ADD KEY `MaCN` (`MaCN`);

--
-- Indexes for table `nganh`
--
ALTER TABLE `nganh`
  ADD PRIMARY KEY (`MaNganh`),
  ADD UNIQUE KEY `TenNganh_UNIQUE` (`TenNganh`),
  ADD UNIQUE KEY `MaNganh_UNIQUE` (`MaNganh`),
  ADD KEY `fk_nganh_HOIDONG1_idx` (`MaHD`);

--
-- Indexes for table `nhanvien`
--
ALTER TABLE `nhanvien`
  ADD PRIMARY KEY (`MaNV`),
  ADD UNIQUE KEY `MaNV_UNIQUE` (`MaNV`),
  ADD KEY `fk_giang_vien_tai_khoan1_idx` (`MaTK`),
  ADD KEY `fk_giangvien_nganh1_idx` (`MaNganh`);

--
-- Indexes for table `phancongdoan`
--
ALTER TABLE `phancongdoan`
  ADD PRIMARY KEY (`MaPhanCong`),
  ADD UNIQUE KEY `MaSV_UNIQUE` (`MaSV`),
  ADD UNIQUE KEY `MaPhanCong_UNIQUE` (`MaPhanCong`),
  ADD KEY `fk_phancongdoan_sinhvien1_idx` (`MaSV`),
  ADD KEY `fk_phancongdoan_nhanvien1_idx` (`MaGVHD`),
  ADD KEY `fk_phancongdoan_nhanvien2_idx` (`MaGVPB`),
  ADD KEY `fk_phancongdoan_doannew1_idx` (`MaDA`),
  ADD KEY `fk_phancongdoan_baocao1_idx` (`MaBC`),
  ADD KEY `fk_phancongdoan_chitiethuongdan1_idx` (`MaCT`);

--
-- Indexes for table `phanconggvtb`
--
ALTER TABLE `phanconggvtb`
  ADD PRIMARY KEY (`MaGV`,`MaTB`),
  ADD KEY `fk_GIANG_VIEN_has_tieu_ban_tieu_ban1` (`MaTB`);

--
-- Indexes for table `phienbanhuongdan`
--
ALTER TABLE `phienbanhuongdan`
  ADD PRIMARY KEY (`MaCT`),
  ADD KEY `fk_phienbanhuongdan_chitietchinhsuadoan1_idx` (`MaDA`,`MaGV`,`ThoiGian`);

--
-- Indexes for table `sinhvien`
--
ALTER TABLE `sinhvien`
  ADD PRIMARY KEY (`MaSV`),
  ADD UNIQUE KEY `email_UNIQUE` (`Email`),
  ADD KEY `fk_sinh_vien_tai_khoan1_idx` (`MaTK`),
  ADD KEY `fk_sinhvien_lop1_idx` (`MaLop`);

--
-- Indexes for table `taikhoan`
--
ALTER TABLE `taikhoan`
  ADD PRIMARY KEY (`MaTK`),
  ADD UNIQUE KEY `ID_UNIQUE` (`MaTK`);

--
-- Indexes for table `tieuban`
--
ALTER TABLE `tieuban`
  ADD PRIMARY KEY (`MaTB`),
  ADD KEY `fk_tieuban_nganh1_idx` (`MaNganh`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `baocao`
--
ALTER TABLE `baocao`
  MODIFY `MaBC` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `hoidong`
--
ALTER TABLE `hoidong`
  MODIFY `MaHD` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `phienbanhuongdan`
--
ALTER TABLE `phienbanhuongdan`
  MODIFY `MaCT` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `chamdiemhd-pb`
--
ALTER TABLE `chamdiemhd-pb`
  ADD CONSTRAINT `fk_cham_diem_hd_pb_giang_vien1` FOREIGN KEY (`MaGV`) REFERENCES `nhanvien` (`MaNV`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_chamdiemhd-pb_phancongdoan1` FOREIGN KEY (`MaPhanCong`) REFERENCES `phancongdoan` (`MaPhanCong`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `chamdiemtb`
--
ALTER TABLE `chamdiemtb`
  ADD CONSTRAINT `fk_chamdiemtb_phancongdoan1` FOREIGN KEY (`MaPhanCong`) REFERENCES `phancongdoan` (`MaPhanCong`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_de_tai_has_PHAN_CONG_GV_TB_PHAN_CONG_GV_TB` FOREIGN KEY (`MaGV`,`MaTB`) REFERENCES `phanconggvtb` (`MaGV`, `MaTB`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `chitietchinhsuadoan`
--
ALTER TABLE `chitietchinhsuadoan`
  ADD CONSTRAINT `fk_doan_has_nhanvien_doan1` FOREIGN KEY (`MaDA`) REFERENCES `doan` (`MaDA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_doan_has_nhanvien_nhanvien1` FOREIGN KEY (`MaGV`) REFERENCES `nhanvien` (`MaNV`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `chuyennganh`
--
ALTER TABLE `chuyennganh`
  ADD CONSTRAINT `fk_CHUYENNGANH_NGANH1` FOREIGN KEY (`MaNganh`) REFERENCES `nganh` (`MaNganh`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `diemsang`
--
ALTER TABLE `diemsang`
  ADD CONSTRAINT `fk_table1_nganh1` FOREIGN KEY (`MaNganh`) REFERENCES `nganh` (`MaNganh`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `doan`
--
ALTER TABLE `doan`
  ADD CONSTRAINT `fk_doan_chuyennganh1` FOREIGN KEY (`MaCN`) REFERENCES `chuyennganh` (`MaCN`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `lop`
--
ALTER TABLE `lop`
  ADD CONSTRAINT `lop_ibfk_1` FOREIGN KEY (`MaCN`) REFERENCES `chuyennganh` (`MaCN`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `nganh`
--
ALTER TABLE `nganh`
  ADD CONSTRAINT `fk_nganh_HOIDONG1` FOREIGN KEY (`MaHD`) REFERENCES `hoidong` (`MaHD`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `nhanvien`
--
ALTER TABLE `nhanvien`
  ADD CONSTRAINT `fk_giang_vien_tai_khoan1` FOREIGN KEY (`MaTK`) REFERENCES `taikhoan` (`MaTK`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_giangvien_nganh1` FOREIGN KEY (`MaNganh`) REFERENCES `nganh` (`MaNganh`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `phancongdoan`
--
ALTER TABLE `phancongdoan`
  ADD CONSTRAINT `fk_phancongdoan_baocao1` FOREIGN KEY (`MaBC`) REFERENCES `baocao` (`MaBC`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_phancongdoan_chitiethuongdan1` FOREIGN KEY (`MaCT`) REFERENCES `phienbanhuongdan` (`MaCT`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_phancongdoan_doannew1` FOREIGN KEY (`MaDA`) REFERENCES `doan` (`MaDA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_phancongdoan_nhanvien1` FOREIGN KEY (`MaGVHD`) REFERENCES `nhanvien` (`MaNV`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_phancongdoan_nhanvien2` FOREIGN KEY (`MaGVPB`) REFERENCES `nhanvien` (`MaNV`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_phancongdoan_sinhvien1` FOREIGN KEY (`MaSV`) REFERENCES `sinhvien` (`MaSV`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `phanconggvtb`
--
ALTER TABLE `phanconggvtb`
  ADD CONSTRAINT `fk_GIANG_VIEN_has_tieu_ban_GIANG_VIEN1` FOREIGN KEY (`MaGV`) REFERENCES `nhanvien` (`MaNV`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_GIANG_VIEN_has_tieu_ban_tieu_ban1` FOREIGN KEY (`MaTB`) REFERENCES `tieuban` (`MaTB`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `phienbanhuongdan`
--
ALTER TABLE `phienbanhuongdan`
  ADD CONSTRAINT `fk_phienbanhuongdan_chitietchinhsuadoan1` FOREIGN KEY (`MaDA`,`MaGV`,`ThoiGian`) REFERENCES `chitietchinhsuadoan` (`MaDA`, `MaGV`, `ThoiGian`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `sinhvien`
--
ALTER TABLE `sinhvien`
  ADD CONSTRAINT `fk_sinh_vien_tai_khoan1` FOREIGN KEY (`MaTK`) REFERENCES `taikhoan` (`MaTK`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_sinhvien_lop1` FOREIGN KEY (`MaLop`) REFERENCES `lop` (`MaLop`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `tieuban`
--
ALTER TABLE `tieuban`
  ADD CONSTRAINT `fk_tieuban_nganh1` FOREIGN KEY (`MaNganh`) REFERENCES `nganh` (`MaNganh`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
