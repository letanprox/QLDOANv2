let mysql = require('mysql');
module.exports = class Connect{
    constructor(){
        // HOST DOMAIN
        this.host = 'localhost';
        this.portSERVER = 7000;
        // MONGO DB
        this.hostsql = 'localhost';
        this.user = 'root';
        this.password = '';
        this.database = 'qldoan';
    }
    //MONGO CONNECT
    async connectMongoDB (callback){
        let con = mysql.createConnection({
            host: this.hostsql,
            user: this.user,
            password: this.password,
            database: this.database,
          });
        con.connect(function(err) {
            if (err) throw err;
            else callback(con);
        });
    }
}