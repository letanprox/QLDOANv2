module.exports = async (callback, scanner) => {
    let index = scanner.req_bundle.index;
    let Model = scanner.inleModel;
    let head_params = scanner.head_params;

    if (index === 'loadChartMot'){

        let result1 = await Model.InleSQL("call ComboBox_HoiDong();");
        let result2 = await Model.InleSQL("call ComboBox_Khoa_TK(1);");
        let data = [];
        data.push(result1)
        data.push(result2)
        callback(JSON.stringify(data), 'application/json');

    }
    if (index === 'loadBieudoToankhoa'){
        let Khoa = head_params.get('Khoa');
        let result1 = await Model.InleSQL("call ThongKeTheoNam("+Khoa+",'1,');");
        console.log("call ThongKeTheoNam("+Khoa+",'1,');")
        let data = [];
        data.push(result1)
        callback(JSON.stringify(data), 'application/json');
    }
    if (index === 'loadBieudoThongke5nam'){
        let HD = head_params.get('HD');
        let result1 = await Model.InleSQL("call Thongke5nam('"+HD+",');");
        console.log("call Thongke5nam('"+HD+",');")
        let data = [];
        data.push(result1)
        callback(JSON.stringify(data), 'application/json');
    }

    if (index === 'loadBieudoPhodiem'){
        let HD = head_params.get('HD');
        let Khoa = head_params.get('Khoa');
        let result1 = await Model.InleSQL("call ThongKePhoDiem("+Khoa+",'HD,1,"+HD+",');");
        let result2 = await Model.InleSQL("call ThongKePhoDiem("+Khoa+",'PB,1,"+HD+",');");
        let result3 = await Model.InleSQL("call ThongKePhoDiem("+Khoa+",'TB,1,"+HD+",');");

        console.log("call ThongKePhoDiem("+Khoa+",'TB,1,"+HD+",');")

        let data = [];
        data.push(result1);
        data.push(result2);
        data.push(result3);
        callback(JSON.stringify(data), 'application/json');
    }

}