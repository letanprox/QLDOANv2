$( "#act-phancongtieuban" ).addClass( "active" );

var listinfoitem;
let currentrowtable;
var page_num = 1;
var tol_page = 0;

$("#name-user").empty();
$("#name-user").append('Admin: ' + getCookie('QLNAME'));
var MaAdmin = getCookie('QL');

var tieudeBangTB = ['Mã sinh viên','Tên sinh viên','Email','Điểm PB','Mã GVPB','Điểm'];
var tennutBangTB = ['Phân công'];
var idnutBangTB = ['phancongx'];

var nutPhancongTB =  ['Phân công ','Thoát'];
var maunutPhancongTB = ['tomato', 'green'];
var idnutPhancongTB = ['phancong', 'thoat'];


var TBtemp;
let MaGVtemp;
let MaDAtemp;
let MaSVtemp;
let nienkhoahientai;


var khoacurrent = 0;
var nghanhcurrent = 'null';
var listkhoa = [];
    var listniemkhoa = [];
var listnghanh = [];
    var listmanganh = [];
    var listtennghanh = [];

var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
                if(String(this.responseURL).includes('api/danhsachphancongTB')){
                    var data = JSON.parse(this.responseText);
                    console.log(data);

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

                    tol_page =  Math.ceil(data[4][0]['NumberSV'] / 10); 
                    listinfoitem = data[5][0];

                    nienkhoahientai =  data[6][0]['nienkhoahientai']

                    LoadListTieuban(listinfoitem);
                }

                if(String(this.responseURL).includes('api/danhsachTBphancong')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    LoadPhancongTieuban(data);
                }
                if(String(this.responseURL).includes('api/addTBphancong')){
                    if(String(this.responseText) == '"that bai"')
                        alert('Trùng mã sinh viên, Email hoặc field rỗng')
                    else
                    loadListTieuban()
                }
                if(String(this.responseURL).includes('api/infoTB')){
                    var data = JSON.parse(this.responseText)
                    console.log(data)
                    LoadInfoTB(data[0][0]);
                }
                
        }
    };


function loadListTieuban(){
    xhttp.open("GET", "/api/danhsachphancongTB?page="+page_num+"&Khoa="+khoacurrent+"&MaAdmin="+MaAdmin+"&MaNghanh="+String(nghanhcurrent), false);
    xhttp.send();
}

function loadPhancongTieuban(MaSV,MaDA){
    xhttp.open("GET", "/api/danhsachTBphancong?MaSV="+MaSV+"&Khoa="+khoacurrent+"&MaNghanh="+String(nghanhcurrent), false);
    xhttp.send();
}

function loadAddPhancongTieuban(){
    // var e = document.getElementsByClassName("slide-select-lorm").item(0);
    // var strUser = String(e.value).split(' - ');

    // console.log(strUser[0].replace(/ /g,''),MaDAtemp)

    xhttp.open("GET", "/api/addTBphancong?MaSV="+MaSVtemp+"&MaTB="+TBtemp, false);
    xhttp.send();
}

function changeKhoaandNghanh(){
    var e = document.getElementsByClassName("select-combox-headbar").item(0);
    nghanhcurrent = String(e.options[e.selectedIndex].value);
    e = document.getElementsByClassName("select-combox-headbar").item(1);
    khoacurrent = e.options[e.selectedIndex].value;
    console.log("mới tạo "+nghanhcurrent,khoacurrent)
    loadListTieuban();
}

function loadInfoTB(){
    xhttp.open("GET", "/api/infoTB?MaTB="+TBtemp, false);
    xhttp.send();
}

function LoadListTieuban(data) {
    console.log(data)

    listmanganh = [];
    listtennghanh = [];
    for(let i = 0;i < listnghanh.length; i++){
        listmanganh.push(listnghanh[i].MaNganh);
        listtennghanh.push(listnghanh[i].TenNganh);
    }

    $('#button-bar').show();
    $('.chose-bar').hide();
    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();
    $('#head-bar').show();
    $('#detail-bar').hide();
    $('.Add-New-Row').hide();

    $('#head-bar').empty();
    $('#button-bar').empty();
    $('.chose-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    $('#head-bar').append(returnFormComboxHeadBar('Nghành',listmanganh, listtennghanh, nghanhcurrent, 'changeKhoaandNghanh',250,0));
    $('#head-bar').append(returnFormComboxHeadBar('Niêm khóa',listkhoa , listniemkhoa, khoacurrent, 'changeKhoaandNghanh',120,20));

    $('#button-bar').append(returnIconHome() + returnNameIndex('Phụ trách')  + returnNameIndex('Tiểu ban') );

    $('#table_data').append(returnTable(tieudeBangTB,data));
    $('.btn-follow-row').append(returnButtonTable(tennutBangTB,idnutBangTB));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
}


function LoadPhancongTieuban(data) {

    var InfoSV = data[0][0][0];
    var listtb = data[1][0];

    $('#button-bar').show();
    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();
    $('#detail-bar').show();
    $('.Add-New-Row').show();

    $('#button-bar').empty();
    $('.Add-New-Row').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Phụ trách')  + returnNameIndex('Tiểu ban') + returnNameIndex('Phân công')  + returnReturnBtn());

    // $('.Add-New-Row').append(returnLormInfo( ['Mã sinh viên: '+InfoSV.MaSV,'Tên sinh viên: '+InfoSV.TenSV]));
    // $('.Add-New-Row').append(returnLormInfo( ['Lớp: '+InfoSV.Lop,'GPA: '+InfoSV.GPA]));
    // $('.Add-New-Row').append(returnLormOneInfo('Email: '+InfoSV.Email));

    // MaDAtemp = InfoSV.MaDA;

    // if(String(InfoSV.TenDA) != "")
    // $('.Add-New-Row').append(returnLormInfo(['Mã đồ án: '+InfoSV.MaDA ,'Tên đồ án: '+InfoSV.TenDA]));
    // else
    // $('.Add-New-Row').append(returnLormInfo(['Mã đồ án: '+InfoSV.MaDA ,'Tên đồ án: Chưa đặt tên']));

    // $('.Add-New-Row').append(returnLormOneInfo('Giảng viên hướng dẫn: '+InfoSV.MaGVHD));
    // $('.Add-New-Row').append(returnLormOneInfo('Giảng viên phản biện: '+InfoSV.MaGVPB));

    // if(String(InfoSV.DiemHD) != 'null')
    // $('.Add-New-Row').append(returnLormOneInfo('Điểm hướng dẫn: '+InfoSV.DiemHD));
    // else
    // $('.Add-New-Row').append(returnLormOneInfo('Điểm hướng dẫn: Chưa chấm'));

    // if(String(InfoSV.DiemPB) != '')
    // $('.Add-New-Row').append(returnLormOneInfo('Điểm phản biện: '+InfoSV.DiemPB));
    // else
    // $('.Add-New-Row').append(returnLormOneInfo('Điểm phản biện: Chưa chấm'));

    // let listTB = [];
    // let choseTB;

    // for(let i = 0; i < listtb.length; i++){
    //     if(String(listtb[i].MaTB) ===  String(TBtemp)) choseTB = listtb[i].MaTB + ' - ' + listtb[i]['total']
    //     listTB.push( listtb[i].MaTB  + '&nbsp;&nbsp; - &nbsp;&nbsp;&nbsp; ' + listtb[i]['total'])
    // }

    // if(String(TBtemp) == '' )
    // $('.Add-New-Row').append(returnLormInputSelect('Phân công tiểu ban: ',listTB ,listTB[0].MaTB));
    // else
    // $('.Add-New-Row').append(returnLormInputSelect('Phân công tiểu ban: ',listTB ,choseTB));

    // $('.Add-New-Row').append(returnLormBtn(nutPhancongTB,maunutPhancongTB,idnutPhancongTB));

    $('.Add-New-Row').empty();
    $('#detail-bar').empty();

    $('#detail-bar').append(

        '<div class="float-thong-tin-doan">'+
        '<span id="thongtin-doan">'+
            '<span id="thongtin-doan-doan">'+
                '<div>Thông tin sinh viên:</div>'+
                '<div>Mã: '+InfoSV.MaSV+'</div>'+
                '<div>Tên: '+InfoSV.TenSV+'</div>'+
                '<div>Ngày sinh: '+InfoSV.NgaySinh.replace('T17:00:00.000Z','')+'</div>'+
                '<div>SDT: '+InfoSV.SDT+'</div>'+
                '<div>Email: '+InfoSV.Email+'</div>'+
                '<div>Lớp: '+InfoSV.MaLop+'</div>'+
                '<div>Ngành: '+InfoSV.TenNganh+' - '+InfoSV.TenCN+'</div>'+

                '<div style="color: rgb(0, 0, 0); font-weight: bold;">Điểm đồ án:</div>'+
                '<span>Điểm GVHD: '+InfoSV.DiemHD+' </span>'+
                '<span>Điểm GVPB: '+InfoSV.DiemPB+' </span>'+
                '<span>Điểm GVPB: '+InfoSV.DiemTB+' </span>'+
                '<span></span>'+
                '<span></span>'+
                '<span></span>'+
            '</span>'+
        '</span>'+
        '</div>'
    );

    $('#detail-bar').append(
        '<span id="thongtin-sv">'+
            '<div>Thông tin giảng viên:</div>'+
            '<div>Mã: DA03</div>'+
            '<div>Tên: Lập trình AI</div>'+
            '<div>SDT: 01551551530</div>'+
            '<div>Email: cuocsong@gmail.com</div>'+
            '<div></div>'+
        '</span>'
    )

    MaSVtemp = InfoSV.MaSV;


    var elementListGV = '';
    for(var i = 0; i < listtb.length; i++){
        if(String(InfoSV.MaTB) === String(listtb[i].MaTB))
        elementListGV = elementListGV + '<option value='+listtb[i].MaTB+' selected>'+listtb[i].MaTB+' - '+listtb[i].total+'</option>';
        else
        elementListGV = elementListGV + '<option value='+listtb[i].MaTB+'>'+listtb[i].MaTB+' - '+listtb[i].total+'</option>';
    }
    $('#detail-bar').append(
        '<div class="phan-cong-muc">'+
            '<select class="select-sinh-vien browser-default custom-select">'+
                    elementListGV+
            '</select>'+
            '<button class="phancong-sinhvien-doan-btn">Phân công</button>'+
        '</div>'
    )

    if(String(InfoSV.MaTB) != 'null'){
        TBtemp = String(InfoSV.MaTB);
    }else{
        TBtemp = String(listtb[0].MaTB);
    }

    $('.select-sinh-vien').on('change', function() {
        TBtemp = this.value;
        loadInfoTB();
    });


    loadInfoTB();

}


function LoadInfoTB(data){
    console.log(data)

    var infotb = data[0];
    $('#thongtin-sv').empty()
    $('#thongtin-sv').append(
        '<div>Thông tin tiểu ban:</div>'+
        '<div>Mã: '+infotb.MaTB+'</div>'+
        '<div>Tên: '+infotb.Ca+'</div>'+
        '<div>Ngày: '+infotb.Ngay.replace('T17:00:00.000Z','')+'</div>'+
        '<div>Thành phần: </div>'
        // '<div>Email: '+infotb.Email+'</div>'+
    )

    $('#thongtin-sv').append(
        '<div style="margin-top:0px" id="groupgvtb"></div>'
    )

    
    for(var i = 0; i<data.length; i++){
        $('#groupgvtb').append(
            '<span style="width:100%; float:left; margin-left:10px">GV'+Number(i + 1)+': '+data[i].MaGV+' - '+data[i].TenGV+'</span>'
        )
    }

  
}


function LoadChitietTieuban() {
    $('#button-bar').show();
    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();

    $('.Add-New-Row').show();

    $('#button-bar').empty();
    $('.Add-New-Row').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Phụ trách')  + returnNameIndex('Tiểu ban') + returnNameIndex('Chi tiết')  +  returnReturnBtn());

    $('.Add-New-Row').append(returnLormInfo(listInfoTieuban1));
    $('.Add-New-Row').append(returnLormInfo(listInfoTieuban2));
    $('.Add-New-Row').append(returnLormOneInfo('Giảng viên hướng dẫn: GV02 - Trần Minh Chiến'));
    $('.Add-New-Row').append(returnLormOneInfo('Giảng viên phản biện: GV02 - Trần Minh Chiến'));

    $('.Add-New-Row').append(returnLormOneInfo('Tiểu ban: TB023'));
    $('.Add-New-Row').append(returnLormBtn(['Thoát'],['tomato'],['thoat']));

}


//CLICK-----------------------------------------------
function EventAdminClick(event) {
    var x = event.target;
    if( x.parentNode.className == "no-color-lum-table"){
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        if(khoacurrent == nienkhoahientai){
            $('#no-color-btn-follow-row').attr("id", "yes-color-btn-follow-row");
        }
        x.parentNode.className = 'yes-color-lum-table';
        currentrowtable = Number(x.parentNode.id.replace('collumtalbe-',''));
    }else if(x.parentNode.className == 'btn-follow-row'){
        if(x.id == "phancongx" ){
            if(khoacurrent == nienkhoahientai){
            TBtemp = listinfoitem[currentrowtable].MaTB;
            loadPhancongTieuban(listinfoitem[currentrowtable].MaSV ,  listinfoitem[currentrowtable].MaDA)
            }
        }else if(x.id == "chitietx"){
            LoadChitietTieuban();
        }
    }else if(x.className == "add_new_btn" || x.parentNode.className == "add_new_btn" || x.parentNode.parentNode.className == "add_new_btn" ||  x.parentNode.parentNode.parentNode.className == "add_new_btn"){
        LoadAddFormTieuban();
    }else if(x.className == "return_btn" || x.parentNode.className == "return_btn" || x.parentNode.parentNode.className == "return_btn" ||  x.parentNode.parentNode.parentNode.className == "return_btn"){
        loadListTieuban();
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
    }else if(x.className == 'phancong-sinhvien-doan-btn'){
        loadAddPhancongTieuban()
    }else if(x.id == 'phancong'){
        loadAddPhancongTieuban()
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

//FIRST------------------------------------------

loadListTieuban();