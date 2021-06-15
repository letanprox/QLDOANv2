const fs = require('fs');
const readline = require('readline');

module.exports = async (callback, scanner) => {
    let index = scanner.req_bundle.index;
    let Model = scanner.inleModel;
    let head_params = scanner.head_params;


    if (index === 'danhsachtieuban'){
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
        let count = await Model.InleSQL("select count(*) from tieuban;");
        let result = await Model.InleSQL("select maTB, ngay, gio, sum(total) sum from ( select maTB, ngay, gio, count(maTB) as total from (SELECT tb.MaTB, tb.ngay, tb.gio FROM tieuban tb INNER JOIN phanconggvtb pc ON tb.MaTB = pc.MaTB) as ListTB group by maTB union select maTB, ngay, gio,0 from tieuban group by maTB ) tmp group by (tmp.maTB) limit "+limit+" offset "+page*limit+";");
        let data = [];
        data.push(result);
        data.push(count);
        callback(JSON.stringify(data), 'application/json');
    }

    if (index === 'dieukienthemtb'){
        let result = await Model.InleSQL("select AUTO_IDTB();");
        callback(JSON.stringify(result), 'application/json');
    }

    if (index === 'themtb'){
        let gio = head_params.get('gio');
        let ngay = head_params.get('ngay');
        gio = gio + ":00"
        let  result1 = await Model.InleSQL("insert into TieuBan(maTB, ngay, gio) values('', '"+ngay+"', '"+gio+"');");
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }
    if (index === 'suatb'){
        let maTB = head_params.get('maTB');
        let gio = head_params.get('gio');
        let ngay = head_params.get('ngay');
        gio = gio + ":00";
        
        let result1 = await Model.InleSQL("UPDATE `tieuban` SET `ngay` = '"+ngay+"' ,  `gio` = '"+gio+"' WHERE `tieuban`.`maTB` = '"+maTB+"'");
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }
    if (index === 'xoatb'){
        let maTB = head_params.get('maTB');
        console.log("delete from tieuban where MaTB='" + maTB+"'")
        let  result1 = await Model.InleSQL("delete from phanconggvtb where MaTB='" + maTB+"'");
        result1 = await Model.InleSQL("delete from tieuban where MaTB='" + maTB+"'");
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }
    if (index === 'timmatb'){
        // let matieuban = head_params.get('matieuban');  
        // let  result1 = await Model.InleSQL("SELECT * FROM `tieu_ban` JOIN hoi_dong ON tieu_ban.maHoiDong=hoi_dong.maHoiDong WHERE `tieu_ban`.`maTieuBan` = " + matieuban );
        //     if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
        //         callback(JSON.stringify("that bai"), 'application/json');
        //     }else{
        //         callback(JSON.stringify(result1), 'application/json');
        //     }
    }
    
    if(index === 'danhsachGVphancongTB'){
        let ngay = String(head_params.get('ngay')).replace('T17:00:00.000Z','');
        let gio = head_params.get('gio');
        console.log(ngay,gio)
        let  result1 = await Model.InleSQL("select MaGV, TenGv from giangvien where MaGV not in (SELECT gv.MaGV  FROM tieuban tb, giangvien gv, phanconggvtb pc where tb.MaTB = pc.MaTB and pc.MaGV= gv.MaGV and ngay='"+ngay+"' and gio = '"+gio+"');");
        console.log(result1)    
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }

    }

    if(index === 'addGVintoTieuban'){
        let TB = head_params.get('TB');
        let GV1 = head_params.get('GV1');
        let GV2 = head_params.get('GV2');
        let GV3 = head_params.get('GV3');
        let GV4 = head_params.get('GV4');
        let GV5 = head_params.get('GV5');

        let  result1 = await Model.InleSQL("insert into phanconggvtb (MaGV, MaTB) values ('"+GV1+"', '"+TB+"')");
          result1 = await Model.InleSQL("insert into phanconggvtb (MaGV, MaTB) values ('"+GV2+"', '"+TB+"')");
          result1 = await Model.InleSQL("insert into phanconggvtb (MaGV, MaTB) values ('"+GV3+"', '"+TB+"')");
          result1 = await Model.InleSQL("insert into phanconggvtb (MaGV, MaTB) values ('"+GV4+"', '"+TB+"')");
          result1 = await Model.InleSQL("insert into phanconggvtb (MaGV, MaTB) values ('"+GV5+"', '"+TB+"')");
        console.log(result1)    
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }

    }


    
    if (index === 'dieukienthemsv'){
        let khoa = head_params.get('khoa');  
        let Id = await Model.InleSQL("select Auto_IDSV("+khoa+")");
        let Email = await Model.InleSQL("select Auto_EmailSV('"+Id[0]['Auto_IDSV('+khoa+')']+"')");

        callback(JSON.stringify({Email,Id,khoa}), 'application/json');
    }



    if (index === 'suasv'){
        let masv = head_params.get('masv');
        let tensv = head_params.get('tensv');
        let emailsv = head_params.get('emailsv');
        let matk = head_params.get('matk');
        let makhoa = head_params.get('makhoa');
        let mksv = head_params.get('mksv');
        let result1 = await Model.InleSQL("UPDATE `sinh_vien` SET `tenSV` = '"+tensv+"' ,  `email` = '"+emailsv+"' , `matKhau` = '"+mksv+"' , `maKhoa` = '"+makhoa+"' , `maTaiKhoan` = '"+matk+"'  WHERE `sinh_vien`.`maSV` = "+masv);
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }

    if (index === 'xoasv'){
        let masv = head_params.get('masv');
        let  result1 = await Model.InleSQL("DELETE FROM `sinh_vien` WHERE `sinh_vien`.`maSV` = " + masv);
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }

    if (index === 'timmasv'){
        let masv = head_params.get('masv');  
        let  result1 = await Model.InleSQL("SELECT * FROM `sinh_vien` WHERE `sinh_vien`.`maSV` = " + masv);
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }









    if (index === 'danhsachgiangvien'){
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
        console.log(page)
        let count = await Model.InleSQL("select count( maGV) from GiangVien");
        let result = await Model.InleSQL("select MaGV, TenGV, ngaysinh, email from GiangVien limit " +limit+ " offset " + page*limit);
        console.log("select MaGV, TenGV, NgaySinh, Lop, Email from GiangVien limit " +limit+ " offset " + page*limit)
        let data = [];
        data.push(result)
        data.push(count)
        console.log(data)
        callback(JSON.stringify(data), 'application/json');
    }

    if (index === 'dieukienthemgv'){  
        let Id = await Model.InleSQL("select AUTO_IDGV();");
        callback(JSON.stringify(Id), 'application/json');
    }

    if (index === 'themgv'){
        let MaGV = head_params.get('MaGV');
        let TenGV = head_params.get('TenGV');
        let email = head_params.get('email');
        let ngaySinh = head_params.get('ngaySinh');

        console.log("INSERT INTO `giangvien` (`MaGV`, `TenGV`, `email`, `ngaySinh`) "+
        "VALUES ('"+MaGV+"','"+TenGV+"','"+email+"', '"+ngaySinh+"')")

        let  result1 = await Model.InleSQL("INSERT INTO `giangvien` (`MaGV`, `TenGV`, `email`, `ngaySinh`) "+
        "VALUES ('"+MaGV+"','"+TenGV+"','"+email+"', '"+ngaySinh+"')");
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{

                await Model.InleSQL("call AfterInsert_GV");
                
                callback(JSON.stringify(result1), 'application/json');
            }
    }

    if (index === 'suagv'){
        let MaGV = head_params.get('MaGV');
        let TenGV = head_params.get('TenGV');
        let email = head_params.get('email');
        let ngaySinh = head_params.get('ngaySinh');
        console.log("UPDATE `giangvien` SET `TenGV` = '"+TenGV+"' ,  `ngaySinh` = '"+ngaySinh+"' , `email` = '"+email+"' WHERE `giangvien`.`MaGV` = "+MaGV)
        let result1 = await Model.InleSQL("UPDATE `giangvien` SET `TenGV` = '"+TenGV+"' ,  `ngaySinh` = '"+ngaySinh+"' , `email` = '"+email+"' WHERE `giangvien`.`MaGV` =  '"+MaGV+"'");
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }



    if (index === 'xoagv'){

        let MaGV = head_params.get('MaGV');
        let  result1 = await Model.InleSQL('delete from GiangVien where MaGV= "'+MaGV+'"');
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }

    if (index === 'timmagv'){

    }



    if(index === 'danhsachphancongHD'){
        let limit = 10;
        let GPA = Number(head_params.get('GPA'));
        let page = Number(head_params.get('page')) - 1;
    
        await Model.InleSQL("call Create_TKforSV( "+GPA+");");
        let count = await Model.InleSQL("select count(*) from DoAn da where da.MaGVPB is  null;")
        let result = await Model.InleSQL("select sv.MaSV, sv.TenSV, sv.NgaySinh, sv.Lop, da.TenDA,da.MaGVHD, sv.GPA from SinhVien sv, DoAn da where  sv.MaSV=da.MaSV and GPA>= "+GPA+" and da.MaGVPB is null limit " +limit+ " OFFSET " + page*limit);

        let data = [];
        data.push(result)
        data.push(count)
        console.log(data)
        callback(JSON.stringify(data), 'application/json');
    }
    if(index === 'danhsachGVHDphancong'){
        let MaSV = String(head_params.get('MaSV'));
        console.log(MaSV)
        let result = await Model.InleSQL("select sv.MaSV, sv.TenSV, da.MaDA, da.TenDA from SinhVien sv, DoAn da where sv.MASV=da.MaSV and sv.MASV='"+MaSV+"'");
        let result1 =  await Model.InleSQL("select MaGV, TenGV from giangvien ");
        let data = [];
        data.push(result)
        data.push(result1)
        console.log(data)
        callback(JSON.stringify(data), 'application/json');
    }

    if(index === 'addGVHDphancong'){
        let MaGVHD = String(head_params.get('MaGVHD'));
        let MaDA = String(head_params.get('MaDA'));
        console.log(MaGVHD,MaDA)
        let  result1 = await Model.InleSQL('update doan set MaGVHD="'+MaGVHD+'" where maDA="'+MaDA+'"');
                       await Model.InleSQL("insert into `chamdiemhd-pb`(MaDA, MaGV) values ('"+MaDA+"', '"+MaGVHD+"')")
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }



    if(index == 'danhsachphancongPB'){
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
    
        let count = await Model.InleSQL("select count(*) from DoAn da, `chamdiemhd-pb` cd where da.MaDA=cd.MaDA and (da.MaGVHD=cd.MaGV and diem>=4) and	not exists(select MaDA from chamdiemtb where MaDA=da.MaDA)")
        let result = await Model.InleSQL("select sv.MaSV, sv.TenSV, sv.Lop, da.MaDA, sv.GPA, da.MaGVPB, cd.diem from SinhVien sv, DoAn da, `chamdiemhd-pb` cd where  sv.MaSV=da.MaSV and da.MaDA=cd.MaDA  and (da.MaGVHD=cd.MaGV and diem>=4) and	not exists(select MaDA from chamdiemtb where MaDA=da.MaDA)  limit " +limit+ " OFFSET " + page*limit);

        let data = [];
        data.push(result)
        data.push(count)

        console.log(data)
        callback(JSON.stringify(data), 'application/json');
    }

    if(index === 'danhsachGVPBphancong'){
        let MaSV = String(head_params.get('MaSV'));
        let MaDA = String(head_params.get('MaDA'));
        console.log("Xxx");
        console.log(MaSV,MaDA);
        let result = await Model.InleSQL("select sv.MaSV, sv.TenSV, da.MaDA, da.TenDA, da.MaGVHD, gv.TenGV from SinhVien sv, DoAn da, GiangVien gv where sv.MASV=da.MaSV and da.MaGVHD=gv.MaGV and sv.MASV='"+MaSV+"'");
        let result1 =  await Model.InleSQL("select MaGV, TenGV from giangvien where MaGV <> (select MaGVHD from doan where MaDA='"+MaDA+"')");
        let data = [];
        data.push(result)
        data.push(result1)
        console.log(data)
        callback(JSON.stringify(data), 'application/json');
    }


    if(index === 'addGVPBphancong'){
        let MaGVPB = String(head_params.get('MaGVPB'));
        let MaDA = String(head_params.get('MaDA'));

        let  result1 = await Model.InleSQL('update doan set MaGVPB="'+MaGVPB+'" where maDA="'+MaDA+'"');
                        await Model.InleSQL("insert into `chamdiemhd-pb`(MaDA, MaGV) values ('"+MaDA+"', '"+MaGVPB+"')")
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }


    if(index == 'danhsachphancongTB'){
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
        
        let result = await Model.InleSQL("call List_PhanCongTB("+page*limit+");");
        let count = await Model.InleSQL("SELECT FOUND_ROWS() ;")

        let data = [];
        data.push(result)
        data.push(count)

        console.log(data)
        callback(JSON.stringify(data), 'application/json');
    }

    if(index === 'danhsachTBphancong'){
        let MaSV = String(head_params.get('MaSV'));
        // let MaDA = String(head_params.get('MaDA'));
        console.log("Xxx")
        // console.log(MaSV,MaDA)
        let result = await Model.InleSQL("select sv.MaSV, sv.TenSV, da.MaDA, da.TenDA, da.MaGVHD, gv.TenGV, da.MaGVPB, gv2.TenGV from SinhVien sv, DoAn da, GiangVien gv, Doan da2, GiangVien gv2 where sv.MASV=da.MaSV and da.MaGVHD=gv.MaGV and sv.MASV=da2.MaSV and da2.MaGVPB=gv2.MaGV and sv.MASV ='"+MaSV+"'");
        let result1 =  await Model.InleSQL("select tmp.MaTB from (select MaTB, count(MaTB) total from phanconggvtb group by MaTB) tmp where tmp.total=5");
        let data = [];
        data.push(result)
        data.push(result1)
        console.log(data)
        callback(JSON.stringify(data), 'application/json');
    }

    if(index === 'addTBphancong'){
        let MaTB = String(head_params.get('MaTB'));
        let MaDA = String(head_params.get('MaDA'));

        let  result1 = await Model.InleSQL("insert into chamdiemtb(MaDA,MaGVTB,MaTB) select '"+MaDA+"', MaGV, MaTB from phanconggvtb where MaTB='"+MaTB+"'");
                        // await Model.InleSQL("insert into `chamdiemhd-pb`(MaDA, MaGV) values ('"+MaDA+"', '"+MaGVPB+"')")
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }
}


const bubbleSort = (array) => {
    for (let i = 0; i < array.length; i++) {
      for (let x = 0; x < array.length - 1 - i; x++) {
        if (array[x] > array[x + 1]) {
          [array[x], array[x + 1]] = [array[x + 1], array[x]];
        }
      }
    }
    return array;
  }