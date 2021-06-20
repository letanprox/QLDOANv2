//ELEMENT-----------------------------------------------------
function returnIconHome() {
    return  '<svg height="20px"  viewBox="0 0 59.465 59.465" width="20px"><g>'+
            '<path d="M58.862,33.886L45.045,20.069v-9.112c0-1.136-0.921-2.056-2.056-2.056c-1.137,0-2.057,0.92-2.057,2.056v5.001L31.185,6.21c-0.801-0.803-2.104-0.803-2.905,0L0.603,33.886c-0.803,0.804-0.803,2.104,0,2.907c0.802,0.803,2.104,0.803,2.907,0L29.732,10.57l26.223,26.223c0.401,0.398,0.93,0.604,1.455,0.604c0.522,0,1.051-0.201,1.452-0.604C59.665,35.988,59.665,34.689,58.862,33.886z"/>'+
            '<path d="M52.979,36.245L31.185,14.449c-0.385-0.385-0.908-0.602-1.454-0.602c-0.545,0-1.068,0.217-1.453,0.602L6.484,36.245c-0.291,0.288-0.487,0.659-0.565,1.062c-0.061,0.314-0.091,0.633-0.091,0.942v10.638c0,2.739,2.229,4.971,4.969,4.971h10.638c1.378,0,2.707-0.582,3.645-1.599c0.854-0.923,1.324-2.12,1.324-3.373v-7.812c0-1.896,1.453-3.48,3.33-3.658c1.878,0.178,3.331,1.762,3.331,3.658v7.812c0,1.252,0.472,2.45,1.324,3.373c0.938,1.017,2.269,1.599,3.646,1.599h10.638c2.74,0,4.971-2.229,4.971-4.972V38.252c0-0.312-0.031-0.63-0.092-0.941C53.471,36.904,53.271,36.533,52.979,36.245z"/>'+
            '</g></svg>'+
            '<i class="fa fa-angle-right"></i>';
}

function returnNameIndex(str) {
    return '<div id="name-item">'+str+'</div><i class="fa fa-angle-right"></i>'
}

function returnInputTextTitle(str){
    return '<input placeholder="'+str+'" id="input-text-title"><i class="fa fa-angle-right"></i>'
}

function returnAddBtn() {
    return  '<div class="add_new_btn" id="button-item">'+
            '<svg height="15px" viewBox="0 0 349.03 349.031" width="15px"><g><path d="M349.03,141.226v66.579c0,5.012-4.061,9.079-9.079,9.079H216.884v123.067c0,5.019-4.067,9.079-9.079,9.079h-66.579c-5.009,0-9.079-4.061-9.079-9.079V216.884H9.079c-5.016,0-9.079-4.067-9.079-9.079v-66.579c0-5.013,4.063-9.079,9.079-9.079h123.068V9.079c0-5.018,4.069-9.079,9.079-9.079h66.579c5.012,0,9.079,4.061,9.079,9.079v123.068h123.067C344.97,132.147,349.03,136.213,349.03,141.226z"/></g></svg>'+
            '<span>Thêm mới</span>'+
            '</div>';
}

function returnAddBtnLeftLabel(name) {
    return  '<div class="add_new_btn" id="button-item-left">'+
            '<svg height="15px" viewBox="0 0 349.03 349.031" width="15px"><g><path d="M349.03,141.226v66.579c0,5.012-4.061,9.079-9.079,9.079H216.884v123.067c0,5.019-4.067,9.079-9.079,9.079h-66.579c-5.009,0-9.079-4.061-9.079-9.079V216.884H9.079c-5.016,0-9.079-4.067-9.079-9.079v-66.579c0-5.013,4.063-9.079,9.079-9.079h123.068V9.079c0-5.018,4.069-9.079,9.079-9.079h66.579c5.012,0,9.079,4.061,9.079,9.079v123.068h123.067C344.97,132.147,349.03,136.213,349.03,141.226z"/></g></svg>'+
            '<span>'+name+'</span>'+
            '</div>';
}


function returnReturnBtn() {
    return  '<div id="leave-btn" class="return_btn">'+
            '<svg  height="15px" viewBox="0 0 489.394 489.394" width="15px">	<g><path d="M375.789,92.867H166.864l17.507-42.795c3.724-9.132,1-19.574-6.691-25.744c-7.701-6.166-18.538-6.508-26.639-0.879L9.574,121.71c-6.197,4.304-9.795,11.457-9.563,18.995c0.231,7.533,4.261,14.446,10.71,18.359l147.925,89.823c8.417,5.108,19.18,4.093,26.481-2.499c7.312-6.591,9.427-17.312,5.219-26.202l-19.443-41.132h204.886c15.119,0,27.418,12.536,27.418,27.654v149.852c0,15.118-12.299,27.19-27.418,27.19h-226.74c-20.226,0-36.623,16.396-36.623,36.622v12.942c0,20.228,16.397,36.624,36.623,36.624h226.74c62.642,0,113.604-50.732,113.604-113.379V206.709C489.395,144.062,438.431,92.867,375.789,92.867z"/></g></svg>'+
            '<span >Trở lại</span></div>';
}

function returnSearchForm(str,str_) {
    return '<input  style="width: 300px; float:left"  class="form-control" id="input-search" type="text" oninput="changesearch(this.value)" src="" alt="" placeholder="'+str+'">'+
        //    '<button id="search-index" style="background-color: tomato;" type="submit">'+str_+'</button>'+
           '<button  id="refresh-index"  style="background-color: tomato;" type="submit">'+str_+'</button>'
}

function returnSearchForm_(str,str_,va) {
    return '<input id="input-search" type="text" oninput="changesearch(this.value)" value="'+va+'" src="" alt="" placeholder="'+str+'">'+
           '<button id="search-index" style="background-color: tomato;" type="submit">'+str_+'</button>'+
           '<button  id="refresh-index"  style="background-color: slateblue;" type="submit">Làm mới</button>'
}

function returnSearchFormNumber(str,str_) {
    return '<input  style="width: 30px; float:left"  class="form-control" id="input-search" type="number" oninput="changesearch(this.value)" src="" alt="" placeholder="'+str+'">'+
        //    '<button id="search-index" style="background-color: tomato;" type="submit">'+str_+'</button>'+
           '<button  id="refresh-index"  style="background-color: tomato;" type="submit">'+str_+'</button>'
}

function returnTable(listLabel, data) {
    var element = ' <thead class="thead-dark"><tr>';
    for(var i = 0; i < listLabel.length; i++){
        element = element + '<th scope="col">'+listLabel[i]+'</th>';
    }
    element = element + '</tr></thead><tbody>';
    for(var i = 0; i < data.length; i++){
        element = element + '<tr  id="collumtalbe-'+i+'" class="no-color-lum-table">';
        Object.keys(data[i]).forEach(key => {
            if(String(data[i][key]) != 'null')
            element = element + '<td>'+String(data[i][key]).replace('T17:00:00.000Z','').replace('.000Z',' ')+'</td>';
            else 
            element = element + '<td>'+'</td>';
        });
        element = element + '</tr>';
    }
    return element+'</tbody>';
}


function returnTableBoCot(listLabel, data,keyx) {
    var element = ' <thead class="thead-dark"><tr>';
    for(var i = 0; i < listLabel.length; i++){
        if(listLabel[i] !== 'null')
        element = element + '<th style="background: rgb(255, 255, 255)" scope="col">'+listLabel[i]+'</th>';
        else
        element = element + '<th style="border: 1px solid transparent" scope="col"></th>';
    }
    element = element + '</tr></thead><tbody>';
    for(var i = 0; i < data.length; i++){
        element = element + '<tr  id="collumtalbe-'+i+'" class="no-color-lum-table">';
        Object.keys(data[i]).forEach(key => {
            if(String(key) != keyx){
                if(String(data[i][key]) != 'null')
                    element = element + '<td class="clor-white">'+String(data[i][key]).replace('T17:00:00.000Z','').replace('.000Z',' ')+'</td>';
                else 
                    element = element + '<td class="clor-white">'+'</td>';
            }else{
                element = element + '<td  style="border: none; width:80px ;  background: transparent">'+String(data[i][key])+'</td>';
            }
        });
        element = element + '</tr>';
    }
    return element+'</tbody>';
}


function returnButtonTable(listButton, listId ) {
    var element = '';
    for(var i = 0; i < listButton.length; i++){
        element = element + '<div  id="'+listId[i]+'">'+listButton[i]+'</div>';
    }
    return element
}


function returnFormLabel(str) {
    // return '<div id="label-Add-New">'+str+'</div>';
    return ''
}
function returnFormLabelInfo(str,str_) {
    return '<div><span>'+str+': </span><span><span class="label-item-add">'+str_+'</span></span></div>';
}
function returnFormInputTime(str,time,va) {
    if(time == 1)
    return '<div><span>'+str+': </span><span>  <input  value="'+va+'" type="datetime-local" class="thoigianform" >  </span></div>';
    else if(time == 2)
    return '<div><span>'+str+': </span><span>  <input  value="'+va+'" type="date" class="thoigianform">  </span></div>';
    else 
    return '<div><span>'+str+': </span><span>  <input  value="'+va+'" type="time" class="thoigianform">  </span></div>';
}
function returnFormInputSelect(str,hamchon,sle,sleva,va) {
    var element = '<div class="slide-bar-add-new-row"><span>'+str+': </span><span><select style="width:200px" class="combo-box-add-long browser-default custom-select" onchange="'+hamchon+'();">'
    for(var i = 0; i < sle.length; i++){
        if(String(va) === String(sle[i]))
        element = element + '<option selected value="'+sle[i]+'">'+sleva[i]+'</option>';
        else
        element = element + '<option value="'+sle[i]+'">'+sleva[i]+'</option>';
    }
    element = element + '</select></span></div>';
    return element
}

function returnFormInputSelectLong(str,hamchon,sle,sleva,va) {
    var element = '<div class="slide-bar-add-new-row"><span>'+str+': </span><span><select style="width:400px" class="combo-box-add-long browser-default custom-select" onchange="'+hamchon+'();">'
    for(var i = 0; i < sle.length; i++){
        if(String(va) === String(sle[i]))
        element = element + '<option selected value="'+sle[i]+'">'+sleva[i]+'</option>';
        else
        element = element + '<option value="'+sle[i]+'">'+sleva[i]+'</option>';
    }
    element = element + '</select></span></div>';
    return element
}

function returnFormInputSelectHaveBtn(str,idsle,sle,sleva,va,idvanew,vanew,idbtn,namebtn) {

    var element = '<div><span>'+str+': </span><span id="'+idsle+'" style="width:200px"><select id="'+idsle+'x" style="width:200px" class="combo-box-add-long browser-default custom-select">'
    for(var i = 0; i < sle.length; i++){
        if(String(va) === String(sle[i]))
        element = element + '<option selected value="'+sle[i]+'">'+sleva[i]+'</option>';
        else
        element = element + '<option value="'+sle[i]+'">'+sleva[i]+'</option>';
    }
    element = element + '</select></span><span style="margin-top:2px;" id="'+idvanew+'" class="label-item-add">'+vanew+'</span><button id="'+idbtn[0]+'" class="select-have-btn" type="submit">'+namebtn[0]+'</button><button  id="'+idbtn[1]+'" class="select-have-btn" type="submit">'+namebtn[1]+'</button></div>';
    return element;


}

function returnFormInputText(str, str_){
    return '<div><span>'+str+':  </span><span><input style="width:150px"   class="input-new-row-short form-control" value="'+str_+'" type="text" ></span></div>'
}
function returnFormInputTextLength(str, str_){
    return '<div><span>'+str+':  </span><span><input  style="width:300px"  class="input-new-row-long form-control" value="'+str_+'" type="text" ></span></div>'
}
function returnFormInputTextRight(str, str_){
    return '<div><span>'+str+':  </span><span><input style="text-align:right;width:300px;" class="input-new-row-long form-control" value="'+str_+'" type="text" ></span></div>'
}

function returnFormBtn(listBtn,listColor,listIdBtn) {
    var element = '<div>';
    for(var i = 0; i < listBtn.length; i++){
        element = element + '<button id="'+listIdBtn[i]+'"  style="background-color:'+listColor[i]+'" type="submit">'+listBtn[i]+'</button>';
    }
    element  = element + '</div>';
    return element;
}


function returnLormInfo(listVa) {
    var element = '<div>';
    for(var i = 0; i < listVa.length; i++){
        element = element + '<div>'+listVa[i]+'</div>';
    }
    element = element + '</div>';
    return element;
}
function returnLormOneInfo(Va) {
    return element = '<div><div class="one-row-item-add">'+Va+'</div></div>';
}
function returnLormBtn(listBtn,listColor,listIdBtn) {
    var element = '<div></div><div></div><div class="left_row_btn">';
    for(var i = 0; i < listBtn.length; i++){
        element = element + '<button id="'+listIdBtn[i]+'"  class="left_row_tb_btn"   style="background-color:'+listColor[i]+'" type="submit">'+listBtn[i]+'</button>';
    }
    element  = element + '</div>';
    return element;
}


function returnLormInputSelect(str,sle,va) {
    var element = '<div><div  class="one-row-item-add" style="color:rgb(38, 77, 0);">' + str + '<select class="slide-select-lorm">';
    for(var i = 0; i < sle.length; i++){
        if(String(va) === String(sle[i]))
        element = element + '<option selected value="'+sle[i]+'">'+sle[i]+'</option>';
        else
        element = element + '<option value="'+sle[i]+'">'+sle[i]+'</option>';
    }
    element = element + '</select></div></div>';
    return element
}

function returNavForm(le, num) {
    var element = '';
    for(var i = 1; i < le; i++){
        if(i == num) element = element + '<span id="chose-nav-item">'+i+'</span>';
        else element = element + '<span>'+i+'</span>'
    }
    return element;
}

function returnSwitchBtn(str,str_) {
    return '<div  class="switchbtn"><span class="loadswitch1" id="activeswitchbar">'+str+'</span><span class="loadswitch2">'+str_+'</span></div>';
}

function returnSwitchTable(str,str_) {
    return '<div  class="switchbtn_table"><span class="loadswitch1" id="activeswitchbar">'+str+'</span><span class="loadswitch2">'+str_+'</span></div>';
}

///Ngoại 
function returnFormKhoa(dskhoa,khoa) {
    var element = '<select id="select-khoa"  class="browser-default custom-select" onchange="changeKhoa();">'
    for(var i = 0; i < dskhoa.length; i++){
        if(Number(dskhoa[i]) == Number(khoa))
            element = element + '<option selected  value="'+dskhoa[i]+'">'+dskhoa[i]+'</option>';
        else
            element = element + '<option value="'+dskhoa[i]+'">'+dskhoa[i]+'</option>';
    }
    element = element + '</select>';
    element = element + '<input style="display: none;" type="text" name="" class="form-control" placeholder="Nhập khóa" id="input-khoa"><button style="display: none;" id="xacnhan-them-khoa">Xác nhận</button><button id="themkhoa" type="submit">Thêm Khóa</button><button style="display: none;" id="dskhoa" type="submit">Danh sách</button>';
    return element
}


function returnFormListKhoa(dskhoa,khoa) {
    var element = '<span class="title-chon-khoa">Chọn khóa </span><select name="cars" id="select-khoa"  class="browser-default custom-select" onchange="changeKhoa();">'
    for(var i = 0; i < dskhoa.length; i++){
        if(Number(dskhoa[i]) == Number(khoa))
        element = element + '<option selected value="'+dskhoa[i]+'">'+dskhoa[i]+'</option>';
        else
        element = element + '<option value="'+dskhoa[i]+'">'+dskhoa[i]+'</option>';
    }
    element = element + '</select>';

    return element;
}




function returnFormComboxHeadBar(tieude,danhsach,danhsachva, chon, hamchon,width,left){
    var element = '<span style="margin-left:'+left+'px" class="title-combox-headbar">'+tieude+'</span><select style="width:'+width+'px;" class="browser-default custom-select  select-combox-headbar" onchange="'+hamchon+'();">'
    for(var i = 0; i < danhsach.length; i++){
        if(String(danhsach[i]) === String(chon))
        element = element + '<option selected value="'+danhsach[i]+'">'+danhsachva[i]+'</option>';
        else
        element = element + '<option value="'+danhsach[i]+'">'+danhsachva[i]+'</option>';
    }
    return element + '</select>';
}


// function returnFormComboxHeadBarSmall(tieude,danhsach,danhsachva, chon, hamchon,width,left){
//     var element = '<span style="margin-left:'+left+'px" class="title-combox-headbar-small">'+tieude+'</span><select style="width:'+width+'px;" class="browser-default custom-select select-combox-headbar-small" onchange="'+hamchon+'();">'
//     for(var i = 0; i < danhsach.length; i++){
//         if(String(danhsach[i]) === String(chon))
//         element = element + '<option selected value="'+danhsach[i]+'">'+danhsachva[i]+'</option>';
//         else
//         element = element + '<option value="'+danhsach[i]+'">'+danhsachva[i]+'</option>';
//     }
//     return element + '</select>';
// }


function returnFormAddComboxBar(idselect,danhsach,danhsachva,chon,hamchon,width,left,nameinput,idinput,namebtn,idbtn,color){
    var element = '<select  style="margin-left:'+left+'px; width:'+width+'px;" id="'+idselect+'" class="browser-default custom-select select-combox-headbar" onchange="'+hamchon+'();">'
    for(var i = 0; i < danhsach.length; i++){
        if(String(danhsach[i]) == String(chon))
        element = element + '<option selected  value="'+danhsach[i]+'">'+danhsachva[i]+'</option>';
        else
        element = element + '<option value="'+danhsach[i]+'">'+danhsachva[i]+'</option>';
    }
    element = element + '</select>';
    element = element + '<input style="margin-left:'+left+'px; width:'+width+'px;display: none;" type="text" class="form-control" placeholder="'+nameinput+'" id="'+idinput+'"><button  style="background-color:'+color[0]+';"  id="'+idbtn[0]+'">'+namebtn[0]+'</button><button style="display: none; background-color:'+color[1]+';" id="'+idbtn[1]+'">'+namebtn[1]+'</button><button style="display: none;background-color:'+color[2]+';" id="'+idbtn[2]+'">'+namebtn[2]+'</button>';
    return element
}

function returnButtonAddMore(idopen,idclose){
    return '<div id="chose-option-more"> <button id="'+idopen+'" ><svg height="20px"  fill="white" viewBox="0 0 491.996 491.996" width="20px"><g>'+
    '<path d="M484.132,124.986l-16.116-16.228c-5.072-5.068-11.82-7.86-19.032-7.86c-7.208,0-13.964,2.792-19.036,7.86l-183.84,183.848'+
    'L62.056,108.554c-5.064-5.068-11.82-7.856-19.028-7.856s-13.968,2.788-19.036,7.856l-16.12,16.128'+
    'c-10.496,10.488-10.496,27.572,0,38.06l219.136,219.924c5.064,5.064,11.812,8.632,19.084,8.632h0.084'+
    'c7.212,0,13.96-3.572,19.024-8.632l218.932-219.328c5.072-5.064,7.856-12.016,7.864-19.224'+
    'C491.996,136.902,489.204,130.046,484.132,124.986z"/>'
    +'</g></svg></button><button id="'+idclose+'"><svg height="20px"  fill="white" viewBox="0 0 491.996 491.996" width="20px"><g>'+
    '<path d="M484.136,328.473L264.988,109.329c-5.064-5.064-11.816-7.844-19.172-7.844c-7.208,0-13.964,2.78-19.02,7.844'+
    'L7.852,328.265C2.788,333.333,0,340.089,0,347.297c0,7.208,2.784,13.968,7.852,19.032l16.124,16.124'+
    'c5.064,5.064,11.824,7.86,19.032,7.86s13.964-2.796,19.032-7.86l183.852-183.852l184.056,184.064'+
    'c5.064,5.06,11.82,7.852,19.032,7.852c7.208,0,13.96-2.792,19.028-7.852l16.128-16.132'+
    'C494.624,356.041,494.624,338.965,484.136,328.473z"/>'+
    +'</g></svg></button></div>';
}

function returnCheckBoxHaveMore(label,listlabel){
    var element = '<div class="display-checkbox" style="margin-top:-3px;"><span>'+label+': </span> <span class="checkboxtag">'
    for(var i = 0; i < listlabel.length; i++){
        element = element + '<div class="form-check"><input class="form-check-input" type="checkbox" value="'+listlabel[i]+'" id="flexCheckDefault"><label>'+listlabel[i]+'</label></div>'
    }
    element = element + '<div class="form-check"><input id="check-khac" class="form-check-input" type="checkbox" value="khac" id="flexCheckDefault"><label class="form-check-label" for="flexCheckDefault">Khác</label></div>';
    element = element + '<input class="form-control input-more-checkbox" type="text" value="">'
    element = element + '</span></div>';
    return element;
}


function returnCheckBoxHaveMore_(listlabel){
    var element = ''
    for(var i = 0; i < listlabel.length; i++){
        element = element + '<div class="form-check"><input class="form-check-input" type="checkbox" value="'+listlabel[i]+'" id="flexCheckDefault"><label>'+listlabel[i]+'</label></div>'
    }
    element = element + '<div class="form-check"><input id="check-khac" class="form-check-input" type="checkbox" value="khac" id="flexCheckDefault"><label class="form-check-label" for="flexCheckDefault">Khác</label></div>';
    element = element + '<input class="form-control input-more-checkbox" type="text" value="">'
    return element;
}