$( "#act-taikhoan" ).addClass( "active" )

$("#name-user").empty();
$("#name-user").append('Admin: ' + getCookie('QLNAME'));
var MaAdmin = getCookie('QL');

var listButtonpk = ['Phân công','Sửa','Xóa'];
var listIdBtnTable = ['phancongx', 'suax' , 'xoax'];

var listBtnpk =  ['Thêm','Thoát'];
var listColorpk = ['tomato', 'green'];
var listIdBtn = ['them', 'thoa'];

var listSuaBtnpk =  ['Sửa','Thoát'];
var listSuaColorpk = ['tomato', 'green'];
var listSuaIdBtn = ['sua', 'thoa'];

var listphancongbtn =  ['Phân công','Thoát'];


var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
                if(String(this.responseURL).includes('api/')){

                }
        }
    };

// ///LOAD----------------------------------------------------
function loadListTieuban(){
    xhttp.open("GET", "/api/danhsachtieuban?page="+page_num+"&khoa="+khoacurrent, false);
    xhttp.send();
}


//ELEMENT-----------------------------------------------------
function LoadListTieuban(data) {

    //xác định ẩn hiện
    $('#button-bar').show();
    $('.chose-bar').show();
    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();
    $('#head-bar').show();

    $('.Add-New-Row').hide();

    //làm rỗng các phần
    $('#head-bar').empty();
    $('#button-bar').empty();
    $('.chose-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    //thêm chi tiết vào
    $('#head-bar').append(returnFormListKhoa(listkhoa,khoacurrent));
    $('#button-bar').append(returnIconHome() + returnNameIndex('Quản lý tiểu ban') +  returnAddBtn());
    $('.chose-bar').append(returnSearchForm('Nhập mã tiểu ban','Tìm kiếm') );
    $('#table_data').append(returnTable( ['Tiểu ban','Ngày','Giờ','Trạng thái'],listTB));
    $('.btn-follow-row').append(returnButtonTable(listButtonpk,listIdBtnTable));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
}


function loadinterface(){
    $('#button-bar').empty();
    $('#button-bar').append(returnIconHome() + returnNameIndex('Tài khoản') + returnSwitchBtn('Thông tin', 'Mật khẩu'));

    LoadInfo();
}

function LoadInfo(){

    $('.Add-New-Row').show();
    $('.Add-New-Row').empty();

    //làm rỗng các phần
    $('.Add-New-Row').append(returnLormOneInfo('Mã tài khoản: ADM209'));
    $('.Add-New-Row').append(returnLormOneInfo('Tên Chủ Tài khoản : Minh Chiến'));
    $('.Add-New-Row').append(returnLormOneInfo('Ngày Sinh : 29/3/2009'));
    $('.Add-New-Row').append(returnLormOneInfo(''));
    $('.Add-New-Row').append(returnLormOneInfo(''));


}


function LoadDoimatkhau(){
    $('.Add-New-Row').show();
    $('.Add-New-Row').empty();
    //làm rỗng các phần
    $('.Add-New-Row').append(returnFormInputTextLength('Mật khẩu cũ','' ));
    $('.Add-New-Row').append(returnFormInputTextLength('Mật khẩu mới','' ));
    $('.Add-New-Row').append(returnFormInputTextLength('Nhập lại mật khẩu','' ));

    $('.Add-New-Row').append(returnFormBtn(['Đổi mật khẩu','Làm mới'],['tomato','green'],['doimatkhaubtn', 'lammoibtn']));
}

//CLICK-----------------------------------------------
function EventAdminClick(event) {
    var x = event.target;
    if( x.parentNode.className == "no-color-lum-table"){

    }else if(x.className == "loadswitch1"){
        LoadInfo();
        $('#activeswitchbar').removeAttr('id');
        x.id = 'activeswitchbar';
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
    }else if(x.className == "loadswitch2"){
        LoadDoimatkhau();
        $('#activeswitchbar').removeAttr('id');
        x.id = 'activeswitchbar';
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
    }else if(x.id == "logout" ||  x.parentNode.id == "logout" || x.parentNode.parentNode.id == "logout"){
        if (confirm('Bạn có muốn đăng xuất')) {
            window.location.replace("/login");
          } else {
          }
    }else{

    }
}

//FIRST------------------------------------------
loadinterface()
