$( "#act-thongke" ).addClass( "active" )

$("#name-user").empty();
$("#name-user").append('Admin: ' + getCookie('QLNAME'));
var MaAdmin = getCookie('QL');

let listTenHD = [];
let listMaHD = [];
let listKhoa = [];

let listLabel55gn;
let khoacurrent;
let HDcurrent;

var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
                //Dữ liệu cho mục tiểu ban
                if(String(this.responseURL).includes('api/loadChartMot')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    var tempdata = data[0][0]
                    for(var i = 0; i < tempdata.length; i++){
                        listTenHD.push(tempdata[i].TenHD)
                    }
                    for(var i = 0; i < tempdata.length; i++){
                        listMaHD.push(tempdata[i].MaHD)
                    }
                    tempdata = data[1][0];
                    for(var i = 0; i < tempdata.length; i++){
                        listKhoa.push(tempdata[i].NamBD);
                    }
                    FirstLoadBieudoToankhoa();
                }
                if(String(this.responseURL).includes('api/loadBieudoToankhoa')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    LoadBieudoToanKhoa(data);
                }
                if(String(this.responseURL).includes('api/loadBieudoThongke5nam')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    LoadChart5nam(data);
                }
                if(String(this.responseURL).includes('api/loadBieudoPhodiem')){
                    var data = JSON.parse(this.responseText);
                    console.log(data)
                    // LoadChart5nam(data);
                    LoadBieudoPhodiem(data)
                }

                
        }
    };

function firstloadBieudoToankhoa(){
    xhttp.open("GET", "/api/loadChartMot", false);
    xhttp.send();
}


function CreateBtnBottomChart(){
    var label_ = listLabel55gn;
    $( '.55gn-btn' ).remove();
    for(var i = 0; i < label_.length; i++){
        $('#wrap-ong-noi').append('<span class="55gn-btn"  id="'+label_[i]+'-55gn"><button id="'+label_[i]+'-phodiembtn">phổ điểm</button><button  id="'+label_[i]+'-5gn">5 năm</button></span>')
    }
    setMarginBtnBottomChart(label_);
}


function setMarginBtnBottomChart(){
    var label_ = listLabel55gn;
    var lengthlabel = Number(label_.length);
    var widthpar = document.getElementById("wrap-ong-noi").offsetWidth - 36;
    var widthbtn = document.getElementById(label_[0]+'-55gn').offsetWidth;
    var margin = (widthpar - widthbtn*lengthlabel) / (lengthlabel*2)
    for(var i = 0; i < label_.length; i++){
        if(i == 0)
        document.getElementById(label_[i]+'-55gn').style.marginLeft = margin + 18  + 'px';
        else if(i == label_.length - 1)
        document.getElementById(label_[i]+'-55gn').style.marginLeft = margin*2 - 7  + 'px';
        else
        document.getElementById(label_[i]+'-55gn').style.marginLeft = margin*2   + 'px';
    }
}

function loadBieudoToanKhoa(){
    xhttp.open("GET", "/api/loadBieudoToankhoa?Khoa="+khoacurrent, false);
    xhttp.send();
}

function loadThongke5nam(){
    xhttp.open("GET", "/api/loadBieudoThongke5nam?HD="+HDcurrent, false);
    xhttp.send();
}


function loadBieudoPhodiem(){
    xhttp.open("GET", "/api/loadBieudoPhodiem?HD="+HDcurrent+"&Khoa="+khoacurrent, false);
    xhttp.send();
}


function FirstLoadBieudoToankhoa(data) {
    $('#button-bar').show();
    $('#head-bar-char').show();

    $('#head-bar-char').empty();
    $('#button-bar').empty();

    $('#button-bar').append(returnIconHome() + returnNameIndex('Thống kê') );
    $('#head-bar-char').append(returnFormComboxHeadBar('Khóa',listKhoa, listKhoa, listKhoa[0], 'changeKhoaandNghanh',90,0));
    $('#head-bar-char').append(returnFormComboxHeadBar('Hội đồng',listMaHD,listTenHD,listMaHD[0] , 'changeKhoaandNghanh',250,20));

    khoacurrent = listKhoa[0];
    loadBieudoToanKhoa();
}


function changeKhoaandNghanh(){
    e = document.getElementsByClassName("select-combox-headbar").item(0);
    khoacurrent = e.options[e.selectedIndex].value;
    loadBieudoToanKhoa();
}



function LoadBieudoToanKhoa(data){
    var listLabel = [];
    var listtotalPass = [];
    var listtotalFail = [];
    var listtotalDA = [];
    var listDiem = [];
    var temlist = data[0][0];
    for(var i = 0; i < temlist.length; i++){
        listLabel.push(temlist[i].MaNganh)
        
        if(String(temlist[i].totalDAPass) === 'null') listtotalPass.push(0);
        else listtotalPass.push(temlist[i].totalDAPass)

        if(String(temlist[i].totalDAFail) === 'null') listtotalFail.push(0);
        else listtotalFail.push(temlist[i].totalDAFail)
        
        if(String(temlist[i].totalDA) === 'null') listtotalDA.push(0);
        else listtotalDA.push(temlist[i].totalDA)

        if(String(temlist[i].Diem) === 'null') listDiem.push(0);
        else listDiem.push(temlist[i].Diem)
    }

    listLabel55gn = listLabel;
    CreateBtnBottomChart()


    $('#content-chart').empty();
    $('#content-chart').append('<canvas id="myChart" ></canvas>');

    $('#mo-rong-chart').remove();
    $('#wrap-ong-noi').append('<button id="mo-rong-chart">mở rộng</button>')
    document.getElementById('mo-rong-chart').style.display = 'none';

var ctx = document.getElementById('myChart');
var myChart = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: listLabel,
        datasets: [{
            type: 'bar', 
            label: 'Hoàn thành',
            data: listtotalPass,
            backgroundColor: [
                'rgba(191, 255, 0, 0.5)',
            ],
            borderColor: [
                'black',
            ],
            yAxisID: 'y',
            borderWidth: 1
        },{
            type: 'bar', 
            label: 'Trượt',
            data: listtotalFail,
            backgroundColor: [
                'rgba(0, 255, 0 , 0.5)',
            ],
            borderColor: [
                'black',
            ],
            yAxisID: 'y',
            borderWidth: 1
        },{
            type: 'bar', 
            label: 'Tổng số DA',
            data: listtotalDA,
            backgroundColor: [
                'rgba(0, 255, 255,0.5)',
            ],
            borderColor: [
                'black',
            ],
            borderWidth: 1,
            yAxisID: 'y',
        },{
            type: 'bar', 
            label: 'Điểm',
            data: listDiem,
            backgroundColor: [
                'rgba(191, 0, 255, 0.5)',
            ],
            borderColor: [
                'black',
            ],
            borderWidth: 1,
            yAxisID: 'y1',
        }]
    },
    options: {
        tooltips:{
            mode:'index',
        },
        scales: {
      y: {
        type: 'linear',
        display: true,
        position: 'left',
      },
      y1: {
        type: 'linear',
        display: true,
        position: 'right',

        // grid line settings
        grid: {
          drawOnChartArea: false, // only want the grid lines for one axis to show up
        },
      },
    }
    }
});



}


function LoadChart5nam(data){
    var listLabel = [];
    var listtotalPass = [];
    var listtotalFail = [];
    var listtotalDA = [];
    var listDiem = [];
    var temlist = data[0][0];
    for(var i = 0; i < temlist.length; i++){
        listLabel.push(temlist[i].NamBD)
        
        if(String(temlist[i].totalDAPass) === 'null') listtotalPass.push(0);
        else listtotalPass.push(temlist[i].totalDAPass)

        if(String(temlist[i].totalDAFail) === 'null') listtotalFail.push(0);
        else listtotalFail.push(temlist[i].totalDAFail)
        
        if(String(temlist[i].totalDA) === 'null') listtotalDA.push(0);
        else listtotalDA.push(temlist[i].totalDA)

        if(String(temlist[i].Diem) === 'null') listDiem.push(0);
        else listDiem.push(temlist[i].Diem)
    }



    $('#lable-header-bar').empty();
    $('#lable-header-bar').append('Chuyên ngành '+HDcurrent+' trong 5 năm')



    document.getElementById('wrap-ba-noi').style.display = 'block';


    

    $('#content-chart-back').empty();
    $('#content-chart-back').append('<canvas id="myChart_" ></canvas>');

    var ctxx = document.getElementById('myChart_');
var myChartx = new Chart(ctxx, {
    type: 'bar',
    data: {
        labels: listLabel,
        datasets: [{
            type: 'line', 
            label: 'Điểm',
            data: listDiem,
            backgroundColor: [
                'rgba(255, 64, 0, 0.5)',
            ],
            borderColor: [
                'black',
            ],
            borderWidth: 2,
            yAxisID: 'y1',
        },{
            type: 'bar', 
            label: 'Hoàn thành',
            data: listtotalPass,
            backgroundColor: [
                'rgba(255, 0, 128, 0.5)',
            ],
            borderColor: [
                'black',
            ],
            yAxisID: 'y',
            borderWidth: 1
        },{
            type: 'bar', 
            label: 'Trượt',
            data: listtotalFail,
            backgroundColor: [
                'rgba(0, 255, 64, 0.5)',
            ],
            borderColor: [
                'black',
            ],
            yAxisID: 'y',
            borderWidth: 1
        },{
            type: 'bar', 
            label: 'Tổng số DA',
            data: listtotalDA,
            backgroundColor: [
                'rgba(255, 255, 0, 0.5)',
            ],
            borderColor: [
                'black',
            ],
            borderWidth: 1,
            yAxisID: 'y',
        }]
    },
    options: {
        tooltips:{
            mode:'index',
        },
        scales: {
            x: {
                stacked: true,
              },
  
      y: {
        type: 'linear',
        display: true,
        position: 'left',
        stacked: true
      },
      y1: {
        type: 'linear',
        display: true,
        position: 'right',

        // grid line settings
        grid: {
          drawOnChartArea: false, // only want the grid lines for one axis to show up
        },
      },
    }
    }
});

Display2Tab();
}



function LoadBieudoPhodiem(data){

 
    var temlist = data[0][0][0];
    var listLabel = ['[0,4)','[4,5.5)','[5.5,7)','[7,8.5)','[8.5,10)'];
    var listSet = [];
    for(var i = 0; i < listLabel.length; i++){
        listSet.push(temlist[listLabel[i]])
    }

    $('#content-chart-back-1').empty();
    $('#content-chart-back-1').append('<canvas id="myChart__" ></canvas>');


    console.log(listSet)

    var ctxx = document.getElementById('myChart__');
    new Chart(ctxx, {
        type: 'bar',
        data: {
            labels: listLabel,
            datasets: [{
                type: 'bar', 
                label: 'Điểm',
                data: listSet,
                backgroundColor: [
                    'rgba(255, 128, 0, 0.5)',
                    'rgba(255, 255, 0, 0.5)',
                    'rgba(64, 255, 0, 0.5)',
                    'rgba(0, 255, 191, 0.5)',
                    'rgba(191, 0, 255, 0.5)',
                ],
                borderColor: [
                    'black',
                ],
                borderWidth: 1
            }]
        },
        options: {
            tooltips:{
                mode:'index',
            },
            scales: {
  
            }
        }
    });






     temlist = data[1][0][0];
     listLabel = ['[0,4)','[4,5.5)','[5.5,7)','[7,8.5)','[8.5,10)'];
     listSet = [];
    for(var i = 0; i < listLabel.length; i++){
        listSet.push(temlist[listLabel[i]])
    }

    $('#content-chart-back-2').empty();
    $('#content-chart-back-2').append('<canvas id="myChart___" ></canvas>');


    ctxx = document.getElementById('myChart___');
    new Chart(ctxx, {
        type: 'bar',
        data: {
            labels: listLabel,
            datasets: [{
                type: 'bar', 
                label: 'Điểm',
                data: listSet,
                backgroundColor: [
                    'rgba(255, 128, 0, 0.5)',
                    'rgba(255, 255, 0, 0.5)',
                    'rgba(64, 255, 0, 0.5)',
                    'rgba(0, 255, 191, 0.5)',
                    'rgba(191, 0, 255, 0.5)',
                ],
                borderColor: [
                    'black',
                ],
                borderWidth: 1
            }]
        },
        options: {
            tooltips:{
                mode:'index',
            },
            scales: {
  
            }
        }
    });





    temlist = data[2][0][0];
    listLabel = ['[0,4)','[4,5.5)','[5.5,7)','[7,8.5)','[8.5,10)'];
    listSet = [];
   for(var i = 0; i < listLabel.length; i++){
       listSet.push(temlist[listLabel[i]])
   }

   $('#content-chart-back-3').empty();
   $('#content-chart-back-3').append('<canvas id="myChart____" ></canvas>');


   ctxx = document.getElementById('myChart____');
   new Chart(ctxx, {
       type: 'bar',
       data: {
           labels: listLabel,
           datasets: [{
               type: 'bar', 
               label: 'Điểm',
               data: listSet,
               backgroundColor: [
                   'rgba(255, 128, 0, 0.5)',
                   'rgba(255, 255, 0, 0.5)',
                   'rgba(64, 255, 0, 0.5)',
                   'rgba(0, 255, 191, 0.5)',
                   'rgba(191, 0, 255, 0.5)',
               ],
               borderColor: [
                   'black',
               ],
               borderWidth: 1
           }]
       },
       options: {
           tooltips:{
               mode:'index',
           },
           scales: {
 
           }
       }
   });


}


function Display2Tab(){

    document.getElementById('wrap-ong-noi').style.display = 'block';
    document.getElementById('wrap-ong-noi').style.width = 'calc(50% - 5px)';
    document.getElementById('content-chart').style.height = (document.getElementById('wrap-ong-noi').offsetWidth / 2) + 'px';
    var x55gn = document.getElementsByClassName('55gn-btn');
    for(var i = 0; i < x55gn.length; i++) x55gn.item(i).style.display = 'none';
    document.getElementById('mo-rong-chart').style.display = 'block';


    document.getElementById('wrap-ba-noi').style.float = 'left';
    document.getElementById('wrap-ba-noi').style.display = 'block';
    document.getElementById('wrap-ba-noi').style.width = 'calc(50% - 5px)';
    document.getElementById('content-chart-back').style.height = (document.getElementById('wrap-ong-noi').offsetWidth / 2) + 'px';
    document.getElementById('thu-nho-chart-back').style.display = 'none';
    document.getElementById('mo-rong-chart-back').style.display = 'block';

}


function Display4Tab(){

    document.getElementById('wrap-ba-noi').style.display = 'none';

    document.getElementById('wrap-ong-noi').style.display = 'block';
    document.getElementById('wrap-ong-noi').style.width = 'calc(76.6% - 5px)';
    document.getElementById('content-chart').style.height = (document.getElementById('wrap-ong-noi').offsetWidth / 2) + 'px';
    var x55gn = document.getElementsByClassName('55gn-btn');
    for(var i = 0; i < x55gn.length; i++) x55gn.item(i).style.display = 'none';
    document.getElementById('mo-rong-chart').style.display = 'block';

    for(var i = 0; i <= 2; i++){
        document.getElementsByClassName('svg_expand').item(i).style.display = 'block';
        document.getElementsByClassName('head-bar-char-back_').item(i).style.fontSize = '13px';
    }
    

    for(var i = 1; i <= 3; i++){
        document.getElementById('wrap-ba-noi-'+i).style.display = 'block';
        document.getElementById('wrap-ba-noi-'+i).style.width = '100%';
        document.getElementById('content-chart-back-'+i).style.height = (document.getElementById('wrap-ba-noi-'+i).offsetWidth / 2) + 'px';
        document.getElementById('thu-nho-chart-back-'+i).style.display = 'none';
        document.getElementById('mo-rong-chart-back-'+i).style.display = 'none';
    }

}

function DisplayOneInTab(num,numray){
    document.getElementById('wrap-ong-noi').style.display = 'none';
    document.getElementById('wrap-ba-noi').style.display = 'none';

    for(var i = 0; i < numray.length; i++){
        document.getElementById('wrap-ba-noi-'+numray[i]).style.display = 'none';
    }

    document.getElementsByClassName('head-bar-char-back_').item(num-1).style.fontSize = '17px';
    document.getElementsByClassName('svg_expand').item(num-1).style.display = 'none';
    document.getElementById('wrap-ba-noi-'+num).style.float = 'left';
    document.getElementById('wrap-ba-noi-'+num).style.display = 'block';
    document.getElementById('wrap-ba-noi-'+num).style.width = '980px';
    document.getElementById('content-chart-back-'+num).style.height = '490px';
    document.getElementById('mo-rong-chart-back-'+num).style.display = 'none';
    document.getElementById('thu-nho-chart-back-'+num).style.display = 'block';
    
}


function EventAdminClick(event) {
    var x = event.target;
    if( x.parentNode.className == "55gn-btn"){
        if(String(x.id).includes('5gn')){
            console.log(x.id)
            HDcurrent = String(x.id).split('-')[0];
            loadThongke5nam();
            document.getElementById('wrap-ba-noi-1').style.display = 'none';
            document.getElementById('wrap-ba-noi-2').style.display = 'none';
            document.getElementById('wrap-ba-noi-3').style.display = 'none';    
        }
        if(String(x.id).includes('phodiembtn')){
            HDcurrent = String(x.id).split('-')[0];
            loadBieudoPhodiem();
            Display4Tab();
        }
    }else if(x.id == "mo-rong-chart-back"){

        document.getElementById('wrap-ba-noi').style.float = 'left';
        document.getElementById('wrap-ba-noi').style.display = 'block';
        document.getElementById('wrap-ba-noi').style.width = '980px';
        document.getElementById('content-chart-back').style.height = '490px';
        document.getElementById('mo-rong-chart-back').style.display = 'none';
        document.getElementById('thu-nho-chart-back').style.display = 'block';

        document.getElementById('wrap-ong-noi').style.display = 'none';
        document.getElementById('wrap-ba-noi-1').style.display = 'none';
        document.getElementById('wrap-ba-noi-2').style.display = 'none';
        document.getElementById('wrap-ba-noi-3').style.display = 'none';

    }else if( x.id == "mo-rong-chart"){

        document.getElementById('wrap-ong-noi').style.width = '980px';
        document.getElementById('content-chart').style.height = '490px';
        var x55gn = document.getElementsByClassName('55gn-btn');
        for(var i = 0; i < x55gn.length; i++) x55gn.item(i).style.display = 'block';
        document.getElementById('mo-rong-chart').style.display = 'none';
        CreateBtnBottomChart();

        document.getElementById('wrap-ba-noi').style.display = 'none';
        document.getElementById('wrap-ba-noi-1').style.display = 'none';
        document.getElementById('wrap-ba-noi-2').style.display = 'none';
        document.getElementById('wrap-ba-noi-3').style.display = 'none';

    }else if( x.id == "head-bar-char-back_1" ||  x.parentNode.id == "head-bar-char-back_1" ||  x.parentNode.parentNode.id == "head-bar-char-back_1"){
        DisplayOneInTab(1,[2,3])
    }else if( x.id == "head-bar-char-back_2" ||  x.parentNode.id == "head-bar-char-back_2" ||  x.parentNode.parentNode.id == "head-bar-char-back_2"){
        DisplayOneInTab(2,[1,3])
    }else if( x.id == "head-bar-char-back_3" ||  x.parentNode.id == "head-bar-char-back_3" ||  x.parentNode.parentNode.id == "head-bar-char-back_3"){
        DisplayOneInTab(3,[1,2])
    }else if( x.id == "thu-nho-chart-back"){
        Display2Tab();
    }else if( x.id == "thu-nho-chart-back-1"){
        Display4Tab();
    }else if( x.id == "thu-nho-chart-back-2"){
        Display4Tab();
    }else if( x.id == "thu-nho-chart-back-3"){
        Display4Tab();
    }else if(x.id == "logout" ||  x.parentNode.id == "logout" || x.parentNode.parentNode.id == "logout"){
        if (confirm('Bạn có muốn đăng xuất')) {
            window.location.replace("/login");
          } else {
          }
    }else{
    }

}

firstloadBieudoToankhoa();