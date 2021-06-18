$( "#act-giangvien" ).addClass( "active" )


$("#name-user").empty();
$("#name-user").append('Admin: ' + getCookie('QLNAME'));
var MaAdmin = getCookie('QL');

var listinfoitem;
var currentlist = 0;
var textsearch = '';

var page_num = 1;
var tol_page = 0;
var currentrowtable = -1;
var isAddGiangvien = false;

var MaGV;
var ngaytemp;
var giotemp;

var khoacurrent = 0;
var nghanhcurrent = '';
var listkhoa = [];
    var listniemkhoa = [];
var listnghanh = [];
    var listmanganh = [];
    var listtennghanh = [];


var tieudeBangGiangvien =['Mã' , 'Tên' , 'Ngày sinh' ,'SDT' , 'Email'];
var tennutBangGiangvien = ['Sửa','Xóa'];
var idnutBangGiangvien = ['suax' , 'xoax'];

var nutThemGiangvien =  ['Thêm','Thoát'];
var maunutThemGiangvien = ['tomato', 'green'];
var idnutThemGiangvien = ['them', 'thoat'];

var nutSuaGiangvien =  ['Sửa','Thoát'];
var matnutSuaGiangvien = ['tomato', 'green'];
var idnutSuaGiangvien = ['sua', 'thoat'];


var textsearch = '';


var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
                if(String(this.responseURL).includes('api/danhsachgiangvien')){
                    // tol_page =  Math.ceil(data[1][0]['count( maGV)'] / 10); 

                    // console.log(data)
                    // console.log(tol_page)
                    // listinfoitem = data[0];
                    // LoadListGiangvien(data[0]);

                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    listnghanh = data[0];
                    listkhoa = [];
                    for(let i = 0; i < data[1].length; i++){
                        listkhoa.push(data[1][i].namBD);
                    }
                    listniemkhoa = [];
                    for(let i = 0; i < data[1].length; i++){
                        listniemkhoa.push(data[1][i].namBD + '-' + Math.ceil(data[1][i].namBD + data[1][i].SoNam));
                    }
                    nghanhcurrent = data[2];
                    khoacurrent = data[3];
                    tol_page = Math.ceil(data[4][0]["NumberGV"] / 10); 
                    listinfoitem = data[5][0];

                    LoadListGiangvien(listinfoitem);
                }

                if(String(this.responseURL).includes('api/danhsachdulieugiangvien')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    tol_page =  Math.ceil(data[0][0]["NumberGV"] / 10); 
                    listinfoitem = data[1][0];
                    LoadListDataGiangvien(listinfoitem);
                }

                if(String(this.responseURL).includes('api/dieukienthemgv')){
                    var data = JSON.parse(this.responseText)
                    console.log(data);
                    // MaGV = data[0]['MaGV'];
                    LoadAddFormGiangvien(data[0]['MaGV']);
                }
                if(String(this.responseURL).includes('api/themgv')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    if(data.success === false){
                        alert(data.message)
                    }else{
                        loadListGiangvien();
                    }
                }

                if(String(this.responseURL).includes('api/suagv')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    if(data.success === false){
                        alert(data.message)
                    }else{
                        loadListGiangvien();
                    }
                }

                if(String(this.responseURL).includes('api/xoagv')){
                    console.log(String(this.responseText))
                    if(String(this.responseText) == '"that bai"')
                        alert('Email hoặc field rỗng')
                    else loadListGiangvien();
                }
        }
    };


///LOAD----------------------------------------------------
function loadListGiangvien(){
    xhttp.open("GET", "/api/danhsachgiangvien?page="+page_num+"&Khoa="+khoacurrent+"&MaNghanh="+String(nghanhcurrent)+"&MaAdmin="+MaAdmin+"&textsearch="+textsearch, false);
    xhttp.send();
}

function loadListDataGiangvien(){
    currentlist = 1;
    textsearch = '';
    xhttp.open("GET", "/api/danhsachdulieugiangvien?page="+page_num+"&Khoa="+khoacurrent+"&MaNghanh="+String(nghanhcurrent)+"&MaAdmin="+MaAdmin, false);
    xhttp.send();
}

function loadAddListGiangvien() {
    console.log(nghanhcurrent)
    xhttp.open("GET", "/api/dieukienthemgv?MaNghanh="+String(nghanhcurrent), false);
    xhttp.send();
}

function addGiangvien() {
    var MaGV = String(document.getElementsByClassName('label-item-add').item(0).innerHTML);
    var TenGV = document.getElementsByClassName('input-new-row-long').item(0).value;
    var SDT = document.getElementsByClassName('input-new-row-long').item(1).value;
    var email = document.getElementsByClassName('input-new-row-long').item(2).value;

    var thoigiansv = document.getElementsByClassName('thoigianform').item(0).value;
    thoigiansv = String(thoigiansv).split('T');
    var ngaysinh = thoigiansv[0];

    console.log(MaGV,TenGV,SDT,email,ngaysinh,String(nghanhcurrent) )

        xhttp.open("GET", "/api/themgv?MaGV="+MaGV+"&TenGV="+TenGV+"&SDT="+SDT+"&email="+email+"&ngaySinh="+ngaysinh+"&MaNghanh="+String(nghanhcurrent), false);
        xhttp.send();

}

function updateListGiangvien() {
    var MaGV = String(document.getElementsByClassName('label-item-add').item(0).innerHTML);
    var TenGV = document.getElementsByClassName('input-new-row-long').item(0).value;
    var SDT = document.getElementsByClassName('input-new-row-long').item(1).value;
    var email = document.getElementsByClassName('input-new-row-long').item(2).value;

    var thoigiansv = document.getElementsByClassName('thoigianform').item(0).value;
    thoigiansv = String(thoigiansv).split('T')
    var ngaysinh = thoigiansv[0];

    console.log(MaGV,TenGV,email,ngaysinh,SDT)

        xhttp.open("GET", "/api/suagv?MaGV="+MaGV+"&TenGV="+TenGV+"&SDT="+SDT+"&email="+email+"&ngaySinh="+ngaysinh+"&MaNghanh="+String(nghanhcurrent), false);
        xhttp.send();

}

function changeKhoaandNghanh(){
    var e = document.getElementsByClassName("select-combox-headbar").item(0);
    nghanhcurrent = String(e.options[e.selectedIndex].value);
    // e = document.getElementsByClassName("select-combox-headbar").item(1);
    // khoacurrent = e.options[e.selectedIndex].value;
    console.log("mới tạo "+nghanhcurrent,khoacurrent)
    if(isAddGiangvien == false){
        loadListGiangvien();
    }else{
        loadAddListGiangvien()
    }
}


function changesearch(s){
    // currentlist = 2;
    textsearch = s;
    page_num = 1;
    loadListGiangvien();
}

///ELEMENT-----------------------------------------------------

function LoadListGiangvien(data) {

    isAddGiangvien = false;
    currentlist = 1;
    listmanganh = [];
    listtennghanh = [];
    for(let i = 0;i < listnghanh.length; i++){
        listmanganh.push(listnghanh[i].MaNganh);
        listtennghanh.push(listnghanh[i].TenNganh);
    }

    $('#button-bar').show();
    $('#head-bar').show();
    $('.chose-bar').show();
    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();


    $('.Add-New-Row').hide();

    $('#head-bar').empty();
    $('#button-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Quản lý giảng viên') +  returnAddBtn());
    $('#head-bar').append(returnFormComboxHeadBar('Nghành',listmanganh, listtennghanh, nghanhcurrent, 'changeKhoaandNghanh',250,0));
    // $('#head-bar').append(returnFormComboxHeadBar('Niêm khóa',listkhoa , listniemkhoa, khoacurrent, 'changeKhoaandNghanh',120,20));


    if(document.getElementById('input-search')){
    }else{
        $('.chose-bar').empty();
        $('.chose-bar').append(returnSearchForm('Nhập giảng viên','Làm mới') );    }

    $('#table_data').append(returnTable(tieudeBangGiangvien,data));
    $('.btn-follow-row').append(returnButtonTable(tennutBangGiangvien,idnutBangGiangvien));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
}

function LoadListDataGiangvien(data){
    isAddGiangvien = false;
    currentlist = 1;
    listmanganh = [];
    listtennghanh = [];
    for(let i = 0;i < listnghanh.length; i++){
        listmanganh.push(listnghanh[i].MaNganh);
        listtennghanh.push(listnghanh[i].TenNganh);
    }


    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    $('#table_data').append(returnTable(tieudeBangGiangvien,data));
    $('.btn-follow-row').append(returnButtonTable(tennutBangGiangvien,idnutBangGiangvien));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
}

function LoadAddFormGiangvien(MaGV) {
    isAddGiangvien = true;
    $('#button-bar').show();
    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();

    $('.Add-New-Row').show();

    $('#button-bar').empty();
    $('.Add-New-Row').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Quản lý giảng viên') + returnNameIndex('Thêm mới') +  returnReturnBtn());
    $('.Add-New-Row').append(returnFormLabel('Thêm mới giảng viên'));
    $('.Add-New-Row').append(returnFormLabelInfo('Mã giảng viên',MaGV));
    $('.Add-New-Row').append(returnFormInputTextLength('Tên','' ));
    $('.Add-New-Row').append(returnFormInputTime('Ngày sinh',2,''));
    $('.Add-New-Row').append(returnFormInputTextLength('SDT', ''));
    $('.Add-New-Row').append(returnFormInputTextRight('Email', '@ptithcm.edu.vn'));
    $('.Add-New-Row').append(returnFormBtn(nutThemGiangvien,maunutThemGiangvien,idnutThemGiangvien));
}

function LoadSuaGiangvien(data) {
    console.log(data)

    MaGV = data.MaNV;

    $('#button-bar').show();
    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();

    $('.Add-New-Row').show();

    $('#button-bar').empty();
    $('.Add-New-Row').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Quản lý giảng viên') + returnNameIndex('Sửa') +  returnReturnBtn());
    $('.Add-New-Row').append(returnFormLabel('Sửa giảng viên'));
    $('.Add-New-Row').append(returnFormLabelInfo('Mã giảng viên',data.MaNV));
    // $('.Add-New-Row').append(returnFormLabelInfo('Nghành',listtennghanh[listmanganh.indexOf(nghanhcurrent)]));
    // $('.Add-New-Row').append(returnFormInputSelect('Nghành', 'xxxx' , listmanganh, listtennghanh, nghanhcurrent));

    $('.Add-New-Row').append(returnFormInputTextLength('Tên',data.TenNV ));
    $('.Add-New-Row').append(returnFormInputTime('Ngày sinh',2,data.NgaySinh.replace('T17:00:00.000Z','')));
    $('.Add-New-Row').append(returnFormInputTextLength('Tên',data.SDT ));
    $('.Add-New-Row').append(returnFormInputTextLength('Email', data.Email));

    $('.Add-New-Row').append(returnFormBtn(['Xác nhận','Thoát'],['tomato','green'],['sua','thoat']));
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
            LoadSuaGiangvien(listinfoitem[currentrowtable])
        }
        if(x.id == 'xoax'){
            xhttp.open("GET", "/api/xoagv?MaGV="+listinfoitem[currentrowtable].MaNV, false);
            xhttp.send();
            console.log(listinfoitem[currentrowtable].MaNV);
        }
    }else if(x.className == "add_new_btn" || x.parentNode.className == "add_new_btn" || x.parentNode.parentNode.className == "add_new_btn" ||  x.parentNode.parentNode.parentNode.className == "add_new_btn"){
        // LoadAddFormGiangvien();
        loadAddListGiangvien()
    }else if(x.className == "return_btn" || x.parentNode.className == "return_btn" || x.parentNode.parentNode.className == "return_btn" ||  x.parentNode.parentNode.parentNode.className == "return_btn"){
        loadListGiangvien() ;

        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
    }else if(x.id == "logout" ||  x.parentNode.id == "logout" || x.parentNode.parentNode.id == "logout"){
        if (confirm('Bạn có muốn đăng xuất')) {
            window.location.replace("/login");
          } else {
          }
    }else if(x.parentNode.className == "nav-page" ){
        page_num = Number(x.innerHTML)
        loadListGiangvien();
    } 
    else{
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
    }if(x.id == "them"){
        addGiangvien() 
    }
    if(x.id == "thoat"){
        loadListGiangvien() 
    }if(x.id == 'sua'){
        updateListGiangvien() 
    }

}

//FIRST---------------------------------------------------------
loadListGiangvien()