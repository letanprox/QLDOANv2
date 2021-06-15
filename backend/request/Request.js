//FILE SYSTEM
const path = require("path");

//MY FILE
const getContentType = require("./ContentType");
const route = require("./Route");

//RETURN REQUEST BUNDLE
module.exports =  (req,returnRoute) => {

    if(req.headers.host === "localhost:7000") req.headers.host = "www.qldean.com";

    let filePath = route(req.headers.host,req.method,req.url,returnRoute);
    let index;
    let contentType;
    let status = 0;

    if (path.extname(filePath) != "") {
        filePath = path.join("../", filePath);
        contentType = getContentType(path.extname(filePath));
        status = 1;
    }else{
        str = filePath.toString();
        filePath = str.substring(0, str.indexOf("@"));
        index = str.substring(str.indexOf("@") + 1, str.length);  
    }
    filePath = decodeURI(filePath);

    return {
        status,
        filePath,
        index,
        contentType
    }
}