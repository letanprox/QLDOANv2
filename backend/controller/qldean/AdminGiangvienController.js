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

    if (index === 'danhsachgiangvien'){

        let textsearch = String(head_params.get('textsearch'));

        let MaAdmin = String(head_params.get('MaAdmin')).trim();
        let MaNghanh = String(head_params.get('MaNghanh')).trim();
        let Khoa = Number(head_params.get('Khoa'));

        let listNganh;
        let listKhoa;

        let MaNghanhtemp;
        let Khoatemp;

        let limit = 10;
        let page = Number(head_params.get('page')) - 1;

        listNganh = await Model.InleSQL("call ComboBox_Nganh()");
        listNganh = listNganh[0];


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
            let count = await Model.InleSQL("SELECT COUNTList_GV('"+MaNghanh+"','"+textsearch+"') AS NumberGV;");
            let select = await Model.InleSQL("call ShowList_GV('"+MaNghanh+"','"+textsearch+"',"+limit*page+");");

            
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

            let count = await Model.InleSQL("SELECT COUNTList_GV('"+MaNghanh+"','"+textsearch+"') AS NumberGV;");
            let select = await Model.InleSQL("call ShowList_GV('"+MaNghanh+"','"+textsearch+"',"+limit*page+");");

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


    if (index === 'danhsachdulieugiangvien'){
        let MaNghanh = String(head_params.get('MaNghanh')).trim();
        let page = Number(head_params.get('page')) - 1;

        let limit = 10;

        let count = await Model.InleSQL("SELECT COUNTList_GV('"+MaNghanh+"') AS NumberGV;");
        let select = await Model.InleSQL("call ShowList_GV('"+MaNghanh+"',"+limit*page+");");

        let data = [];
        data.push(count)
        data.push(select)
        callback(JSON.stringify(data), 'application/json');
    }



    if (index === 'dieukienthemgv'){
        let MaNghanh = String(head_params.get('MaNghanh'));
        console.log(MaNghanh+"xxxxxxxxxxxx")
        let result = await Model.InleSQL("select auto_IDGV('"+MaNghanh+"') AS MaGV;");
        callback(JSON.stringify(result), 'application/json');
    }

    if (index === 'themgv'){
        let MaGV = head_params.get('MaGV');
        let TenGV = head_params.get('TenGV');
        let SDT = head_params.get('SDT');
        let email = head_params.get('email');
        let ngaySinh = head_params.get('ngaySinh');
        let MaNghanh = String(head_params.get('MaNghanh'));


        let today = new Date();
        let date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        if (TenGV.length == 0) {
            callback(JSON.stringify({ success: false, message: "Tên không được bỏ trống"}), 'application/json');
            return;
         }else if (/\d/.test(TenGV)) {    
            callback(JSON.stringify({ success: false, message: "Không nhập số trong tên"}), 'application/json');
            return;
        }else if (ngaySinh.length == 0) {
            callback(JSON.stringify({ success: false, message: "Vui lòng nhập ngày sinh"}), 'application/json');
            return;
        }else if(Date.parse(ngaySinh) > Date.parse(date)) {
            callback(JSON.stringify({ success: false, message: "Không nhập ngày sinh lớn hơn hiện tại"}), 'application/json');
            return;    
        }else if (SDT.length==0) {
            callback(JSON.stringify({ success: false, message: "SĐT không được bỏ trống"}), 'application/json');
            return;
        }else if (!/^\d+$/.test(SDT)){
            callback(JSON.stringify({ success: false, message: "Không nhập chữ trong SĐT"}), 'application/json');
            return;
        }else if (SDT.length> 15) {
            callback(JSON.stringify({ success: false, message: "Vui lòng nhập đúng SĐT"}), 'application/json');
            return;
        }else if (email.length<10) {
            callback(JSON.stringify({ success: false, message: "Vui lòng nhập đúng Email"}), 'application/json');
            return;
        }

        // console.log("INSERT INTO nhanvien (MaNV, TenNV, Email, NgaySinh, SDT, MaNganh) VALUES  ('"+MaGV+"', '"+TenGV+"', '"+email+"', '"+ngaySinh+"', '"+SDT+"','"+MaNghanh+"');")
        
        let  result1 = await Model.InleSQL("INSERT INTO nhanvien (MaNV, TenNV, Email, NgaySinh, SDT, MaNganh) VALUES  ('"+MaGV+"', '"+TenGV+"', '"+email+"', '"+ngaySinh+"', '"+SDT+"','"+MaNghanh+"');");
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            callback(JSON.stringify({ success: false, message: "Lỗi hệ thống!"}), 'application/json');
        }else{
            callback(JSON.stringify({ success: true, message: "Thành công!"}), 'application/json');
        }
    }


    if (index === 'suagv'){
        let MaGV = head_params.get('MaGV');
        let TenGV = head_params.get('TenGV');
        let SDT = head_params.get('SDT');
        let email = head_params.get('email');
        let ngaySinh = head_params.get('ngaySinh');
        let MaNghanh = String(head_params.get('MaNghanh'));

        let today = new Date();
        let date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        if (TenGV.length == 0) {
            callback(JSON.stringify({ success: false, message: "Tên không được bỏ trống"}), 'application/json');
            return;
         }else if (/\d/.test(TenGV)) {    
            callback(JSON.stringify({ success: false, message: "Không nhập số trong tên"}), 'application/json');
            return;
        }else if (ngaySinh.length == 0) {
            callback(JSON.stringify({ success: false, message: "Vui lòng nhập ngày sinh"}), 'application/json');
            return;
        }else if(Date.parse(ngaySinh) > Date.parse(date)) {
            callback(JSON.stringify({ success: false, message: "Không nhập ngày sinh lớn hơn hiện tại"}), 'application/json');
            return;    
        }else if (SDT.length==0) {
            callback(JSON.stringify({ success: false, message: "SĐT không được bỏ trống"}), 'application/json');
            return;
        }else if (!/^\d+$/.test(SDT)){
            callback(JSON.stringify({ success: false, message: "Không nhập chữ trong SĐT"}), 'application/json');
            return;
        }else if (SDT.length> 15) {
            callback(JSON.stringify({ success: false, message: "Vui lòng nhập đúng SĐT"}), 'application/json');
            return;
        }else if (email.length<10) {
            callback(JSON.stringify({ success: false, message: "Vui lòng nhập đúng Email"}), 'application/json');
            return;
        }

        console.log("update NhanVien set TenNV='"+TenGV+"', NgaySinh='"+ngaySinh+"', SDT='"+SDT+"', Email='"+email+"' where MaNV='"+MaGV+"';")
        let result1 = await Model.InleSQL("update NhanVien set TenNV='"+TenGV+"', NgaySinh='"+ngaySinh+"', SDT='"+SDT+"', Email='"+email+"' where MaNV='"+MaGV+"';");
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            callback(JSON.stringify({ success: false, message: "Lỗi hệ thống!"}), 'application/json');
        }else{
            callback(JSON.stringify({ success: true, message: "Thành công!"}), 'application/json');
        }
    }

    if (index === 'xoagv'){
        let MaGV = head_params.get('MaGV');
        console.log("CALL Delete_GV('"+MaGV+"')")
        let  result1 = await Model.InleSQL("CALL Delete_GV('"+MaGV+"')");
        console.log(result1)
            if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }


}