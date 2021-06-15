module.exports = async (callback, scanner) => {
    let index = scanner.req_bundle.index;
    let Model = scanner.inleModel;
    let head_params = scanner.head_params;
    
    if (index === 'danhsachdoan'){
        let limit = 10;
        let page = Number(head_params.get('page')) - 1;
        let result = await Model.InleSQL(" select MaDA, TenDA, MaGVHD, TenGV from doan da, giangvien gv where da.MaGVHD=gv.MaGV limit "+limit+" OFFSET " + page*limit);
        let count = await Model.InleSQL(" SELECT FOUND_ROWS() ;");
        callback(JSON.stringify([result, count]), 'application/json');
    }


}