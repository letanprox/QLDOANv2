$( "#act-taikhoan" ).addClass( "active" );

$("#name-user").empty();
$("#name-user").append('Admin: ' + getCookie('QLNAME'));
var MaAdmin = getCookie('QL');

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
    $('#button-bar').append(returnIconHome() + returnNameIndex('Tài khoản'));
    LoadInfo();
}

function LoadInfo(){
    $('#doimatkhau-taikhoan').show();
    $('#info-taikhoan').show();
    $('#info-taikhoan').empty();
    $('#info-taikhoan').append(
        '<div><span>Tên: </span><span>Nguyễn Ngọc Hân</span></div>'+
        '<div><span>Email: </span> <span>Nguyenngocurx@gmail.com</span></div>'+
        '<div><span>SDT: </span><span>02554484542</span></div>'+
        '<div><span>Ngày sinh: </span> <span>21/12/2021</span></div>'
    )

    $('#doimatkhau-taikhoan').append(
        '<div><input class="form-control" placeholder="mật khẩu cũ" type="password"></div>'+
        '<div><input  class="form-control" placeholder="mật khẩu mới" type="password"></div>'+
        '<div><input  class="form-control" placeholder="xác nhận" type="password"></div>'+
        '<div>'+
            '<button>Xác nhận</button>'  +
            '<button>Làm mới</button>'+
        '</div>'
    )

    document.getElementById('button-bar').style.width = document.getElementById('contain-account').offsetWidth+'px';

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

(function($){
    $.fn.focusTextToEnd = function(){
        this.focus();
        var $thisVal = this.val();
        this.val('').val($thisVal);
        return this;
    }
}(jQuery));




$( "#input-name" ).change(function() {
    document.getElementById('cap-nhat-info-tai-khoang').style.opacity = '1';
  });


document.getElementById('input-name').style.display = "none";
//CLICK-----------------------------------------------
function EventAdminClick(event) {
    var x = event.target;
    if( x.parentNode.className == "no-color-lum-table"){

    }else if(x.id == "pencil-name"){

        x.style.display="none";
        document.getElementById('input-name').style.display = "block";
        document.getElementById('label-name').style.display = "none";

        
        $('#input-name').focus();
        $('#input-name').focusTextToEnd();
    
    }else if(x.id == "input-name" || x.className == "label-title" ){


    
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

        document.getElementById('label-name').innerHTML  =  String(document.getElementById('input-name').value);
        document.getElementById('pencil-name').style.display="block";
        document.getElementById('input-name').style.display = "none";
        document.getElementById('label-name').style.display = "block";
      
    }
}
//FIRST------------------------------------------
loadinterface()
