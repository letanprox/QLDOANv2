module.exports = (setroute = require("./Setroute")) => {
    let root_1 = "qldean.com";

    setroute.pushRoute(root_1,"GET","", "qldean/Home.html");

    setroute.pushRoute(root_1,"GET","login", "qldean/login-form/Login_v15/Login.html");
    
    setroute.pushRoute(root_1,"GET","panel", "qldean/Panel.html");
    setroute.pushRoute(root_1,"GET","panel1", "qldean/Panel1.html");

    setroute.pushRoute(root_1,"GET","admin/quanlytieuban", "qldean/Admin/AdminxQuanlytieuban.html");
    setroute.pushRoute(root_1,"GET","admin/quanlysinhvien", "qldean/Admin/AdminxQuanlysinhvien.html");
    setroute.pushRoute(root_1,"GET","admin/quanlygiangvien", "qldean/Admin/AdminxQuanlygiangvien.html");
    setroute.pushRoute(root_1,"GET","admin/phancongphutrach", "qldean/Admin/AdminxPhancongphutrach.html");
    setroute.pushRoute(root_1,"GET","admin/phancongphanbien", "qldean/Admin/AdminxPhancongphanbien.html");
    setroute.pushRoute(root_1,"GET","admin/phanconghuongdan", "qldean/Admin/AdminxPhanconghuongdan.html");
    setroute.pushRoute(root_1,"GET","admin/phancongtieuban", "qldean/Admin/AdminxPhancongtieuban.html");
    setroute.pushRoute(root_1,"GET","admin/taikhoan", "qldean/Admin/AdminxTaikhoan.html");
    setroute.pushRoute(root_1,"GET","admin/thongke", "qldean/Admin/AdminxThongke.html");

    setroute.pushRoute(root_1,"GET","giangvien/taikhoan", "qldean/Teacher/TeacherxTaikhoan.html");

    setroute.pushRoute(root_1,"GET","giangvien/huongdan", "qldean/Teacher/TeacherxHuongdan.html");
    
    setroute.pushRoute(root_1,"GET","giangvien/danhsachdoan", "qldean/Teacher/TeacherxDanhsachdoan.html");
    setroute.pushRoute(root_1,"GET","giangvien/danhsachsinhvien", "qldean/Teacher/TeacherxDanhsachsinhvien.html");
    setroute.pushRoute(root_1,"GET","giangvien/phanbien", "qldean/Teacher/TeacherxPhanbien.html");
    setroute.pushRoute(root_1,"GET","giangvien/tieuban", "qldean/Teacher/TeacherxTieuban.html");

    setroute.pushRoute(root_1,"GET","thongtindoan", "qldean/Student/StudentxDoan.html");

    return setroute.getRoute();
}