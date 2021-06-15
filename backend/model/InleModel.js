const util = require('util');
module.exports = class InleModel{
    constructor(sql){
        this.sql = sql;
        this.query = util.promisify(sql.query).bind(sql);
    }
    async InleSQL(SQLcommand){
        try {
            const rows = await this.query(SQLcommand);
            return rows;
        } catch(e){
            
            return (JSON.parse(JSON.stringify(e)).sqlMessage + "fail");
        }
    }
}