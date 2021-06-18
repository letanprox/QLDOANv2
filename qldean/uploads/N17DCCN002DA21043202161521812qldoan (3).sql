-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th6 15, 2021 lúc 06:34 AM
-- Phiên bản máy phục vụ: 10.4.18-MariaDB
-- Phiên bản PHP: 7.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `qldoan`
--

DELIMITER $$
--
-- Thủ tục
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
where MaPhanCong=idPC and Diem is not null;

if @demDiem=2 then 
	select 0 as status;
else 
	update `chamdiemhd-pb`
    set Diem=d
    where MaPhanCong=idPC and MaGV=idGV;
    select 1 as status;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ChamDiem_PB` (IN `idPC` CHAR(7), IN `idGV` CHAR(7), IN `d` FLOAT)  BEGIN
select MaphanCong, count(*) into @tmpidPC, @demDiem
from chamdiemtb
where MaPhanCong='PC17001' and Diem is null;

if @demDiem<>5  and @tmpidPC is not null then 
	select 0 as status;
else 
	update `chamdiemhd-pb`
    set Diem=d
    where MaPhanCong=idPC and MaGV=idGV;
    select 1 as status;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ChamDiem_TB` (IN `idPC` CHAR(7), IN `idTB` CHAR(2), IN `idGV` CHAR(7), IN `d` FLOAT)  BEGIN
select Ngay, Ca into @ngay, @ca
from tieuban
where MaTB=idTB;

select date(now()), time(now()) into @curDate, @curTime;

if @curDate=@ngay then 
	if @ca='SA' then 
		if @curTime>'07:00:00' then 
			update chamdiemtieuban
            set Diem=d
            where MaPhanCong=idPC and MaGV=idGV;
            SELECT 1 as status;
		else
			SELECT 0 as status;
		end if;
	else
		if @curTime>'12:00:00' then 
			update chamdiemtieuban
            set Diem=d
            where MaPhanCong=idPC and MaGV=idGV;
            SELECT 1 as status;
		else
			SELECT 0 as status;
		end if;
	end if;
else 
	SELECT 0 as status;
end if; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckLogin` (IN `username` VARCHAR(255), IN `pass` VARCHAR(255))  BEGIN
    
    select count(*) into @dem
    from taikhoan
    where TenDangNhap=upper(username) and md5(pass)=MatKhau;
    
    if @dem=0 then 
    select null;
    else
    	select Quyen into @tmpQuyen
        from taikhoan
        where TenDangNhap=upper(username) and md5(pass)=MatKhau;
        
        if @tmpQuyen='SV' then
			set @tmpTbl='sinhvien';
		else
            set @tmpTbl='nhanvien';
            set @tmpQuyen='NV';
		end if;
        
        set @sql= concat('select ',@tmpTbl,'.Ten',@tmpQuyen,' as user ,tk.Quyen\r\n\t\t\t\t\t\t\tfrom taikhoan tk, ',@tmpTbl,'\r\n\t\t\t\t\t\t\twhere tk.MaTK=',@tmpTbl,'.MaTK and TenDangNhap=upper(?) and md5(?)=MatKhau;');
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
	SELECT kh.namBD,nganh.SoNam
    from DiemSang kh, nganh
    where kh.MaNganh=nganh.MaNganh and kh.MaNganh=idNganh
    ORDER by namBD DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_Khoa_TK` (IN `idHD` INT)  BEGIN
select distinct(d.NamBD)
from diemsang d, nganh, hoidong hd
where d.MaNganh=nganh.MaNganh and nganh.MaHD=hd.MaHD and hd.MaHD=idHD
ORDER BY d.NamBD DESC;
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
) tblTB, 
	(
		select distinct MaPhanCong, MaTB
		from chamdiemtb
    ) tblDATB
where tblTB.MaTB=tblDATB.MaTB
group by MaTB
union
select MaTB,0
		from tieuban  
		where
        SUBSTRING(MaTB, 3,2)=right(khoa, 2) 
        and (ngay>curdate() or (ngay=curdate() and ca='CH' and CURTIME()<'12:00:00'))
        and MaTB not in (select distinct MaTB from chamdiemtb)
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
group by MaGV,TenGV
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `ComboBox_PhanCongGVTB` (IN `idNganh` CHAR(2), IN `n` DATE, IN `g` CHAR(2))  begin
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
		select distinct(MaGV) from phanconggvtb
	)
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_DA` (IN `idDA` CHAR(7))  BEGIN
SET SQL_SAFE_UPDATES = 0;
	delete from phienbanhuongdan where MaDA=idDA;
    delete from chitietchinhsuadoan where MaDA=idDA;
    delete from doan where MaDA=idDA;
SET SQL_SAFE_UPDATES = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_FileHD` (IN `idCT` INT)  BEGIN
    update phienbanhuongdan
    set TrangThai=2
    where MaCT=idCT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_GV` (IN `idGV` CHAR(7))  begin
	declare  isExitScore int;
    declare  isExitTB int;
    declare isExitPC int;
    declare dem int;
    declare i int;
    declare tmpMaPC char(7);
    declare tmpMaGV char(7);
    declare  tmpVaitro char(2);
    declare demBaoCaoDA int;
    select sum(dem) total into isExitScore
	from (
		select count(Diem) dem
		from `chamdiemhd-pb`
		where MaGV=idGV and Diem is not null
        union 
        select count(Diem) dem
		from chamdiemtb
		where MaGV=idGV and Diem is not null
	) tmp;
    -- kiểm tra GV đó đã chấm bất kỳ điểm nào chưa, hay đã tham gia vào bất kì tiểu ban nào chưa
    select count(MaTB) into isExitTB
		from phanconggvtb
		where MaGV=idGV;
	 -- kiểm tra GV đó đã tham gia vào bất kì tiểu ban nào chưa
     select count(MaPhanCong) into isExitPC
     from phancongdoan
     where MaGVHD=idGV or MaGVPB=idGV;
	SET SQL_SAFE_UPDATES = 0;
    
    if isExitScore<>0 then
		update NhanVien
		set MaTK=null
		where MaNV=idGV;
            
		update taikhoan
		set	TenDangNhap = null,
			MatKhau =null,
			Quyen=null
		where TenDangNhap=idGV;
    else 
		if isExitPC=0 and isExitTB=0 then
			delete from NhanVien
			where MaNV=idGV;
			update taikhoan
			set	TenDangNhap = null,
				MatKhau =null,
				Quyen=null
			where TenDangNhap=idGV;
		elseif isExitPC=0 and isExitTB<>0 then
			select distinct(MaTB)
            from chamdiemtb
            where MaGV=idGV;
		elseif isExitPC<>0 and isExitTB=0 then
        
            select count(*) into demBaoCaoDA from phancongdoan
            where MaPhanCong in (
				select pc.MaPhanCong
				from `chamdiemhd-pb` cd, phancongdoan pc
				where  cd.MaPhanCong=pc.MaPhanCong and cd.MaGV=pc.MaGVHD and cd.MaGV=idGV
            ) and MaBC is not null;
            
				if demBaoCaoDA<>0 then 
					select MaSV, MaDA
					from phancongdoan
					where MaGVHD=idGV and MaBC is not null;
                    -- thông báo ra là những sinh viên này đã nộp báo cáo nên k cho xóa GV vì trường GVHD của phancongdoan k dc null 
				else 
                
                    delete from `chamdiemhd-pb`
					where MaGV=idGV;
                    
					delete from phancongdoan
					where MaGVHD=idGV;
                    
					-- xóa tất cả các mã phân công mà GV đó  là GVHD 
					UPDATE  phancongdoan
					SET  MaGVPB = null
					where MaGVPB=idGV;
					-- update MaGVPB về null đối với những mã phân công mà GV này là GVPB 
                    
                    delete from NhanVien
					where MaNV=idGV;
					update taikhoan
					set	TenDangNhap = null,
						MatKhau =null,
						Quyen=null
					where TenDangNhap=idGV;
				end if;
		else
			select distinct(MaTB)
            from chamdiemtb
            where MaGV=idGV;
		end if;
	end if;
    SET SQL_SAFE_UPDATES = 1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_TK` (`id` VARCHAR(10))  begin
		
		declare tbl char(2);
        declare idTK char(5);
        
		select Quyen into tbl
        from taikhoan 
        where TenDangNhap=id;
        
        select MaTK into idTK
        from taikhoan 
        where TenDangNhap=id;
        SET SQL_SAFE_UPDATES = 0;
        if tbl='GV' then
			update giangvien
            set MaTK=null
            where MaGV=id;
		elseif tbl='SV' then
			update sinhvien
            set MaTK=null
            where MaSV=id;
		else
			update quanly
            set MaTK=null
            where MaQL=id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `List_PhanCongTB` (`os` INT)  begin
		select sv.MaSV, sv.TenSV, MaLop, da.MaDA, cd.diem, cdtb.MaTB 
		from doan da, `chamdiemhd-pb` cd, sinhvien sv, chamdiemtb cdtb
		where sv.MaSV= da.MaSV and da.MaDA=cd.MaDA and cdtb.MaDA=da.MaDA and da.MaGVPB=cd.MaGV and cd.diem>=4
		union
		select sv.MaSV, TenSV, MaLop, da.MaDA, cd.diem,''
		from doan da, `chamdiemhd-pb` cd, sinhvien sv
		where sv.MaSV= da.MaSV and da.MaDA=cd.MaDA and da.MaGVPB=cd.MaGV and diem>=4 
		and sv.MaSV not in 
		(select sv.MaSV
		from doan da, `chamdiemhd-pb` cd, sinhvien sv, chamdiemtb cdtb
		where sv.MaSV= da.MaSV and da.MaDA=cd.MaDA and cdtb.MaDA=da.MaDA and da.MaGVPB=cd.MaGV and cd.diem>=4)
        limit 10 offset os;
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
	select 'Bạn không thể nộp báo cáo';
else
	if @count=0 then 
		select MaBC into @idBC from phancongdoan 
		where MaPhanCong=idPC; 
        if @idBC is null then 
			select count(*)+1 into @maxIDBC from baocao;
			insert baocao(MaBC, Tep, MoTa, TrangThai, ThoiGian) value(@maxIDBC, file, details, 1, t);
            SET SQL_SAFE_UPDATES = 0;
            update phancongdoan
            set MaBC=@maxIDBC
            where MaPhanCong=idPC;
            SET SQL_SAFE_UPDATES = 1;

		else 
			update baocao
            set 
				Tep=file,
                MoTa=details,
                TrangThai=1
			where MaBC=@idBC;
		end if;
    elseif @count=3 then 
		select distinct(cd.MaTB), tb.Ngay into @tmp, @ngay 
        from chamdiemtb cd, tieuban tb
        where cd.MaTB=tb.MaTB and pc.MaPhanCong=idPC;
        
        if date(now())<@ngay then
			select MaBC into @idBC from  phancongdoan 
            where MaPhanCong=idPC;
            update baocao
            set 
				Tep=file,
                MoTa=details,
                TrangThai=1
			where MaBC=@idBC;
		else 
			select 'Đã quá hạn báo cáo';
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
	end if;
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PhanCong_DA` (IN `idGV` CHAR(7), IN `idSV` CHAR(10), IN `idDA` CHAR(7), IN `idCT` INT)  BEGIN
	SELECT NgayPhanCong into @tmpDate
    from phancongdoan
    where MaSV=idSV and MaGVHD=idGV;
    SET SQL_SAFE_UPDATES = 0;
    if @tmpDate is not null THEN
		if date(now())<=(@tmpDate+INTERVAL 7 DAY) then
			update phancongdoan
			set MaDA=idDA,
				MaCt=idCT
			where MaSV=idSV and MaGVHD=idGV;
            select 'success';
		else
			select 'Ngoài thời gian thay đổi';
		end if;
	else
		update phancongdoan
		set MaDA=idDA,
			MaCt=idCT,
			NgayPhanCong=date(now())
		where MaSV=idSV and MaGVHD=idGV;
        select 'success';
    end if;
    SET SQL_SAFE_UPDATES = 1;
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
select tmp1.MaPhanCong, tmp1.MaGVHD, tmp1.TenGVHD, tmp1.DiemHD, tmp1.MaGVPB, tmp1.TenGVPB, tmp1.DiemPB, tmp2.MaTB, tmp2.DiemTB
from (select tmp.MaPhanCong, tmp.MaGVHD, tmp.TenGVHD, tmp.DiemHD, tmp.MaGVPB, gv.TenNV as TenGVPB, tmp.DiemPB
		from (select tmp.MaPhanCong, tmp.MaGVHD, tmp.TenGVHD, tmp.DiemHD, tmp.MaGVPB, cdpb.Diem as DiemPB
				from (select pc.MaPhanCong, pc.MaGVHD, gv.tenNV as TenGVHD, cdhd.Diem as DiemHD, pc.MaGVPB
						from phancongdoan pc, `chamdiemhd-pb` cdhd, nhanvien gv
						where pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV and cdhd.MaGV=gv.MaNV and pc.MaSV=idSV) tmp
				left join `chamdiemhd-pb` cdpb
				on tmp.MaPhanCong=cdpb.MaPhanCong and tmp.MaGVPB=cdpb.MaGV) tmp, nhanvien gv
		where tmp.MaGVPB=gv.MaNV
		) tmp1
left join (select MaPhanCong, MaTB, AVG(Diem) as DiemTB
			from chamdiemtb
			group by MaPhanCong, MaTB) tmp2
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
			where MaGVHD=idGV and MaDA=idDA and substring(MaPhanCong,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2)) tmp2
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
    if @isExit=0 or (@isExit<>0 and @tmpDA is null) THEN
    	select sv.MaSV, sv.TenSV,sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop,sv.SDT, sv.Email, sv.GPA, '' as 'MaDA', '' as 'TenDA', '' as Diem, null as MaGVHD
        from sinhvien sv, lop, chuyennganh cn, nganh 
        WHERE sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and MaSV=idSV;
    ELSE
		select sv.MaSV, sv.TenSV,sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop,sv.SDT, sv.Email, sv.GPA,  pc.MaDA, da.TenDA, cd.Diem, pc.MaGVHD
        from SinhVien sv, lop, chuyennganh cn, nganh, PhanCongDoAn pc,Doan da, `chamdiemhd-pb` cd
        where sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and sv.MASV=pc.MaSV and pc.MaDA=da.MaDA and pc.MaPhanCong=cd.MaPhanCong and pc.MaGVHD=cd.MaGV and sv.MaSV=idSV;
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
		select sv.MaSV, sv.TenSV, sv.NgaySinh, nganh.TenNganh, cn.TenCN, sv.MaLop, sv.SDT, sv.Email, sv.GPA, pc.MaDA, da.TenDA,pc.MaGVHD,gvhd.TenNV as 'TenGVHD', cdhd.Diem as 'DiemHD', cdpb.Diem as 'DiemPB', pc.MaGVPB
        from sinhvien sv, lop, chuyennganh cn, nganh, PhanCongdoan pc, doan da ,nhanvien gvhd,`chamdiemhd-pb` cdhd, nhanvien gvpb,`chamdiemhd-pb` cdpb
        where sv.MaLop=lop.MaLop and lop.MaCN=cn.MaCN and cn.MaNganh=nganh.MaNganh and sv.MaSV=pc.MaSV and pc.MaGVHD=gvhd.MaNV and pc.MaPhanCong=cdhd.MaPhanCong and pc.MaGVHD=cdhd.MaGV
        and pc.MaGVPB=gvpb.MaNV and pc.MaPhanCong=cdpb.MaPhanCong and pc.MaGVPB=cdpb.MaGV and pc.MaDA=da.MaDA and sv.MaSV=idSV;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_DA` (IN `idCN` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
select *
from (select tmp.MaDA, tmp.TenDA, tmp.MaCN, tmp.tenCN, tmp.MaGV, tmp.TenGV, tmp.minThoiGian, tmp.maxThoiGian, IFNULL(tmp1.MaSV,'') AS MaSV , IFNULL(tmp1.TenSV,'') AS TenSV, tmp1.NgayPhanCong, tmp1.MaCT
		from (select tmp.MaDA, da.TenDA, da.MaCN, cn.tenCN, tmp.MaGV, gv.TenNV as TenGV, date(tmp.minThoiGian) as minThoiGian, date(tmp.maxThoiGian) as maxThoiGian
				from (select tmp.MaDA, ct.MaGV, tmp.minThoiGian, tmp.maxThoiGian
						from (select MaDA, min(ThoiGian) as minThoiGian, max(ThoiGian) as maxThoiGian
								from chitietchinhsuadoan 
								group by MaDA) tmp, chitietchinhsuadoan ct
						where tmp.MaDA=ct.MaDA and tmp.minthoiGian=ct.ThoiGian) tmp, doan da, chuyennganh cn, nhanvien gv
				where tmp.MaDA=da.MaDA and cn.MaCN=da.MaCN and tmp.MaGV=gv.MaNV and da.MaCN=idCN) tmp
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SVBaoCao` (IN `idTB` CHAR(6), IN `os` INT)  BEGIN
select DISTINCT(cd.MaPhanCong), pc.MaSV, sv.TenSV, sv.MaLop, sv.SDT, sv.Email  
from chamdiemtb cd, phancongdoan pc, sinhvien sv
where cd.MaPhanCong=pc.MaPhanCong and pc.MaSV=sv.MaSV and cd.MaTB=idTB
order by cd.MaPhanCong
limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SvDAHD` (IN `khoa` YEAR, IN `idNganh` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
select Diem into @diem from DiemSang where NamBD=khoa and MaNGanh=idNganh;

select *
from (select sv.MaSV, sv.TenSV, sv.Email, sv.GPA, tmp.MaGVHD, tmp.TenGVHD, tmp.diem
		from sinhvien sv, 
			(select pc.MaSV, pc.MaDA, pc.MaGVHD, gv.TenNV as TenGVHD,cd.diem
			from phancongdoan pc, `chamdiemhd-pb` cd, nhanvien gv 
			where 
			SUBSTRING(pc.MaSV, 2,2)=right(khoa, 2) 
			and SUBSTRING(MaSV, 6,2)=idNganh
			and pc.MaPhanCong=cd.MaPhanCong and pc.MaGVHD=cd.MaGV and pc.MaGVHD=gv.MaGV and (cd.diem <4 or cd.diem is null))
			tmp
		where sv.MaSV=tmp.MaSV
		union
		-- select Diem into @diem from DiemSang where NamBD='2018' and MaNGanh='CN';
		select MaSV,TenSV, Email,GPA,'','',null
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
where concat('.', MaSV, '.', TenSV, '.', Email, '.', GPA, '.', MaGVHD, '.', diem, '.') like concat('%',tukhoa,'%')
order by MaSV ASC
limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SvDAPB` (IN `khoa` YEAR, IN `idNganh` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  begin
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
order by MaSV ASC
limit 10 offset os;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SvDATB` (IN `khoa` YEAR, IN `idNganh` CHAR(2), IN `tukhoa` VARCHAR(255), IN `os` INT)  begin
select *
from (select tmp1.MaSV, tmp1.TenSV, tmp1.Email, tmp1.DiemPB, tmp2.MaTB, tmp2.Diemtb, tmp2.slDiem
		from (select sv.MaSV, sv.TenSV, sv.Email, cdpb.Diem as DiemPB, pc.MaPhanCong
				from sinhvien sv, phancongdoan pc, `chamdiemhd-pb` cdpb
				where pc.MaSV=sv.MaSV and pc.MaPhanCong=cdpb.MaPhanCong and pc.MaGVPB=cdpb.MaGV and cdpb.Diem>=4 and SUBSTRING(pc.MaPhanCong, 3,2)=right(khoa, 2) and SUBSTRING(pc.MaSV, 6,2)=idNganh
				) tmp1
		left join (select MaPhanCong, MaTB, AVG(Diem) as Diemtb, count(Diem) as slDiem
					from chamdiemtb
					where SUBSTRING(MaPhanCong, 3,2)=right(khoa, 2)
					group by MaPhanCong, MaTB) tmp2
		on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp
where concat('.', MaSV, '.', TenSV, '.', Email, '.', DiemPB, '.', MaTB, '.', Diemtb/slDiem, '.') like concat('%',tukhoa,'%')
order by MaSV ASC
limit 10 offset os;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SVHD_GV` (IN `idGV` CHAR(7), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
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
order by MaSV
limit 10 offset os;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowList_SVPB_GV` (IN `idGV` CHAR(7), IN `tukhoa` VARCHAR(255), IN `os` INT)  BEGIN
select pc.MaPhanCong, sv.MaSV, sv.TenSV, sv.MaLop, pc.MaDA, da.TenDA, cd.Diem, pc.MaCT
from sinhvien sv, phancongdoan pc, doan da, `chamdiemhd-pb` cd
where pc.MaSV=sv.MaSV and pc.MaDA=da.MaDA and cd.MaPhanCong=pc.MaPhanCong and cd.MaGV=pc.MaGVPB and pc.MaGVPB=idGV and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2)
and concat('.', sv.MaSV, '.', sv.TenSV, '.', sv.MaLop, '.', pc.MaDA, '.', da.TenDA, '.', cd.Diem, '.') like concat('%',tukhoa,'%')
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
    ORDER by MaTB ASC
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `Update_DAFull` (IN `idDA` CHAR(7), IN `ten` VARCHAR(255), IN `idCN` CHAR(2), IN `idGV` CHAR(7), IN `t` DATETIME, IN `details` VARCHAR(255), IN `file` VARCHAR(255))  BEGIN
	SET SQL_SAFE_UPDATES = 0;
	update doan
    set TenDA=ten,
		MaCN=idCN
	where MaDA=idDA;
    insert into chitietchinhsuadoan(MaDA,MaGV,ThoiGian) value(idDA,idGV, t);
	
	set @maxid=(select Max(MaCT)+1 from phienbanhuongdan);
    select count(pc.MaPhanCong) into @dem
    from phienbanhuongdan pb, phancongdoan pc
    where pb.MaCT=pc.MaCT and pb.MaDA=idDA and pb.TrangThai=0;
    if @dem=0 then
    	set @loai=0;
    else
    	set @loai=1;
    end if;
    if length(file)<>0 then 
		insert into phienbanhuongdan(MaCT, Tep, MoTa, TrangThai, MaDA, MaGV, ThoiGian) 
		value(@maxid,file, details, @loai, idDA, idGV, t);
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
-- Các hàm
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

CREATE DEFINER=`root`@`localhost` FUNCTION `Auto_IDPC` (`idSV` CHAR(10)) RETURNS CHAR(7) CHARSET utf8mb4 BEGIN
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
				where tmp.MaDA=da.MaDA and cn.MaCN=da.MaCN and tmp.MaGV=gv.MaNV and da.MaCN=idCN) tmp
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
	where pb.MaGV=gv.MaNV and pb.MaDA=idDA and TrangThai<>2) tmp
Left join phancongdoan pc
on tmp.MaCT=pc.MaCT
group by tmp.MaCT
            ) tmpList;
        return (demHang);
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

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SVBaoCao` (`idTB` CHAR(6)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang 
        FROM(
select DISTINCT(cd.MaPhanCong), pc.MaSV, sv.TenSV, sv.MaLop, sv.SDT, sv.Email  
from chamdiemtb cd, phancongdoan pc, sinhvien sv
where cd.MaPhanCong=pc.MaPhanCong and pc.MaSV=sv.MaSV and cd.MaTB=idTB
        ) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SVDAHD` (`khoa` YEAR, `tukhoa` VARCHAR(255), `idNganh` CHAR(2)) RETURNS INT(11) begin
declare demHang int;
select Diem into @diem from DiemSang where NamBD=khoa and MaNGanh=idNganh;
	SELECT COUNT(*) into demHang
    FROM (
			select *
from (select sv.MaSV, sv.TenSV, sv.Email, sv.GPA, tmp.MaGVHD, tmp.diem
		from sinhvien sv, 
			(select pc.MaSV, pc.MaDA, pc.MaGVHD,cd.diem
			from phancongdoan pc, `chamdiemhd-pb` cd
			where 
			SUBSTRING(pc.MaSV, 2,2)=right(khoa, 2) 
			and SUBSTRING(MaSV, 6,2)=idNganh
			and pc.MaPhanCong=cd.MaPhanCong and pc.MaGVHD=cd.MaGV and (cd.diem <4 or cd.diem is null))
			tmp
		where sv.MaSV=tmp.MaSV
		union
		-- select Diem into @diem from DiemSang where NamBD='2018' and MaNGanh='CN';
		select MaSV,TenSV, Email,GPA,'',null
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
where concat('.', MaSV, '.', TenSV, '.', Email, '.', GPA, '.', MaGVHD, '.', diem, '.') like concat('%',tukhoa,'%')
)svlist;
		RETURN (demHang);
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
from (select tmp1.MaSV, tmp1.TenSV, tmp1.Email, tmp1.DiemPB, tmp2.MaTB, tmp2.Diemtb, tmp2.slDiem
		from (select sv.MaSV, sv.TenSV, sv.Email, cdpb.Diem as DiemPB, pc.MaPhanCong
				from sinhvien sv, phancongdoan pc, `chamdiemhd-pb` cdpb
				where pc.MaSV=sv.MaSV and pc.MaPhanCong=cdpb.MaPhanCong and pc.MaGVPB=cdpb.MaGV and cdpb.Diem>=4 and SUBSTRING(pc.MaPhanCong, 3,2)=right(khoa, 2) and SUBSTRING(pc.MaSV, 6,2)=idNganh
				) tmp1
		left join (select MaPhanCong, MaTB, AVG(Diem) as Diemtb, count(Diem) as slDiem
					from chamdiemtb
					where SUBSTRING(MaPhanCong, 3,2)=right(khoa, 2)
					group by MaPhanCong, MaTB) tmp2
		on tmp1.MaPhanCong=tmp2.MaPhanCong) tmp
where concat('.', MaSV, '.', TenSV, '.', Email, '.', DiemPB, '.', MaTB, '.', Diemtb/slDiem, '.') like concat('%',tukhoa,'%')
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
            select pc.MaPhanCong, sv.MaSV, sv.TenSV, sv.MaLop, pc.MaDA, da.TenDA, cd.Diem, pc.MaCT
from sinhvien sv, phancongdoan pc, doan da, `chamdiemhd-pb` cd
where pc.MaSV=sv.MaSV and pc.MaDA=da.MaDA and cd.MaPhanCong=pc.MaPhanCong and cd.MaGV=pc.MaGVPB and pc.MaGVPB=idGV and substring(pc.MaPhanCong,3,2)=right(nienkhoahientai(substring(idGV,3,2)),2)
and concat('.', sv.MaSV, '.', sv.TenSV, '.', sv.MaLop, '.', pc.MaDA, '.', da.TenDA, '.', cd.Diem, '.') like concat('%',tukhoa,'%')
            ) tmpList;
        return (demHang);
	end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountList_SVTB_GV` (`idGV` CHAR(7), `idTB` CHAR(6), `tukhoa` VARCHAR(255)) RETURNS INT(11) begin
		DECLARE demHang int;
        SELECT COUNT(*) into demHang FROM(
		select pc.MaPhanCong, cd.MaTB, sv.MaSV, sv.TenSV, sv.MaLop, da.MaDA, da.TenDA, cd.Diem, pc.MaCT
from sinhvien sv, phancongdoan pc, doan da, chamdiemtb cd
where pc.MaSV=sv.MaSV and pc.MaDA=da.MaDA and pc.MaPhanCong=cd.MaPhanCong and cd.MaGV=idGV and cd.MaTB=idTB
and concat('.', sv.MaSV, '.', sv.TenSV, '.', sv.MaLop, '.', da.MaDA, '.', da.TenDA, '.', cd.Diem, '.') like concat('%',tukhoa,'%')
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
RETURN(@result);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `TrangThai_UpTaiLieuHDCaNhan` (`idDA` CHAR(7), `idGV` CHAR(7)) RETURNS INT(11) BEGIN
select MaCT into @idCT
from phienbanhuongdan
where MaDA=idDA and MaGV=idGV and TrangThai=0;

select count(*) into @result
from phancongdoan
where MaCT=@idCT;
RETURN(@result);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `baocao`
--

CREATE TABLE `baocao` (
  `MaBC` int(11) NOT NULL,
  `Tep` varchar(100) NOT NULL,
  `MoTa` varchar(255) DEFAULT NULL,
  `ThoiGian` datetime NOT NULL,
  `TrangThai` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `baocao`
--

INSERT INTO `baocao` (`MaBC`, `Tep`, `MoTa`, `ThoiGian`, `TrangThai`) VALUES
(1, 'da21043gvcn00620210605220710queryPhanCongGVPB (1).sql', 'Tệp văn bản,Tệp trình chiếu,vccc,', '2021-06-09 13:48:35', 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chamdiemhd-pb`
--

CREATE TABLE `chamdiemhd-pb` (
  `MaPhanCong` char(7) NOT NULL,
  `MaGV` varchar(7) NOT NULL,
  `Diem` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `chamdiemhd-pb`
--

INSERT INTO `chamdiemhd-pb` (`MaPhanCong`, `MaGV`, `Diem`) VALUES
('PC17001', 'GVPT001', 5),
('PC17001', 'GVPT002', 5),
('PC17003', 'GVPT001', 2),
('PC17003', 'GVPT003', 5),
('PC17004', 'GVPT004', 0),
('PC17005', 'GVPT002', 5),
('PC17006', 'GVCN002', 6),
('PC17006', 'GVCN006', 5),
('PC17007', 'GVCN002', 8),
('PC17007', 'GVCN006', 9),
('PC17009', 'GVNa005', 5),
('PC17010', 'GVCN003', 5),
('PC17011', 'GVCN007', 5),
('PC17012', 'GVCN006', 5);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chamdiemtb`
--

CREATE TABLE `chamdiemtb` (
  `MaPhanCong` char(7) NOT NULL,
  `MaGV` varchar(7) NOT NULL,
  `MaTB` char(6) NOT NULL,
  `Diem` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `chamdiemtb`
--

INSERT INTO `chamdiemtb` (`MaPhanCong`, `MaGV`, `MaTB`, `Diem`) VALUES
('PC17001', 'GVPT001', 'TB1708', NULL),
('PC17001', 'GVPT002', 'TB1708', NULL),
('PC17001', 'GVPT003', 'TB1708', NULL),
('PC17001', 'GVPT004', 'TB1708', NULL),
('PC17001', 'GVPT005', 'TB1708', NULL),
('PC17006', 'GVCN002', 'TB1701', NULL),
('PC17006', 'GVCN003', 'TB1701', NULL),
('PC17006', 'GVCN006', 'TB1701', NULL),
('PC17006', 'GVCN007', 'TB1701', NULL),
('PC17006', 'GVNa005', 'TB1701', NULL),
('PC17007', 'GVCN002', 'TB1701', NULL),
('PC17007', 'GVCN003', 'TB1701', NULL),
('PC17007', 'GVCN006', 'TB1701', NULL),
('PC17007', 'GVCN007', 'TB1701', NULL),
('PC17007', 'GVNa005', 'TB1701', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chitietchinhsuadoan`
--

CREATE TABLE `chitietchinhsuadoan` (
  `MaDA` char(7) NOT NULL,
  `MaGV` varchar(7) NOT NULL,
  `ThoiGian` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `chitietchinhsuadoan`
--

INSERT INTO `chitietchinhsuadoan` (`MaDA`, `MaGV`, `ThoiGian`) VALUES
('DA17011', 'GVCN006', '2021-06-01 00:00:00'),
('DA17011', 'GVCN006', '2021-06-04 00:00:00'),
('DA21023', 'GVCN006', '2021-06-03 00:00:00'),
('DA21024', 'GVPT001', '2021-06-03 00:00:00'),
('DA21025', 'GVCN006', '2021-06-03 00:00:00'),
('DA21029', 'GVCN006', '2021-06-03 00:00:00'),
('DA21031', 'GVCN006', '2021-06-03 00:00:00'),
('DA21036', 'GVCN006', '2021-06-03 00:00:00'),
('DA21039', 'GVCN006', '2021-06-04 00:00:00'),
('DA21040', 'GVCN006', '2021-06-05 11:23:51'),
('DA21040', 'GVCN006', '2021-06-05 11:23:59'),
('DA21040', 'GVCN006', '2021-06-05 11:24:06'),
('DA21040', 'GVCN006', '2021-06-05 11:24:18'),
('DA21040', 'GVCN006', '2021-06-05 11:24:27'),
('DA21040', 'GVCN006', '2021-06-05 11:24:33'),
('DA21040', 'GVCN006', '2021-06-11 15:55:58'),
('DA21040', 'GVCN006', '2021-06-11 15:56:09'),
('DA21042', 'GVCN006', '2021-06-05 15:37:35'),
('DA21042', 'GVCN006', '2021-06-05 15:37:41'),
('DA21042', 'GVCN006', '2021-06-14 06:51:07'),
('DA21042', 'GVCN006', '2021-06-15 00:40:39'),
('DA21043', 'GVCN006', '2021-06-05 22:07:10'),
('DA21043', 'GVCN006', '2021-06-13 14:06:54'),
('DA21043', 'GVCN006', '2021-06-15 00:33:28'),
('DA21043', 'GVCN006', '2021-06-15 00:33:53'),
('DA21044', 'GVCN006', '2021-06-09 17:15:16'),
('DA21044', 'GVCN006', '2021-06-11 11:27:51'),
('DA21044', 'GVCN006', '2021-06-11 11:28:48'),
('DA21044', 'GVCN006', '2021-06-11 11:29:30'),
('DA21045', 'GVCN006', '2021-06-09 19:12:32'),
('DA21045', 'GVCN006', '2021-06-13 14:06:21'),
('DA21046', 'GVCN006', '2021-06-11 11:55:37'),
('DA21046', 'GVCN006', '2021-06-11 11:56:01'),
('DA21046', 'GVCN006', '2021-06-11 13:34:41'),
('DA21046', 'GVCN006', '2021-06-11 13:37:13'),
('DA21046', 'GVCN006', '2021-06-11 13:39:09'),
('DA21046', 'GVCN006', '2021-06-14 08:13:26'),
('DA21047', 'GVCN006', '2021-06-11 11:56:23'),
('DA21047', 'GVCN006', '2021-06-13 14:14:05'),
('DA21048', 'GVCN006', '2021-06-11 12:16:16'),
('DA21048', 'GVCN006', '2021-06-11 15:43:34'),
('DA21048', 'GVCN006', '2021-06-11 15:47:44'),
('DA21048', 'GVCN006', '2021-06-11 15:47:45'),
('DA21048', 'GVCN006', '2021-06-11 15:52:48'),
('DA21048', 'GVCN006', '2021-06-11 15:59:54'),
('DA21048', 'GVCN006', '2021-06-11 16:00:35'),
('DA21048', 'GVCN006', '2021-06-14 23:23:32'),
('DA21049', 'GVCN006', '2021-06-11 13:52:32'),
('DA21049', 'GVCN006', '2021-06-11 14:20:07'),
('DA21049', 'GVCN006', '2021-06-11 14:20:24'),
('DA21049', 'GVCN006', '2021-06-11 16:12:48'),
('DA21049', 'GVCN006', '2021-06-15 00:06:42'),
('DA21050', 'GVCN006', '2021-06-11 14:05:54'),
('DA21050', 'GVCN006', '2021-06-11 14:18:06'),
('DA21050', 'GVCN006', '2021-06-11 14:19:40'),
('DA21050', 'GVCN006', '2021-06-11 14:31:58'),
('DA21050', 'GVCN006', '2021-06-14 08:16:12'),
('DA21050', 'GVCN006', '2021-06-14 22:21:44'),
('DA21050', 'GVCN006', '2021-06-14 22:22:51'),
('DA21050', 'GVCN006', '2021-06-14 22:34:11'),
('DA21050', 'GVCN006', '2021-06-14 22:35:24'),
('DA21050', 'GVCN006', '2021-06-14 22:35:48'),
('DA21050', 'GVCN006', '2021-06-15 00:07:08'),
('DA21051', 'GVCN006', '2021-06-11 14:06:02'),
('DA21051', 'GVCN006', '2021-06-11 16:00:45'),
('DA21052', 'GVCN006', '2021-06-11 14:30:58'),
('DA21053', 'GVCN006', '2021-06-13 13:41:05'),
('DA21054', 'GVCN006', '2021-06-13 13:41:56'),
('DA21055', 'GVCN006', '2021-06-13 13:52:40'),
('DA21055', 'GVCN006', '2021-06-13 14:02:43'),
('DA21056', 'GVCN006', '2021-06-13 14:03:50'),
('DA21057', 'GVCN006', '2021-06-13 14:14:50'),
('DA21057', 'GVCN006', '2021-06-13 14:15:02'),
('DA21057', 'GVCN006', '2021-06-13 17:56:29'),
('DA21058', 'GVCN006', '2021-06-13 14:21:48'),
('DA21058', 'GVCN006', '2021-06-13 14:22:42'),
('DA21058', 'GVCN006', '2021-06-13 14:23:24'),
('DA21058', 'GVCN006', '2021-06-14 06:55:17'),
('DA21058', 'GVCN006', '2021-06-14 06:55:46'),
('DA21059', 'GVCN006', '2021-06-14 08:17:01'),
('DA21060', 'GVCN006', '2021-06-14 08:18:34'),
('DA21060', 'GVCN006', '2021-06-15 00:01:07'),
('DA21061', 'GVCN006', '2021-06-14 22:42:58'),
('DA21061', 'GVCN006', '2021-06-14 22:43:09'),
('DA21061', 'GVCN006', '2021-06-14 22:43:24');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chuyennganh`
--

CREATE TABLE `chuyennganh` (
  `MaCN` char(2) NOT NULL,
  `TenCN` varchar(50) NOT NULL,
  `MaNganh` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `chuyennganh`
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
-- Cấu trúc bảng cho bảng `diemsang`
--

CREATE TABLE `diemsang` (
  `MaNganh` char(2) NOT NULL,
  `NamBD` year(4) NOT NULL,
  `Diem` float NOT NULL DEFAULT 2.5
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `diemsang`
--

INSERT INTO `diemsang` (`MaNganh`, `NamBD`, `Diem`) VALUES
('AT', 2017, 2.5),
('AT', 2020, 2.5),
('CN', 2013, 2.5),
('CN', 2014, 7),
('CN', 2015, 2.5),
('CN', 2017, 2.5),
('CN', 2018, 2.5),
('PT', 2015, 2.5),
('PT', 2017, 2.5),
('PT', 2018, 2.5),
('PT', 2019, 2.5);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `doan`
--

CREATE TABLE `doan` (
  `MaDA` char(7) NOT NULL,
  `TenDA` varchar(255) NOT NULL,
  `MaCN` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `doan`
--

INSERT INTO `doan` (`MaDA`, `TenDA`, `MaCN`) VALUES
('DA16001', 'web', 'CP'),
('DA17010', 'webapp', 'CP'),
('DA17011', 'test', 'IS'),
('DA21001', 'webapp', 'CP'),
('DA21002', 'doan', 'CP'),
('DA21003', '', 'PU'),
('DA21004', '', 'CP'),
('DA21005', '', 'CP'),
('DA21006', '', 'CP'),
('DA21007', '', 'CP'),
('DA21008', 'wap', 'CP'),
('DA21009', 'tays', 'IS'),
('DA21010', 'sss', 'CP'),
('DA21015', 'sss', 'CP'),
('DA21016', '14', 'CS'),
('DA21018', '14', 'CS'),
('DA21019', 'tanss', 'CP'),
('DA21023', 'ty', 'IS'),
('DA21024', 'ABC', 'PU'),
('DA21025', 'tyu', 'IS'),
('DA21029', 'xxxx', 'IS'),
('DA21031', 'tay', 'IS'),
('DA21036', 'chien', 'IS'),
('DA21039', 'MMMMM', 'CS'),
('DA21040', 'doancuoicungxx', 'CP'),
('DA21042', 'xxx', 'CP'),
('DA21043', 'ttt', 'CP'),
('DA21044', 'doanqq', 'CP'),
('DA21045', 'doanxxx', 'CP'),
('DA21046', '1234', 'CP'),
('DA21047', '123', 'CP'),
('DA21048', 'xxx', 'CP'),
('DA21049', 'xxxxx', 'CP'),
('DA21050', '555', 'CP'),
('DA21051', 'tttt', 'CP'),
('DA21052', 'iiiii', 'CP'),
('DA21053', 'xxxx', 'CP'),
('DA21054', 'zxxxx', 'CP'),
('DA21055', 'doancuocdoi', 'CP'),
('DA21056', 'xxxx', 'CP'),
('DA21057', 'tttt', 'CP'),
('DA21058', 'doananchotan', 'CP'),
('DA21059', 'doanllll', 'CP'),
('DA21060', 'doanans xxx', 'CP'),
('DA21061', 'tavx', 'CP');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `hoidong`
--

CREATE TABLE `hoidong` (
  `MaHD` int(11) NOT NULL,
  `TenHD` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Đang đổ dữ liệu cho bảng `hoidong`
--

INSERT INTO `hoidong` (`MaHD`, `TenHD`) VALUES
(1, 'Khoa Công nghệ thông tin');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lop`
--

CREATE TABLE `lop` (
  `MaLop` char(11) NOT NULL,
  `MaCN` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `lop`
--

INSERT INTO `lop` (`MaLop`, `MaCN`) VALUES
('D16CQAT01-N', 'AT'),
('D17CQAT01-N', 'AT'),
('D17CQAT02-N', 'AT'),
('D17CQAT03-N', 'AT'),
('D20CQAT01-N', 'AT'),
('D13CQCP01-N', 'CP'),
('D15CQCP01-N', 'CP'),
('D15CQCP02-N', 'CP'),
('D16CQCP01-N', 'CP'),
('D17CQCP01-N', 'CP'),
('D17CQCP02-N', 'CP'),
('D17CQCP03-N', 'CP'),
('D17CQCP04-N', 'CP'),
('D17CQCP05-N', 'CP'),
('D18CQCP01-N', 'CP'),
('D17CQCS01-N', 'CS'),
('D14CQIS01-N', 'IS'),
('D16CQIS01-N', 'IS'),
('D17CQIS-N', 'IS'),
('D17CQIS01-N', 'IS'),
('D17CQIS02-N', 'IS'),
('D17CQMT01-N', 'MT'),
('D17CQPU01-N', 'PU'),
('D17CQPU02-N', 'PU'),
('D17CQPU03-N', 'PU'),
('D18CQPU01-N', 'PU'),
('D18CQPU02-N', 'PU'),
('D18CQPU03-N', 'PU'),
('D18CQPU04-N', 'PU'),
('D18CQPU05-N', 'PU'),
('D19CQPU01-N', 'PU'),
('D16CQTK01-N', 'TK'),
('D17CQTK01-N', 'TK'),
('D17CQTK02-N', 'TK'),
('D17CQTK03-N', 'TK'),
('D17CQTK04-N', 'TK');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nganh`
--

CREATE TABLE `nganh` (
  `MaNganh` char(2) NOT NULL,
  `TenNganh` varchar(50) NOT NULL,
  `SoNam` float NOT NULL DEFAULT 4.5,
  `MaHD` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `nganh`
--

INSERT INTO `nganh` (`MaNganh`, `TenNganh`, `SoNam`, `MaHD`) VALUES
('AT', 'An toàn thông tin', 4.5, 1),
('CN', 'Công nghệ thông tin', 4.5, 1),
('PT', 'Công nghệ đa phương tiện', 4.5, 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nhanvien`
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
-- Đang đổ dữ liệu cho bảng `nhanvien`
--

INSERT INTO `nhanvien` (`MaNV`, `TenNV`, `NgaySinh`, `MaNganh`, `SDT`, `Email`, `MaTK`) VALUES
('GVAT001', 'Huỳnh Văn Nhứt', '1978-12-23', 'AT', '0903007234', 'vannhut2312@ptithcm.edu.vn', 'TK0002'),
('GVAT008', 'Đỗ Thị Ngọc Lan', '1989-12-12', 'AT', NULL, 'Ngoclan1989@ptithcm.edu.vn', 'TK0011'),
('GVAT009', 'thyu', '2021-04-29', 'AT', '121', '1212@ptithcm.edu.vn', 'TK0015'),
('GVCN002', 'Trần Thị Thanh Hảo', '1996-12-11', 'CN', '0376699418', 'âts@ptithcm.edu.vn', 'TK0004'),
('GVCN003', 'Hồ Thị Quỳnh Giang', '1987-11-15', 'CN', '0903014589', 'quynhgiang1511@ptithcm.edu.vn', 'TK0005'),
('GVCN006', 'Hồ Thị Quỳnh Giang', '1987-11-14', 'CN', '0903014589', 'quynhgiang1511@ptithcm.edu.vn', 'TK0010'),
('GVCN007', '231', '2021-05-05', 'CN', '1212', '121212@ptithcm.edu.vn', 'TK0006'),
('GVCN008', 'dứdsfda', '2021-06-01', 'CN', '12312', 'sdfsf@ptithcm.edu.vn', 'TK0023'),
('GVNa005', 'uuuu21', '2021-05-11', 'CN', 'uuuu12', 'uuuu@ptithcm.edu.vn', 'TK0016'),
('GVPT001', 'tyxx', '2021-05-04', 'PT', '1212', '1212@ptithcm.edu.vn', 'TK0003'),
('GVPT002', 'tan', '2021-05-06', 'PT', '1212', '1212@ptithcm.edu.vn', 'TK0007'),
('GVPT003', 'tayu', '2021-06-18', 'PT', '121312', '121212@ptithcm.edu.vn', 'TK0027'),
('GVPT004', 'mu', '2021-06-10', 'PT', '1212', '121212@ptithcm.edu.vn', 'TK0030'),
('GVPT005', '23212', '2021-06-16', 'PT', '121214312', '121212@ptithcm.edu.vn', 'TK0031'),
('QL001', 'Thanh Ngọc Tịnh', '2021-06-01', 'AT', '8945631230', 'admindagafd', 'TK0017');

--
-- Bẫy `nhanvien`
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
-- Cấu trúc bảng cho bảng `phancongdoan`
--

CREATE TABLE `phancongdoan` (
  `MaPhanCong` char(7) NOT NULL,
  `MaDA` char(7) DEFAULT NULL,
  `MaSV` char(10) NOT NULL,
  `MaGVHD` varchar(7) NOT NULL,
  `MaGVPB` varchar(7) DEFAULT NULL,
  `NgayPhanCong` date DEFAULT NULL,
  `MaBC` int(11) DEFAULT NULL,
  `MaCT` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `phancongdoan`
--

INSERT INTO `phancongdoan` (`MaPhanCong`, `MaDA`, `MaSV`, `MaGVHD`, `MaGVPB`, `NgayPhanCong`, `MaBC`, `MaCT`) VALUES
('PC17001', 'DA21003', 'N17DCPT002', 'GVPT001', 'GVPT002', NULL, NULL, 0),
('PC17003', NULL, 'N17DCPT003', 'GVPT003', 'GVPT001', NULL, NULL, 0),
('PC17004', 'DA21042', 'N17DCPT004', 'GVPT004', NULL, NULL, NULL, 25),
('PC17005', NULL, 'N17DCPT005', 'GVPT002', NULL, NULL, NULL, 0),
('PC17006', 'DA21049', 'N17DCCN001', 'GVCN006', 'GVCN002', '2021-06-14', NULL, 60),
('PC17007', 'DA21043', 'N17DCCN002', 'GVCN002', 'GVCN006', NULL, 1, 26),
('PC17009', NULL, 'N17DCCN004', 'GVNa005', NULL, NULL, NULL, NULL),
('PC17010', NULL, 'N17DCCN005', 'GVCN003', NULL, NULL, NULL, NULL),
('PC17011', NULL, 'N17DCCN003', 'GVCN007', NULL, NULL, NULL, NULL),
('PC17012', 'DA21048', 'N17DCCN006', 'GVCN006', NULL, '2021-06-14', NULL, 90);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `phanconggvtb`
--

CREATE TABLE `phanconggvtb` (
  `MaGV` varchar(7) NOT NULL,
  `MaTB` char(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `phanconggvtb`
--

INSERT INTO `phanconggvtb` (`MaGV`, `MaTB`) VALUES
('GVAT001', 'TB1707'),
('GVAT008', 'TB1707'),
('GVAT009', 'TB1707'),
('GVCN002', 'TB1602'),
('GVCN002', 'TB1701'),
('GVCN002', 'TB1705'),
('GVCN002', 'TB1712'),
('GVCN002', 'TB1713'),
('GVCN002', 'TB1714'),
('GVCN002', 'TB1716'),
('GVCN002', 'TB1717'),
('GVCN002', 'TB1718'),
('GVCN002', 'TB1723'),
('GVCN002', 'undefi'),
('GVCN003', 'TB1602'),
('GVCN003', 'TB1701'),
('GVCN003', 'TB1705'),
('GVCN003', 'TB1712'),
('GVCN003', 'TB1713'),
('GVCN003', 'TB1714'),
('GVCN003', 'TB1716'),
('GVCN003', 'TB1717'),
('GVCN003', 'TB1718'),
('GVCN003', 'TB1723'),
('GVCN003', 'TB1724'),
('GVCN006', 'TB1701'),
('GVCN006', 'TB1705'),
('GVCN006', 'TB1712'),
('GVCN006', 'TB1713'),
('GVCN006', 'TB1714'),
('GVCN006', 'TB1716'),
('GVCN006', 'TB1717'),
('GVCN006', 'TB1718'),
('GVCN006', 'TB1723'),
('GVCN006', 'TB1724'),
('GVCN007', 'TB1705'),
('GVCN007', 'TB1712'),
('GVCN007', 'TB1713'),
('GVCN007', 'TB1717'),
('GVCN007', 'TB1723'),
('GVCN007', 'TB1724'),
('GVCN007', 'undefi'),
('GVCN008', 'TB1713'),
('GVNa005', 'TB1602'),
('GVNa005', 'TB1705'),
('GVNa005', 'TB1712'),
('GVNa005', 'TB1717'),
('GVNa005', 'TB1723'),
('GVNa005', 'undefi'),
('GVPT001', 'TB1704'),
('GVPT001', 'TB1708'),
('GVPT002', 'TB1704'),
('GVPT002', 'TB1708'),
('GVPT003', 'TB1704'),
('GVPT003', 'TB1708'),
('GVPT004', 'TB1708'),
('GVPT005', 'TB1708');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `phienbanhuongdan`
--

CREATE TABLE `phienbanhuongdan` (
  `MaCT` int(11) NOT NULL,
  `Tep` varchar(100) DEFAULT NULL,
  `TrangThai` int(11) NOT NULL DEFAULT 1,
  `MoTa` varchar(255) DEFAULT NULL,
  `MaDA` char(7) NOT NULL,
  `MaGV` varchar(7) NOT NULL,
  `ThoiGian` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `phienbanhuongdan`
--

INSERT INTO `phienbanhuongdan` (`MaCT`, `Tep`, `TrangThai`, `MoTa`, `MaDA`, `MaGV`, `ThoiGian`) VALUES
(1, 'da17011gvcn00620210601000000file1.doc', 1, NULL, 'DA17011', 'GVCN006', '2021-06-01 00:00:00'),
(4, NULL, 1, NULL, 'DA21023', 'GVCN006', '2021-06-03 00:00:00'),
(5, 'da21024gvpt00120210603000000abc.rar', 0, 'Tệp văn bản, tệp chương trình', 'DA21024', 'GVPT001', '2021-06-03 00:00:00'),
(6, 'da21025gvcn00620210603000000y2mate.comkonohapeaceost_320kbps.mp3,', 0, 'Tệp văn bản,vc,', 'DA21025', 'GVCN006', '2021-06-03 00:00:00'),
(10, 'da21029gvcn006202106030000001e5ee4fad11b011d8b6066177d87faa2(1).txt,', 0, 'Tệp văn bản,Tệp chương trình,', 'DA21029', 'GVCN006', '2021-06-03 00:00:00'),
(12, 'da21031gvcn00620210603000000312c13360f2830d3d9f774899d411104.txt,', 0, 'Tệp văn bản,Tệp trình chiếu,', 'DA21031', 'GVCN006', '2021-06-03 00:00:00'),
(17, 'da17011gvcn00620210604000000fileupdate.rar', 1, NULL, 'DA17011', 'GVCN006', '2021-06-04 00:00:00'),
(19, 'da21039gvcn00620210604000000[FoOP - Okami] One Piece 975 - 1080p Ver 1.mp3_vocals.mp3,', 0, 'video,', 'DA21039', 'GVCN006', '2021-06-04 00:00:00'),
(20, 'da21040gvcn00620210605112351KY THUAT DO HOA.v12.suo', 2, 'Tệp văn bản,Tệp trình chiếu,', 'DA21040', 'GVCN006', '2021-06-05 11:23:51'),
(21, 'da21040gvcn00620210605112359polygon.cpp', 2, 'Tệp chương trình,vcc,', 'DA21040', 'GVCN006', '2021-06-05 11:23:59'),
(22, 'da21040gvcn00620210605112418kythuatdohoa.vc.db', 2, 'Tệp văn bản,Tệp trình chiếu,', 'DA21040', 'GVCN006', '2021-06-05 11:24:18'),
(23, 'da21040gvcn00620210605112427get_video_info(1)', 0, 'Tệp văn bản,Tệp trình chiếu,', 'DA21040', 'GVCN006', '2021-06-05 11:24:27'),
(25, 'da21042gvcn00620210605153735get_video_info (1)', 0, 'Tệp chương trình,', 'DA21042', 'GVCN006', '2021-06-05 15:37:35'),
(26, 'da21043gvcn00620210605220710queryPhanCongGVPB (1).sql', 0, '', 'DA21043', 'GVCN006', '2021-06-05 22:07:10'),
(27, 'da21044gvcn00620210609171516Untitled1.cpp', 2, 'Tệp văn bản,Tệp trình chiếu,ggg,', 'DA21044', 'GVCN006', '2021-06-09 17:15:16'),
(28, 'da21045gvcn00620210609191232193488866_4159139814143197_5509727209385752445_n.png', 0, 'Tệp văn bản,hhhh,', 'DA21045', 'GVCN006', '2021-06-09 19:12:32'),
(29, 'da21044gvcn00620210611112848employee.svg', 2, 'ggg,', 'DA21044', 'GVCN006', '2021-06-11 11:28:48'),
(30, 'da21044gvcn00620210611112930graduationhat.svg', 0, 'ssss,', 'DA21044', 'GVCN006', '2021-06-11 11:29:30'),
(31, 'down-arrow.svg', 2, 'Tệp văn bản,xxx,', 'DA21046', 'GVCN006', '2021-06-11 11:55:37'),
(32, 'da21046gvcn00620210611115601group.svg', 2, 'Tệp văn bản,Tệp chương trình,xxx,', 'DA21046', 'GVCN006', '2021-06-11 11:56:01'),
(33, 'group.svg', 0, 'Tệp văn bản,Tệp trình chiếu,Tệp chương trình,xxx,', 'DA21047', 'GVCN006', '2021-06-11 11:56:23'),
(34, 'customer-satisfaction.svg', 2, 'Tệp văn bản,xxx,', 'DA21048', 'GVCN006', '2021-06-11 12:16:16'),
(40, 'da21046gvcn00620210611133441gvcn006da2104620210611133441interface.js', 2, '', 'DA21046', 'GVCN006', '2021-06-11 13:34:41'),
(41, 'da21046gvcn00620210611133713gvcn006da2104620210611133713js.js', 2, '', 'DA21046', 'GVCN006', '2021-06-11 13:37:13'),
(42, 'da21046gvcn00620210611133909gvcn006da2104620210611133909downarrow.svg', 2, 'Tệp văn bản,rrr,', 'DA21046', 'GVCN006', '2021-06-11 13:39:09'),
(43, 'GVCN006DA2104920210611135232down-arrow.svg', 2, 'Tệp văn bản,xx,', 'DA21049', 'GVCN006', '2021-06-11 13:52:32'),
(44, 'GVCN006DA2105020210611140554plus-symbol-button.svg', 2, 'Tệp văn bản,y,', 'DA21050', 'GVCN006', '2021-06-11 14:05:54'),
(45, 'GVCN006DA2105120210611140602group.svg', 0, '', 'DA21051', 'GVCN006', '2021-06-11 14:06:02'),
(46, 'da21050gvcn00620210611141806gvcn006da2105020210611141806group.svg', 2, 'Tệp văn bản,', 'DA21050', 'GVCN006', '2021-06-11 14:18:06'),
(47, 'GVCN006DA2105020210611141940bad-review.svg', 2, 'Tệp trình chiếu,Tệp chương trình,', 'DA21050', 'GVCN006', '2021-06-11 14:19:40'),
(48, 'GVCN006DA2104920210611142007home-button-for-interface.svg', 2, 'Tệp văn bản,7,', 'DA21049', 'GVCN006', '2021-06-11 14:20:07'),
(49, 'GVCN006DA2104920210611142024logout.svg', 2, 'Tệp văn bản,', 'DA21049', 'GVCN006', '2021-06-11 14:20:24'),
(50, 'GVCN006DA2105220210611143058graduation-hat.svg', 0, 'ô,', 'DA21052', 'GVCN006', '2021-06-11 14:30:58'),
(51, 'GVCN006DA2105020210611143158teacher-at-the-blackboard.svg', 2, 'Tệp văn bản,', 'DA21050', 'GVCN006', '2021-06-11 14:31:58'),
(52, 'GVCN006DA2104820210611154744group.svg', 2, 'Tệp văn bản,iiii,', 'DA21048', 'GVCN006', '2021-06-11 15:47:44'),
(53, 'GVCN006DA2104820210611154745group.svg', 2, 'Tệp văn bản,iiii,', 'DA21048', 'GVCN006', '2021-06-11 15:47:45'),
(54, 'GVCN006DA2104820210611155248bad-review.svg', 2, 'Tệp trình chiếu,xxx,', 'DA21048', 'GVCN006', '2021-06-11 15:52:48'),
(55, 'GVCN006DA2104020210611155558clipboard.svg', 0, 'Tệp văn bản,Tệp chương trình,xxxx,', 'DA21040', 'GVCN006', '2021-06-11 15:55:58'),
(56, 'GVCN006DA2104020210611155609down-arrow.svg', 0, 'Tệp văn bản,xxx,', 'DA21040', 'GVCN006', '2021-06-11 15:56:09'),
(57, 'GVCN006DA2104820210611155954down-arrow.svg', 2, 'Tệp văn bản,v,', 'DA21048', 'GVCN006', '2021-06-11 15:59:54'),
(58, 'GVCN006DA2104820210611160035bad-review.svg', 0, 'Tệp văn bản,iiii,', 'DA21048', 'GVCN006', '2021-06-11 16:00:35'),
(59, 'GVCN006DA2105120210611160045down-arrow.svg', 0, 'Tệp văn bản,rrr,', 'DA21051', 'GVCN006', '2021-06-11 16:00:45'),
(60, 'GVCN006DA2104920210611161248clipboard.svg', 0, 'Tệp văn bản,Tệp trình chiếu,', 'DA21049', 'GVCN006', '2021-06-11 16:12:48'),
(61, 'GVCN006DA2105320210613134105Untitledchart.png', 0, 'xxx,', 'DA21053', 'GVCN006', '2021-06-13 13:41:05'),
(62, 'GVCN006DA2105420210613134156chart.png', 0, 'Tệp văn bản,xxx,', 'DA21054', 'GVCN006', '2021-06-13 13:41:56'),
(63, 'GVCN006DA2105520210613135240Untitled1.cpp', 0, 'Tệp văn bản,', 'DA21055', 'GVCN006', '2021-06-13 13:52:40'),
(64, 'GVCN006DA2105520210613140243jumpstart.zip', 0, 'Tệp văn bản,Tệp trình chiếu,Tệp chương trình,zzz,', 'DA21055', 'GVCN006', '2021-06-13 14:02:43'),
(65, 'GVCN006DA2105620210613140350sll.zip', 0, 'xxx,', 'DA21056', 'GVCN006', '2021-06-13 14:03:50'),
(66, 'GVCN006DA2104520210613140621Circle.h', 0, 'Tệp văn bản,Tệp trình chiếu,xxxx,', 'DA21045', 'GVCN006', '2021-06-13 14:06:21'),
(67, 'GVCN006DA2104320210613140654KY THUAT DO HOA.v12.suo', 0, 'Tệp văn bản,', 'DA21043', 'GVCN006', '2021-06-13 14:06:54'),
(68, 'GVCN006DA2104720210613141405sll.zip', 0, 'Tệp văn bản,Tệp trình chiếu,xxxx,', 'DA21047', 'GVCN006', '2021-06-13 14:14:05'),
(69, 'GVCN006DA2105720210613141450chart.png', 2, 'Tệp văn bản,Tệp chương trình,xx,', 'DA21057', 'GVCN006', '2021-06-13 14:14:50'),
(70, 'GVCN006DA2105720210613141502Untitledchart.png', 0, 'uuu,', 'DA21057', 'GVCN006', '2021-06-13 14:15:02'),
(71, 'GVCN006DA2105820210613142148jumpstart.zip', 2, 'Tệp văn bản,', 'DA21058', 'GVCN006', '2021-06-13 14:21:48'),
(72, 'GVCN006DA2105820210613142242jumpstart.zip', 2, 'Tệp văn bản,xxx,', 'DA21058', 'GVCN006', '2021-06-13 14:22:42'),
(73, 'GVCN006DA2105820210613142324sll.zip', 0, 'Tệp văn bản,', 'DA21058', 'GVCN006', '2021-06-13 14:23:24'),
(74, 'GVCN006DA2105720210613175629sll.zip', 0, 'Tệp văn bản,Tệp trình chiếu,Tệp chương trình,', 'DA21057', 'GVCN006', '2021-06-13 17:56:29'),
(75, 'GVCN006DA2104220210614065107login', 0, 'Tệp văn bản,tt,', 'DA21042', 'GVCN006', '2021-06-14 06:51:07'),
(76, 'GVCN006DA2105820210614065515login', 0, 'xxx,', 'DA21058', 'GVCN006', '2021-06-14 06:55:17'),
(77, 'GVCN006DA2105820210614065544queryChamDiemHD.sql', 0, '', 'DA21058', 'GVCN006', '2021-06-14 06:55:46'),
(78, 'GVCN006DA2104620210614081326login', 0, 'Tệp văn bản,', 'DA21046', 'GVCN006', '2021-06-14 08:13:26'),
(79, 'GVCN006DA2105020210614081612queryChamDiemHD.sql', 2, 'Tệp chương trình,xxx,', 'DA21050', 'GVCN006', '2021-06-14 08:16:12'),
(80, 'GVCN006DA2105920210614081701Code.exe', 0, 'xxx,', 'DA21059', 'GVCN006', '2021-06-14 08:17:01'),
(81, 'GVCN006DA2106020210614081833Code.VisualElementsManifest.xml', 0, 'xxx,', 'DA21060', 'GVCN006', '2021-06-14 08:18:34'),
(82, 'GVCN006DA2105020210614222143icudtl.dat', 2, 'Tệp văn bản,', 'DA21050', 'GVCN006', '2021-06-14 22:21:44'),
(83, 'GVCN006DA2105020210614222250resources.pak', 2, 'Tệp chương trình,', 'DA21050', 'GVCN006', '2021-06-14 22:22:51'),
(84, 'GVCN006DA2105020210614223409d3dcompiler_47.dll', 2, 'Tệp văn bản,Tệp trình chiếu,', 'DA21050', 'GVCN006', '2021-06-14 22:34:11'),
(85, 'GVCN006DA2105020210614223524unins000.dat', 0, 'Tệp văn bản,', 'DA21050', 'GVCN006', '2021-06-14 22:35:24'),
(86, 'GVCN006DA2105020210614223548libGLESv2.dll', 0, 'Tệp trình chiếu,', 'DA21050', 'GVCN006', '2021-06-14 22:35:48'),
(87, 'GVCN006DA2106120210614224257d3dcompiler_47.dll', 2, 'Tệp văn bản,', 'DA21061', 'GVCN006', '2021-06-14 22:42:58'),
(88, 'GVCN006DA2106120210614224308chrome_100_percent.pak', 0, 'Tệp văn bản,', 'DA21061', 'GVCN006', '2021-06-14 22:43:09'),
(89, 'GVCN006DA2106120210614224323ffmpeg.dll', 0, 'Tệp văn bản,', 'DA21061', 'GVCN006', '2021-06-14 22:43:24'),
(90, 'GVCN006DA2104820210614232332Code.VisualElementsManifest.xml', 1, 'Tệp chương trình,', 'DA21048', 'GVCN006', '2021-06-14 23:23:32'),
(91, 'GVCN006DA2106020210615000106icudtl.dat', 1, 'Tệp trình chiếu,', 'DA21060', 'GVCN006', '2021-06-15 00:01:07'),
(92, 'GVCN006DA2104920210615000641Untitledchart.png', 0, 'Tệp văn bản,', 'DA21049', 'GVCN006', '2021-06-15 00:06:42'),
(93, 'GVCN006DA2105020210615000707xxxx.png', 0, 'Tệp văn bản,', 'DA21050', 'GVCN006', '2021-06-15 00:07:08'),
(94, 'GVCN006DA2104320210615003327queryPhanCongDATB.sql', 2, 'Tệp trình chiếu,', 'DA21043', 'GVCN006', '2021-06-15 00:33:28'),
(95, 'GVCN006DA2104320210615003353Untitled1.cpp', 1, 'Tệp văn bản,', 'DA21043', 'GVCN006', '2021-06-15 00:33:53'),
(96, 'GVCN006DA2104220210615004039xxxx.png', 1, 'Tệp văn bản,', 'DA21042', 'GVCN006', '2021-06-15 00:40:39');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `sinhvien`
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
-- Đang đổ dữ liệu cho bảng `sinhvien`
--

INSERT INTO `sinhvien` (`MaSV`, `TenSV`, `NgaySinh`, `MaLop`, `GPA`, `SDT`, `Email`, `MaTK`) VALUES
('N15DCCN001', '123', '2021-06-15', 'D15CQCP02-N', 12, '1212', 'N15DCCN001@student.ptithcm.edu.vn', NULL),
('N15DCPT001', 'tan', '2021-06-10', 'D17CQPU02-N', 12, '12312', 'N15DCPT001@student.ptithcm.edu.vn', NULL),
('N17DCAT001', 'yttt', '2021-06-17', 'D17CQAT01-N', 2, '123123123', 'N17DCAT001@student.ptithcm.edu.vn', NULL),
('N17DCCN001', 'tan', '2021-06-16', 'D17CQCP05-N', 1212, '1212212', 'N17DCCN001@student.ptithcm.edu.vn', 'TK0012'),
('N17DCCN002', 'A', '2021-06-23', 'D17CQCP01-N', 2.8, '786543120', 'N17DCCN002@student.ptithcm.edu.vn', 'TK0013'),
('N17DCCN003', 'B', '2021-06-05', 'D17CQCP02-N', 3, '7984512', 'N17DCCN003@student.ptithcm.edu.vn', 'TK0021'),
('N17DCCN004', 'xxx', '2021-06-03', 'D17CQCP01-N', 12, '1213131212', 'N17DCCN004@student.ptithcm.edu.vn', 'TK0019'),
('N17DCCN005', 'tan', '2021-06-10', 'D17CQCP01-N', 1, 'ta', 'N17DCCN005@student.ptithcm.edu.vn', 'TK0020'),
('N17DCCN006', 'le quoc tan', '2021-06-11', 'D17CQCP01-N', 4, '121212', 'N17DCCN006@student.ptithcm.edu.vn', 'TK0022'),
('N17DCCN008', 'ssss', '2021-06-04', 'D17CQCP01-N', 4, '0120371920', 'N17DCCN008@student.ptithcm.edu.vn', NULL),
('N17DCCN009', 'sss', '2021-06-02', 'D17CQCP01-N', 2, '1223131231', 'N17DCCN009@student.ptithcm.edu.vn', NULL),
('N17DCPT001', 'A', '2021-06-16', 'D17CQPU02-N', 2.5, '89456230', 'N17DCPT001@student.ptithcm.edu.vn', 'TK0028'),
('N17DCPT002', 'tan', '2021-06-24', 'D17CQTK02-N', 12, '121313', 'N17DCPT002@student.ptithcm.edu.vn', 'TK0026'),
('N17DCPT003', 'ty', '2021-06-08', 'D17CQTK03-N', 1.2, '123123', 'N17DCPT003@student.ptithcm.edu.vn', 'TK0029'),
('N17DCPT004', 'tan', '2021-06-03', 'D17CQTK04-N', 1212, '12313', 'N17DCPT004@student.ptithcm.edu.vn', 'TK0032'),
('N17DCPT005', '12', '2021-06-10', 'D17CQPU03-N', 12, '1212', 'N17DCPT005@student.ptithcm.edu.vn', 'TK0008'),
('N18DCPT001', 'xxxx', '2021-06-03', 'D18CQPU01-N', 12, '1212', 'N18DCPT001@student.ptithcm.edu.vn', NULL),
('N18DCPT002', '123', '2021-06-04', 'D18CQPU02-N', 12, '23', 'N18DCPT002@student.ptithcm.edu.vn', NULL),
('N18DCPT003', '123', '2021-06-09', 'D18CQPU03-N', 12, '231', 'N18DCPT003@student.ptithcm.edu.vn', NULL),
('N18DCPT004', 'tan', '2021-06-09', 'D18CQPU04-N', 12, '12', 'N18DCPT004@student.ptithcm.edu.vn', NULL),
('N18DCPT005', '12', '2021-06-25', 'D18CQPU01-N', 12, '1212', 'N18DCPT005@student.ptithcm.edu.vn', NULL),
('N18DCPT006', '12', '2021-06-03', 'D18CQPU03-N', 121, '12', 'N18DCPT006@student.ptithcm.edu.vn', NULL),
('N18DCPT007', '12', '2021-06-23', 'D18CQPU05-N', 12, '12', 'N18DCPT007@student.ptithcm.edu.vn', NULL),
('N19DCPT001', 'tandeptrai', '2021-06-16', 'D19CQPU01-N', 12, '121', 'N19DCPT001@student.ptithcm.edu.vn', NULL),
('N20DCAT001', 'tu', '2021-06-16', 'D20CQAT01-N', 5, '123121212', 'N20DCAT001@student.ptithcm.edu.vn', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `taikhoan`
--

CREATE TABLE `taikhoan` (
  `MaTK` char(6) NOT NULL,
  `TenDangNhap` varchar(15) DEFAULT NULL,
  `MatKhau` varchar(50) DEFAULT NULL,
  `Quyen` char(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `taikhoan`
--

INSERT INTO `taikhoan` (`MaTK`, `TenDangNhap`, `MatKhau`, `Quyen`) VALUES
('TK0001', 'GVCN001', '22011bb728dd5d6fd7448c75275811f6', 'GV'),
('TK0002', 'GVAT001', '2ffb037705b48ab35fd49a7829ca56a6', 'GV'),
('TK0003', 'GVPT001', 'ce28339d1cfd1af5d71a29e61f0deff8', 'GV'),
('TK0004', 'GVCN002', 'f633985777b2d9c5802b0b2410223042', 'GV'),
('TK0005', 'GVCN003', 'd94f47bb691a781bdd704e47ca5744f4', 'GV'),
('TK0006', 'GVCN007', '2541be29754cba3cef7d7331a685e846', 'GV'),
('TK0007', 'GVPT002', '80d9f4b32dc7a6f06449a013079a9f35', 'GV'),
('TK0008', 'N17DCPT005', '58aab7b657f051e067e83c09da373684', 'SV'),
('TK0010', 'GVCN006', '975fbf9a5114886ba7b3d74f244fa5f6', 'GV'),
('TK0011', 'GVAT008', 'beaa258e0157937fd0a5df93fd193db3', 'GV'),
('TK0012', 'N17DCCN001', '330f9d072d3bfb3cec4f4472fb7ffdf8', 'SV'),
('TK0013', 'N17DCCN002', '009cf6e9600ac5eba8e2d2d358cbe245', 'SV'),
('TK0014', 'N17DCCN003', '393efba908e68ee8f951b34ebc9c0779', 'SV'),
('TK0015', 'GVAT009', 'cd57446cd3304300f1c1272b26843edd', 'GV'),
('TK0016', 'GVNa005', 'ecb84e45d390d16fcf0b39adf995b341', 'GV'),
('TK0017', 'QL001', '6167c613df1ee796a56ee11419438ba0', 'QL'),
('TK0018', 'N17DCCN004', '4fbc7122d6da6a5fbe32e8a9970f8f4b', 'SV'),
('TK0019', 'N17DCCN004', '4fbc7122d6da6a5fbe32e8a9970f8f4b', 'SV'),
('TK0020', 'N17DCCN005', '2446652cdb14290a4049cf2fb48750ba', 'SV'),
('TK0021', 'N17DCCN003', '4107f360b46b331d4e0bddf1c483efbe', 'SV'),
('TK0022', 'N17DCCN006', '63767f44b7308cc715dc9ea32b94074b', 'SV'),
('TK0023', 'GVCN008', 'df5892be7f3d89886e8f49b9ab2d6062', 'GV'),
('TK0024', 'N17DCCN011', 'ce5b08b2634090af789927bae265e436', NULL),
('TK0025', 'N17DCCN019', '5a72a46ff2033989c5b2d0016af20fa9', NULL),
('TK0026', 'N17DCPT002', 'a540a5d616adf49a737e19fdc1a0ec5a', 'SV'),
('TK0027', 'GVPT003', '49a1ac40d89acaf6b49a91f59eb62f5f', 'GV'),
('TK0028', 'N17DCPT001', '9a7e09738e0b27cfc1108172d4760897', 'SV'),
('TK0029', 'N17DCPT003', '661200882b2a7ad797a6d91db7d5fa67', 'SV'),
('TK0030', 'GVPT004', '2d448f23a6ffa033e2d409512d677e3a', 'GV'),
('TK0031', 'GVPT005', 'c68a0f91b3afec068efd5473938c2057', 'GV'),
('TK0032', 'N17DCPT004', 'c4bf5ff6356abc1b99d1e89172c9c45a', 'SV');

--
-- Bẫy `taikhoan`
--
DELIMITER $$
CREATE TRIGGER `Insert_TK` BEFORE INSERT ON `taikhoan` FOR EACH ROW BEGIN
    set new.MaTK=AUTO_IDTK();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `test`
--

CREATE TABLE `test` (
  `id` int(11) DEFAULT NULL,
  `v1` int(11) DEFAULT NULL,
  `v2` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tieuban`
--

CREATE TABLE `tieuban` (
  `MaTB` char(6) NOT NULL,
  `MaNganh` char(2) NOT NULL,
  `Ngay` date NOT NULL,
  `Ca` char(2) NOT NULL DEFAULT 'SA' COMMENT 'SA or CH'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `tieuban`
--

INSERT INTO `tieuban` (`MaTB`, `MaNganh`, `Ngay`, `Ca`) VALUES
('TB1601', 'CN', '2021-06-26', 'SA'),
('TB1602', 'CN', '2021-05-18', 'SA'),
('TB1603', 'AT', '2021-05-14', 'SA'),
('TB1701', 'CN', '2021-06-26', 'SA'),
('TB1703', 'AT', '2021-05-16', 'CH'),
('TB1704', 'PT', '2021-05-17', 'SA'),
('TB1705', 'CN', '2021-05-13', 'SA'),
('TB1707', 'AT', '2021-05-16', 'CH'),
('TB1708', 'PT', '2021-05-17', 'SA'),
('TB1712', 'CN', '2021-05-28', 'SA'),
('TB1713', 'CN', '2021-05-11', 'SA'),
('TB1714', 'CN', '2021-06-14', 'SA'),
('TB1716', 'CN', '2021-05-20', 'CH'),
('TB1717', 'CN', '2021-06-04', 'SA'),
('TB1718', 'CN', '2021-06-13', 'SA'),
('TB1723', 'CN', '2021-06-04', 'SA'),
('TB1724', 'CN', '2021-06-10', 'CH'),
('TB1725', 'CN', '2021-06-10', 'CH'),
('TB1801', 'AT', '2021-05-15', 'SA'),
('TB1802', 'AT', '2021-05-15', 'SA');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `baocao`
--
ALTER TABLE `baocao`
  ADD PRIMARY KEY (`MaBC`),
  ADD UNIQUE KEY `TepVB_UNIQUE` (`Tep`);

--
-- Chỉ mục cho bảng `chamdiemhd-pb`
--
ALTER TABLE `chamdiemhd-pb`
  ADD PRIMARY KEY (`MaPhanCong`,`MaGV`),
  ADD KEY `fk_cham_diem_hd_pb_giang_vien1` (`MaGV`),
  ADD KEY `fk_chamdiemhd-pb_phancongdoan1_idx` (`MaPhanCong`);

--
-- Chỉ mục cho bảng `chamdiemtb`
--
ALTER TABLE `chamdiemtb`
  ADD PRIMARY KEY (`MaPhanCong`,`MaGV`,`MaTB`),
  ADD KEY `fk_de_tai_has_PHAN_CONG_GV_TB_PHAN_CONG_GV_TB1` (`MaGV`,`MaTB`),
  ADD KEY `fk_chamdiemtb_phancongdoan1_idx` (`MaPhanCong`);

--
-- Chỉ mục cho bảng `chitietchinhsuadoan`
--
ALTER TABLE `chitietchinhsuadoan`
  ADD PRIMARY KEY (`MaDA`,`MaGV`,`ThoiGian`),
  ADD KEY `fk_doan_has_nhanvien_nhanvien1_idx` (`MaGV`),
  ADD KEY `fk_doan_has_nhanvien_doan1_idx` (`MaDA`);

--
-- Chỉ mục cho bảng `chuyennganh`
--
ALTER TABLE `chuyennganh`
  ADD PRIMARY KEY (`MaCN`),
  ADD UNIQUE KEY `TenChuyenNganh_UNIQUE` (`TenCN`),
  ADD KEY `fk_CHUYENNGANH_NGANH1_idx` (`MaNganh`);

--
-- Chỉ mục cho bảng `diemsang`
--
ALTER TABLE `diemsang`
  ADD PRIMARY KEY (`MaNganh`,`NamBD`);

--
-- Chỉ mục cho bảng `doan`
--
ALTER TABLE `doan`
  ADD PRIMARY KEY (`MaDA`),
  ADD KEY `fk_doan_chuyennganh1_idx` (`MaCN`);

--
-- Chỉ mục cho bảng `hoidong`
--
ALTER TABLE `hoidong`
  ADD PRIMARY KEY (`MaHD`),
  ADD UNIQUE KEY `TenHD_UNIQUE` (`TenHD`);

--
-- Chỉ mục cho bảng `lop`
--
ALTER TABLE `lop`
  ADD PRIMARY KEY (`MaLop`),
  ADD UNIQUE KEY `MaLop_UNIQUE` (`MaLop`),
  ADD KEY `MaCN` (`MaCN`);

--
-- Chỉ mục cho bảng `nganh`
--
ALTER TABLE `nganh`
  ADD PRIMARY KEY (`MaNganh`),
  ADD UNIQUE KEY `TenNganh_UNIQUE` (`TenNganh`),
  ADD UNIQUE KEY `MaNganh_UNIQUE` (`MaNganh`),
  ADD KEY `fk_nganh_HOIDONG1_idx` (`MaHD`);

--
-- Chỉ mục cho bảng `nhanvien`
--
ALTER TABLE `nhanvien`
  ADD PRIMARY KEY (`MaNV`),
  ADD UNIQUE KEY `MaNV_UNIQUE` (`MaNV`),
  ADD KEY `fk_giang_vien_tai_khoan1_idx` (`MaTK`),
  ADD KEY `fk_giangvien_nganh1_idx` (`MaNganh`);

--
-- Chỉ mục cho bảng `phancongdoan`
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
-- Chỉ mục cho bảng `phanconggvtb`
--
ALTER TABLE `phanconggvtb`
  ADD PRIMARY KEY (`MaGV`,`MaTB`),
  ADD KEY `fk_GIANG_VIEN_has_tieu_ban_tieu_ban1` (`MaTB`);

--
-- Chỉ mục cho bảng `phienbanhuongdan`
--
ALTER TABLE `phienbanhuongdan`
  ADD PRIMARY KEY (`MaCT`),
  ADD KEY `fk_phienbanhuongdan_chitietchinhsuadoan1_idx` (`MaDA`,`MaGV`,`ThoiGian`);

--
-- Chỉ mục cho bảng `sinhvien`
--
ALTER TABLE `sinhvien`
  ADD PRIMARY KEY (`MaSV`),
  ADD UNIQUE KEY `email_UNIQUE` (`Email`),
  ADD KEY `fk_sinh_vien_tai_khoan1_idx` (`MaTK`),
  ADD KEY `fk_sinhvien_lop1_idx` (`MaLop`);

--
-- Chỉ mục cho bảng `taikhoan`
--
ALTER TABLE `taikhoan`
  ADD PRIMARY KEY (`MaTK`),
  ADD UNIQUE KEY `ID_UNIQUE` (`MaTK`);

--
-- Chỉ mục cho bảng `tieuban`
--
ALTER TABLE `tieuban`
  ADD PRIMARY KEY (`MaTB`),
  ADD KEY `fk_tieuban_nganh1_idx` (`MaNganh`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `baocao`
--
ALTER TABLE `baocao`
  MODIFY `MaBC` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `hoidong`
--
ALTER TABLE `hoidong`
  MODIFY `MaHD` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `phienbanhuongdan`
--
ALTER TABLE `phienbanhuongdan`
  MODIFY `MaCT` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `chamdiemhd-pb`
--
ALTER TABLE `chamdiemhd-pb`
  ADD CONSTRAINT `fk_cham_diem_hd_pb_giang_vien1` FOREIGN KEY (`MaGV`) REFERENCES `nhanvien` (`MaNV`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_chamdiemhd-pb_phancongdoan1` FOREIGN KEY (`MaPhanCong`) REFERENCES `phancongdoan` (`MaPhanCong`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `chamdiemtb`
--
ALTER TABLE `chamdiemtb`
  ADD CONSTRAINT `fk_chamdiemtb_phancongdoan1` FOREIGN KEY (`MaPhanCong`) REFERENCES `phancongdoan` (`MaPhanCong`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_de_tai_has_PHAN_CONG_GV_TB_PHAN_CONG_GV_TB` FOREIGN KEY (`MaGV`,`MaTB`) REFERENCES `phanconggvtb` (`MaGV`, `MaTB`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `chitietchinhsuadoan`
--
ALTER TABLE `chitietchinhsuadoan`
  ADD CONSTRAINT `fk_doan_has_nhanvien_doan1` FOREIGN KEY (`MaDA`) REFERENCES `doan` (`MaDA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_doan_has_nhanvien_nhanvien1` FOREIGN KEY (`MaGV`) REFERENCES `nhanvien` (`MaNV`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `chuyennganh`
--
ALTER TABLE `chuyennganh`
  ADD CONSTRAINT `fk_CHUYENNGANH_NGANH1` FOREIGN KEY (`MaNganh`) REFERENCES `nganh` (`MaNganh`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `diemsang`
--
ALTER TABLE `diemsang`
  ADD CONSTRAINT `fk_table1_nganh1` FOREIGN KEY (`MaNganh`) REFERENCES `nganh` (`MaNganh`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `doan`
--
ALTER TABLE `doan`
  ADD CONSTRAINT `fk_doan_chuyennganh1` FOREIGN KEY (`MaCN`) REFERENCES `chuyennganh` (`MaCN`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `lop`
--
ALTER TABLE `lop`
  ADD CONSTRAINT `lop_ibfk_1` FOREIGN KEY (`MaCN`) REFERENCES `chuyennganh` (`MaCN`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `nganh`
--
ALTER TABLE `nganh`
  ADD CONSTRAINT `fk_nganh_HOIDONG1` FOREIGN KEY (`MaHD`) REFERENCES `hoidong` (`MaHD`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `nhanvien`
--
ALTER TABLE `nhanvien`
  ADD CONSTRAINT `fk_giang_vien_tai_khoan1` FOREIGN KEY (`MaTK`) REFERENCES `taikhoan` (`MaTK`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_giangvien_nganh1` FOREIGN KEY (`MaNganh`) REFERENCES `nganh` (`MaNganh`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `phancongdoan`
--
ALTER TABLE `phancongdoan`
  ADD CONSTRAINT `fk_phancongdoan_baocao1` FOREIGN KEY (`MaBC`) REFERENCES `baocao` (`MaBC`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_phancongdoan_chitiethuongdan1` FOREIGN KEY (`MaCT`) REFERENCES `phienbanhuongdan` (`MaCT`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_phancongdoan_doannew1` FOREIGN KEY (`MaDA`) REFERENCES `doan` (`MaDA`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_phancongdoan_nhanvien1` FOREIGN KEY (`MaGVHD`) REFERENCES `nhanvien` (`MaNV`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_phancongdoan_nhanvien2` FOREIGN KEY (`MaGVPB`) REFERENCES `nhanvien` (`MaNV`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_phancongdoan_sinhvien1` FOREIGN KEY (`MaSV`) REFERENCES `sinhvien` (`MaSV`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `phanconggvtb`
--
ALTER TABLE `phanconggvtb`
  ADD CONSTRAINT `fk_GIANG_VIEN_has_tieu_ban_GIANG_VIEN1` FOREIGN KEY (`MaGV`) REFERENCES `nhanvien` (`MaNV`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_GIANG_VIEN_has_tieu_ban_tieu_ban1` FOREIGN KEY (`MaTB`) REFERENCES `tieuban` (`MaTB`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `phienbanhuongdan`
--
ALTER TABLE `phienbanhuongdan`
  ADD CONSTRAINT `fk_phienbanhuongdan_chitietchinhsuadoan1` FOREIGN KEY (`MaDA`,`MaGV`,`ThoiGian`) REFERENCES `chitietchinhsuadoan` (`MaDA`, `MaGV`, `ThoiGian`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `sinhvien`
--
ALTER TABLE `sinhvien`
  ADD CONSTRAINT `fk_sinh_vien_tai_khoan1` FOREIGN KEY (`MaTK`) REFERENCES `taikhoan` (`MaTK`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_sinhvien_lop1` FOREIGN KEY (`MaLop`) REFERENCES `lop` (`MaLop`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Các ràng buộc cho bảng `tieuban`
--
ALTER TABLE `tieuban`
  ADD CONSTRAINT `fk_tieuban_nganh1` FOREIGN KEY (`MaNganh`) REFERENCES `nganh` (`MaNganh`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
