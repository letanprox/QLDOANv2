const mysql = require('mysql'); // or use import if you use TS
const util = require('util');
const conn = mysql.createConnection({            
    host: "localhost",
    user: "tan",
    password: "12345",
    database: "mydb"
});

// node native promisify
const query = util.promisify(conn.query).bind(conn);

(async () => {
  try {
    const rows = await query('SELECT * FROM customers');
    console.log(rows);
  } finally {
    conn.end();
  }
})()