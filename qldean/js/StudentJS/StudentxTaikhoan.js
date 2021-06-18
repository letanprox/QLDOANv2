$( "#act-taikhoang" ).addClass( "active" )

$("#name-user").empty();
$("#name-user").append('SV: ' + getCookie('SVNAME'));
var MaSV = getCookie('SV');
console.log(MaSV + ':MÃ')


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
function loadinterface(){
    $('#button-bar').empty();
    $('#button-bar').append(returnIconHome() + returnNameIndex('Tài khoản') + returnSwitchBtn('Thông tin', 'Mật khẩu'));
    LoadInfo();
}

function LoadInfo(){
    $('#doimatkhau-taikhoan').hide();
    $('#info-taikhoan').show();
    $('#info-taikhoan').empty();
    $('#info-taikhoan').append(
        '<div><span>Tên: </span><span>Nguyễn Ngọc Hân</span></div>'+
        '<div><span>Email: </span> <span>Nguyenngocurx@gmail.com</span></div>'+
        '<div><span>SDT: </span><span>02554484542</span></div>'+
        '<div><span>Ngày sinh: </span> <span>21/12/2021</span></div>'
    )
}


function LoadDoimatkhau(){
    $('#info-taikhoan').hide();
    $('#doimatkhau-taikhoan').show();
    $('#doimatkhau-taikhoan').empty();
    $('#doimatkhau-taikhoan').append(
        '<div><input class="form-control" placeholder="mật khẩu cũ" type="password"></div>'+
        '<div><input  class="form-control" placeholder="mật khẩu mới" type="password"></div>'+
        '<div><input  class="form-control" placeholder="xác nhận" type="password"></div>'+
        '<div>'+
            '<button>Xác nhận</button>'  +
            '<button>Làm mới</button>'+
        '</div>'
    )
}

//CLICK-----------------------------------------------
function EventTeacherClick(event) {
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
