//FILE SYSTEM
const fs = require("fs");
const path = require("path");

var listCheckJoinHTML = [
  ["addheadQLdean", "qldean/Home.html" , "qldean/Login.html" , "qldean/Panel.html" , "qldean/Panel1.html" ,
    "qldean/Admin/AdminxQuanlytieuban.html" ,"qldean/Admin/AdminxQuanlysinhvien.html", "qldean/Admin/AdminxQuanlygiangvien.html", 
    "qldean/Admin/AdminxPhancongphutrach.html" , 'qldean/Admin/AdminxPhancongphanbien.html' , 'qldean/Admin/AdminxPhanconghuongdan.html' , 'qldean/Admin/AdminxPhancongtieuban.html' , "qldean/Admin/AdminxTaikhoan.html",
    "qldean/Teacher/TeacherxPhancong.html" , "qldean/Teacher/TeacherxTaikhoan.html", "qldean/Teacher/TeacherxHuongdan.html" , "qldean/Teacher/TeacherxDanhsachdoan.html","qldean/Teacher/TeacherxPhanbien.html","qldean/Teacher/TeacherxTieuban.html", "qldean/Teacher/TeacherxDanhsachsinhvien.html","qldean/Student/StudentxDoan.html","qldean/Admin/AdminxThongke.html"],
];

var preventFolder = [
  "backend","controller", "model" , "node_modules" , "request" , "response" , "route"
];

//READ AND RETURN CLIENT
module.exports = (res,req_bundle) => {
        // Read File

        req_bundle.filePath = String(req_bundle.filePath).replace(/\\/g,"/");

        fs.readFile(req_bundle.filePath, (err, content) => {
            if (err) {
              if (err.code == "ENOENT") {
                // Page Not Found
                fs.readFile(path.join(__dirname, "404.html"),(err, content) => {
                    res.writeHead(404, { "Content-Type": "text/html" });
                    res.end(content, "utf8");
                  }
                );
              }else{
                // Server Error
                res.writeHead(500);
                res.end(`Server Error: ${err.code}`);
              }
            }else {

              let endResponsive = (content) => {
                res.writeHead(200, { "Content-Type": req_bundle.contentType });
                res.end(content, "utf8");
              }
              //File join HTML
              if(req_bundle.contentType === "text/html"){
                //check 
                let checkfor = false;
                let nameImplementFile;
                for(let i = 0; i < listCheckJoinHTML.length ; i++){
                  let check = false;
                  for(let j = 1 ; j < listCheckJoinHTML[i].length ; j++){
                    if((String(req_bundle.filePath)).includes(String(listCheckJoinHTML[i][j]))){
                      check = true;
                    } 
                  }
                  if(check === true){
                    checkfor = true;
                    nameImplementFile = listCheckJoinHTML[i][0];
                  }
                }
                //respon
                if(checkfor === true){
                  const InResponseFile = require("./InResponseFile/"+nameImplementFile+".js");
                  InResponseFile(content,endResponsive);
                }else{
                  endResponsive(content);
                }
              
              //FIle Only
              }else{
                let check = false;
                req_bundle.filePath.split('/').forEach(function(segpath){
                  for(let i = 0; i < preventFolder.length ; i++){
                    if(String(segpath) === String(preventFolder[i])) check = true; 
                  }
                });
                if(check === true)
                  endResponsive("FAil To LOad FIle System");
                else
                  endResponsive(content);
              }
            }
        });
}