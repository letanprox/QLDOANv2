$( "#act-phanconghuongdan" ).addClass( "active" );

var listinfoitem;
let currentrowtable;
var page_num = 1;
var tol_page = 0;

$("#name-user").empty();
$("#name-user").append('Admin: ' + getCookie('QLNAME'));
var MaAdmin = getCookie('QL');

var tieudeBangHD = ['Mã sinh viên','Tên sinh viên','Email','GPA','Mã GVHD','Tên GVHD','Điểm'];
var tennutBangHD = ['Phân công'];
var idnutBangHD = ['phancongx'];

var nutPhancongHD =  ['Phân công ','Thoát'];
var maunutPhancongHD = ['tomato', 'green'];
var idnutPhancongHD = ['phancong', 'thoat'];

let MaGVtemp;
let MaDAtemp;
let MaSVtemp;
let NgaySinhtemp;
let GPAtemp = 0;
let nienkhoahientai;
let TTmokhoamoi;

var khoacurrent = 0;
var nghanhcurrent = '';
var listkhoa = [];
    var listniemkhoa = [];
var listnghanh = [];
    var listmanganh = [];
    var listtennghanh = [];

var textsearch = '';

var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
                if(String(this.responseURL).includes('api/danhsachphancongHD')){
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

                    GPAtemp = data[4];

                    tol_page =  Math.ceil(data[5][0]['NumberSV'] / 10); 
                    listinfoitem = data[6][0];
                    nienkhoahientai =  data[7][0]['nienkhoahientai']
                    TTmokhoamoi = data[8][0]['TTmokhoamoi']
                    LoadListHuongdan(listinfoitem);
                }

                if(String(this.responseURL).includes('api/danhsachGVHDphancong')){
                    var data = JSON.parse(this.responseText)

                    LoadPhancongHuongdan(data);
                }
                if(String(this.responseURL).includes('api/addGVHDphancong')){
                    if(String(this.responseText) == '"that bai"')
                        alert('Trùng mã sinh viên, Email hoặc field rỗng')
                    else
                        loadListHuongdan();
                }
                if(String(this.responseURL).includes('api/infoGVHD')){
                    var data = JSON.parse(this.responseText)
                    console.log(data)
                    LoadInfoGV(data[0][0][0]);
                }
                


        }
    };


function loadListHuongdan(){
    xhttp.open("GET", "/api/danhsachphancongHD?page="+page_num+"&GPA="+GPAtemp+"&Khoa="+khoacurrent+"&MaAdmin="+MaAdmin+"&MaNghanh="+String(nghanhcurrent)+"&textsearch="+textsearch, false);
    xhttp.send();
}

function loadPhancongHuongdan(MaSV){
    xhttp.open("GET", "/api/danhsachGVHDphancong?MaSV="+MaSV+"&Khoa="+khoacurrent+"&MaAdmin="+MaAdmin+"&MaNghanh="+String(nghanhcurrent), false);
    xhttp.send();
}

function loadAddPhancongHuongdan(){
        xhttp.open("GET", "/api/addGVHDphancong?MaSV="+MaSVtemp+"&MaGVHD="+MaGVtemp, false);
        xhttp.send();
}


function changeKhoaandNghanh(){
    var e = document.getElementsByClassName("select-combox-headbar").item(0);
    nghanhcurrent = String(e.options[e.selectedIndex].value);
    e = document.getElementsByClassName("select-combox-headbar").item(1);
    khoacurrent = e.options[e.selectedIndex].value;
    loadListHuongdan();
}


function loadInfoGV(){
    xhttp.open("GET", "/api/infoGVHD?MaGV="+MaGVtemp, false);
    xhttp.send();
}

function LoadListHuongdan(data) {
    listmanganh = [];
    listtennghanh = [];
    for(let i = 0;i < listnghanh.length; i++){
        listmanganh.push(listnghanh[i].MaNganh);
        listtennghanh.push(listnghanh[i].TenNganh);
    }

    $('#button-bar').show();
    $('.chose-bar').show();
    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();
    $('#head-bar').show();
    $('.Add-New-Row').hide();
    $('#detail-bar').hide();

    $('#head-bar').empty();
    $('#button-bar').empty();
    $('.chose-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    

    $('#head-bar').append(returnFormComboxHeadBar('Nghành',listmanganh, listtennghanh, nghanhcurrent, 'changeKhoaandNghanh',250,0));
    $('#head-bar').append(returnFormComboxHeadBar('Niêm khóa',listkhoa , listniemkhoa, khoacurrent, 'changeKhoaandNghanh',120,20));
    if(TTmokhoamoi == 1) $('#head-bar').append( '<a href="/admin/quanlysinhvien?mokhoamoi='+nienkhoahientai+'">'+ returnAddBtnLeftLabel('Mở Khóa mới') + '</a>');

    $('#button-bar').append(returnIconHome() + returnNameIndex('Phụ trách')  + returnNameIndex('Hướng dẫn') );
    $('.chose-bar').append(returnSearchForm('Nhập GPA tối thiểu','Lọc') );
    document.getElementById('input-search').value = GPAtemp;

    $('#table_data').append(returnTable(tieudeBangHD,data));
    $('.btn-follow-row').append(returnButtonTable(tennutBangHD,idnutBangHD));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
}


function LoadPhancongHuongdan(data) {
    var InfoSV = data[0][0][0];
    var listgvhd = data[1][0];

    console.log(InfoSV)
    console.log(listgvhd)

    $('#detail-bar').show();
    $('#button-bar').show();
    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();

    $('.Add-New-Row').show();

    $('#button-bar').empty();
    $('.Add-New-Row').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Phụ trách')  + returnNameIndex('Hướng dẫn') + returnNameIndex('Phân công')  + returnReturnBtn());

    // $('.Add-New-Row').append(returnLormInfo( ['Mã sinh viên: '+InfoSV.MaSV,'Tên sinh viên: '+InfoSV.TenSV]));
    // $('.Add-New-Row').append(returnLormInfo( ['Lớp: '+InfoSV.MaLop,'GPA: '+InfoSV.GPA]));
    // $('.Add-New-Row').append(returnLormOneInfo('SDT: '+InfoSV.SDT));
    // $('.Add-New-Row').append(returnLormOneInfo('Email: '+InfoSV.Email));

    // if(String(InfoSV.TenDA) != '')
    // $('.Add-New-Row').append(returnLormInfo(['Mã đồ án: '+InfoSV.MaDA ,'Tên đồ án: '+InfoSV.TenDA]));
    // else
    // $('.Add-New-Row').append(returnLormInfo(['Mã đồ án: '+InfoSV.MaDA ,'Tên đồ án: Chưa đặt tên']));

    // if(String(InfoSV.Diem) != '')
    // $('.Add-New-Row').append(returnLormOneInfo('Điểm hướng dẫn: '+InfoSV.Diem));
    // else
    // $('.Add-New-Row').append(returnLormOneInfo('Điểm hướng dẫn: Chưa chấm'));

    // MaDAtemp = InfoSV.MaDA;
    // MaSVtemp = InfoSV.MaSV;
    // NgaySinhtemp = InfoSV.NgaySinh;

    // let listGVHD = [];
    // let choseGV;

    // for(let i = 0; i < listgvhd.length; i++){
    //     if(String(listgvhd[i].MaGV) ===  String(MaGVtemp)) choseGV = listgvhd[i].MaGV+' - '+listgvhd[i].TenGV
    //     listGVHD.push( listgvhd[i].MaGV+' - '+listgvhd[i].TenGV)
    // }
       
    // if(String(MaGVtemp) == 'null')
    // $('.Add-New-Row').append(returnLormInputSelect('Phân công giáo viên hướng dẫn: ',listGVHD ,listgvhd[0].MaGV+' - '+listgvhd[0].TenGV));
    // else
    // $('.Add-New-Row').append(returnLormInputSelect('Phân công giáo viên hướng dẫn: ',listGVHD ,choseGV));
    // $('.Add-New-Row').append(returnLormBtn(nutPhancongHD,maunutPhancongHD,idnutPhancongHD));

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
                '<span>Điểm GVHD: '+InfoSV.Diem+' </span>'+
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
    for(var i = 0; i < listgvhd.length; i++){
        if(String(InfoSV.MaGVHD) === String(listgvhd[i].MaGV))
        elementListGV = elementListGV + '<option value='+listgvhd[i].MaGV+' selected>'+listgvhd[i].MaGV+' - '+listgvhd[i].TenGV+'</option>';
        else
        elementListGV = elementListGV + '<option value='+listgvhd[i].MaGV+'>'+listgvhd[i].MaGV+' - '+listgvhd[i].TenGV+'</option>';
    }

    $('#detail-bar').append(
        '<div class="phan-cong-muc">'+
            '<select class="select-sinh-vien browser-default custom-select">'+
                    elementListGV+
            '</select>'+
            '<button class="phancong-sinhvien-doan-btn">Phân công</button>'+
        '</div>'
    )

    if(String(InfoSV.MaGVHD) != 'null'){
        MaGVtemp = String(InfoSV.MaGVHD);
    }else{
        MaGVtemp = String(listgvhd[0].MaGV);
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



//CLICK-----------------------------------------------
function EventAdminClick(event) {
    var x = event.target;
    if( x.parentNode.className == "no-color-lum-table"){

        currentrowtable = Number(x.parentNode.id.replace('collumtalbe-',''));
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        x.parentNode.className = 'yes-color-lum-table';
        if(khoacurrent == nienkhoahientai && String(listinfoitem[currentrowtable].Diem) == ''){
            $('#no-color-btn-follow-row').attr("id", "yes-color-btn-follow-row");
        }else{
            $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
        }
     

   
    }else if(x.parentNode.className == "nav-page" ){
        page_num = Number(x.innerHTML)
        loadListHuongdan();
    } else if(x.parentNode.className == 'btn-follow-row'){
        if(x.id == "phancongx" ){
            if(khoacurrent == nienkhoahientai){
            MaGVtemp = listinfoitem[currentrowtable].MaGVHD;
            loadPhancongHuongdan(listinfoitem[currentrowtable].MaSV);
            }
        }
    }else if(x.className === 'phancong-sinhvien-doan-btn'){
        loadAddPhancongHuongdan();
    }else if(x.className == "add_new_btn" || x.parentNode.className == "add_new_btn" || x.parentNode.parentNode.className == "add_new_btn" ||  x.parentNode.parentNode.parentNode.className == "add_new_btn"){
        LoadAddFormHuongdan();
    }else if(x.className == "return_btn" || x.parentNode.className == "return_btn" || x.parentNode.parentNode.className == "return_btn" ||  x.parentNode.parentNode.parentNode.className == "return_btn"){
        // LoadListHuongdan();
        loadListHuongdan();
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
    }else if(x.id == 'refresh-index'){
        GPAtemp = Number(document.getElementById('input-search').value);
        loadListHuongdan();
    }else if(x.id == 'phancong'){
        loadAddPhancongHuongdan();
    }else if(x.id== 'thoat'){
        loadListHuongdan();
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

loadListHuongdan();