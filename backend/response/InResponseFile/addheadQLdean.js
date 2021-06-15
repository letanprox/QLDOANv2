const fs = require("fs");
module.exports = (content,endResponsive) => {
    fs.readFile('../qldean/Head.html', function(err, data) {
        let repage = data.toString() + content.toString() + '</body></html>';
        // Success
        endResponsive(repage);
    });
}