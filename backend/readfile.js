var fs = require('fs')
fs.readFile("controller/qldean/Text/khoa.txt", 'utf8', function (err,data) {
    var formatted = data.replace('2015,0', '2015,1');
    fs.writeFile("controller/qldean/Text/khoa.txt", formatted, 'utf8', function (err) {
    if (err) return console.log(err);
 });
});