const fs = require('fs');
const readline = require('readline');
const path = require("path");

module.exports = async (callback, scanner) => {
    let index = scanner.req_bundle.index;
    let Model = scanner.inleModel;
    let head_params = scanner.head_params;


    //call CheckLogin('GVCN006','GVCN006#19871114')
    //call CheckLogin('QL001','QL001#14111987')

//     -- call CheckLogin('QL001','QL001@010621'); 
//     -- call CheckLogin('GVCN006','GVCN006@19871114')
//    call CheckLogin('N17DCCN002','N17DCCN002@230621')
   
//    #ddmmyy -.-

    if(index === 'login'){
        let username = String(head_params.get('username'))
        let pass = String(head_params.get('pass'))
        pass = pass.replace('@','#');

        console.log(username,pass)

        let count = await Model.InleSQL("call CheckLogin('"+username+"','"+pass+"')");

        console.log(count)

        let data = [];
        data.push(count[0][0]['Quyen'],username,String(count[0][0]['Quyen']) + 'NAME',count[0][0]['user']);
        callback(JSON.stringify(data), 'application/json');
    }

}