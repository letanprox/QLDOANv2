$( "#act-phancongphanbien" ).addClass( "active" );

var listinfoitem;
let currentrowtable;
var page_num = 1;
var tol_page = 0;

$("#name-user").empty();
$("#name-user").append('Admin: ' + getCookie('QLNAME'));
var MaAdmin = getCookie('QL');

var tieudeBangPB = ['Mã sinh viên','Tên sinh viên','Email','Điểm HD','Mã GVPB','Điểm'];
var tennutBangPB = ['Phân công'];
var idnutBangPB = ['phancongx'];

var nutPhancongPB =  ['Phân công ','Thoát'];
var maunutPhancongPB = ['tomato', 'green'];
var idnutPhancongPB = ['phancong', 'thoat'];

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
                if(String(this.responseURL).includes('api/danhsachphancongPB')){
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

                    LoadListPhanbien(listinfoitem);
                }

                if(String(this.responseURL).includes('api/danhsachGVPBphancong')){
                    var data = JSON.parse(this.responseText)

                    console.log(data)
                    LoadPhancongPhanbien(data);

                }
                if(String(this.responseURL).includes('api/addGVPBphancong')){
                    if(String(this.responseText) == '"that bai"')
                        alert('Trùng mã sinh viên, Email hoặc field rỗng')
                    else
                        loadListPhanbien()
                }
                if(String(this.responseURL).includes('api/infoGVPB')){
                    var data = JSON.parse(this.responseText)
                    console.log(data)
                    LoadInfoGV(data[0][0][0]);
                }
        }
    };



function loadListPhanbien(){
    console.log(nghanhcurrent)
    xhttp.open("GET", "/api/danhsachphancongPB?page="+page_num+"&Khoa="+khoacurrent+"&MaAdmin="+MaAdmin+"&MaNghanh="+String(nghanhcurrent), false);
    xhttp.send();
}

function loadPhancongPhanbien(MaSV,MaDA){
    xhttp.open("GET", "/api/danhsachGVPBphancong?MaSV="+MaSV+"&MaAdmin="+MaAdmin+"&MaNghanh="+String(nghanhcurrent), false);
    xhttp.send();
}

function loadAddPhancongPhanbien(){

    xhttp.open("GET", "/api/addGVPBphancong?MaSV="+MaSVtemp+"&MaGVPB="+MaGVtemp, false);
    xhttp.send();
}

function changeKhoaandNghanh(){
    var e = document.getElementsByClassName("select-combox-headbar").item(0);
    nghanhcurrent = String(e.options[e.selectedIndex].value);
    e = document.getElementsByClassName("select-combox-headbar").item(1);
    khoacurrent = e.options[e.selectedIndex].value;
    console.log("mới tạo "+nghanhcurrent,khoacurrent)
    loadListPhanbien();
}

function loadInfoGV(){
    xhttp.open("GET", "/api/infoGVPB?MaGV="+MaGVtemp, false);
    xhttp.send();
}



function LoadListPhanbien(data) {
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

    $('#button-bar').append(returnIconHome() + returnNameIndex('Phụ trách')  + returnNameIndex('Phản biện') );

    $('#table_data').append(returnTable(tieudeBangPB,data));
    $('.btn-follow-row').append(returnButtonTable(tennutBangPB,idnutBangPB));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
}


function LoadPhancongPhanbien(data) {

    
    var InfoSV = data[0][0][0];
    var listgvpb = data[1][0];

    console.log(InfoSV,listgvpb)

    $('#button-bar').show();
    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();
    $('#detail-bar').show();
    $('.Add-New-Row').show();

    $('#button-bar').empty();
    $('.Add-New-Row').empty();



    $('#button-bar').append(returnIconHome() + returnNameIndex('Phụ trách')  + returnNameIndex('Phản biện') + returnNameIndex('Phân công')  + returnReturnBtn());
    // $('.Add-New-Row').append(returnLormInfo( ['Mã sinh viên: '+InfoSV.MaSV,'Tên sinh viên: '+InfoSV.TenSV]));

    // $('.Add-New-Row').append(returnLormInfo( ['Lớp: '+InfoSV.Lop,'GPA: '+InfoSV.GPA]));
    // $('.Add-New-Row').append(returnLormOneInfo('Email: '+InfoSV.Email));

    // if(String(InfoSV.TenDA) != 'null')
    // $('.Add-New-Row').append(returnLormInfo(['Mã đồ án: '+InfoSV.MaDA ,'Tên đồ án: '+InfoSV.TenDA]));
    // else
    // $('.Add-New-Row').append(returnLormInfo(['Mã đồ án: '+InfoSV.MaDA ,'Tên đồ án: Chưa đặt tên']));

    // $('.Add-New-Row').append(returnLormOneInfo('Giảng viên hướng dẫn: ' +InfoSV.MaGVHD + ' - '+InfoSV.TenGVHD));

    // if(String(InfoSV.DiemHD) != 'null')
    // $('.Add-New-Row').append(returnLormOneInfo('Điểm hướng dẫn: '+InfoSV.DiemHD));
    // else
    // $('.Add-New-Row').append(returnLormOneInfo('Điểm hướng dẫn: Chưa chấm'));

    // if(String(InfoSV.DiemPB) != '')
    // $('.Add-New-Row').append(returnLormOneInfo('Điểm phản biện: '+InfoSV.DiemPB));
    // else
    // $('.Add-New-Row').append(returnLormOneInfo('Điểm phản biện: Chưa chấm'));

    // MaDAtemp = InfoSV.MaDA;

    // let listGVPB = [];
    // let choseGV;

    // for(let i = 0; i < listgvpb.length; i++){
    //     if(String(listgvpb[i].MaGV) ===  String(MaGVtemp)) choseGV = listgvpb[i].MaGV+' - '+listgvpb[i].TenGV
    //     listGVPB.push( listgvpb[i].MaGV+' - '+listgvpb[i].TenGV)
    // }

    // if(String(MaGVtemp) == 'null')
    // $('.Add-New-Row').append(returnLormInputSelect('Phân công giáo viên phản biện: ',listGVPB ,listgvpb[0].MaGV+' - '+listgvpb[0].TenGV));
    // else
    // $('.Add-New-Row').append(returnLormInputSelect('Phân công giáo viên phản biện: ',listGVPB ,choseGV));
    // $('.Add-New-Row').append(returnLormBtn(nutPhancongPB,maunutPhancongPB,idnutPhancongPB));

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
    for(var i = 0; i < listgvpb.length; i++){
        if(String(InfoSV.MaGVPB) === String(listgvpb[i].MaGV))
        elementListGV = elementListGV + '<option value='+listgvpb[i].MaGV+' selected>'+listgvpb[i].MaGV+' - '+listgvpb[i].TenGV+'</option>';
        else
        elementListGV = elementListGV + '<option value='+listgvpb[i].MaGV+'>'+listgvpb[i].MaGV+' - '+listgvpb[i].TenGV+'</option>';
    }

    $('#detail-bar').append(
        '<div class="phan-cong-muc">'+
            '<select class="select-sinh-vien browser-default custom-select">'+
                    elementListGV+
            '</select>'+
            '<button class="phancong-sinhvien-doan-btn">Phân công</button>'+
        '</div>'
    )


    if(String(InfoSV.MaGVPB) != 'null'){
        MaGVtemp = String(InfoSV.MaGVPB);
    }else{
        MaGVtemp = String(listgvpb[0].MaGV);
    }

    $('.select-sinh-vien').on('change', function() {
        MaGVtemp = this.value;
        loadInfoGV();
    });

    loadInfoGV();



}



function LoadInfoGV(data){
    $('#thongtin-sv').empty();


    console.log(data)
    $('#thongtin-sv').append(
        '<div>Thông tin giảng viên:</div>'+
        '<div>Mã: '+data.MaNV+'</div>'+
        '<div>Tên: '+data.TenNV+'</div>'+
        '<div>SDT: '+data.SDT+'</div>'+
        '<div>Email: '+data.Email+'</div>'+
        '<div>Ngày sinh: '+data.NgaySinh.replace('T17:00:00.000Z','')+'</div>'+
        '<div></div>'
    )
}


function LoadChitietPhanbien() {
    $('#button-bar').show();
    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();

    $('.Add-New-Row').show();

    $('#button-bar').empty();
    $('.Add-New-Row').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Phụ trách')  + returnNameIndex('Phản biện') + returnNameIndex('Chi tiết')  +  returnReturnBtn());

    $('.Add-New-Row').append(returnLormInfo(listInfoPhanbien1));
    $('.Add-New-Row').append(returnLormInfo(listInfoPhanbien2));
    $('.Add-New-Row').append(returnLormOneInfo('Giảng viên hướng dẫn: GV02 - Trần Minh Chiến'));
    $('.Add-New-Row').append(returnLormOneInfo('Tiểu ban: TB02'));

    $('.Add-New-Row').append(returnLormOneInfo('Giảng viên phản biện: GV02 - Trần Minh Chiến'));
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
            console.log(listinfoitem[currentrowtable].MaSV)
            MaGVtemp = listinfoitem[currentrowtable].MaGVPB;
            MaSVtemp =  listinfoitem[currentrowtable].MaSV;
            loadPhancongPhanbien(listinfoitem[currentrowtable].MaSV,  listinfoitem[currentrowtable].MaDA);
            }
        }else if(x.id == "chitietx"){
            LoadChitietPhanbien();
        }
    }else if(x.className == "add_new_btn" || x.parentNode.className == "add_new_btn" || x.parentNode.parentNode.className == "add_new_btn" ||  x.parentNode.parentNode.parentNode.className == "add_new_btn"){
        LoadAddFormPhanbien();
    }else if(x.className == "return_btn" || x.parentNode.className == "return_btn" || x.parentNode.parentNode.className == "return_btn" ||  x.parentNode.parentNode.parentNode.className == "return_btn"){
        loadListPhanbien();
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
    }else if(x.className == 'phancong-sinhvien-doan-btn'){
        loadAddPhancongPhanbien();
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

loadListPhanbien();