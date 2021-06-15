class SetRoute{
    constructor() {
        this.listFile = {"state":[]};
        this.listFile.state["qldean.com"] = [];
    }
    pushRoute(root,method,name,file){
        this.data = { 
            "method":method,
            "name":name, 
            "file":file, 
        };
        this.listFile.state[root].push(this.data);
    }
    getRoute(){
        return this.listFile;
    }
}
module.exports = new SetRoute();