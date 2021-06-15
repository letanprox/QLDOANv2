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

    if (index === 'danhsachphancongPB'){

        let MaAdmin = String(head_params.get('MaAdmin')).trim();
        let MaNghanh = String(head_params.get('MaNghanh')).trim();
        let Khoa = Number(head_params.get('Khoa'));

        let textsearch = String(head_params.get('textsearch'));
        console.log(MaNghanh)
        
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
  
            let count = await Model.InleSQL("select COUNTList_SvDAPB('"+Khoa+"','"+MaNghanh+"','"+textsearch+"') AS NumberSV");
            let select = await Model.InleSQL("call ShowList_SvDAPB('"+Khoa+"','"+MaNghanh+"','"+textsearch+"',"+page*limit+")");
            let niemkhoahientai = await Model.InleSQL("select nienkhoahientai('"+MaNghanh+"') AS nienkhoahientai");

            let data = [];
            data.push(listNganh);
            data.push(listKhoa);
            data.push(MaNghanh);
            data.push(Khoa);
            data.push(count)
            data.push(select)
            data.push(niemkhoahientai);

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
  
            let count = await Model.InleSQL("select CountList_SvDAPB('"+Khoa+"','"+MaNghanh+"','"+textsearch+"') AS NumberSV");
            let select = await Model.InleSQL("call ShowList_SvDAPB('"+Khoa+"','"+MaNghanh+"','"+textsearch+"',"+page*limit+")");
            let niemkhoahientai = await Model.InleSQL("select nienkhoahientai('"+MaNghanh+"') AS nienkhoahientai");


            let data = [];
            data.push(listNganh);
            data.push(listKhoa);
            data.push(MaNghanh);
            data.push(Khoa);
            data.push(count)
            data.push(select)
            data.push(niemkhoahientai);
  
            callback(JSON.stringify(data), 'application/json');
        });
    }
    }


    if(index === 'danhsachGVPBphancong'){
        let MaSV = String(head_params.get('MaSV'));
        let MaNghanh = String(head_params.get('MaNghanh'));
        let Khoa = Number(head_params.get('Khoa'));
       
        let result = await Model.InleSQL("call ShowInfor_SVPB('"+MaSV+"')");
        let result1 = await Model.InleSQL("call ComboBox_PhanCongGVPB('"+MaNghanh+"', '"+MaSV+"');");

        console.log("call ShowInfor_SVPB('"+MaSV+"')")
        let data = [];
        data.push(result)
        data.push(result1)
   
        callback(JSON.stringify(data), 'application/json');
    }

    if(index === 'infoGVPB'){
        let MaGV = String(head_params.get('MaGV'));
        let result = await Model.InleSQL("call ShowInfor_GV('"+MaGV+"')");
        let data = [];
        data.push(result);
        callback(JSON.stringify(data), 'application/json');
    }


    if(index === 'addGVPBphancong'){
        let MaGVPB = String(head_params.get('MaGVPB'));
        let MaSV = String(head_params.get('MaSV'));

        result = await Model.InleSQL('call PhanCong_GVPB("'+MaSV+'", "'+MaGVPB+'");')

            if(String(result).includes('Duplicate entry') || String(result).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result), 'application/json');
            }
    }


}