const fs = require('fs');
const readline = require('readline');

module.exports = async (callback, scanner) => {
    let index = scanner.req_bundle.index;
    let Model = scanner.inleModel;
    let head_params = scanner.head_params;

    if (index === 'info_user'){
        let Ma = head_params.get('Ma');
        let result1 = await Model.InleSQL("call ShowInfor_User('"+Ma+"');");
        console.log("call ShowInfor_User('"+Ma+"');")
        let data = [];
        data.push(result1)
        callback(JSON.stringify(data), 'application/json');
    }

    if (index === 'sua_admin_teacher'){
        let Ma = head_params.get('Ma');
        let Ten = head_params.get('Ten');
        let Email = head_params.get('Email');
        let SDT = head_params.get('SDT');
        let Ngaysinh = head_params.get('Ngaysinh');

        let result1 = await Model.InleSQL("update nhanvien SET	TenNV='"+Ten+"', Ngaysinh='"+Ngaysinh+"', SDT='"+SDT+"', Email='"+Email+"' where MaNV='"+Ma+"';");
        
        
        console.log(result1)

        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            callback(JSON.stringify("that bai"), 'application/json');
        }else{
            callback(JSON.stringify(result1), 'application/json');
        }
    }

    if (index === 'sua_sv'){
        let Ma = head_params.get('Ma');
        let Ten = head_params.get('Ten');
        let SDT = head_params.get('SDT');
        let Ngaysinh = head_params.get('Ngaysinh');

        let result1 = await Model.InleSQL("update sinhvien SET	TenSV='"+Ten+"', Ngaysinh='"+Ngaysinh+"', SDT='"+SDT+"' where MaSV='"+Ma+"';");
        
        
        console.log(result1)
        if(String(result1).includes('Duplicate entry') || String(result1).includes('fail')){
            callback(JSON.stringify("that bai"), 'application/json');
        }else{
            callback(JSON.stringify(result1), 'application/json');
        }
    }

    if (index === 'doi_matkhau'){
        let Ma = head_params.get('Ma');
        let Pass = head_params.get('Pass');
        let Old = head_params.get('Old');
        Old = Old.replace('@','#');
        let result1 = await Model.InleSQL("call ChangePassword('"+Ma+"','"+Old+"', '"+Pass+"')");
        console.log("call ChangePassword('"+Ma+"','"+Old+"', '"+Pass+"')")
        callback(JSON.stringify(result1), 'application/json');
    }

}