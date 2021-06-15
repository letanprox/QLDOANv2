function caculateDay(day){
    date1 = new Date(day);
    var today = new Date();
    var date = today.getFullYear()+'/'+(today.getMonth()+1)+'/'+today.getDate();
    var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
    date2 =  new Date(date+' '+time);    
    time = Math.abs(((date2.getTime() - date1.getTime())/1000));
    if(time / (60) < 60){
        return Math.floor(time / (60)) + " phút trước"; 
    }else if(time / (60*60) < 24){
        return Math.floor(time / (60*60)) + " giờ trước"; 
    }else if( time / (60*60) >= 24 && time / (60*60*24) < 7){
        return Math.floor(time / (60*60*24)) + " ngày trước"; 
    }else if( time / (60*60*24) >= 7 && time / (60*60*24) < 28){
        return Math.floor(time / (60*60*24*7)) + " tuần trước"; 
    }else{
        return day;
    }                             
}

function getCurrentTime(){
  var today = new Date();
  var date = today.getFullYear()+'/'+(today.getMonth()+1)+'/'+today.getDate();
  var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
  return date+' '+time;
}

function getCurrentTimex(){
  var today = new Date();

  var Moth;
  var Day;
  var Gio;
  var Phut;
  var Giay;

  if(Number(today.getMonth()+1) < 10){
    Moth = '0'+Number(today.getMonth()+1)
  }else{
    Moth = Number(today.getMonth()+1);
  }

  if(Number(today.getDate()) < 10){
    Day = '0'+Number(today.getDate())
  }else{
    Day = Number(today.getDate());
  }

  if(Number(today.getHours()) < 10){
    Gio = '0'+Number(today.getHours())
  }else{
    Gio = Number(today.getHours());
  }

  if(Number(today.getMinutes()) < 10){
    Phut = '0'+Number(today.getMinutes())
  }else{
    Phut = Number(today.getMinutes());
  }

  if(Number(today.getSeconds()) < 10){
    Giay = '0'+Number(today.getSeconds())
  }else{
    Giay = Number(today.getSeconds());
  }

  var date = today.getFullYear()+'-'+Moth+'-'+Day;
  var time = Gio + ":" + Phut + ":" + Giay;
  return date+' '+time;
}


function getCurrentDay(){
  var today = new Date();
  var date = today.getDate()+'/'+(today.getMonth()+1)+'/'+today.getFullYear();
  return date;
}

function getCurrentDayx(){
  var today = new Date();
  var date = today.getFullYear()+'/'+(today.getMonth()+1)+'/'+today.getDate();
  return date;
}

function decode_utf8( s ){
    return decodeURI(s).replace(/0765547053/gi, "&");
}

function GetUrlParameter(sParam){
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++){
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam){
            return sParameterName[1];
        }
    }
}

function setCookie(cname, cvalue, exdays) {
  var d = new Date();
  d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
  var expires = "expires="+d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

function getCookie(cname) {
  var name = cname + "=";
  var ca = document.cookie.split(';');
  for(var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

function checkCookie(name) {
  var cname = getCookie(name);
  if (cname != "") {
    return true;
  } else {
    return false;
  }
}

function iOS() {
  return [
    'iPad Simulator',
    'iPhone Simulator',
    'iPod Simulator',
    'iPad',
    'iPhone',
    'iPod'
  ].includes(navigator.platform)
  // iPad on iOS 13 detection
  || (navigator.userAgent.includes("Mac") && "ontouchend" in document)
}


function isNumeric(num){
  return !isNaN(num)
}