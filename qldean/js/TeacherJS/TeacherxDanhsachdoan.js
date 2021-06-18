$( "#act-danhsachdoan" ).addClass( "active" )

var tieudeBangTacadoan =  ['Đồ án' , 'Chuyên ngành' , 'Người tạo','Ngày tạo','Lần cuối cập nhật','Sinh viên thực hiện'] 
var tennutBangTacadoan = ['Tài liệu'];
var idnutBangTacadoan = ['tailieu'];

var tieudeBangCanhandoan =  ['Mã đồ án','Tên đồ án', 'Ngày tạo', 'Sinh viên thực hiện' ];
var tennutBangCanhandoan = [ 'Sửa', 'Xóa' ,'Tài liệu'];
var idnutBangCanhandoan = ['sua','xoa','tailieu'];

var tieudeBangTailieu = ['Tệp','Giảng viên','Mô tả','Thời gian',"null"]

var nutThemDoan = ['Xác nhận', 'Thoát'];
var maunutThemDoan = ['tomato','green'];
var idnutThemDoan = ['them','thoat'];

var nutSuaDoan = ['Xác nhận', 'Thoát'];
var maunutSuaDoan = ['tomato','green'];
var idnutSuaDoan = ['suax','thoat'];

var danhsachcheckMota = ['Tệp văn bản','Tệp trình chiếu','Tệp chương trình'];

var listchuyenganh = [];
    var listmachuyennganh = [];
    var listtenchuyennganh = [];


$("#name-user").empty();
$("#name-user").append('GV: ' + getCookie('GVNAME'));
var MaGV = getCookie('GV');
console.log(MaGV + ':MÃ')


var MaChuyennganh = "";
var MaDoan = '';
var TenDoan = '';
var MaCT = '';
var MaSV = '';
var MaCTTailieu = '';
var MaSVCanhan;
var TenSVCanhan;

var contentfile;
var namefilex;
var tepname;

var listinfoitem;
var page_num = 1;
var tol_page = 1;

var pageStatus = 1;  /// MANY PAGE
var pagelist = 0; ///SWITCH
let checkfileupdate = false; ///FILE IS UPDATED ?

var checkaddthemfile = false;
var NUMBERFILE;

var textsearch = '';


var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {

                if(String(this.responseURL).includes('api/danhsachdoan-data')){
                    var data = JSON.parse(this.responseText);
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
                    MaChuyennganh = data[1];
                    tol_page =  Math.ceil(data[2][0]['Number'] / 10); 
                    listinfoitem = data[3][0]
                    LoadListDoan(chuyendoiBangdoancanhan(listinfoitem))
                    pagelist = 1;
                }
                if(String(this.responseURL).includes('api/danhsachdoan-tatca')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    tol_page =  Math.ceil(data[0][0]['Number'] / 10); 
                    listinfoitem = data[1][0];
                    LoadListDoanTatca(chuyendoiBangdoantatca(listinfoitem))
                    pagelist = 2;
                }
                if(String(this.responseURL).includes('api/danhsachdoan-canhan')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    tol_page =  Math.ceil(data[0][0]['Number'] / 10); 
                    listinfoitem = data[1][0];
                    LoadListDoanCanhan(chuyendoiBangdoancanhan(listinfoitem))
                    pagelist = 1;
                }
                if(String(this.responseURL).includes('api/danhsachtailieu')){
                    var data = JSON.parse(this.responseText);
                    console.log(data);
                    tol_page =  Math.ceil(data[0][0]['Number'] / 10); 
                    listinfoitem = data[1][0];

                    LoadTailieu(listinfoitem,data[2][0]['Checkx']);
                }

                if(String(this.responseURL).includes('api/dieukienthemdoan')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    listchuyenganh = data[0][0];
                    listmachuyennganh = [];
                    for(let i = 0; i< listchuyenganh.length; i++){
                        listmachuyennganh.push(listchuyenganh[i].MaCN)
                    }
                    listtenchuyennganh = [];
                    for(let i = 0; i < listchuyenganh.length; i++){
                        listtenchuyennganh.push(listchuyenganh[i].TenCN)
                    }
                    MaDoan = data[1][0]['MaDoan'];
                    LoadAddDoan();
                }
                if(String(this.responseURL).includes('api/themdoan')){
                    if(String(this.responseText) == '"that bai"')alert('Fail')
                    else {
                        LoadHeadPage1();
                        if(pagelist == 1) loadListDoanCanhan();
                        else if((pagelist == 2)) loadListDoanTatca();
                    };
                }

                if(String(this.responseURL).includes('api/dieukiensuadoan')){
                    var data = JSON.parse(this.responseText);
                    LoadSuaDoan(data[0][0]);
                }
                if(String(this.responseURL).includes('api/suadoan')){
                    if(String(this.responseText) == '"that bai"')alert('Fail')
                    else {

                        if(pageStatus == 2){
                             $('.Form-input-file').hide();
                             $('.shadow-input-diem').hide();
                            loadListTailieu()   
                        }else{
                            LoadHeadPage1();
                            if(pagelist == 1) loadListDoanCanhan();
                            else if((pagelist == 2)) loadListDoanTatca();
                        }

                    };
                }
                if(String(this.responseURL).includes('api/xoadoan')){
                    if(String(this.responseText) == '"that bai"')alert('Fail')
                    else {
                        LoadHeadPage1();
                        if(pagelist == 1) loadListDoanCanhan();
                        else if((pagelist == 2)) loadListDoanTatca();
                    };
                }


                if(String(this.responseURL).includes('api/firstload-phancong-tailieu')){
                    var data = JSON.parse(this.responseText);
                    console.log("Thông tin đồ án")
                    console.log(data[0][0][0])
                    console.log(data[1][0])
                    LoadPhancongTailieu(data[0][0][0],data[1][0]);
                    console.log(data[1][0])  
                }
                if(String(this.responseURL).includes('api/infosv-phancong-tailieu')){
                    var data = JSON.parse(this.responseText);
                    console.log(data[0][0][0])
                    LoadInfoSvPhancongtailieu(data[0][0][0])
                }
                if(String(this.responseURL).includes('api/IsExitFileHD')){
                    var data = JSON.parse(this.responseText);
                    console.log(data[0][0]['Number'])

                    if(Number(data[0][0]['Number']) === 0){
                        NUMBERFILE = Number(data[0][0]['Number']);
                        loadAddThemFile();

                    }else{
                        if (confirm('Tài liệu hướng dẫn bạn tải lên cho đồ án này chưa được sử dụng. Bạn có muốn thay thế nó không?')) {
                            // Save it!
                            NUMBERFILE = Number(data[0][0]['Number']);
                            checkaddthemfile = true;
                            loadAddThemFile();
                            console.log('Thing was saved to the database.');
                          } else {
                            // Do nothing!
                            $('.Form-input-file').hide();
                            $('.shadow-input-diem').hide();
                            console.log('Thing was not saved to the database.');
                          }
                    }
                    // LoadInfoSvPhancongtailieu(data[0][0][0])
                }

                
                if(String(this.responseURL).includes('api/add-phancong-tailieu')){
                    if(String(this.responseText) == '"that bai"')alert('Fail')
                    else {
                        loadListTailieu()
                    };
                }  


                if(String(this.responseURL).includes('api/check-phancong-tailieu')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    if (confirm('Sinh viên này đã được phân công đồ án, bạn có muốn thay đổi?')) {
                        // Save it!
                         xhttp.open("GET", "/api/add-phancong-tailieu?MaDoan="+MaDoan+"&MaGV="+MaGV+"&MaSV="+MaSV+"&MaCT="+MaCT, false);
                        xhttp.send();    
                      } else {
                        // Do nothing!
                      }
                    
                } 
        }
    };


function changeChuyennganh(){
    var e = document.getElementsByClassName("select-combox-headbar").item(0);
    MaChuyennganh = String(e.options[e.selectedIndex].value);
    if(pagelist == 1) loadListDoanCanhan();
    else if(pagelist == 2) loadListDoanTatca();
}

function chuyendoiBangdoantatca(data){
    var listdoantatca = [];
    var status = '';
    for(let i = 0; i < data.length; i++){
        if(Number(data[i].totalPCInCurYear) == 0)  status = 'Chưa phân công';
        else  status = 'Đã phân công';

        if(String(data[i].MaSV) === 'null')
        listdoantatca.push({Doan: String(data[i].MaDA+' - '+data[i].TenDA) , CN: String(data[i].MaCN+' - '+data[i].tenCN), Nguoitao: String(data[i].MaGV+' - '+data[i].TenGV) , Ngaytao: String(data[i].minThoiGian).replace('T',' '), Capnhatcuoi: String(data[i].maxThoiGian) , Trangthai:'' })
        else
        listdoantatca.push({Doan: String(data[i].MaDA+' - '+data[i].TenDA) , CN: String(data[i].MaCN+' - '+data[i].tenCN), Nguoitao: String(data[i].MaGV+' - '+data[i].TenGV) , Ngaytao: String(data[i].minThoiGian).replace('T',' '), Capnhatcuoi: String(data[i].maxThoiGian) , Trangthai: String(data[i].MaSV) +' - ' + String(data[i].TenSV) })

    }
    return listdoantatca;
}

function chuyendoiBangdoancanhan(data){
    let bangcanhan = [];
    let status;
    for(let i = 0;i < data.length; i++){
        if(data[i].totalPCinCurYear == 0) status = 'Chưa phân công';
        else status = 'Đã phân công';


        if(String(data[i].MaSV) === 'null')
        bangcanhan.push({madoan: data[i].MaDA, Tendoan: data[i].TenDA, ngaytao:data[i].ThoiGian.replace('T',' '), trangthai: ''})
        else 
        bangcanhan.push({madoan: data[i].MaDA, Tendoan: data[i].TenDA, ngaytao:data[i].ThoiGian.replace('T',' '), trangthai:  String(data[i].MaSV) +' - ' + String(data[i].TenSV)})
    }
    return bangcanhan;
}
   
function loadListDoan(){
    xhttp.open("GET", "/api/danhsachdoan-data?MaGV="+MaGV+"&MaChuyennganh="+MaChuyennganh+"&page="+page_num+"&textsearch="+textsearch, false);
    xhttp.send();
}

function loadListDoanTatca(){
    xhttp.open("GET", "/api/danhsachdoan-tatca?MaGV="+MaGV+"&MaChuyennganh="+MaChuyennganh+"&page="+page_num+"&textsearch="+textsearch, false);
    xhttp.send();
}

function loadListDoanCanhan(){
    xhttp.open("GET", "/api/danhsachdoan-canhan?MaGV="+MaGV+"&MaChuyennganh="+MaChuyennganh+"&page="+page_num+"&textsearch="+textsearch, false);
    xhttp.send();
}

function loadListTailieu(){
    xhttp.open("GET", "/api/danhsachtailieu?MaGV="+MaGV+"&MaDoan="+MaDoan+"&page="+page_num, false);
    xhttp.send();
}

function dieukienthemdoan(){
    xhttp.open("GET", "/api/dieukienthemdoan?MaGV="+MaGV, false);
    xhttp.send();
}

function dieukiensuadoan(){
    xhttp.open("GET", "/api/dieukiensuadoan?MaDoan="+MaDoan+"&MaGV="+MaGV, false);
    xhttp.send();
}

function loadXoaDoan(){
    xhttp.open("GET", "/api/xoadoan?MaDoan="+MaDoan, false);
    xhttp.send();
}

function loadFirstPhancongtailieu(){
    xhttp.open("GET", "/api/firstload-phancong-tailieu?MaDoan="+MaDoan+"&MaGV="+MaGV+"&MaCT="+MaCT+"&MaCN="+MaChuyennganh, false);
    xhttp.send();
}

function loadInfoSvPhancongtailieu(MaSV){
    xhttp.open("GET", "/api/infosv-phancong-tailieu?MaSV="+MaSV, false);
    xhttp.send();
}

function loadCheckFileuploadTailieu(){
    xhttp.open("GET", "/api/IsExitFileHD?MaGV="+MaGV+"&MaDA="+MaDoan, false);
    xhttp.send();
}

function changesearch(s){
    console.log(s)
    textsearch = s;
    if(pageStatus == 1){
        LoadHeadPage1();
        if(pagelist == 1) loadListDoanCanhan();
        else if((pagelist == 2)) loadListDoanTatca();
    }
}

//ELEMENT-----------------------------------------------------
function LoadListDoan(data){
    pageStatus = 1;

    $('#button-bar').show();
    $('.chose-bar').show();
    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();
    $('.switch-bar').show();
    $('#head-bar').show();

    $('.label-bar').hide();
    $('#detail-bar').hide()
    $('.Add-New-Row').hide();
    $('.Detail-project').hide();

    $('#button-bar').empty();
    $('.chose-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();
    $('#head-bar').empty();

    document.getElementById("table_data").style.backgroundColor = 'rgb(255, 255, 255)';
    document.getElementsByClassName('btn-follow-row').item(0).style.marginRight = '0px';
    document.getElementById("button-bar").style.width = 'calc(100% - 0px)';
  
    $('#button-bar').append(returnIconHome() + returnNameIndex('Đồ án')  +  returnAddBtn());
    $('#head-bar').append(returnFormComboxHeadBar('Chuyên nghành',listmachuyennganh, listtenchuyennganh, MaChuyennganh, 'changeChuyennganh',300,0));
    $('.chose-bar').append(returnSearchForm('Nhập mã đồ án','Tìm kiếm'));
    if(pagelist == 0) $('.switch-bar').append( returnSwitchTable('Cá nhân', 'Tất cả'))
    $('#table_data').append(returnTable(tieudeBangCanhandoan,data));
    $('.btn-follow-row').append(returnButtonTable(tennutBangCanhandoan,idnutBangCanhandoan));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
}

function LoadHeadPage1(){
    $('#button-bar').show();
    $('.chose-bar').show();
    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();
    $('.switch-bar').show();
    $('#head-bar').show();
    $('.chose-bar').show();

    $('#detail-bar').hide()
    $('.Add-New-Row').hide();
    $('.Detail-project').hide();

    $('#button-bar').empty();
    // $('.chose-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();
    $('#head-bar').empty();
    
    document.getElementById("table_data").style.backgroundColor = 'rgb(255, 255, 255)';
    document.getElementsByClassName('btn-follow-row').item(0).style.marginRight = '0px';
    document.getElementById("button-bar").style.width = 'calc(100% - 0px)'

    $('#button-bar').append(returnIconHome() + returnNameIndex('Đồ án')  +  returnAddBtn());
    $('#head-bar').append(returnFormComboxHeadBar('Chuyên nghành',listmachuyennganh, listtenchuyennganh, MaChuyennganh, 'changeChuyennganh',300,0));
    // $('.chose-bar').append(returnSearchForm('Nhập mã đồ án','Tìm kiếm'));
}

function LoadListDoanCanhan(data){
    pageStatus = 1;

    $('.switch-bar').show();
    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();
    $('#detail-bar').hide();
    $('.label-bar').hide();

    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    $('#table_data').append(returnTable(tieudeBangCanhandoan,data));
    $('.btn-follow-row').append(returnButtonTable(tennutBangCanhandoan,idnutBangCanhandoan));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
}

function LoadListDoanTatca(data){
    pageStatus = 1;

    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();
    $('.switch-bar').show();
    $('#detail-bar').hide();
    $('.label-bar').hide();

    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    $('#table_data').append(returnTable(tieudeBangTacadoan,data));
    $('.btn-follow-row').append(returnButtonTable(tennutBangTacadoan,idnutBangTacadoan));
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
}

function ResetCheckbox(){
    for(var i = 0; i < danhsachcheckMota.length; i++){
        if(document.getElementsByClassName("form-check-input").item(i)) document.getElementsByClassName("form-check-input").item(i).checked = false;
    }
    $(".input-more-checkbox").empty();
    $(".input-more-checkbox").hide();
}

function getFile(){
    document.getElementById('selectedFile').click();
}

function LoadAddDoan(){
    $('#button-bar').show();
    $('.Add-New-Row').show();

    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();
    $('.Detail-project').hide();
    $('#head-bar').hide();
    $('.switch-bar').hide();

    $('.Add-New-Row').empty();
    $('#button-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Đồ án') + returnNameIndex('Thêm mới')   +  returnReturnBtn());
    $('.Add-New-Row').append(returnFormLabelInfo('Mã đồ án',MaDoan));
    $('.Add-New-Row').append(returnFormInputTextLength('Tên đồ án','' ));
    $('.Add-New-Row').append(returnFormInputSelect('Chuyên nghành', 'changeChuyennghanh' , listmachuyennganh,listtenchuyennganh, MaChuyennganh));
    $('.Add-New-Row').append('<div><span>Thêm tệp: </span> <span class="uploadfile-tag">  <button onclick="getFile()"; class="add-file-add-row">Thêm tệp</button>   </span></div>');
    $('.Add-New-Row').append(returnCheckBoxHaveMore('Mô tả',danhsachcheckMota));
    $(".display-checkbox").hide();
    $(".input-more-checkbox").hide();
    $('.Add-New-Row').append(returnFormLabelInfo('Ngày thêm',getCurrentTime()));
    $('.Add-New-Row').append(returnFormBtn(nutThemDoan,maunutThemDoan,idnutThemDoan));

    $("#check-khac").change(function() {
        if(this.checked) {
            $(".input-more-checkbox").show()
        }else{
            $(".input-more-checkbox").hide();
        }
    });
    document.getElementById('selectedFile').onchange = function() {
        ResetCheckbox();
        document.getElementsByClassName('input-more-checkbox').item(0).value = '';
        document.getElementsByClassName("form-check-input").item(danhsachcheckMota.length).checked = false;
        var fullPath = document.getElementById('selectedFile').value;
        if (fullPath) {
            contentfile = document.getElementById("selectedFile").files[0];
            $('.uploadfile-tag').append('<span id="contentfile-'+1+'" class="item-add-file-upload"><span>'+contentfile['name']+'</span>   <span>   <svg height="20px"    viewBox="0 0 512.171 512.171" width="20px"> <path d="m243.1875 182.859375 113.132812-113.132813c12.5-12.5 12.5-32.765624 0-45.246093l-15.082031-15.082031c-12.503906-12.503907-32.769531-12.503907-45.25 0l-113.128906 113.128906-113.132813-113.152344c-12.5-12.5-32.765624-12.5-45.246093 0l-15.105469 15.082031c-12.5 12.503907-12.5 32.769531 0 45.25l113.152344 113.152344-113.128906 113.128906c-12.503907 12.503907-12.503907 32.769531 0 45.25l15.082031 15.082031c12.5 12.5 32.765625 12.5 45.246093 0l113.132813-113.132812 113.128906 113.132812c12.503907 12.5 32.769531 12.5 45.25 0l15.082031-15.082031c12.5-12.503906 12.5-32.769531 0-45.25zm0 0"/> </svg>  </span> </span>')
            $(".display-checkbox").show();
            $('.add-file-add-row').hide();
        }
    };
}

function loadAddDoan(){
    var MaDoan = document.getElementsByClassName('label-item-add').item(0).innerHTML;
    var TenDoan = document.getElementsByClassName('input-new-row-long form-control').item(0).value;
    var e = document.getElementsByClassName('combo-box-add-long').item(0);
    var chuyennganh = e.options[e.selectedIndex].value;
    var filedoc = namefilex;
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
    console.log("/api/themdoan?MaDoan="+MaDoan+"&TenDoan="+TenDoan+"&chuyennganh="+chuyennganh+"&ngay="+getCurrentTime()+"&MaGV="+MaGV+"&filedoc="+filedoc+"&infotep="+infotep)
    xhttp.open("GET", "/api/themdoan?MaDoan="+MaDoan+"&TenDoan="+TenDoan+"&chuyennganh="+chuyennganh+"&ngay="+getCurrentTime()+"&MaGV="+MaGV+"&filedoc="+filedoc+"&infotep="+infotep, false);
    xhttp.send();
}

function LoadSuaDoan(data){
    checkfileupdate = false;

    $('#button-bar').show();
    $('.Add-New-Row').show();

    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();
    $('.Detail-project').hide();
    $('#head-bar').hide();
    $('.switch-bar').hide();

    $('.Add-New-Row').empty();
    $('#button-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Đồ án') + returnNameIndex('Sửa')   +  returnReturnBtn());
    $('.Add-New-Row').append(returnFormLabelInfo('Mã đồ án',MaDoan));
    $('.Add-New-Row').append(returnFormInputTextLength('Tên đồ án',data.TenDA ));
    $('.Add-New-Row').append(returnFormInputSelect('Chuyên nghành', 'changeChuyennghanh' , listmachuyennganh,listtenchuyennganh, data.MaCN));

    $('.Add-New-Row').append('<div><span>Thêm tệp: </span> <span class="uploadfile-tag">  <button onclick="getFile()"; class="add-file-add-row">Thêm tệp</button>   </span></div>');
   
    if(String(data.Tep_Goc) !== 'null'){
        tepname = data.Tep_Goc;
        $('.uploadfile-tag').append('<span id="contentfile-'+1+'" class="item-add-file-upload"><span>'+tepname+'</span>   <span>   <svg height="20px"    viewBox="0 0 512.171 512.171" width="20px"> <path d="m243.1875 182.859375 113.132812-113.132813c12.5-12.5 12.5-32.765624 0-45.246093l-15.082031-15.082031c-12.503906-12.503907-32.769531-12.503907-45.25 0l-113.128906 113.128906-113.132813-113.152344c-12.5-12.5-32.765624-12.5-45.246093 0l-15.105469 15.082031c-12.5 12.503907-12.5 32.769531 0 45.25l113.152344 113.152344-113.128906 113.128906c-12.503907 12.503907-12.503907 32.769531 0 45.25l15.082031 15.082031c12.5 12.5 32.765625 12.5 45.246093 0l113.132813-113.132812 113.128906 113.132812c12.503907 12.5 32.769531 12.5 45.25 0l15.082031-15.082031c12.5-12.503906 12.5-32.769531 0-45.25zm0 0"/> </svg>  </span> </span>   ')
        $(".display-checkbox").show();
        $('.add-file-add-row').hide();

        $('.Add-New-Row').append(returnCheckBoxHaveMore('Mô tả',danhsachcheckMota));
        for(var i = 0; i < danhsachcheckMota.length ; i++){
            if(String(data.MoTa).includes(danhsachcheckMota[i])){
                document.getElementsByClassName("form-check-input").item(i).checked = true;
            }
        }

        if(String(data.MoTa) !== ''){
            var Motacuoi = String(data.MoTa).split(',')
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
    }else{
        $(".display-checkbox").hide()
        $('.add-file-add-row').show();
    }

    $('.Add-New-Row').append(returnFormBtn(nutSuaDoan,maunutSuaDoan,idnutSuaDoan));

    //Them ham
    $("#check-khac").change(function() {
        if(this.checked){
            $(".input-more-checkbox").show();
        }else{
            $(".input-more-checkbox").hide();
        }
    });

    document.getElementById('selectedFile').onchange = function() {
        ResetCheckbox();
        document.getElementsByClassName('input-more-checkbox').item(0).value = '';
        document.getElementsByClassName("form-check-input").item(danhsachcheckMota.length).checked = false;
        checkfileupdate = true;
        var fullPath = document.getElementById('selectedFile').value;
        if (fullPath) {
            contentfile = document.getElementById("selectedFile").files[0];
            $('.uploadfile-tag').append('<span id="contentfile-'+1+'" class="item-add-file-upload"><span>'+contentfile['name']+'</span>   <span>   <svg height="20px"    viewBox="0 0 512.171 512.171" width="20px"> <path d="m243.1875 182.859375 113.132812-113.132813c12.5-12.5 12.5-32.765624 0-45.246093l-15.082031-15.082031c-12.503906-12.503907-32.769531-12.503907-45.25 0l-113.128906 113.128906-113.132813-113.152344c-12.5-12.5-32.765624-12.5-45.246093 0l-15.105469 15.082031c-12.5 12.503907-12.5 32.769531 0 45.25l113.152344 113.152344-113.128906 113.128906c-12.503907 12.503907-12.503907 32.769531 0 45.25l15.082031 15.082031c12.5 12.5 32.765625 12.5 45.246093 0l113.132813-113.132812 113.128906 113.132812c12.503907 12.5 32.769531 12.5 45.25 0l15.082031-15.082031c12.5-12.503906 12.5-32.769531 0-45.25zm0 0"/> </svg>  </span> </span>   ')
            $(".display-checkbox").show()
            $('.add-file-add-row').hide();
        }
    };
    NUMBERFILE = data.MaCT;
}

function loadSuaDoan(){
    var MaDoan = document.getElementsByClassName('label-item-add').item(0).innerHTML;
    var TenDoan = document.getElementsByClassName('input-new-row-long form-control').item(0).value;
    var e = document.getElementsByClassName('combo-box-add-long').item(0);
    var chuyennganh = e.options[e.selectedIndex].value;
    var filedoc = '';
    var ischangefile = 'x';
    if(checkfileupdate === true){
        filedoc = namefilex;
        ischangefile = 's';
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
    xhttp.open("GET", "/api/suadoan?MaDoan="+MaDoan+"&TenDoan="+TenDoan+"&chuyennganh="+chuyennganh+"&ngay="+getCurrentTime()+"&MaGV="+MaGV+"&filedoc="+filedoc+"&infotep="+infotep+"&NUMBERFILE="+NUMBERFILE+"&ischangefile="+ischangefile, false);
    xhttp.send();
}


////////////////////////////
function LoadTailieu(data,Checkcanhan){
    pageStatus = 2;

    console.log(Checkcanhan)

    var listtailieu = [];
    
    for(var i = 0; i < data.length; i++){
        console.log("Loai" + data[i].Loai)
        console.log("trangthai" + data[i].TrangThai)

        var trangthai = '';
        if(data[i].Loai === 0) trangthai =  '<svg style="margin-right:13px"  height="20px"  viewBox="0 0 512 512" width="20px"><path style="fill:#FDA429;" d="M463.813,482H29.988L4.382,507.607C7.096,510.322,10.846,512,14.988,512h448.825 c8.284,0,15-6.716,15-15S472.097,482,463.813,482z"/><path style="fill:#FD6B82;" d="M507.594,119.527L392.461,4.393c-5.857-5.858-15.355-5.858-21.213,0L315.772,59.87 c-5.858,5.858-5.858,15.355,0,21.213l115.134,115.134c5.854,5.855,15.357,5.857,21.213,0l55.476-55.476 C513.453,134.882,513.453,125.384,507.594,119.527z"/><path style="fill:#FC495C;" d="M450.028,61.96l-76.689,76.689l57.567,57.567c5.854,5.855,15.357,5.857,21.213,0l55.476-55.476 c5.858-5.858,5.858-15.355,0-21.213L450.028,61.96z"/><path style="fill:#FAD557;" d="M455.798,190.189l-55.24,172.42c-1.4,4.38-4.72,7.87-9.02,9.48L23.298,509.91 c-2.198,0.703-4.441,2.09-8.31,2.09c-3.91,0-7.74-1.53-10.61-4.39c-8.159-8.178-2.4-18.123-2.3-18.92l137.82-368.24 c1.61-4.3,5.1-7.62,9.48-9.02l172.42-55.24c5.36-1.71,11.21-0.29,15.19,3.68l115.13,115.13 C456.088,178.979,457.508,184.839,455.798,190.189z"/><g><path style="fill:#FCB12B;" d="M394.553,117.435L4.378,507.609c2.87,2.86,6.7,4.39,10.61,4.39c3.869,0,6.112-1.388,8.31-2.09 l368.24-137.82c4.3-1.61,7.62-5.1,9.02-9.48l55.24-172.42c1.71-5.35,0.29-11.21-3.68-15.19L394.553,117.435z"/><path style="fill:#FCB12B;" d="M290.645,221.343c-25.271-25.271-66.388-25.27-91.658,0c-21.819,21.82-24.697,55.024-9.368,79.816 L2.078,488.69c-0.097,0.773-5.857,10.743,2.3,18.92c2.87,2.86,6.7,4.39,10.61,4.39c3.841,0,6.088-1.38,8.31-2.09l187.546-187.555 c25.159,15.488,58.31,12.139,79.801-9.353l0,0C315.975,287.672,315.977,246.674,290.645,221.343z"/></g><path style="fill:#FDA429;" d="M290.645,221.343C274.582,237.406,20.472,491.516,4.378,507.609c2.87,2.86,6.7,4.39,10.61,4.39 c3.842,0,6.088-1.38,8.31-2.09l187.546-187.555c25.159,15.488,58.31,12.139,79.801-9.353l0,0 C315.975,287.672,315.977,246.674,290.645,221.343z"/></svg>'
        if(data[i].TrangThai === 1){ trangthai = trangthai + '<svg class="tick-xanh-tablex" height="20px"  viewBox="0 0 367.805 367.805" width="20px"><path style="fill:#3BB54A;" d="M183.903,0.001c101.566,0,183.902,82.336,183.902,183.902s-82.336,183.902-183.902,183.902 S0.001,285.469,0.001,183.903l0,0C-0.288,82.625,81.579,0.29,182.856,0.001C183.205,0,183.554,0,183.903,0.001z"/><polygon style="fill:#D4E1F4;" points="285.78,133.225 155.168,263.837 82.025,191.217 111.805,161.96 155.168,204.801  256.001,103.968"/></svg>';}
        else {trangthai = trangthai + '<svg class="tick-xanh-tablex" height="20px"  viewBox="0 0 367.805 367.805" width="20px"><path style="fill:transparent;" d="M183.903,0.001c101.566,0,183.902,82.336,183.902,183.902s-82.336,183.902-183.902,183.902 S0.001,285.469,0.001,183.903l0,0C-0.288,82.625,81.579,0.29,182.856,0.001C183.205,0,183.554,0,183.903,0.001z"/><polygon style="fill:#D4E1F4;" points="285.78,133.225 155.168,263.837 82.025,191.217 111.805,161.96 155.168,204.801  256.001,103.968"/></svg>';}
        listtailieu.push({tep:data[i].Tep_Goc,giangvien: data[i].MaGV + '-' + data[i].TenNV,Mota:data[i].MoTa,thoigian: data[i].ThoiGian, trangthai:trangthai });
    }

    $('#button-bar').show();
    $('#table_data').show();
    $('.btn-follow-row').show();
    $('.nav-page').show();
    $('.label-bar').show();

    $('.chose-bar').hide();
    $('.switch-bar').hide();
    $('#head-bar').hide();
    $('.Add-New-Row').hide();
    $('.Detail-project').hide();
    $('#detail-bar').hide()

    $('#button-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();
    $('.label-bar').empty();
    $('#head-bar').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Đồ án') + returnNameIndex('Tài liệu')  +  returnReturnBtn());
    if(Checkcanhan !== 0)  $('.label-bar').append( '<div id="label-table"> <span> Đồ án: '+MaDoan+'-'+TenDoan+' </span>  <button id="btn-upfile-label">Thêm tệp</button>  </div>' )
    else $('.label-bar').append( '<div id="label-table"> <span> Đồ án: '+MaDoan+'-'+TenDoan+' </span>   </div>' )

    $('#table_data').append(returnTableBoCot(tieudeBangTailieu,listtailieu,'trangthai'));
    document.getElementById("table_data").style.backgroundColor = 'transparent'
    document.getElementById("table_data").style.border = '1px solid transparent'
    document.getElementById("table_data").style.boxShadow = 'none'
    document.getElementById("button-bar").style.width = 'calc(100% - 82px)'
    

    $('.btn-follow-row').append(returnButtonTable(['Phân công'],['phancong']));
    document.getElementsByClassName('btn-follow-row').item(0).style.marginRight = '76px';
    $('.nav-page').append(returNavForm(tol_page+1, page_num));
    console.log(data);
}


async function loadAddThemFile(){

    namefilex = MaGV+MaDoan+getCurrentTimex().replace(/\D/g,'')+contentfile['name'];
    var formData = new FormData();
    formData.append("file", contentfile);        
    formData.append("namefile", namefilex);                            
    xhttp.open("POST", '/api/upfile_doan');
    xhttp.send(formData);

    await new Promise(resolve => setTimeout(resolve, 500));

    var chuyennganh = MaChuyennganh;
    var filedoc = namefilex;
    var ischangefile = 'x';
    if(checkaddthemfile === true){
        ischangefile = 's';
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
    console.log("/api/suadoan?MaDoan="+MaDoan+"&TenDoan="+TenDoan+"&chuyennganh="+chuyennganh+"&ngay="+getCurrentTime()+"&MaGV="+MaGV+"&filedoc="+filedoc+"&infotep="+infotep+"&NUMBERFILE="+NUMBERFILE+"&ischangefile="+ischangefile)
    xhttp.open("GET", "/api/suadoan?MaDoan="+MaDoan+"&TenDoan="+TenDoan+"&chuyennganh="+chuyennganh+"&ngay="+getCurrentTime()+"&MaGV="+MaGV+"&filedoc="+filedoc+"&infotep="+infotep+"&NUMBERFILE="+NUMBERFILE+"&ischangefile="+ischangefile, false);
    xhttp.send();
}

function LoadThemFile(){
    $("#tep-tai-lieu").val(null);
    ResetCheckbox();
    document.getElementsByClassName('input-more-checkbox').item(0).value = '';
    document.getElementsByClassName("form-check-input").item(danhsachcheckMota.length).checked = false;

    $("#check-khac").change(function() {
        if(this.checked){
            $(".input-more-checkbox").show();
        }else{
            $(".input-more-checkbox").hide();
        }
    });

    document.getElementById('tep-tai-lieu').onchange = function() {
        ResetCheckbox();
        document.getElementsByClassName('input-more-checkbox').item(0).value = '';
        document.getElementsByClassName("form-check-input").item(danhsachcheckMota.length).checked = false;

        var fullPath = document.getElementById('tep-tai-lieu').value;
        if (fullPath) {
            contentfile = document.getElementById("tep-tai-lieu").files[0];
        }
    };
}


function LoadPhancongTailieu(doan,listsinhvien){
    pageStatus = 3;

    $('#button-bar').show();
    $('#detail-bar').show()

    $('#head-bar').hide();
    $('.Add-New-Row').hide();
    $('.Detail-project').hide();
    $('.label-bar').hide();
    $('.chose-bar').hide();
    $('#table_data').hide();
    $('.btn-follow-row').hide();
    $('.nav-page').hide();
    $('.switch-bar').hide();

    $('#button-bar').empty();
    $('#table_data').empty();
    $('.btn-follow-row').empty();
    $('.nav-page').empty();
    $('.label-bar').empty();
    $('#head-bar').empty();
    $('#detail-bar').empty();

    document.getElementById("button-bar").style.width = 'calc(100% - 0px)'

    $('#button-bar').append(returnIconHome() + returnNameIndex('Đồ án') + returnNameIndex('Tài liệu')  + returnNameIndex('Phân công')  + returnReturnBtn());

    $('#detail-bar').append(
        '<span id="thongtin-doan">'+
            '<span id="thongtin-doan-doan">'+
                '<div>Thông tin đồ án:</div>'+
                '<div>Mã: '+doan.MaDA+'</div>'+
                '<div>Tên: '+doan.TenDA+'</div>'+
                '<div>Chuyên ngành: '+doan.tenCN+'</div>'+
                '<div>Người tạo: '+doan.MaNguoiTaoDA+' - '+doan.TenNguoiTaoDA+'</div>'+
                '<div>Ngày tạo: '+doan.NgayTao.replace('T17:00:00.000Z','')+'</div>'+
                '<div style="color: rgb(107, 144, 185);">Tài liệu hướng dẫn:</div>'+
                '<span>Người cập nhật: '+doan.MaNguoiCapNhat+' - '+doan.TenNguoiCapNhat+'</span>'+
                '<span>Ngày cập nhật: '+doan.NgayCapNhat.replace('T17:00:00.000Z','')+'</span>'+
                '<span>Tệp: <a href="/qldean/uploads/'+doan.Tep+'">'+doan.Tep_Goc+'</a> </span>'+
                '<span>Mô tả: '+doan.MoTa+'</span><span></span><span></span>'+
            '</span>'+
        '</span>'
    );


    $('#detail-bar').append('<span id="thongtin-sv">'+
                                '<div>Thông tin sinh viên:</div>'+
                                '<div>Mã: DA03</div>'+
                                '<div>Tên: Lập trình AI</div>'+
                                '<div>Ngày sinh: 23.12.1212</div>'+
                                '<div>SDT: 01551551530</div>'+
                                '<div>Email: cuocsong@gmail.com</div>'+
                                '<div>Lớp: D182XCASD</div>'+
                                '<div>Ngành: Công nghệ thông tin - Công nghệ phần mềm</div>'+
                                '<div></div>'+
                            '</span>');

    // if(pagelist == 1) if(String(MaSVCanhan) !== "null") listsinhvien = [{MaSV:MaSVCanhan,tenSV: TenSVCanhan}]

    if(pagelist == 1) if(String(doan.MaSV) !== "null") {
    for(var i = 0; i < listsinhvien.length;i++){
        if(String(listsinhvien[i].MaSV) === String(doan.MaSV)){
            doan.TenSV = String(listsinhvien[i].tenSV);
        }
    }
    listsinhvien = [{MaSV:doan.MaSV,tenSV: doan.TenSV}]
    }

    var element = '<select class="select-sinh-vien browser-default custom-select">';
    for(let i = 0; i< listsinhvien.length; i++){
        if(String(listsinhvien[i].MaSV) === String(doan.MaSV))  element = element +  '<option selected  value="'+listsinhvien[i].MaSV+'">'+listsinhvien[i].MaSV+' - '+listsinhvien[i].tenSV+'</option>';
        else element = element +  '<option  value="'+listsinhvien[i].MaSV+'">'+listsinhvien[i].MaSV+' - '+listsinhvien[i].tenSV+'</option>';
    }
    element = element + '</select>';
    $('#detail-bar').append(element);

    if(String(doan.MaSV) === 'null'){
        MaSV = listsinhvien[0].MaSV;
    }else{
        MaSV = doan.MaSV;
    }
    $('.select-sinh-vien').on('change', function() {
        MaSV = this.value;
        loadInfoSvPhancongtailieu(this.value);
    });
    $('#detail-bar').append('<button class="phancong-sinhvien-doan-btn">Phân công</button>')
    loadInfoSvPhancongtailieu(MaSV);
}

function LoadInfoSvPhancongtailieu(infosv){
    $('#thongtin-sv').empty();
    $('#thongtin-sv').append(
        '<div>Thông tin sinh viên:</div>'+
        '<div>Mã: '+infosv.MaSV+'</div>'+
        '<div>Tên: '+infosv.TenSV+'</div>'+
        '<div>Ngày sinh: '+infosv.NgaySinh.replace('T17:00:00.000Z','')+'</div>'+
        '<div>SDT: '+infosv.SDT+'</div>'+
        '<div>Email: '+infosv.Email+'</div>'+
        '<div>Lớp: '+infosv.MaLop+'</div>'+
        '<div>Ngành: '+infosv.TenNganh+' - '+infosv.TenCN+'</div>'+
        '<div></div>'
    )
}


//CLICK-----------------------------------------------
async function EventTeacherClick(event) {
    var x = event.target;
    ///COLLUM TABLE
    if( x.parentNode.className == "no-color-lum-table"){
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#no-color-btn-follow-row').attr("id", "yes-color-btn-follow-row");
        x.parentNode.className = 'yes-color-lum-table';
        currentrowtable = Number(x.parentNode.id.replace('collumtalbe-',''));

        if(pageStatus != 2){
        if(listinfoitem[currentrowtable].pbFileKhac == 1 || listinfoitem[currentrowtable].totalPC == 1){
            document.querySelector('#yes-color-btn-follow-row div:first-child').style.background = "rgba(70, 100, 145, 0.233)";
            document.querySelector('#yes-color-btn-follow-row div:nth-child(2)').style.background = "rgba(202, 107, 72, 0.26)";
        }else{
            document.querySelector('#yes-color-btn-follow-row div:first-child').style.background = "rgb(70, 100, 145)";
            document.querySelector('#yes-color-btn-follow-row div:nth-child(2)').style.background = "rgb(202, 107, 72)";
        }
        }else{
            document.querySelector('.yes-color-lum-table td:nth-child(4)').style.background = "#dbdbdb";
        }
    }

    else if(x.parentNode.className == "yes-color-lum-table"){
 
    }

    ///SWITCH BTN
    else if(x.className == "loadswitch1"){
        $('#activeswitchbar').removeAttr('id');
        x.id = 'activeswitchbar';
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
        page_num = 1;
        loadListDoanCanhan();
    }else if(x.className == "loadswitch2"){
        $('#activeswitchbar').removeAttr('id');
        x.id = 'activeswitchbar';
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
        page_num = 1;
        loadListDoanTatca();
    }

    ///BUTTON TABLE
    else if(x.parentNode.className == 'btn-follow-row'){
        if(x.id == 'sua'){
            if(listinfoitem[currentrowtable].pbFileKhac == 0 && listinfoitem[currentrowtable].totalPC == 0){
                MaDoan = listinfoitem[currentrowtable].MaDA;
                dieukiensuadoan();
            }
        }
        if(x.id == "xoa"){
            MaDoan = listinfoitem[currentrowtable].MaDA;
            loadXoaDoan();
        }
        if(x.id == "phancong"){
            MaCT = listinfoitem[currentrowtable].MaCT;
            console.log(MaCT);
            // MaSVCanhan = listinfoitem[currentrowtable].MaSV;
            // TenSVCanhan = listinfoitem[currentrowtable].tenSV;
            loadFirstPhancongtailieu();
        }
        if(x.id == "tailieu"){
            MaDoan = listinfoitem[currentrowtable].MaDA;
            TenDoan = listinfoitem[currentrowtable].TenDA;
            // MaSVCanhan = listinfoitem[currentrowtable].MaSV;
            // TenSVCanhan = listinfoitem[currentrowtable].TenSV;
            MaCTTailieu = listinfoitem[currentrowtable].MaCT;
            loadListTailieu()
            $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
            $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
        }
    }

    ///NAV-PAGE
    else if(x.parentNode.className == "nav-page" ){
        if(pageStatus == 1){
            page_num = Number(x.innerHTML);
            LoadHeadPage1();
            if(pagelist == 1) loadListDoanCanhan();
            else if((pagelist == 2)) loadListDoanTatca();
        }
    }
    
    ///DELETE ITEM FILE
    else if(x.parentNode.parentNode.className == 'item-add-file-upload'){
        checkfileupdate = true;
        x.parentNode.parentNode.parentNode.removeChild(x.parentNode.parentNode);
        $(".display-checkbox").hide();
        $('.add-file-add-row').show();
        console.log('delete');
    }else if(x.parentNode.parentNode.parentNode.className == 'item-add-file-upload'){
        checkfileupdate = true;
        x.parentNode.parentNode.parentNode.parentNode.removeChild(x.parentNode.parentNode.parentNode);
        $(".display-checkbox").hide();
        $('.add-file-add-row').show();
        console.log('deletxe');
    }

    ///ADD NEW BTN
    else if(x.className == "add_new_btn" || x.parentNode.className == "add_new_btn" || x.parentNode.parentNode.className == "add_new_btn" ||  x.parentNode.parentNode.parentNode.className == "add_new_btn"){
        dieukienthemdoan();
    }
    
    ///RETURN BTN
    else if(x.className == "return_btn" || x.parentNode.className == "return_btn" || x.parentNode.parentNode.className == "return_btn" ||  x.parentNode.parentNode.parentNode.className == "return_btn"){
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
        if(pageStatus <= 2){
        LoadHeadPage1();
        if(pagelist == 1) loadListDoanCanhan();
        else if((pagelist == 2)) loadListDoanTatca();
        }else if(pageStatus == 3){
            loadListTailieu()   
        }
    }
    
    /// THOAT BTN
    else if(x.id == "thoat" ){
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
        if(pageStatus <= 2){
        LoadHeadPage1();
        if(pagelist == 1) loadListDoanCanhan();
        else if((pagelist == 2)) loadListDoanTatca();
        }else if(pageStatus == 3){
            loadListTailieu()   
        }
    }
    
    ///XAC NHAN THEM BTN
    else if(x.id == "them" ){
        namefilex = MaGV+MaDoan+getCurrentTimex().replace(/\D/g,'')+contentfile['name'];
        var formData = new FormData();
        formData.append("file", contentfile);        
        formData.append("namefile", namefilex);                            
        xhttp.open("POST", '/api/upfile_doan');
        xhttp.send(formData);

        await new Promise(resolve => setTimeout(resolve, 500));
        
        loadAddDoan();
    }
    
    ///XAC NHAN SUA BTN
    else if(x.id == "suax" ){
        if(checkfileupdate == true){
            namefilex = MaGV+MaDoan+getCurrentTimex().replace(/\D/g,'')+contentfile['name'];
            var formData = new FormData();
            formData.append("file", contentfile);        
            formData.append("namefile", namefilex);                            
            xhttp.open("POST", '/api/upfile_doan');
            xhttp.send(formData);

            await new Promise(resolve => setTimeout(resolve, 500));

            loadSuaDoan();
        }else{
            loadSuaDoan();
        }
    }
    
    ///PHAN CONG TAILIEUBTN
    else if(x.className == "phancong-sinhvien-doan-btn"){
        console.log(MaDoan,MaGV,MaSV,MaCT)

        xhttp.open("GET", "/api/check-phancong-tailieu?MaSV="+MaSV, false);
        xhttp.send();    
    }
    
    ///UPLOAD FILE BTN
    else if(x.id == "btn-upfile-label"){
        $('.Form-input-file').show();
        $('.shadow-input-diem').show();
        LoadThemFile();
    }else if(x.id == "btn-thoat-diem"){
        $('.Form-input-file').hide();
        $('.shadow-input-diem').hide();
    }else if(x.id == "btn-nhap-diem"){
        loadCheckFileuploadTailieu();

    }
    ///ELSE
    else{
        if(document.querySelector('#yes-color-btn-follow-row div:first-child')){
            document.querySelector('#yes-color-btn-follow-row div:first-child').style.background = "rgba(70, 100, 145, 0.233)";
            document.querySelector('#yes-color-btn-follow-row div:nth-child(2)').style.background = "rgba(202, 107, 72, 0.26)";
        }
        $('.yes-color-lum-table').removeClass('yes-color-lum-table').addClass('no-color-lum-table');
        $('#yes-color-btn-follow-row').attr("id", "no-color-btn-follow-row");
    }
}
//FIRST---------------------------------------------------------
loadListDoan();

