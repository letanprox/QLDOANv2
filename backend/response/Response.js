let URL = require('url').URL;

module.exports = async (scanner) => {

        let getController = () => {
            if(scanner.req_bundle.filePath != ''){
            Controller = require("../controller" + scanner.req_bundle.filePath);
            Controller(function(result, ContentType) {
                scanner.res.writeHead(200, { "Content-Type": ContentType });
                scanner.res.end(result, "utf8");
            }, scanner);
            }else{
                scanner.res.writeHead(500);
                scanner.res.end(`Server Error: not found route`);
            }
        }

        scanner.head_params = new URL('http://' + "localhost" + scanner.req.url).searchParams;
        let body = '';
            scanner.req.on('data', (data) => {
                body += data;
            });
            scanner.req.on('end', () => {
                scanner.body_params  = body;
                getController();
            });       
}