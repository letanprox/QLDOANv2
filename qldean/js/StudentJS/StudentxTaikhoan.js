$( "#act-taikhoang" ).addClass( "active" )

$("#name-user").empty();
$("#name-user").append('SV: ' + getCookie('SVNAME'));
var MaSV = getCookie('SV');
console.log(MaSV + ':MÃ')

var currentwidth;
var MATK = '';


(function($){
    $.fn.focusTextToEnd = function(){
        this.focus();
        var $thisVal = this.val();
        this.val('').val($thisVal);
        return this;
    }
}(jQuery));


var labellist = ['name','day','number','emails'];

var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
                if(String(this.responseURL).includes('api/info_user')){
                    var data = JSON.parse(this.responseText);
                    
                    LoadInfo(data[0][0]);
                }

                if(String(this.responseURL).includes('api/sua_sv')){
                    if(String(this.responseText) == '"that bai"')
                        alert('Fail')
                    else{
                        alert('Cập nhật thành công!');
                        document.getElementById('cap-nhat-info-tai-khoang').style.opacity = '0.3';
                    } 
                  
                }

                if(String(this.responseURL).includes('api/doi_matkhau')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    if(Number(data[0][0].status) === 1){
                                                alert('Đổi mật khẩu thành công!');
                        $('#doimatkhau-taikhoan').empty();
                        $('#doimatkhau-taikhoan').append(
                            '<div><input id="old-pass" class="form-control" placeholder="mật khẩu cũ" type="password"></div>'+
                            '<div><input id="new-pass" class="form-control" placeholder="mật khẩu mới" type="password"></div>'+
                            '<div><input id="renew-pass" class="form-control" placeholder="xác nhận" type="password"></div>'+
                             '<div>'+
                            '<button id="xacnhan-pass">Xác nhận</button>'  +
                                '<button id="refresh-pass">Làm mới</button>'+
                                '</div>'
                        )
                    }else{
                        alert('Nhập sai mật khẩu cũ!')
                    }
                }
        }
    };

// ///LOAD----------------------------------------------------
function loadInfo(){
    xhttp.open("GET", "/api/info_user?Ma="+MaSV, false);
    xhttp.send();
}


function updateInfo(){

    let Ten = document.getElementById('input-name').value;
    // let Email = document.getElementById('input-emails').value;
    let SDT = document.getElementById('input-number').value;
    let Ngaysinh = getDateFormatx(document.getElementById('input-day').value);


    xhttp.open("GET", "/api/sua_sv?Ma="+MaSV+"&Ten="+Ten+"&SDT="+SDT+"&Ngaysinh="+Ngaysinh, false);
    xhttp.send();
}

function updatePass(){
    let OldPass = document.getElementById('old-pass').value;
    let NewPass = document.getElementById('new-pass').value;
    let RenewPass = document.getElementById('renew-pass').value;

    if(String(NewPass) === String(RenewPass)){
        xhttp.open("GET", "/api/doi_matkhau?Ma="+MATK+"&Pass="+NewPass+"&Old="+OldPass, false);
        xhttp.send();
    }else{
        alert('Mật khẩu xác nhận chưa đúng!')
    }

}


//ELEMENT-----------------------------------------------------
function loadinterface(){
    $('#button-bar').empty();
    $('#button-bar').append(returnIconHome() + returnNameIndex('Tài khoản'));
    loadInfo();
}

function LoadInfo(data){

    $('#doimatkhau-taikhoan').show();
    $('#doimatkhau-taikhoan').empty();
    $('#info-account').show();
    $('#info-account').empty();

    var element = '';

    data = data[0];
    console.log(data)

    MATK = data.MaTK;

    element = element + '<div><label class="label-title">Tên: </label><label id="label-name" >'+data.TenSV+'</label><input id="input-name" value="'+data.TenSV+'" type="text"><i id="pencil-name" class="fa fa-pencil" style="font-size:12px;" aria-hidden="true"></i></div>';
    element = element + '<div><label class="label-title">Ngày sinh: </label><label id="label-day" >'+getDateFormat(data.NgaySinh)+'</label><input id="input-day" value="'+getDateFormatx(data.NgaySinh)+'" type="date"><i id="pencil-day" class="fa fa-pencil" style="font-size:12px;" aria-hidden="true"></i></div>';
    element = element + '<div><label class="label-title">SDT: </label><label id="label-number" >'+data.SDT+'</label><input id="input-number" value="'+data.SDT+'" type="number"><i id="pencil-number" class="fa fa-pencil" style="font-size:12px;" aria-hidden="true"></i></div>';
    element = element + '<div><label class="label-title">Email: </label><label  >'+data.Email+'</label></div>';
    element = element + '<div><label class="label-title">Lớp: </label><label  >'+data.MaLop+'</label></div>';
    element = element + '<div><label class="label-title">GPA: </label><label  >'+data.GPA+'</label></div>';


    element = element + '<div><button id="cap-nhat-info-tai-khoang">Cập nhật</button></div>';

    $('#info-account').append(element);


    $('#doimatkhau-taikhoan').append(
        '<div><input id="old-pass" class="form-control" placeholder="mật khẩu cũ" type="password"></div>'+
        '<div><input id="new-pass" class="form-control" placeholder="mật khẩu mới" type="password"></div>'+
        '<div><input id="renew-pass" class="form-control" placeholder="xác nhận" type="password"></div>'+
        '<div>'+
            '<button id="xacnhan-pass">Xác nhận</button>'  +
            '<button id="refresh-pass">Làm mới</button>'+
        '</div>'
    )


    document.getElementById('contain-account').style.width = document.getElementById('button-bar').offsetWidth+'px';
    document.getElementById('info-account').style.width = Number(document.getElementById('button-bar').offsetWidth)/2+'px';
    currentwidth =  Number(document.getElementById('info-account').offsetWidth);

    for(var i = 0; i < labellist.length; i++){
        $( "#input-"+labellist[i] ).change(function() {
            document.getElementById('cap-nhat-info-tai-khoang').style.opacity = '1';
        });
    }
}




document.getElementById('input-name').style.display = "none";
//CLICK-----------------------------------------------
function EventTeacherClick(event) {
    var x = event.target;
    if( x.parentNode.className == "no-color-lum-table"){

    }else if(x.id == "pencil-name" || x.id == "label-name"){

        document.getElementById('pencil-name').style.display = "none";
        document.getElementById('input-name').style.display = "block";
        document.getElementById('label-name').style.display = "none";
        $('#input-name').focus();
        $('#input-name').focusTextToEnd();
    
    }else if(x.id == "pencil-emails" || x.id == "label-emails"){

        document.getElementById('pencil-emails').style.display = "none";
        document.getElementById('input-emails').style.display = "block";
        document.getElementById('label-emails').style.display = "none";
        $('#input-emails').focus();
        // $('#input-emails').focusTextToEnd();
    
    }else if(x.id == "pencil-day" || x.id == "label-day"){

        document.getElementById('pencil-day').style.display = "none";
        document.getElementById('input-day').style.display = "block";
        document.getElementById('label-day').style.display = "none";
        $('#input-day').focus();
        $('#input-day').focusTextToEnd();
    
    }else if(x.id == "pencil-number"  || x.id == "label-number"){

        document.getElementById('pencil-number').style.display = "none";
        document.getElementById('input-number').style.display = "block";
        document.getElementById('label-number').style.display = "none";
        $('#input-number').focus();
        $('#input-number').focusTextToEnd();
    
    }else if(x.id == "cap-nhat-info-tai-khoang"){

        if(document.getElementById('cap-nhat-info-tai-khoang').style.opacity === '1'){
            console.log("xxxxx");
            updateInfo();
        }
    
    }else if(x.id == "input-name" || x.id == "input-emails" || x.id == "input-day" || x.id == "input-number" || x.className == "label-title" ){

    }else if(x.id == "xacnhan-pass" ){
        updatePass();
    }else if(x.id == "refresh-pass"){


        $('#doimatkhau-taikhoan').empty();
        $('#doimatkhau-taikhoan').append(
            '<div><input class="form-control" placeholder="mật khẩu cũ" type="password"></div>'+
            '<div><input  class="form-control" placeholder="mật khẩu mới" type="password"></div>'+
            '<div><input  class="form-control" placeholder="xác nhận" type="password"></div>'+
            '<div>'+
                '<button>Xác nhận</button>'  +
                '<button id="refresh-pass">Làm mới</button>'+
            '</div>'
        )

        console.log("xxxx")
    }else if(x.id == "logout" ||  x.parentNode.id == "logout" || x.parentNode.parentNode.id == "logout"){
        if (confirm('Bạn có muốn đăng xuất')) {
            window.location.replace("/login");
          } else {
          }
    }else{

        for(var i = 0; i < labellist.length; i++){
            if(labellist[i] == 'day'){
                document.getElementById('label-'+labellist[i]).innerHTML  =  getDateFormat(String(document.getElementById('input-'+labellist[i]).value));
            }else{
                document.getElementById('label-'+labellist[i]).innerHTML  =  String(document.getElementById('input-'+labellist[i]).value);
            }
            document.getElementById('pencil-'+labellist[i]).style.display="block";
            document.getElementById('input-'+labellist[i]).style.display = "none";
            document.getElementById('label-'+labellist[i]).style.display = "block";
        }

        document.getElementById('info-account').style.width = currentwidth+'px';
        document.getElementById('contain-account').style.width = currentwidth*2+'px';
      
    }
}
//FIRST------------------------------------------
loadinterface()
loadInfo();