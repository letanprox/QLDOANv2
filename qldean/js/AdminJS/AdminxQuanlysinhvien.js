$( "#act-sinhvien" ).addClass( "active" )


$("#name-user").empty();
$("#name-user").append('Admin: ' + getCookie('QLNAME'));
var MaAdmin = getCookie('QL');

var niemkhoamoi;
var ismokhoa = false;

var listinfoitem;
var currentlist = 0;
var textsearch = '';
var isaddSinhvien = false;

var page_num = 1;
var tol_page = 0;
var currentrowtable = -1;

var maSV;
var EmailSV;

var khoacurrent = 0;
var nghanhcurrent = '';
var chuyennghanhcurrent = '';
var lopcurrent = '';

var khoacurrenttemp = 0;

var listnghanh = [];
    var listmanganh = [];
    var listtennghanh = [];

var liststartkhoa = [];
var listkhoa = [];
var listkhoatemp = [];
var listniemkhoa = [];
var listniemkhoatemp = [];
var rangeKhoa = [2010,2021]

var listchuyenganh = [];
    var listmachuyennganh = [];
    var listtenchuyennganh = [];

var checklistlop = true;
var listlop = []

var itemSV;

var tieudeBangSinhvien = ['Mã' , 'Tên' , 'Lớp' ,'Chuyên ngành'  , 'SDT' , 'Email' , 'GPA'] 
var tennutBangSinhvien = ['Sửa','Xóa'];
var idnutBangSinhvien = [ 'suax' , 'xoax'];

var nutThemSinhvien =  ['Thêm','Thoát'];
var maunutThemSinhvien = ['tomato', 'green'];
var idnutThemSinhvien = ['them', 'thoat'];

var nutSuaSinhvien =  ['Sửa','Thoát'];
var matnutSuaSinhvien = ['tomato', 'green'];
var idnutSuaSinhvien = ['sua', 'thoat'];



var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
                if(String(this.responseURL).includes('api/danhsachsinhvien')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)

                    listnghanh = data[0];
                    listmanganh = [];
                    for(let i = 0; i< listnghanh.length; i++){
                        listmanganh.push(listnghanh[i].MaNganh)
                    }
                    listtennghanh = [];
                    for(let i = 0; i < listnghanh.length; i++){
                        listtennghanh.push(listnghanh[i].TenNganh)
                    }

                    listkhoa = [];
                    liststartkhoa = data[1];
                    for(let i = 0; i < data[1].length; i++){
                        listkhoa.push(data[1][i].namBD);
                    }
                    listkhoatemp = listkhoa;
                    listniemkhoa = [];
                    for(let i = 0; i < data[1].length; i++){
                        listniemkhoa.push(data[1][i].namBD + '-' + Math.ceil(data[1][i].namBD + data[1][i].SoNam));
                    }
                    listniemkhoatemp = listniemkhoa;

                    nghanhcurrent = data[2];
                    if(isaddSinhvien == false) khoacurrent = data[3];
                    khoacurrenttemp = data[3];

                    tol_page =  Math.ceil(data[4][0]["NumberSV"] / 10); 
                    listinfoitem = data[5][0];

                    LoadListSinhvien(listinfoitem);
                }
                if(String(this.responseURL).includes('api/dieukienthemsv')){
                    var data = JSON.parse(this.responseText)
                    console.log(data)

                    maSV = data[0];
                    EmailSV = data[1];

                    listchuyenganh = data[2];
                    listmachuyennganh = [];
                    for(let i = 0; i< listchuyenganh.length; i++){
                        listmachuyennganh.push(listchuyenganh[i].MaCN)
                    }
                    listtenchuyennganh = [];
                    for(let i = 0; i < listchuyenganh.length; i++){
                        listtenchuyennganh.push(listchuyenganh[i].TenCN)
                    }

                    listlop = []
                    for(let i = 0; i < data[3].length; i++){
                        listlop.push(data[3][i].MaLop)
                    }
                    lopcurrent = data[4];
                    
                    LoadAddFormSinhvien();
                }

                if(String(this.responseURL).includes('api/dieukiensuasv')){
                    var data = JSON.parse(this.responseText)
                    console.log(data)

                    listchuyenganh = data[0];
                    listmachuyennganh = [];
                    for(let i = 0; i< listchuyenganh.length; i++){
                        listmachuyennganh.push(listchuyenganh[i].MaCN)
                    }
                    listtenchuyennganh = [];
                    for(let i = 0; i < listchuyenganh.length; i++){
                        listtenchuyennganh.push(listchuyenganh[i].TenCN)
                    }
                    listlop = []
                    for(let i = 0; i < data[1].length; i++){
                        listlop.push(data[1][i].MaLop)
                    }

                    lopcurrent = data[3];
                    console.log(listchuyenganh,listlop)
                    LoadSuaFormSinhvien(itemSV,data[2][0]['checkCount']); 
                }

                if(String(this.responseURL).includes('api/danhsach-theo-chuyennganhvakhoa')){
                    var data = JSON.parse(this.responseText)
                    console.log(data)
                    listlop=[];
                    for(let i = 0; i < data[0].length; i++){
                        listlop.push(data[0][i].MaLop)
                    }
                    if(listlop.length > 0){
                        checklistlop = true;
                        LoadComboxLop();
                        createLopmoi();
                    }else{
                        checklistlop = false;
                        createLopmoi()
                    }
                }
                if(String(this.responseURL).includes('api/taomoilop')){
                    var data = JSON.parse(this.responseText)
                    if(checklistlop === false){
                        $('#label-lop').empty().append(data)
                        $('#combox-ds-lop').hide();
                        $('#label-lop').show();
                        $('#themlopbtn').hide();
                        $('#dslopbtn').hide();
                    }else{
                        lopcurrent = data;
                        $('#label-lop').empty().append(lopcurrent)
                    }
                }

                if(String(this.responseURL).includes('api/themsv')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    if(data.success === false){
                        alert(data.message)
                    }else{
                        loadListSinhvien();
                    }
                }
                if(String(this.responseURL).includes('api/suasv')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    if(data.success === false){
                        alert(data.message)
                    }else{
                        loadListSinhvien();
                    }
                }
                if(String(this.responseURL).includes('api/xoasv')){
                    if(String(this.responseText) == '"that bai"')
                        alert('Fail')
                    else loadListSinhvien();
                }


                if(String(this.responseURL).includes('/api/themkhoasv')){
                    if(String(this.responseText) == '"that bai"')
                        alert('Fail');
                    else{
                        khoacurrent = Number(document.getElementById('input-khoa').value);
                        listkhoa.push(Number(document.getElementById('input-khoa').value))
                        listkhoa = bubbleSort(listkhoa);
            
                        $('#head-bar').empty();
                        $('#head-bar').append(returnFormKhoa(listkhoa,khoacur));
            
                        $('#xacnhan-them-khoa').hide();
                        $('#dskhoa').hide();
                        $('#themkhoa').show();
                        $('#input-khoa').hide();
                        $('#select-khoa').show();

                        loadListSinhvien();
                    } 
                }
        }
    };

///LOAD----------------------------------------------------
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

function loadListSinhvien(){
    xhttp.open("GET", "/api/danhsachsinhvien?page="+page_num+"&Khoa="+khoacurrent+"&MaNghanh="+String(nghanhcurrent)+"&MaAdmin="+MaAdmin+"&textsearch="+textsearch, false);
    xhttp.send();
}

function loadAddListSinhvien() {
    var e = document.getElementsByClassName("select-combox-headbar").item(0);
    nghanhcurrent = String(e.options[e.selectedIndex].value);
    e = document.getElementsByClassName("select-combox-headbar").item(1);
    khoacurrenttemp = e.options[e.selectedIndex].value;
        // khoacurrent = e.options[e.selectedIndex].value;
    xhttp.open("GET", "/api/dieukienthemsv?Khoa="+khoacurrenttemp+"&MaNghanh="+nghanhcurrent+"&MaAdmin="+MaAdmin, false);
    xhttp.send();
}

function loadSuaListSinhvien() {
    var e = document.getElementsByClassName("select-combox-headbar").item(0);
    nghanhcurrent = String(e.options[e.selectedIndex].value);
    e = document.getElementsByClassName("select-combox-headbar").item(1);
    khoacurrent = e.options[e.selectedIndex].value;
    xhttp.open("GET", "/api/dieukiensuasv?Khoa="+khoacurrent+"&MaNghanh="+nghanhcurrent+"&MaChuyenNghanh="+itemSV.MaCN+"&MaSV="+itemSV.MaSV, false);
    xhttp.send();
}

function addSinhvien() {
    var tensv = document.getElementsByClassName('input-new-row-long').item(0).value;
    var SDT = document.getElementsByClassName('input-new-row-long').item(1).value;
    var GPA = document.getElementsByClassName('input-new-row-short').item(0).value;

    var e = document.getElementsByClassName('combo-box-add-long').item(0);
    var chuyennganh = e.options[e.selectedIndex].value;
    var lop;

    e = document.getElementsByClassName("select-combox-headbar").item(1);
    khoacurrent = e.options[e.selectedIndex].value;
    
    if(document.getElementsByClassName('label-item-add').item(2).style.display === "none"){
        var e = document.getElementsByClassName('combo-box-add-long').item(1);
         lop = e.options[e.selectedIndex].value;
    }else{
         lop = String(document.getElementsByClassName('label-item-add').item(2).innerHTML);
    }

    console.log(lop)
    

    var thoigiantieuban = document.getElementsByClassName('thoigianform').item(0).value;
    thoigiantieuban = String(thoigiantieuban).split('T')
    var ngay = thoigiantieuban[0];

    console.log( "/api/themsv?MaSV="+maSV+"&TenSV="+tensv+"&NgaySinh="+ngay+"&Lop="+lop+"&chuyennganh="+chuyennganh+"&GPA="+GPA+"&Email="+EmailSV+"&SDT="+SDT+"&Khoa="+khoacurrent)
    xhttp.open("GET", "/api/themsv?MaSV="+maSV+"&TenSV="+tensv+"&NgaySinh="+ngay+"&Lop="+lop+"&MaNghanh="+nghanhcurrent+"&GPA="+GPA+"&Email="+EmailSV+"&SDT="+SDT+"&Khoa="+khoacurrent, false);
    xhttp.send();

}

function updateListSinhvien() {

    var tensv = document.getElementsByClassName('input-new-row-long').item(0).value;
    var SDT = document.getElementsByClassName('input-new-row-long').item(1).value;
    var GPA = document.getElementsByClassName('input-new-row-short').item(0).value;

    var lop;
    if(document.getElementsByClassName('label-item-add').item(4).style.display === "none"){
        var e = document.getElementsByClassName('combo-box-add-long').item(1);
         lop = e.options[e.selectedIndex].value;
    }else{
         lop = String(document.getElementsByClassName('label-item-add').item(4).innerHTML);
    }
    

    var thoigiantieuban = document.getElementsByClassName('thoigianform').item(0).value;
    thoigiantieuban = String(thoigiantieuban).split('T')
    var ngay = thoigiantieuban[0];

    console.log(itemSV.MaSV,tensv,ngay,lop,GPA)

    xhttp.open("GET", "/api/suasv?MaSV="+itemSV.MaSV+"&TenSV="+tensv+"&NgaySinh="+ngay+"&Lop="+lop+"&GPA="+GPA+"&SDT="+SDT, false);
    xhttp.send();

}

function changeKhoa(){
    var e = document.getElementById("select-khoa");
    khoacurrent = e.options[e.selectedIndex].text;
    console.log(khoacurrent)
    xhttp.open("GET", "/api/danhsachsinhvien?page="+page_num+"&khoa="+khoacurrent, false);
    xhttp.send();
}

function changeChuyennghanh(){
    var e = document.getElementsByClassName("combo-box-add-long").item(0);
    chuyennghanhcurrent = String(e.options[e.selectedIndex].value);

    xhttp.open("GET", "/api/danhsach-theo-chuyennganhvakhoa?MaChuyenNghanh="+chuyennghanhcurrent+"&Khoa="+khoacurrent, false);
    xhttp.send();
}


function createLopmoi(){
    var e = document.getElementsByClassName("combo-box-add-long").item(0);
    chuyennghanhcurrent = String(e.options[e.selectedIndex].value);
    
    xhttp.open("GET", "/api/taomoilop?MaChuyenNghanh="+chuyennghanhcurrent+"&Khoa="+khoacurrent, false);
    xhttp.send();
}


function changeKhoaandNghanh(){
    var e = document.getElementsByClassName("select-combox-headbar").item(0);
    nghanhcurrent = String(e.options[e.selectedIndex].value);

    var e = document.getElementsByClassName("select-combox-headbar").item(1);

    if(isaddSinhvien == false ) khoacurrent = Number(e.options[e.selectedIndex].value);
    khoacurrenttemp = Number(e.options[e.selectedIndex].value);

    if(isaddSinhvien == true){
        loadAddListSinhvien();
    }else{
        loadListSinhvien();
    }
}

function changesearch(s){
    // currentlist = 2;
    textsearch = s;
    page_num = 1;
    loadListSinhvien();
}
//ELEMENT-----------------------------------------------------
function LoadListSinhvien(data) {

    data = data.map(o => {
        let obj = Object.assign({}, o);
        delete obj.NgaySinh;
        delete obj.MaCN;
        return obj;
      });

    isaddSinhvien = false;
    $('#button-bar').show();
    $('.chose-bar').show();
    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();
    $('#head-bar').show();
    $('.Add-New-Row').hide();

    $('#head-bar').empty();
    $('#button-bar').empty();

    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Quản lý sinh viên')  +  returnAddBtn());
    $('#head-bar').append(returnFormComboxHeadBar('Nghành',listmanganh, listtennghanh, nghanhcurrent, 'changeKhoaandNghanh',250,0));
    $('#head-bar').append(returnFormComboxHeadBar('Niêm khóa',listkhoa , listniemkhoa, khoacurrent, 'changeKhoaandNghanh',120,20));
    

    if(document.getElementById('input-search')){
    }else{
        $('.chose-bar').empty();
        $('.chose-bar').append(returnSearchForm('Tìm mã sinh viên','Làm mới') );    
    }

    $('#table_data').append(returnTable(tieudeBangSinhvien,data));
    $('.btn-follow-row').append(returnButtonTable(tennutBangSinhvien,idnutBangSinhvien));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));

    if(ismokhoa == true) loadAddListSinhvien();

}

function LoadComboxLop(){
    $('#combox-ds-lopx').empty();
    $('#combox-ds-lop').show();
    $('#label-lop').hide();
    $('#themlopbtn').show();
    $('#dslopbtn').hide();
    var element = '';
    for(var i = 0; i < listlop.length; i++){
        if(i == 0)
        element = element + '<option selected value="'+listlop[i]+'">'+listlop[i]+'</option>';
        else 
        element = element + '<option value="'+listlop[i]+'">'+listlop[i]+'</option>';
    }
    $('#combox-ds-lopx').append(element);
}

function LoadAddFormSinhvien() {
    isaddSinhvien = true;

    $('#button-bar').show();
    $('#head-bar').show();
    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();

    $('#head-bar').empty();
    $('.Add-New-Row').show();
    $('#chose-bar').empty();
    $('#button-bar').empty();
    $('.Add-New-Row').empty();

    $('#head-bar').append(returnFormComboxHeadBar('Nghành',listmanganh, listtennghanh, nghanhcurrent, 'changeKhoaandNghanh',250,0));
    $('#head-bar').append(returnFormAddComboxBar('chon-list-khoa-add' ,listkhoatemp , listniemkhoatemp, khoacurrenttemp, 'changeKhoaandNghanh',120,20,'Thêm khóa','them-khoa-input',['Thêm mới','Xác nhận','Danh sách'],['them-khoa-btn','xacnhan-khoa-btn','ds-khoa-btn'],['cornflowerblue','tomato','cornflowerblue']));

    $('#button-bar').append(returnIconHome() + returnNameIndex('Quản lý sinh viên') + returnNameIndex('Thêm mới') +  returnReturnBtn());
    $('.Add-New-Row').append(returnFormLabel('Thêm mới sinh viên'));
    $('.Add-New-Row').append(returnFormLabelInfo('Mã sinh viên',maSV));
    $('.Add-New-Row').append(returnFormInputTextLength('Tên','' ));
    $('.Add-New-Row').append(returnFormInputTime('Ngày sinh',2,''));

    $('.Add-New-Row').append(returnFormLabelInfo('Email',EmailSV));
    $('.Add-New-Row').append(returnFormInputTextLength('SDT','' ));

    if(listmachuyennganh.length > 0){
        $('.Add-New-Row').append(returnFormInputSelect('Chuyên nghành', 'changeChuyennghanh' , listmachuyennganh, listtenchuyennganh, chuyennghanhcurrent));
    }

    if(listlop.length > 0){
        $('.Add-New-Row').append(returnFormInputSelectHaveBtn('Lớp','combox-ds-lop',listlop,listlop,'','label-lop',lopcurrent,['themlopbtn','dslopbtn'],['Thêm lớp','Danh sách']))
        $('#combox-ds-lop').show();
        $('#label-lop').hide();
        $('#themlopbtn').show();
        $('#dslopbtn').hide();
        checklistlop = true;
    }else{
        $('.Add-New-Row').append(returnFormInputSelectHaveBtn('Lớp','combox-ds-lop',listlop,listlop,'','label-lop',lopcurrent,['themlopbtn','dslopbtn'],['Thêm lớp','Danh sách']))
        $('#combox-ds-lop').hide();
        $('#label-lop').show();
        $('#themlopbtn').hide();
        $('#dslopbtn').hide();
        checklistlop = false;
    }
    
    $('.Add-New-Row').append(returnFormInputText('GPA', ''));
    $('.Add-New-Row').append(returnFormBtn(nutThemSinhvien,maunutThemSinhvien,idnutThemSinhvien));

    LoadAddnewNienkhoa()
}

function LoadSuaFormSinhvien(listData,checkChuyennganh) {
    console.log(listData)
    $('#button-bar').show();
    $('.chose-bar').hide();
    $('#head-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();

    $('.Add-New-Row').show();
    $('#button-bar').empty();
    $('.Add-New-Row').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Quản lý sinh viên') + returnNameIndex('Sửa') +  returnReturnBtn());
    $('.Add-New-Row').append(returnFormLabel('Sửa sinh viên'));
    $('.Add-New-Row').append(returnFormLabelInfo('Mã sinh viên',listData.MaSV));

    $('.Add-New-Row').append(returnFormLabelInfo('Niêm khóa',listniemkhoa[listkhoa.indexOf(Number(khoacurrent))]));
    $('.Add-New-Row').append(returnFormLabelInfo('Nghành',listtennghanh[listmanganh.indexOf(nghanhcurrent)]));
    $('.Add-New-Row').append(returnFormInputTextLength('Tên',listData.TenSV ));

    $('.Add-New-Row').append(returnFormInputTime('Ngày sinh',2,listData.NgaySinh.replace('T17:00:00.000Z','')));
    $('.Add-New-Row').append(returnFormLabelInfo('Email',listData.Email));
    $('.Add-New-Row').append(returnFormInputTextLength('SDT',listData.SDT ));

    if(checkChuyennganh == 0){
        if(listmachuyennganh.length > 0){
            $('.Add-New-Row').append(returnFormInputSelect('Chuyên nghành', 'changeChuyennghanh' , listmachuyennganh, listtenchuyennganh, listData.MaCN));
        }
    }
    if(listlop.length > 0){
        $('.Add-New-Row').append(returnFormInputSelectHaveBtn('Lớp','combox-ds-lop',listlop,listlop,itemSV.MaLop,'label-lop',lopcurrent,['themlopbtn','dslopbtn'],['Thêm lớp','Danh sách']))
        $('#combox-ds-lop').show();
        $('#label-lop').hide();
        $('#themlopbtn').show();
        $('#dslopbtn').hide();
        checklistlop = true;
    }else{
        $('.Add-New-Row').append(returnFormInputSelectHaveBtn('Lớp','combox-ds-lop',listlop,listlop,itemSV.MaLop,'label-lop',lopcurrent,['themlopbtn','dslopbtn'],['Thêm lớp','Danh sách']))
        $('#combox-ds-lop').hide();
        $('#label-lop').show();
        $('#themlopbtn').hide();
        $('#dslopbtn').hide();
        checklistlop = false;
    }
    $('.Add-New-Row').append(returnFormInputText('GPA', listData.GPA));
    $('.Add-New-Row').append(returnFormBtn(['Xác nhận', 'Thoát'],['tomato', 'green'],['sua','thoat']));
}

////NGOAI LE
function LoadAddnewNienkhoa(){
    if(ismokhoa == true){
        
        ismokhoa = false;
        isaddSinhvien = true;
        document.getElementById('them-khoa-input').value = niemkhoamoi;

        listkhoa = [];
        for(let i = 0; i < liststartkhoa.length; i++){
            listkhoa.push(liststartkhoa[i].namBD);
        }
        console.log(listkhoa,nghanhcurrent)
        listkhoatemp = [];
        listniemkhoatemp = [];

        console.log(Number(niemkhoamoi) + 'xffffffffff')

        if(Number(niemkhoamoi) !== 0 || String(Number(niemkhoamoi)) !== 'NaN')
        if(listkhoa.indexOf(Number(niemkhoamoi)) !== -1){
            alert("Khóa đã tồn tại!")
            khoacurrent = Number(niemkhoamoi);
            loadListSinhvien();
        } else{
            if(Number(niemkhoamoi) >= rangeKhoa[0] && Number(niemkhoamoi) <= rangeKhoa[1]){
                $.getJSON( "/api/layniemkhoatheonam?MaNghanh="+nghanhcurrent, function( data ) {

                    console.log("/api/layniemkhoatheonam?MaNghanh="+nghanhcurrent)

                    listkhoatemp = listkhoa;
                    listkhoatemp.push(Number(niemkhoamoi));
                    listkhoatemp = bubbleSort(listkhoatemp);

                    console.log(Number(niemkhoamoi) + 'xffffffffff')

                    console.log(listkhoatemp+Number(niemkhoamoi))

                    for(let i = 0; i < listkhoatemp.length; i++){
                        if(Number(niemkhoamoi) == listkhoatemp[i]){
                            listniemkhoatemp.push(Number(niemkhoamoi) + '-' + Math.ceil(Number(niemkhoamoi) + data[0].SoNam));
                        }else{
                            for(let k = 0; k < liststartkhoa.length; k++){
                                if(Number(liststartkhoa[k].namBD) == Number(listkhoatemp[i])){
                                    listniemkhoatemp.push(listkhoatemp[i] + '-' + Math.ceil(listkhoatemp[i] + liststartkhoa[k].SoNam));
                                }
                            }
                        }
                    }
                    $('#chon-list-khoa-add').empty();

                    var element = '';
                    for(var i = 0; i < listniemkhoatemp.length; i++){
                        if(Number(listkhoatemp[i]) == Number(niemkhoamoi))
                        element = element + '<option selected value="'+listkhoatemp[i]+'">'+listniemkhoatemp[i]+'</option>';
                        else 
                        element = element + '<option value="'+listkhoatemp[i]+'">'+listniemkhoatemp[i]+'</option>';
                    }
                    $('#chon-list-khoa-add').append(element);
                    $('#chon-list-khoa-add').show();
                    $('#them-khoa-btn').show();
                    $('#them-khoa-input').hide();
                    $('#ds-khoa-btn').hide();
                    $('#xacnhan-khoa-btn').hide();
                    khoacurrenttemp = Number(niemkhoamoi);
                    changeKhoaandNghanh();

                });
            }
        }

    }
}

//CLICK-----------------------------------------------
function EventAdminClick(event) {
    var x = event.target;
    if( x.parentNode.className == "no-color-lum-table"){
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#no-color-btn-follow-row').attr("id", "yes-color-btn-follow-row");
        x.parentNode.className = 'yes-color-lum-table';
        currentrowtable = Number(x.parentNode.id.replace('collumtalbe-',''));
    }else if(x.parentNode.className == 'btn-follow-row'){
        if(x.id == "suax"){
            console.log(currentrowtable)
            itemSV = listinfoitem[currentrowtable];
            loadSuaListSinhvien();
        }
        if(x.id == 'xoax'){
            console.log(listinfoitem[currentrowtable].MaSV)
            xhttp.open("GET", "/api/xoasv?MaSV="+listinfoitem[currentrowtable].MaSV, false);
            xhttp.send();
        }

    }else if(x.id == 'them'){
        addSinhvien();
    }else if(x.className == "add_new_btn" || x.parentNode.className == "add_new_btn" || x.parentNode.parentNode.className == "add_new_btn" ||  x.parentNode.parentNode.parentNode.className == "add_new_btn"){
            loadAddListSinhvien();
    }else if(x.className == "return_btn" || x.parentNode.className == "return_btn" || x.parentNode.parentNode.className == "return_btn" ||  x.parentNode.parentNode.parentNode.className == "return_btn"){
        loadListSinhvien();
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
    }else if(x.parentNode.className == "nav-page" ){
        page_num = Number(x.innerHTML)
        loadListSinhvien();
    }else if(x.id == 'them-khoa-btn'){
        $('#chon-list-khoa-add').hide();
        $('#them-khoa-btn').hide();
        $('#them-khoa-input').show();
        $('#ds-khoa-btn').show();
        $('#xacnhan-khoa-btn').show();
    }else if(x.id == 'ds-khoa-btn'){
        $('#chon-list-khoa-add').show();
        $('#them-khoa-btn').show();
        $('#them-khoa-input').hide();
        $('#ds-khoa-btn').hide();
        $('#xacnhan-khoa-btn').hide();
    }else if(x.id == 'xacnhan-khoa-btn'){

        listkhoa = [];
        for(let i = 0; i < liststartkhoa.length; i++){
            listkhoa.push(liststartkhoa[i].namBD);
        }
        console.log(listkhoa)
        listkhoatemp = [];
        listniemkhoatemp = [];
        if(Number(document.getElementById('them-khoa-input').value) !== 0 || String(Number(document.getElementById('them-khoa-input').value)) !== 'NaN')
        if(listkhoa.indexOf(Number(document.getElementById('them-khoa-input').value)) !== -1){
            alert("Khóa đã tồn tại!")
        } else{
            if(Number(document.getElementById('them-khoa-input').value) >= rangeKhoa[0] && Number(document.getElementById('them-khoa-input').value) <= rangeKhoa[1]){
                $.getJSON( "/api/layniemkhoatheonam?MaNghanh="+nghanhcurrent, function( data ) {
                    
                    listkhoatemp = listkhoa;
                    listkhoatemp.push(Number(document.getElementById('them-khoa-input').value));
                    listkhoatemp = bubbleSort(listkhoatemp);

                    for(let i = 0; i < listkhoatemp.length; i++){
                        if(Number(document.getElementById('them-khoa-input').value) == listkhoatemp[i]){
                            listniemkhoatemp.push(Number(document.getElementById('them-khoa-input').value) + '-' + Math.ceil(Number(document.getElementById('them-khoa-input').value) + data[0].SoNam));
                        }else{
                            for(let k = 0; k < liststartkhoa.length; k++){
                                if(Number(liststartkhoa[k].namBD) == Number(listkhoatemp[i])){
                                    listniemkhoatemp.push(listkhoatemp[i] + '-' + Math.ceil(listkhoatemp[i] + liststartkhoa[k].SoNam));
                                }
                            }
                        }
                    }
                    $('#chon-list-khoa-add').empty();

                    var element = '';
                    for(var i = 0; i < listniemkhoatemp.length; i++){
                        if(Number(listkhoatemp[i]) == Number(document.getElementById('them-khoa-input').value))
                        element = element + '<option selected value="'+listkhoatemp[i]+'">'+listniemkhoatemp[i]+'</option>';
                        else 
                        element = element + '<option value="'+listkhoatemp[i]+'">'+listniemkhoatemp[i]+'</option>';
                    }
                    $('#chon-list-khoa-add').append(element);
                    $('#chon-list-khoa-add').show();
                    $('#them-khoa-btn').show();
                    $('#them-khoa-input').hide();
                    $('#ds-khoa-btn').hide();
                    $('#xacnhan-khoa-btn').hide();
                    khoacurrenttemp = Number(document.getElementById('them-khoa-input').value);
                    changeKhoaandNghanh();
                });
                
            }else{
                alert("Vượt quá năm quy định!")
            }

        }
    }else if(x.id == 'sua'){
        updateListSinhvien();
    }else if(x.id == 'thoat'){
        loadListSinhvien();
    }else if(x.id == 'themlopbtn'){
        $('#combox-ds-lop').hide();
        $('#label-lop').show();
        $('#themlopbtn').hide();
        $('#dslopbtn').show();
    }else if(x.id == 'dslopbtn'){
        $('#combox-ds-lop').show();
        $('#label-lop').hide();
        $('#themlopbtn').show();
        $('#dslopbtn').hide();
    }else if(x.id == "logout" ||  x.parentNode.id == "logout" || x.parentNode.parentNode.id == "logout"){
        if (confirm('Bạn có muốn đăng xuất')) {
            window.location.replace("/login");
          } else {
          }
    }else{
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
    }
}

//FIRST---------------------------------------------------------
if(GetUrlParameter('mokhoamoi') !== undefined){
    ismokhoa = true;
    niemkhoamoi = Number(GetUrlParameter('mokhoamoi'))
    console.log(niemkhoamoi)
}

loadListSinhvien();