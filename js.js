
var listLabelpk = ['Tiểu ban','Ngày','Giờ','Trạng thái'];
var data =[{TieuBan:"TB12" , Ngay:'23/12/1212', Gio: '12:10', trangthai:"dang phan cong"}]

var listButtonpk = ['Phân công','Sửa','Xóa'];

var listBtnpk =  ['Phân công','Sửa','Xóa'];
var listColorpk = ['tomato', 'green' , 'blue'];
var listIdBtn = ['phancong', 'sua' , 'xoa'];

var listVapk = ['sinh vien: 21', 'nlop: 12']

$('#table_data').empty();
$('.btn-follow-row').empty();
$('#button-bar').empty();
$('.nav-page').empty();
$('.nav-page').append(returNavForm(10, 2) );

$('#table_data').append(returnTable(listLabelpk,data));
$('.btn-follow-row').append(returnButtonTable(listButtonpk));
$('#button-bar').append(returnIconHome() + returnNameIndex('Quản lý tiểu ban') +  returnAddBtn());

$('.Add-New-Row').empty();
$('.Add-New-Row').append(returnFormLabel('Them moi') + returnFormLabelInfo('label','123') + returnFormInputTime('thoi gian',1,'2021-12-12T07:30')  +returnFormInputText('xxx','xxx') + returnFormInputSelect('str',listButtonpk,'') + returnFormBtn(listBtnpk,listColorpk,listIdBtn));

$('.Add-New-Row').append(returnLormInfo(listVapk) + returnLormOneInfo('xxxxx:xxxxx') + returnLormInputSelect('str: ',listButtonpk,'') + returnLormBtn(listBtnpk,listColorpk,listIdBtn))