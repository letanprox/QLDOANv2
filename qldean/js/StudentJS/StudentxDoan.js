$( "#act-doan" ).addClass( "active" )

// var MaSV = 'N17DCCN001';

$("#name-user").empty();
$("#name-user").append('SV: ' + getCookie('SVNAME'));
var MaSV = getCookie('SV');
console.log(MaSV + ':MÃ')


var danhsachcheckMota = ['Tệp văn bản','Tệp trình chiếu','Tệp chương trình'];
var contentfile = '';
var filename = '';

var tieudeBangTieuban = ['STT','MaSV','TenSV','MaLop','SDT','Email'];

var listinfoitem;
var page_num = 1;
var tol_page = 0;


var MaDA;
var MaPC;
var MaTB;
var listDiemx = '';

var isupdatefile = false;


var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {

                if(String(this.responseURL).includes('api/doan-sinhvien')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    LoadListTieuban(data[0][0][0],data[1][0][0],data[2][0][0],data[3][0][0])
                }

                if(String(this.responseURL).includes('nopbaocao-sinhvien')){
                    if(String(this.responseText) == '"that bai"')alert('Fail')
                    else {
                        alert('Cập nhật thành công')
                        isupdatefile = false;
                        document.getElementById('cap-nhat-baocao').style.opacity = '0.2';
                    };
                }

                if(String(this.responseURL).includes('danhsach-tieuban-sinhvien')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    tol_page =  Math.ceil(data[0][0]["Number"] / 10); 
                    LoadDanhsachtieuban(data[1][0])
                }
            }
        }



function loadDoanSinhvien(){
    xhttp.open("GET", "api/doan-sinhvien?MaSV="+MaSV, false);
    xhttp.send();
}


function loadDanhsachtieuban(){
    xhttp.open("GET", "api/danhsach-tieuban-sinhvien?MaTB="+MaTB+"&page="+page_num, false);
    xhttp.send();
}



function getFile(){
    document.getElementById('selectedFile').click();
}

function ResetCheckbox(){
    for(var i = 0; i < danhsachcheckMota.length; i++){
        if(document.getElementsByClassName("form-check-input").item(i)) document.getElementsByClassName("form-check-input").item(i).checked = false;
    }

    
    $(".input-more-checkbox").empty();
    $(".input-more-checkbox").hide();
}

//LOAD ELEMENT TIỂU BAN-----------------------------------------------------
function LoadListTieuban(infodoan,infodiem,infotep,infogvtb) {

    $('#button-bar').show();
    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();
    $('#head-bar').hide();
    $('.Add-New-Row').hide();

    $('.Detail-project').show();

    $('#head-bar').empty();
    $('#button-bar').empty();
    $('.chose-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    

    $('#button-bar').append(returnIconHome() + returnNameIndex('Đồ án'));

    $('.Detail-project').empty();

    var elementGVorTB = '';

    if(infogvtb.hasOwnProperty('Email')){
        elementGVorTB = elementGVorTB + '<div>Thông tin giảng viên:</div>'+
                                        '<span>Mã: '+infogvtb.MaNV+'</span>'+
                                        '<span>Tên: '+infogvtb.TenNV+'</span>'+
                                        '<span>Email: '+infogvtb.Email+'</span>'+
                                        '<span>SDT: '+infogvtb.SDT+'</span>'
    }else{
        MaTB = infogvtb.MaTB;
        elementGVorTB = elementGVorTB + '<div>Thông tin tiểu ban:</div>'+
                                        '<span>Mã: '+infogvtb.MaTB+'</span>'+
                                        '<span>Ngày:' +infogvtb.Ngay+'</span>'+
                                        '<span>Ca: '+infogvtb.Ca+'</span>'+
                                        '<span><button id="danhsach-tieuban">Danh sách</button></span>'

            
    }

    $('.Detail-project').append(
        '<span id="info-doan-sv">'+
            '<div>Thông tin đồ án:</div>'+
            '<div>Mã: '+infodoan.MaDA+'</div>'+
            '<div>Tên: '+infodoan.TenDA+'</div>'+
            '<div>Tài liệu hướng dẫn: <a href="">'+infodoan.Tep_Goc+'</a> </div>'+
            elementGVorTB+
            
        '</span>'
    )

    MaDA = infodoan.MaDA;
    MaPC = infodiem.MaPhanCong;
    filename = infodoan.Tep;


    var elementDiem = '<span id="info-diem-doan-sv"><div>Điểm đồ án:</div>';

    if(String(infodiem.DiemHD) != 'null'){
        elementDiem = elementDiem + '<div>Hướng dẫn:</div><div style="margin-top: 0px;"><table style="width:100%; margin-top: 3px;"><tr>' + '<td>'+infodiem.MaGVHD+' - '+infodiem.TenGVHD+'</td> <td>Điểm: '+infodiem.DiemHD+'</td>' + '</tr></table></div><br><br>';
        listDiemx = listDiemx + String(infodiem.DiemHD)+'-';


    }
    if(String(infodiem.DiemPB) != 'null'){
        elementDiem = elementDiem + '<div>Phản biện:</div><div style="margin-top: 0px;"><table style="width:100%; margin-top: 3px;"><tr>' + '<td>'+infodiem.MaGVPB+' - '+infodiem.TenGVPB+'</td> <td>Điểm: '+infodiem.DiemPB+'</td>' + '</tr></table></div><br><br>';
        listDiemx = listDiemx + String(infodiem.DiemPB)+'-';


    }
    if(String(infodiem.DiemTB) != 'null'){
        elementDiem = elementDiem + '<div>Tiểu ban:</div><div style="margin-top: 0px;"><table style="width:100%; margin-top: 3px;"><tr>' + '<td>'+infodiem.MaTB+'&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</td> <td>Điểm: '+infodiem.DiemTB+'</td>' + '</tr></table></div>';
        listDiemx = listDiemx + String(infodiem.DiemTB)+'-';



    }
    elementDiem = elementDiem + '</span>';
    $('.Detail-project').append(
        elementDiem
    )


    $('.Detail-project').append(
        '<span class="up-file-baocao">'+
            '<div style="font-weight: bold; color: blueviolet; width: 100%;">Nộp báo cáo: </div>'+
            '<span class="uploadfile-tag">'+
            '</span>'+
            '<div id="check-box-baocao" >'+
                '<span>Mô tả: </span> '+
                '<span class="checkboxtag">'+
                '</span>'+
            '</div>'+

            '<button id="cap-nhat-baocao">Cập nhật</button>'+
        '</span>'
    )


    $('.uploadfile-tag').append(
        '<button onclick="getFile()" class="add-file-add-row" >Thêm tệp</button>   '+
            '<span id="contentfile-1" class="item-add-file-upload"><span id="ten_tep">'+infotep.Tep_Goc+'</span>   '+
                '<span>   <svg height="20px" viewBox="0 0 512.171 512.171" width="20px"> <path d="m243.1875 182.859375 113.132812-113.132813c12.5-12.5 12.5-32.765624 0-45.246093l-15.082031-15.082031c-12.503906-12.503907-32.769531-12.503907-45.25 0l-113.128906 113.128906-113.132813-113.152344c-12.5-12.5-32.765624-12.5-45.246093 0l-15.105469 15.082031c-12.5 12.503907-12.5 32.769531 0 45.25l113.152344 113.152344-113.128906 113.128906c-12.503907 12.503907-12.503907 32.769531 0 45.25l15.082031 15.082031c12.5 12.5 32.765625 12.5 45.246093 0l113.132813-113.132812 113.128906 113.132812c12.503907 12.5 32.769531 12.5 45.25 0l15.082031-15.082031c12.5-12.503906 12.5-32.769531 0-45.25zm0 0"></path> </svg>  </span> '+
            '</span> '
    );
    $('.checkboxtag').append(returnCheckBoxHaveMore_(danhsachcheckMota))

    for(var i = 0; i < danhsachcheckMota.length ; i++){
        if(String(infotep.MoTa).includes(danhsachcheckMota[i])){
            document.getElementsByClassName("form-check-input").item(i).checked = true;
        }
    }

    if(String(infotep.MoTa) !== 'null' && String(infotep.MoTa) !== ''){
        var Motacuoi = String(infotep.MoTa).split(',')
        Motacuoi = Motacuoi[Motacuoi.length - 2];
        if(!danhsachcheckMota.includes(Motacuoi)){
            if(String(Motacuoi) != ''){
                $(".input-more-checkbox").show();
                document.getElementsByClassName("form-check-input").item(danhsachcheckMota.length).checked = true;
                document.getElementsByClassName('input-more-checkbox').item(0).value = Motacuoi;
            }else{
                $(".input-more-checkbox").hide();
                document.getElementsByClassName("form-check-input").item(danhsachcheckMota.length).checked = false;
            }
        }else{
            $(".input-more-checkbox").hide()
            document.getElementsByClassName("form-check-input").item(danhsachcheckMota.length).checked = false;
        }
    }else{
        $(".input-more-checkbox").hide()
        document.getElementsByClassName("form-check-input").item(danhsachcheckMota.length).checked = false;
    }

    if(String(infotep.Tep_Goc) !== 'null' && String(infotep.Tep_Goc) !== ''){
        $('.add-file-add-row').hide();
    }

    $(".input-more-checkbox").change(function() {
        document.getElementById('cap-nhat-baocao').style.opacity = '1';
    })


    $(".form-check-input").change(function() {
        document.getElementById('cap-nhat-baocao').style.opacity = '1';
    })

    $("#check-khac").change(function() {
        document.getElementById('cap-nhat-baocao').style.opacity = '1';
        if(this.checked){
            $(".input-more-checkbox").show();
        }else{
            $(".input-more-checkbox").hide();
        }
    });

    document.getElementById('cap-nhat-baocao').style.opacity = '0.2';

    document.getElementById('selectedFile').onchange = function() {

        document.getElementById('cap-nhat-baocao').style.opacity = '1';

        isupdatefile = true;
        ResetCheckbox();
        document.getElementsByClassName('input-more-checkbox').item(0).value = '';
        document.getElementsByClassName("form-check-input").item(danhsachcheckMota.length).checked = false;
        var fullPath = document.getElementById('selectedFile').value;
        if (fullPath) {
            var startIndex = (fullPath.indexOf('\\') >= 0 ? fullPath.lastIndexOf('\\') : fullPath.lastIndexOf('/'));
            filename = fullPath.substring(startIndex);
            if (filename.indexOf('\\') === 0 || filename.indexOf('/') === 0) {
                filename = filename.substring(1);
            }

            contentfile = document.getElementById("selectedFile").files[0];


            $('#ten_tep').empty();
            $('#ten_tep').append(filename)

            $(".item-add-file-upload").show();
            $("#check-box-baocao").show();
            $('.add-file-add-row').hide();
        }
    };

}



function LoadDanhsachtieuban(data) {
    var listdata = [];
    for(var i = 0; i < data.length; i++){
        listdata.push({stt: (page_num-1)*10 + i+1, Masv: data[i].MaSV, TenSV: data[i].TenSV, MaLop: data[i].MaLop,SDT:data[i].SDT, Email: data[i].Email})
    }
    $('#button-bar').show();
    $('.chose-bar').show();
    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();
    $('#head-bar').show();
    $('.Add-New-Row').hide();
    $('.Detail-project').hide();

    $('#head-bar').empty();
    $('#button-bar').empty();
    $('.chose-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Đồ án') + returnNameIndex('Danh sách báo cáo') +  returnReturnBtn());
    $('.chose-bar').append(returnSearchForm('Tìm mã sinh viên','Làm mới')  );
    $('#table_data').append(returnTable( tieudeBangTieuban ,listdata));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
}





//CLICK-----------------------------------------------
async function EventTeacherClick(event) {
    var x = event.target;
    if( x.parentNode.className == "no-color-lum-table"){

    }else if(x.parentNode.parentNode.className == 'item-add-file-upload'){
        // x.parentNode.parentNode.parentNode.removeChild(x.parentNode.parentNode);
        $(".item-add-file-upload").hide();
        
        console.log('delete');
        $("#check-box-baocao").hide();
        $('.add-file-add-row').show();
    }else if(x.parentNode.parentNode.parentNode.className == 'item-add-file-upload'){
        // x.parentNode.parentNode.parentNode.parentNode.removeChild(x.parentNode.parentNode.parentNode);
        $(".item-add-file-upload").hide();

        console.log('deletxe')
        $("#check-box-baocao").hide();
        $('.add-file-add-row').show();
        
    }else if(x.className == "return_btn" || x.parentNode.className == "return_btn" || x.parentNode.parentNode.className == "return_btn" ||  x.parentNode.parentNode.parentNode.className == "return_btn"){
        
        $('#button-bar').show();
        $('.chose-bar').hide();
        $('#table_data').hide();
        $('.btn-follow-row').hide();
        $('.nav-page').hide();
        $('#head-bar').hide();
        $('.Add-New-Row').hide();
    
        $('.Detail-project').show();
    
        $('#head-bar').empty();
        $('#button-bar').empty();
        $('.chose-bar').empty();
        $('#table_data').empty();
        $('.btn-follow-row').empty();
        $('.nav-page').empty();
    
        
    
        $('#button-bar').append(returnIconHome() + returnNameIndex('Đồ án'));
    
        $('.Detail-project').show();


    }else if(x.id == "cap-nhat-baocao" ){



        if(isupdatefile == true){

            console.log('upfile')

            var namefilex = MaSV+MaDA+getCurrentTime().replace(/\D/g,'')+contentfile['name'];

            var formData = new FormData();
            formData.append("file", contentfile);        
            formData.append("namefile", namefilex);                            
            xhttp.open("POST", '/api/upfile_doan');
            xhttp.send(formData);

        }



        if(document.getElementById('cap-nhat-baocao').style.opacity === '1'){

            var namefilex;
            if(isupdatefile == true){
                namefilex = MaSV+MaDA+getCurrentTimex().replace(/\D/g,'')+contentfile['name'];
            }else{
                namefilex = filename;
            }

            var checkedValue = []; 
            var inputElements = document.getElementsByClassName('form-check-input');
            for(var i=0; inputElements[i]; ++i){
                  if(inputElements[i].checked){
                       checkedValue.push(inputElements[i].value);
                  }
            }
            if(checkedValue.includes('khac')){
                checkedValue.push(document.getElementsByClassName('input-more-checkbox').item(0).value)
            }
            var infotep = '';
            for(var i = 0; i < checkedValue.length; i++){
                if(String(checkedValue[i]) !== 'khac')
                infotep = infotep + checkedValue[i] + ',';
            }
            console.log(infotep,MaPC,listDiemx,namefilex,getCurrentTime)
            xhttp.open("GET", "/api/nopbaocao-sinhvien?MaPC="+MaPC+"&infotep="+infotep+"&listDiemx="+listDiemx+"&ngay="+getCurrentTimex()+"&namefilex="+namefilex, false);
            xhttp.send();
        }




    }else if(x.id == "danhsach-tieuban" ){
        loadDanhsachtieuban()
    }else if(x.id == "logout" ||  x.parentNode.id == "logout" || x.parentNode.parentNode.id == "logout"){
        if (confirm('Bạn có muốn đăng xuất')) {
            window.location.replace("/login");
          } else {
          }
    }
}






loadDoanSinhvien();