const readline = require('readline');
const fs = require('fs');

module.exports = async (callback, scanner) => {
    let index = scanner.req_bundle.index;
    let Model = scanner.inleModel;
    let head_params = scanner.head_params;
    
    if (index === 'danhsachtatcadoan'){
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
        let result = await Model.InleSQL(" select MaDA, TenDA, MaGVHD, TenGV from doan da, giangvien gv where da.MaGVHD=gv.MaGV limit "+limit+" OFFSET " + page*limit);
        let count = await Model.InleSQL(" SELECT FOUND_ROWS() ;");
        callback(JSON.stringify([result, count]), 'application/json');
    }
    if (index === 'danhsachdoanhuongdan'){
        let MaGV = head_params.get('MaGV');
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
        let result = await Model.InleSQL("select sv.MaSV, TenSV, Lop, Email, MaDA, TenDA from SinhVien sv, DoAn da where sv.MaSV=da.MaSV and da.MaGVHD='"+MaGV+"' LIMIT "+limit+" OFFSET " + page*limit);
        let count = await Model.InleSQL(" SELECT FOUND_ROWS() ;");
        callback(JSON.stringify([result, count]), 'application/json');
    }
    if (index === 'dieukienthemdoan'){
        // let MaNghanh = head_params.get('MaNghanh');
        let MaGV = head_params.get('MaGV');
        let list = await Model.InleSQL("call ComboBox_CN_GV('"+MaGV+"')");
        let MaDoan = await Model.InleSQL("select auto_IDDA() AS MaDoan");
        let data = [];
        data.push(list);
        data.push(MaDoan)
        callback(JSON.stringify(data), 'application/json');
    }

    if (index === 'themdoan'){
        let MaDoan = head_params.get('MaDoan');
        let TenDoan = head_params.get('TenDoan');
        let chuyennganh = head_params.get('chuyennganh');
        let ngay = head_params.get('ngay');
        let MaGV = head_params.get('MaGV');
        let filedoc = head_params.get('filedoc');
        let infotep = head_params.get('infotep');
        
        console.log("call Add_DA('"+MaDoan+"', '"+TenDoan+"', '"+chuyennganh+"','"+MaGV+"','"+ngay+"','"+filedoc+"','"+infotep+"')")
  
        let  result1 = await Model.InleSQL("call Add_DA('"+MaDoan+"', '"+TenDoan+"', '"+chuyennganh+"','"+MaGV+"','"+ngay+"','"+filedoc+"','"+infotep+"')");
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            console.log(result1)
            callback(JSON.stringify("that bai"), 'application/json');
        }else{
            callback(JSON.stringify(result1), 'application/json');
        }
    }

    if (index === 'dieukiensuadoan'){
        let MaDoan = head_params.get('MaDoan');
        let MaGV = head_params.get('MaGV');

        console.log("call shonInfor_DA_Update('"+MaDoan+"', '"+MaGV+"');")
        let  data = await Model.InleSQL("call shonInfor_DA_Update('"+MaDoan+"', '"+MaGV+"');");
        callback(JSON.stringify(data), 'application/json');
    }

    if (index === 'suadoan'){
        let MaDoan = head_params.get('MaDoan');
        let TenDoan = head_params.get('TenDoan');
        let chuyennganh = head_params.get('chuyennganh');
        let ngay = head_params.get('ngay') ;
        let MaGV = head_params.get('MaGV');
        let filedoc = head_params.get('filedoc');
        let infotep = head_params.get('infotep');
        let NUMBERFILE = head_params.get('NUMBERFILE');
        let ischangefile = head_params.get('ischangefile');

        if(String(ischangefile) !== 'x'){ 
            await Model.InleSQL("call DELETE_FileHD("+NUMBERFILE+")");
            console.log("call DELETE_FileHD("+NUMBERFILE+")")
        }
        console.log("call Update_DAFull('"+MaDoan+"', '"+TenDoan+"', '"+chuyennganh+"','"+MaGV+"','"+ngay+"','"+infotep+"','"+filedoc+"')")
        let  result1 = await Model.InleSQL("call Update_DAFull('"+MaDoan+"', '"+TenDoan+"', '"+chuyennganh+"','"+MaGV+"','"+ngay+"','"+infotep+"','"+filedoc+"')");
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            console.log(result1)
            callback(JSON.stringify("that bai"), 'application/json');
        }else{
            callback(JSON.stringify(result1), 'application/json');
        }
    }

    if (index === 'xoadoan'){
        let MaDoan = head_params.get('MaDoan');

        let  result1 = await Model.InleSQL("call Delete_DA('"+MaDoan+"')");
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            callback(JSON.stringify("that bai"), 'application/json');
        }else{
            callback(JSON.stringify(result1), 'application/json');
        }
        
    }


    if (index === 'danhsachdoan-data'){

        let MaGV = String(head_params.get('MaGV')).trim();
        let MaChuyennganh = String(head_params.get('MaChuyennganh')).trim();
        let textsearch = String(head_params.get('textsearch'));
        
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;

        let listChuyennganh;
        let MaChuyennganhtemp;

        listChuyennganh = await Model.InleSQL("call ComboBox_CN_GV('"+MaGV+"')");
        listChuyennganh = listChuyennganh[0];

        let ishaveGV = false;

        console.log(MaChuyennganh+'xxx')

    if(MaChuyennganh === '' || String(MaChuyennganh) === 'null'){

        lineReader = readline.createInterface({
            input: fs.createReadStream('controller/qldean/Text/TeacherStatus.txt')
        });
        lineReader.on('line', function (line) {
            if(String(line).includes(MaGV)) {
                ishaveGV = true;
                MaChuyennganhtemp = String(line.split(',')[1]);
            }
        });
        lineReader.on('close', async function () {
            console.log(MaChuyennganhtemp);
            if(ishaveGV == true){
                if(MaChuyennganhtemp === '#'){
                    MaChuyennganh = listChuyennganh[0].MaCN;
                
                    fs.readFile("controller/qldean/Text/TeacherStatus.txt", 'utf8', function (err,data) {
                        let formatted = data.replace( String(MaGV+','+MaChuyennganhtemp),String(MaGV+','+MaChuyennganh));
                        fs.writeFile("controller/qldean/Text/TeacherStatus.txt", '', 'utf8', function (err) {
                            if (err) return console.log(err);
                            fs.writeFile("controller/qldean/Text/TeacherStatus.txt", formatted, 'utf8', function (err) {
                                if (err) return console.log(err);
                            });
                        });
                    });

                }else{
                    MaChuyennganh = MaChuyennganhtemp;
                }
            }else{
                MaChuyennganh = listChuyennganh[0].MaCN;
                fs.appendFile("controller/qldean/Text/TeacherStatus.txt", String(MaGV+','+MaChuyennganh+','), function (err) {
                    if (err) return console.log(err);
                  })
            }

            let count = await Model.InleSQL("SELECT CountList_DAofGV('"+MaGV+"','"+MaChuyennganh+"','"+textsearch+"') AS Number;");
            let select = await Model.InleSQL("call ShowList_DAofGV('"+MaGV+"','"+MaChuyennganh+"','"+textsearch+"',"+limit*page+");");
            console.log("SELECT CountList_DAofGV('"+MaGV+"','"+MaChuyennganh+"')")

            let data = [];
            data.push(listChuyennganh);
            data.push(MaChuyennganh);
            data.push(count)
            data.push(select)
            callback(JSON.stringify(data), 'application/json');
        });

    }else{

        lineReader = readline.createInterface({
            input: fs.createReadStream('controller/qldean/Text/TeacherStatus.txt')
        });
        lineReader.on('line', function (line) {
            if(String(line).includes(MaGV)) {
                MaChuyennganhtemp = String(line.split(',')[1]).trim();
            }
        });
        
        lineReader.on('close', async function () {

            fs.readFile("controller/qldean/Text/TeacherStatus.txt", 'utf8', function (err,data) {
                let formatted = data.replace(  String(MaGV+','+MaChuyennganhtemp),String(MaGV+','+MaChuyennganh));
                fs.writeFile("controller/qldean/Text/TeacherStatus.txt", '', 'utf8', function (err) {
                    if (err) return console.log(err);
                    fs.writeFile("controller/qldean/Text/TeacherStatus.txt", formatted, 'utf8', function (err) {
                        if (err) return console.log(err);
                    });
                });
            });

            console.log("SELECT CountList_DAofGV('"+MaGV+"','"+MaChuyennganh+"') AS Number;")
            let count = await Model.InleSQL("SELECT CountList_DAofGV('"+MaGV+"','"+MaChuyennganh+"','"+textsearch+"') AS Number;");
            let select = await Model.InleSQL("call ShowList_DAofGV('"+MaGV+"','"+MaChuyennganh+"','"+textsearch+"',"+limit*page+");");

            let data = [];
            data.push(listChuyennganh);
            data.push(MaChuyennganh);
            data.push(count);
            data.push(select);

            callback(JSON.stringify(data), 'application/json');
        });
    }
    }


    if (index === 'danhsachdoan-canhan'){

        let MaGV = String(head_params.get('MaGV')).trim();
        let MaChuyennganh = String(head_params.get('MaChuyennganh')).trim();
        let textsearch = String(head_params.get('textsearch'));
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;

        let MaChuyennganhtemp;

        lineReader = readline.createInterface({
            input: fs.createReadStream('controller/qldean/Text/TeacherStatus.txt')
        });
        lineReader.on('line', function (line) {
            if(String(line).includes(MaGV)) {
                MaChuyennganhtemp = String(line.split(',')[1]).trim();
            }
        });
        
        lineReader.on('close', async function () {

            fs.readFile("controller/qldean/Text/TeacherStatus.txt", 'utf8', function (err,data) {
                let formatted = data.replace(  String(MaGV+','+MaChuyennganhtemp),String(MaGV+','+MaChuyennganh));
                fs.writeFile("controller/qldean/Text/TeacherStatus.txt", '', 'utf8', function (err) {
                    if (err) return console.log(err);
                    fs.writeFile("controller/qldean/Text/TeacherStatus.txt", formatted, 'utf8', function (err) {
                        if (err) return console.log(err);
                    });
                });
            });

            let count = await Model.InleSQL("SELECT CountList_DAofGV('"+MaGV+"','"+MaChuyennganh+"','"+textsearch+"') AS Number;");
            let select = await Model.InleSQL("call ShowList_DAofGV('"+MaGV+"','"+MaChuyennganh+"','"+textsearch+"',"+limit*page+");");
    
            let data = [];
            data.push(count);
            data.push(select);
    
            callback(JSON.stringify(data), 'application/json');
        });




    }

    if (index === 'danhsachdoan-tatca'){

        let MaGV = String(head_params.get('MaGV')).trim();
        let MaChuyennganh = String(head_params.get('MaChuyennganh')).trim();
        let textsearch = String(head_params.get('textsearch'));
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;


        let MaChuyennganhtemp;

        lineReader = readline.createInterface({
            input: fs.createReadStream('controller/qldean/Text/TeacherStatus.txt')
        });
        lineReader.on('line', function (line) {
            if(String(line).includes(MaGV)) {
                MaChuyennganhtemp = String(line.split(',')[1]).trim();
            }
        });

        lineReader.on('close', async function () {

            fs.readFile("controller/qldean/Text/TeacherStatus.txt", 'utf8', function (err,data) {
                let formatted = data.replace(  String(MaGV+','+MaChuyennganhtemp),String(MaGV+','+MaChuyennganh));
                fs.writeFile("controller/qldean/Text/TeacherStatus.txt", '', 'utf8', function (err) {
                    if (err) return console.log(err);
                    fs.writeFile("controller/qldean/Text/TeacherStatus.txt", formatted, 'utf8', function (err) {
                        if (err) return console.log(err);
                    });
                });
            });

            let count = await Model.InleSQL("select CountList_DA('"+MaChuyennganh+"','"+textsearch+"') AS Number;");
            let select = await Model.InleSQL("call ShowList_DA('"+MaChuyennganh+"','"+textsearch+"',"+limit*page+");");
    
            let data = [];
            data.push(count);
            data.push(select);
    
            callback(JSON.stringify(data), 'application/json');

        });
    }

    if(index === 'danhsachtailieu'){
        let MaGV = String(head_params.get('MaGV')).trim();
        let MaDoan = String(head_params.get('MaDoan')).trim();
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;

        let check =  await Model.InleSQL("select TrangThai_UpTaiLieuHDCaNhan('"+MaDoan+"', '"+MaGV+"') AS Checkx;");
        let count = await Model.InleSQL("select CountList_Files('"+MaDoan+"', '"+MaGV+"') AS Number;");
        let select = await Model.InleSQL("call ShowList_Files('"+MaDoan+"', '"+MaGV+"','',"+limit*page+")");
        console.log("select TrangThai_UpTaiLieuHDCaNhan('"+MaDoan+"', '"+MaGV+"')")
        let data = [];
        data.push(count);
        data.push(select);
        data.push(check);

        callback(JSON.stringify(data), 'application/json');
    }


    if(index === 'firstload-phancong-tailieu'){
        let MaGV = String(head_params.get('MaGV')).trim();
        let MaDoan = String(head_params.get('MaDoan')).trim();
        let MaCT = String(head_params.get('MaCT')).trim();
        let MaCN = String(head_params.get('MaCN')).trim();


        let select1 = await Model.InleSQL("call ShowInfor_DA('"+MaGV+"','"+MaDoan+"',"+MaCT+");");
        let select2 = await Model.InleSQL("call ComboBox_SV('"+MaGV+"','"+MaCN+"');");
        console.log("call ComboBox_SV('"+MaGV+"','"+MaCN+"')")
        console.log("call ShowInfor_DA('"+MaGV+"','"+MaDoan+"',"+MaCT+");")
        
        console.log(select1)
        // let select = await Model.InleSQL("call ShowList_Files('"+MaDoan+"', '"+MaGV+"',"+limit*page+")");

        let data = [];

        data.push(select1);
        data.push(select2);

        callback(JSON.stringify(data), 'application/json');
    }

    if(index === 'infosv-phancong-tailieu'){
        let MaSV = String(head_params.get('MaSV')).trim();
        let select1 = await Model.InleSQL("call ShowInfor_SV('"+MaSV+"')");

        let data = [];
        data.push(select1);
        callback(JSON.stringify(data), 'application/json');
    }
    if(index === 'check-phancong-tailieu'){
        let MaSV = head_params.get('MaSV');
        let  result = await Model.InleSQL("select count(*) as dem  from phancongdoan where MaSV ='"+MaSV+"';");
        callback(JSON.stringify(result), 'application/json');
    }

    if(index === 'add-phancong-tailieu'){
        let MaDoan = head_params.get('MaDoan');
        let MaGV = head_params.get('MaGV');
        let MaSV = head_params.get('MaSV');
        let MaCT = head_params.get('MaCT');

        let  result1 = await Model.InleSQL("call PhanCong_DA('"+MaGV+"','"+MaSV+"','"+MaDoan+"',"+MaCT+")");
        console.log("call PhanCong_DA('"+MaGV+"','"+MaSV+"','"+MaDoan+"',"+MaCT+")")
        console.log(result1)
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }

    if(index === 'danhsach-chamdiem-huongdan'){
        let textsearch = head_params.get('textsearch');
        let MaGV = head_params.get('MaGV');
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
        let result = await Model.InleSQL("call ShowList_SVHD_GV('"+MaGV+"','"+textsearch+"',"+page*limit+");");
        let count = await Model.InleSQL("select CountList_SVHD_GV('"+MaGV+"','"+textsearch+"') AS Number");
        callback(JSON.stringify([result, count]), 'application/json');
    }
    if(index === 'loadChamdiemhuongdan'){
        let MaDoan = head_params.get('MaDoan');
        let MaPC = head_params.get('MaPC');
        let MaGV = head_params.get('MaGV');
        let MaSV = head_params.get('MaSV');
        let MaCT = head_params.get('MaCT');

        let result = await Model.InleSQL("call ShowInfor_SVHD('"+MaSV+"')");
        let result1 = await Model.InleSQL("call ShowInfor_DA('"+MaGV+"','"+MaDoan+"',"+MaCT+");"); 
        let result2 = await Model.InleSQL("call ShowFullDiem('"+MaSV+"');"); 
        let result3 = await Model.InleSQL("call ShowFile_BaoCao('"+MaPC+"');");
        
        console.log("call ShowFullDiem('"+MaSV+"');")

        let data = [];
        data.push(result);
        data.push(result1);
        data.push(result2);
        data.push(result3);
        callback(JSON.stringify(data), 'application/json');
    }
    if(index === 'chamDiemHuongdan'){
        let DiemCham = head_params.get('DiemCham');
        let MaPC = head_params.get('MaPC');
        let MaGV = head_params.get('MaGV');

        let result1 = await Model.InleSQL("call ChamDiem_HD('"+MaPC+"', '"+MaGV+"',"+DiemCham+");");
        console.log("call ChamDiem_HD('"+MaPC+"', '"+MaGV+"',"+DiemCham+");")
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            callback(JSON.stringify("that bai"), 'application/json');
        }else{
            callback(JSON.stringify(result1), 'application/json');
        }
    }

    if(index === 'danhsach-chamdiem-phanbien'){
        let textsearch = head_params.get('textsearch');
        let MaGV = head_params.get('MaGV');
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
        let result = await Model.InleSQL("call ShowList_SVPB_GV('"+MaGV+"','"+textsearch+"',"+page*limit+");");
        let count = await Model.InleSQL("select CountList_SVPB_GV('"+MaGV+"','"+textsearch+"') AS Number");
        callback(JSON.stringify([result, count]), 'application/json');
    }
    if(index === 'loadChamdiemphanbien'){
        let MaDoan = head_params.get('MaDoan');
        let MaPC = head_params.get('MaPC');
        let MaGV = head_params.get('MaGV');
        let MaSV = head_params.get('MaSV');
        let MaCT = head_params.get('MaCT');

        let result = await Model.InleSQL("call ShowInfor_SVPB('"+MaSV+"')");
        let result1 = await Model.InleSQL("call ShowInfor_DA('"+MaGV+"','"+MaDoan+"',"+MaCT+");"); 
        let result2 = await Model.InleSQL("call ShowFullDiem('"+MaSV+"');"); 
        let result3 = await Model.InleSQL("call ShowFile_BaoCao('"+MaPC+"');"); 

        console.log("call ShowInfor_DA('"+MaGV+"','"+MaDoan+"',"+MaCT+");")

        let data = [];
        data.push(result);
        data.push(result1);
        data.push(result2);
        data.push(result3);
        callback(JSON.stringify(data), 'application/json');
    }

    if(index === 'chamDiemPhanbien'){
        let DiemCham = head_params.get('DiemCham');
        let MaPC = head_params.get('MaPC');
        let MaGV = head_params.get('MaGV');

        let result1 = await Model.InleSQL("call ChamDiem_PB('"+MaPC+"', '"+MaGV+"',"+DiemCham+");");
        console.log("call ChamDiem_PB('"+MaPC+"', '"+MaGV+"',"+DiemCham+");")
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            callback(JSON.stringify("that bai"), 'application/json');
        }else{
            callback(JSON.stringify(result1), 'application/json');
        }
    }

    if(index === 'danhsachtieubanphancong'){
        let textsearch = head_params.get('textsearch');
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
        let MaGV = head_params.get('MaGV');

        let count = await Model.InleSQL("SELECT CountList_TB_GV('"+MaGV+"','"+textsearch+"') AS Number;");
        let select = await Model.InleSQL("call ShowList_TB_GV('"+MaGV+"','"+textsearch+"', "+page*limit+");");

        let data = [];
        data.push(count);
        data.push(select);
        callback(JSON.stringify(data), 'application/json');
    }
    if(index === 'danhsach-chamdiem-tieuban'){
        let textsearch = head_params.get('textsearch');
        let MaTB = head_params.get('MaTB');
        let MaGV = head_params.get('MaGV');
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
        let result = await Model.InleSQL("call ShowList_SVTB_GV('"+MaGV+"','"+MaTB+"','"+textsearch+"',"+page*limit+");");
        let count = await Model.InleSQL("select CountList_SVTB_GV('"+MaGV+"','"+MaTB+"','"+textsearch+"') AS Number");
        callback(JSON.stringify([result, count]), 'application/json');
    }
    if(index === 'loadChamdiemtieuban'){
        let MaDoan = head_params.get('MaDoan');
        let MaPC = head_params.get('MaPC');
        let MaGV = head_params.get('MaGV');
        let MaSV = head_params.get('MaSV');
        let MaCT = head_params.get('MaCT');

        let result = await Model.InleSQL("call ShowInfor_SVTB('"+MaSV+"')");
        let result1 = await Model.InleSQL("call ShowInfor_DA('"+MaGV+"','"+MaDoan+"',"+MaCT+");"); 
        let result2 = await Model.InleSQL("call ShowFullDiem('"+MaSV+"');"); 
        let result3 = await Model.InleSQL("call ShowFile_BaoCao('"+MaPC+"');"); 
        let result4 = await Model.InleSQL("call ShowDiem('"+MaPC+"', '"+MaGV+"')"); 
       

        console.log("call ShowInfor_SVTB('"+MaSV+"')");

        let data = [];
        data.push(result);
        data.push(result1);
        data.push(result2);
        data.push(result3);
        data.push(result4);
        callback(JSON.stringify(data), 'application/json');
    }
    if(index === 'chamDiemTieuban'){
        let DiemCham = head_params.get('DiemCham');
        let MaPC = head_params.get('MaPC');
        let MaGV = head_params.get('MaGV');
        let MaTB = head_params.get('MaTB');

        let result1 = await Model.InleSQL("call ChamDiem_TB('"+MaPC+"', '"+MaTB+"', '"+MaGV+"',"+DiemCham+");");
        console.log("call ChamDiem_TB('"+MaPC+"', '"+MaTB+"', '"+MaGV+"',"+DiemCham+");");
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            callback(JSON.stringify("that bai"), 'application/json');
        }else{
            callback(JSON.stringify(result1), 'application/json');
        }
    }

    if(index === 'IsExitFileHD'){
        let MaGV = head_params.get('MaGV');
        let MaDA = head_params.get('MaDA');

        let result = await Model.InleSQL("SELECT IsExitFileHD('"+MaDA+"', '"+MaGV+"') AS Number;"); 
        console.log("SELECT IsExitFileHD('"+MaDA+"', '"+MaGV+"');");

        let data = [];
        data.push(result);
        callback(JSON.stringify(data), 'application/json');
    }
}