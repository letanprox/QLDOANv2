//FILE SYSTEM
const http = require("http");
let url = require('url');
const formidable = require('formidable');


//CONNECT MONGO
let Connect = require("./Connect");
const connect = new Connect();

const path = require('path');
const fs = require('fs');

//RES REQ
const reqUest = require("./request/Request");
const resPonse = require("./response/Response");
const responseFile = require("./response/ResponseFile.js");
let InleModel = require("./model/InleModel");

//LIST ROUTE
let routeother_ = require("./route/RouteOther");
const routeother = routeother_();
let routeapi_ = require("./route/RouteApi");
const routeapi = routeapi_();

//SCANNER
const scanner = {};

//CREATE SERVER
let SERVER = async (con) => {
    scanner.sql = con;
    scanner.inleModel = new InleModel(scanner.sql);
    
    http.createServer((req, res) => {
            scanner.req = req;
            scanner.res = res;

            ///UPLOAD LÀM SAU
            if(req.url.includes('api/upfile_')){
                var form = new formidable.IncomingForm();
                form.uploadDir = "../qldean/uploads/";
                form.parse(scanner.req, function (err, fields, file) {
                    var path = file.file.path;
                    var newpath = form.uploadDir + fields.namefile;
                    fs.rename(path, newpath, function (err) {
                        if (err) throw err;
                        console.log(err)
                        res.writeHead(200)
                        res.end('thanh cong');
                    });
                });
            }else{
                if((req.url).includes("api")) scanner.req_bundle = reqUest(req,routeapi);
                else scanner.req_bundle = reqUest(req,routeother);
            
                if (scanner.req_bundle.status == 1) responseFile(scanner.res, scanner.req_bundle);
                else resPonse(scanner);
            }

    }).listen(connect.portSERVER, () => console.log("server run on PORT:" + connect.portSERVER));;
}
//RUN SERVER
connect.connectMongoDB(SERVER);