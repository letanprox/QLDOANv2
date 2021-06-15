const readline = require('readline');
const fs = require('fs');

module.exports = async (callback, scanner) => {
    let index = scanner.req_bundle.index;
    let Model = scanner.inleModel;
    let head_params = scanner.head_params;
    
    if (index === 'doan-sinhvien'){

        let MaSV = head_params.get('MaSV');

        let result = await Model.InleSQL("select MaPhanCong, MaGVHD, MaDA, MaCT from phancongdoan where MaSV='"+MaSV+"';");
       
        console.log(result)

        let MaGV = result[0]['MaGVHD']
        let MaDA = result[0]['MaDA']
        let MaCT = result[0]['MaCT']
        let MaPC = result[0]['MaPhanCong']

        let result1 = await Model.InleSQL("call ShowInfor_DA('"+MaGV+"','"+MaDA+"',"+MaCT+");"); 
        let result2 = await Model.InleSQL("call ShowFullDiem('"+MaSV+"');"); 
        let result3 = await Model.InleSQL("call ShowFile_BaoCao('"+MaPC+"');"); 
        let result4;


       
        console.log(result2[0][0]['DiemTB'],result2[0][0]['DiemPB'],result2[0][0]['DiemHD'])

        if(String(result2[0][0]['DiemPB']) === 'null' && String(result2[0][0]['DiemTB']) === 'null'){
            result4 = await Model.InleSQL("call ShowInfor_GV('"+String(result2[0][0]['MaGVHD'])+"');"); 
        }else if(String(result2[0][0]['DiemPB']) != 'null' && String(result2[0][0]['DiemTB']) === 'null'){
            result4 = await Model.InleSQL("call ShowInfor_GV('"+String(result2[0][0]['MaGVPB'])+"');"); 
        }else{
            result4 = await Model.InleSQL("call ShowInfor_TB('"+String(result2[0][0]['MaTB'])+"');"); 
        }


        let data = [];
        data.push(result1);
        data.push(result2);
        data.push(result3);
        data.push(result4);
        
        callback(JSON.stringify(data), 'application/json');
    }

    if (index === 'nopbaocao-sinhvien'){
        let MaPC = head_params.get('MaPC');
        let infotep = head_params.get('infotep');
        let listDiemx = head_params.get('listDiemx');
        let ngay = head_params.get('ngay');
        let namefilex = head_params.get('namefilex');


        let  result1 = await Model.InleSQL("call NopBaoCao('"+MaPC+"', '"+listDiemx+"', '"+namefilex+"', '"+infotep+"', '"+ngay+"')");
        console.log("call NopBaoCao('"+MaPC+"', '"+listDiemx+"', '"+namefilex+"', '"+infotep+"', '"+ngay+"')")
        console.log(result1)    
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
                callback(JSON.stringify("that bai"), 'application/json');
            }else{
                callback(JSON.stringify(result1), 'application/json');
            }
    }


    if (index === 'danhsach-tieuban-sinhvien'){
        let MaTB = head_params.get('MaTB');
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;

        let count = await Model.InleSQL("select CountList_SVBaoCao('"+MaTB+"') AS Number"); 
        let select = await Model.InleSQL("call ShowList_SVBaoCao('"+MaTB+"',"+page*limit+");"); 

        let data = [];
        data.push(count);
        data.push(select);
        callback(JSON.stringify(data), 'application/json');
    }

}