const fs = require('fs');
const readline = require('readline');
const bubbleSort = (array) => {
    for (let i = 0; i < array.length; i++) {
      for (let x = 0; x < array.length - 1 - i; x++) {
        if (array[x] < array[x + 1]) {
          [array[x], array[x + 1]] = [array[x + 1], array[x]];
        }
      }
    }
    return array;
  }

module.exports = async (callback, scanner) => {
    let index = scanner.req_bundle.index;
    let Model = scanner.inleModel;
    let head_params = scanner.head_params;


    if (index === 'dieukienthemsv'){
        let MaNghanh = head_params.get('MaNghanh');
        let Khoa = head_params.get('Khoa');
        let MaAdmin = String(head_params.get('MaAdmin')).trim();

        let MaNghanhtemp;
        let Khoatemp;

        listNganh = await Model.InleSQL("call ComboBox_Nganh()");
        listNganh = listNganh[0];

        lineReader = readline.createInterface({
            input: fs.createReadStream('controller/qldean/Text/AdminStatus.txt')
        });
        lineReader.on('line', function (line) {
            if(String(line).includes(MaAdmin)) {
                MaNghanhtemp = String(line.split(',')[1]).trim();
                Khoatemp = Number(line.split(',')[2]);
            }
        });
        lineReader.on('close', async function () {
            console.log(String(MaAdmin+','+MaNghanh+','+Khoa), String(MaAdmin+','+MaNghanhtemp+','+Khoatemp))
            fs.readFile("controller/qldean/Text/AdminStatus.txt", 'utf8', function (err,data) {
                let formatted = data.replace( String(MaAdmin+','+MaNghanhtemp+','+Khoatemp),String(MaAdmin+','+MaNghanh+','+Khoa));
                fs.writeFile("controller/qldean/Text/AdminStatus.txt", '', 'utf8', function (err) {
                    if (err) return console.log(err);
                    fs.writeFile("controller/qldean/Text/AdminStatus.txt", formatted, 'utf8', function (err) {
                        if (err) return console.log(err);
                    });
                });
            });

        });



        let MaSV = await Model.InleSQL("select AUTO_IDSV('"+Khoa+"','"+MaNghanh+"') as MaSV"); MaSV = MaSV[0]['MaSV']
        let EmailSV = MaSV + '@student.ptithcm.edu.vn';
        let listchuyenganh = await Model.InleSQL("call ComboBox_CN('"+MaNghanh+"')");listchuyenganh = listchuyenganh[0];
        let listlop;
        let Lop;
        if(listchuyenganh.length > 0){
            console.log("call ComboBox_Lop('"+Khoa+"','"+listchuyenganh[0].MaCN+"')")
            listlop = await Model.InleSQL("call ComboBox_Lop('"+Khoa+"','"+listchuyenganh[0].MaCN+"')"); listlop = listlop[0]
            Lop = await Model.InleSQL("SELECT Auto_IDLop('"+Khoa+"','"+listchuyenganh[0].MaCN+"') AS Lop"); Lop = Lop[0]['Lop'];
        }else{
            listlop = [];
            Lop = '';
        }
        let data = [];
        data.push(MaSV);
        data.push(EmailSV)
        data.push(listchuyenganh)
        data.push(listlop);
        data.push(Lop);
        callback(JSON.stringify(data), 'application/json');
    }

    if(index === 'dieukiensuasv'){
        let MaNghanh = head_params.get('MaNghanh');
        let Khoa = head_params.get('Khoa');
        let MaChuyenNghanh = String(head_params.get('MaChuyenNghanh'));
        let MaSV = String(head_params.get('MaSV'));
        
        console.log("select count(*) into @dem from phancongdoan where MaSV='"+MaSV+"'")
        let countchek = await Model.InleSQL("select count(*) AS checkCount from phancongdoan where MaSV='"+MaSV+"'");
        let listchuyenganh = await Model.InleSQL("call ComboBox_CN('"+MaNghanh+"')");listchuyenganh = listchuyenganh[0];
        let listlop;
        let Lop;
        if(listchuyenganh.length > 0){
            console.log("call ComboBox_Lop('"+Khoa+"','"+MaChuyenNghanh+"')")
            listlop = await Model.InleSQL("call ComboBox_Lop('"+Khoa+"','"+MaChuyenNghanh+"')"); listlop = listlop[0]
            Lop = await Model.InleSQL("SELECT Auto_IDLop('"+Khoa+"','"+MaChuyenNghanh+"') AS Lop"); Lop = Lop[0]['Lop'];
        }else{
            listlop = [];
            Lop = '';
        }
        let data = [];
        data.push(listchuyenganh);
        data.push(listlop);
        data.push(countchek);
        data.push(Lop);
        callback(JSON.stringify(data), 'application/json');
    }

    if(index === 'danhsach-theo-nghanh'){
        let MaNghanh = head_params.get('MaNghanh');
        let listchuyenganh = await Model.InleSQL("call ComboBox_CN('"+MaNghanh+"')");
        let data = [];
        data.push(listchuyenganh[0]);
        callback(JSON.stringify(data), 'application/json');
    }
    if(index === 'danhsach-theo-nganhvakhoa'){
        let Khoa = head_params.get('Khoa');
        let MaNghanh = head_params.get('MaNghanh');
        let MaSV = await Model.InleSQL("select AUTO_IDSV('"+Khoa+"','"+MaNghanh+"') as MaSV");
        MaSV = MaSV[0]['MaSV']
        let EmailSV = MaSV + '@student.ptithcm.edu.vn';
        let data = [];
        data.push({MaSV:MaSV,EmailSV:EmailSV});
        callback(JSON.stringify(data), 'application/json');
    }
    if(index === 'danhsach-theo-chuyennganhvakhoa'){
        let Khoa = head_params.get('Khoa');
        let MaChuyenNghanh = head_params.get('MaChuyenNghanh');
        let data = [];
        let listlop = await Model.InleSQL("call ComboBox_Lop('"+Khoa+"','"+MaChuyenNghanh+"')");
        console.log(listlop)
        data.push(listlop[0]);
        callback(JSON.stringify(data), 'application/json');
    }
    if(index === 'taomoilop'){
        let Khoa = head_params.get('Khoa');
        let MaChuyenNghanh = head_params.get('MaChuyenNghanh');
        let data = [];
        let Lop = await Model.InleSQL("SELECT Auto_IDLop('"+Khoa+"','"+MaChuyenNghanh+"') AS Lop");
        data.push(Lop[0]['Lop']);
        callback(JSON.stringify(data), 'application/json');
    }
    if(index === 'layniemkhoatheonam'){
        let MaNghanh = head_params.get('MaNghanh');
        let namniemkhoa = await Model.InleSQL("select SoNam from Nganh where MaNganh='"+MaNghanh+"'");
        callback(JSON.stringify(namniemkhoa), 'application/json');
    }
    


    if (index === 'themsv'){
      let MaSV = head_params.get('MaSV');
      let TenSV = head_params.get('TenSV');
      let NgaySinh = head_params.get('NgaySinh');
      let Lop = head_params.get('Lop');
      let GPA = head_params.get('GPA');
      let Email = head_params.get('Email');
      let SDT = head_params.get('SDT');
      let Khoa = head_params.get('Khoa');
      let MaNghanh = head_params.get('MaNghanh');

      let today = new Date();
      let date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
    if (TenSV.length == 0) {
        callback(JSON.stringify({ success: false, message: "Tên không được bỏ trống" }), 'application/json');
        return;
    } else if (/\d/.test(TenSV)) {
        callback(JSON.stringify({ success: false, message: "Không nhập số trong tên" }), 'application/json');
        return;
    } else if (NgaySinh !== "") {
        callback(JSON.stringify({ success: false, message: "Vui lòng nhập ngày sinh" }), 'application/json');
        return;
    } else if(Date.parse(NgaySinh) > Date.parse(date)) {
        callback(JSON.stringify({ success: false, message: "Không nhập ngày sinh lớn hơn hiện tại" }), 'application/json');
        return;
    } else if (SDT.length == 0) {
        callback(JSON.stringify({ success: false, message: "SĐT không được bỏ trống" }), 'application/json');
        return;
    } else if (!/^\d+$/.test(SDT)) {
        callback(JSON.stringify({ success: false, message: "Không nhập chữ trong SĐT" }), 'application/json');
        return;
    } else if (SDT.length < 10) {
        callback(JSON.stringify({ success: false, message: "Vui lòng nhập đúng SĐT" }), 'application/json');
        return;
    } else if (GPA.length == 0) {
        callback(JSON.stringify({ success: false, message: "GPA không được bỏ trống" }), 'application/json');
        return;
    } else if (isNaN(GPA)) {
        callback(JSON.stringify({ success: false, message: "Vui lòng không nhập chữ vào GPA" }), 'application/json');
        return;
    } else if (GPA > 4 || GPA < 0) {
        callback(JSON.stringify({ success: false, message: "Vui lòng nhập đúng GPA (hệ số 4)" }), 'application/json');
        return;
    }
      console.log(MaSV,TenSV,NgaySinh,Lop,GPA,Email,Khoa)

    //   console.log("call Insert_SV('"+Khoa+"','"+MaNghanh+"','"+Lop+"','"+MaSV+"','"+TenSV+"','"+NgaySinh+"',"+GPA+",'"+SDT+"')")
      let  result1 = await Model.InleSQL("call Insert_SV('"+Khoa+"','"+MaNghanh+"','"+Lop+"','"+MaSV+"','"+TenSV+"','"+NgaySinh+"',"+GPA+",'"+SDT+"')");
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            callback(JSON.stringify({ success: false, message: "Lỗi hệ thống!"}), 'application/json');
        }else{
            callback(JSON.stringify({ success: true, message: "Thành công!"}), 'application/json');
        }
    }

    if (index === 'danhsachsinhvien'){
        let MaAdmin = String(head_params.get('MaAdmin')).trim();
        let MaNghanh = String(head_params.get('MaNghanh')).trim();
        let Khoa = Number(head_params.get('Khoa'));

        let textsearch = String(head_params.get('textsearch'));

        let listNganh;
        let listKhoa;

        let MaNghanhtemp;
        let Khoatemp;

        let limit = 10;
        let page = Number(head_params.get('page')) - 1;

        listNganh = await Model.InleSQL("call ComboBox_Nganh()");
        listNganh = listNganh[0];

        console.log("Start+"+MaNghanh,Khoa)

    if(MaNghanh === '' || Khoa == 0 || String(MaNghanh) === 'null'){

        lineReader = readline.createInterface({
            input: fs.createReadStream('controller/qldean/Text/AdminStatus.txt')
        });
        lineReader.on('line', function (line) {
            if(String(line).includes(MaAdmin)) {
                MaNghanhtemp = String(line.split(',')[1]);
                Khoatemp = Number(line.split(',')[2]);
                if(String(Khoatemp) == 'NaN') Khoatemp = '#';
            }
        });
        lineReader.on('close', async function () {
            console.log(MaNghanhtemp)
            if(MaNghanhtemp === '#' || Khoatemp === '#'){
                MaNghanh = listNganh[0].MaNganh;
                listKhoa = await Model.InleSQL("call ComboBox_Khoa('"+MaNghanh+"')");
                listKhoa = listKhoa[0];
                Khoa = listKhoa[0].namBD;

                fs.readFile("controller/qldean/Text/AdminStatus.txt", 'utf8', function (err,data) {
                    let formatted = data.replace( String(MaAdmin+','+MaNghanhtemp+','+Khoatemp),String(MaAdmin+','+MaNghanh+','+Khoa));
                    fs.writeFile("controller/qldean/Text/AdminStatus.txt", '', 'utf8', function (err) {
                        if (err) return console.log(err);
                        fs.writeFile("controller/qldean/Text/AdminStatus.txt", formatted, 'utf8', function (err) {
                            if (err) return console.log(err);
                        });
                    });
                });

            }else{
                MaNghanh = MaNghanhtemp;
                Khoa = Khoatemp;
                listKhoa = await Model.InleSQL("call ComboBox_Khoa('"+MaNghanh+"')");
                listKhoa = listKhoa[0];
            }

            let count = await Model.InleSQL("select CountList_SV('"+Khoa+"','"+MaNghanh+"','"+textsearch+"') AS NumberSV");
            let select = await Model.InleSQL("call ShowList_SV('"+Khoa+"','"+MaNghanh+"','"+textsearch+"',"+page*limit+")");

            let data = [];
            data.push(listNganh);
            data.push(listKhoa);
            data.push(MaNghanh);
            data.push(Khoa);
            data.push(count)
            data.push(select)
            callback(JSON.stringify(data), 'application/json');
        });

    }else{
        lineReader = readline.createInterface({
            input: fs.createReadStream('controller/qldean/Text/AdminStatus.txt')
        });
        lineReader.on('line', function (line) {
            if(String(line).includes(MaAdmin)) {
                MaNghanhtemp = String(line.split(',')[1]).trim();
                Khoatemp = Number(line.split(',')[2]);
            }
        });

        lineReader.on('close', async function () {

            ///SUA LOI XUNG DOT ///
            listKhoa = await Model.InleSQL("call ComboBox_Khoa('"+MaNghanh+"')");
            listKhoa = listKhoa[0];
            let templistcheck = [];
            for(let o = 0; o < listKhoa.length; o++){
                templistcheck.push(Number(listKhoa[o].namBD));
            }
            templistcheck = bubbleSort(templistcheck);
            console.log(Number(templistcheck[0]) + 'xxxxxxxxxxx')
            if(Khoa > Number(templistcheck[0])){
                Khoa = Number(templistcheck[0]);
            }
            ////////

            console.log(String(MaAdmin+','+MaNghanh+','+Khoa), String(MaAdmin+','+MaNghanhtemp+','+Khoatemp))
            fs.readFile("controller/qldean/Text/AdminStatus.txt", 'utf8', function (err,data) {
                let formatted = data.replace( String(MaAdmin+','+MaNghanhtemp+','+Khoatemp),String(MaAdmin+','+MaNghanh+','+Khoa));
                fs.writeFile("controller/qldean/Text/AdminStatus.txt", '', 'utf8', function (err) {
                    if (err) return console.log(err);
                    fs.writeFile("controller/qldean/Text/AdminStatus.txt", formatted, 'utf8', function (err) {
                        if (err) return console.log(err);
                    });
                });
            });

            listKhoa = await Model.InleSQL("call ComboBox_Khoa('"+MaNghanh+"')");
            listKhoa = listKhoa[0];

            let count = await Model.InleSQL("select CountList_SV('"+Khoa+"','"+MaNghanh+"','"+textsearch+"')  AS NumberSV");
            let select = await Model.InleSQL("call ShowList_SV('"+Khoa+"','"+MaNghanh+"','"+textsearch+"',"+page*limit+")");

            let data = [];
            data.push(listNganh);
            data.push(listKhoa);
            data.push(MaNghanh);
            data.push(Khoa);
            data.push(count)
            data.push(select)

            callback(JSON.stringify(data), 'application/json');
        });
    }
    }

    if (index === 'suasv'){
      let MaSV = head_params.get('MaSV');
      let TenSV = head_params.get('TenSV');
      let NgaySinh = head_params.get('NgaySinh');
      let Lop = head_params.get('Lop');
      let GPA = head_params.get('GPA');
      let SDT = head_params.get('SDT');



      let today = new Date();
      let date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
    if (TenSV.length == 0) {
        callback(JSON.stringify({ success: false, message: "Tên không được bỏ trống" }), 'application/json');
        return;
    } else if (/\d/.test(TenSV)) {
        callback(JSON.stringify({ success: false, message: "Không nhập số trong tên" }), 'application/json');
        return;
    } else if (NgaySinh.length == 0) {
        callback(JSON.stringify({ success: false, message: "Vui lòng nhập ngày sinh" }), 'application/json');
        return;
    } else if(Date.parse(NgaySinh) > Date.parse(date)) {
        callback(JSON.stringify({ success: false, message: "Không nhập ngày sinh lớn hơn hiện tại" }), 'application/json');
        return;
    } else if (SDT.length == 0) {
        callback(JSON.stringify({ success: false, message: "SĐT không được bỏ trống" }), 'application/json');
        return;
    } else if (!/^\d+$/.test(SDT)) {
        callback(JSON.stringify({ success: false, message: "Không nhập chữ trong SĐT" }), 'application/json');
        return;
    } else if (SDT.length < 7) {
        callback(JSON.stringify({ success: false, message: "Vui lòng nhập đúng SĐT" }), 'application/json');
        return;
    } else if (GPA.length == 0) {
        callback(JSON.stringify({ success: false, message: "GPA không được bỏ trống" }), 'application/json');
        return;
    } else if (isNaN(GPA)) {
        callback(JSON.stringify({ success: false, message: "Vui lòng không nhập chữ vào GPA" }), 'application/json');
        return;
    } else if (GPA > 4 || GPA < 0) {
        callback(JSON.stringify({ success: false, message: "Vui lòng nhập đúng GPA (hệ số 4)" }), 'application/json');
        return;
    }


      // let Email = head_params.get('Email');
      console.log(MaSV,TenSV,NgaySinh,Lop,GPA,SDT+"capnhatsv")
      let result1 = await Model.InleSQL("call update_SV('"+Lop+"','"+MaSV+"', '"+TenSV+"', '"+NgaySinh+"',"+GPA+", '"+SDT+"')");
       console.log("call update_SV('"+Lop+"','"+MaSV+"', '"+TenSV+"', '"+NgaySinh+"',"+GPA+", '"+SDT+"')")
       console.log(result1)
      if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
        callback(JSON.stringify({ success: false, message: "Lỗi hệ thống!"}), 'application/json');
    }else{
        callback(JSON.stringify({ success: true, message: "Thành công!"}), 'application/json');
    }
    }

    if (index === 'xoasv'){
      let MaSV = head_params.get('MaSV');
      let  result1 = await Model.InleSQL("DELETE FROM `SinhVien` WHERE `MaSV` = '" + MaSV + "'");
          if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
              callback(JSON.stringify("that bai"), 'application/json');
          }else{
              callback(JSON.stringify(result1), 'application/json');
          }
    }
}