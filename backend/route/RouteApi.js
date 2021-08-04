module.exports = (setroute = require("./Setroute")) => {
    let root_1 = "qldean.com";

    setroute.pushRoute(root_1,"GET","api/login", "qldean/LoginController@login");

    setroute.pushRoute(root_1,"GET","api/danhsachtieuban", "qldean/AdminTieubanController@danhsachtieuban");
    setroute.pushRoute(root_1,"GET","api/danhsachdulieutieuban", "qldean/AdminTieubanController@danhsachdulieutieuban");
    setroute.pushRoute(root_1,"GET","api/timmatb", "qldean/AdminTieubanController@timmatb");

    setroute.pushRoute(root_1,"GET","api/dieukienthemtb", "qldean/AdminTieubanController@dieukienthemtb");

    setroute.pushRoute(root_1,"GET","api/themtb", "qldean/AdminTieubanController@themtb");
    setroute.pushRoute(root_1,"GET","api/IsEditTB", "qldean/AdminTieubanController@IsEditTB");
    setroute.pushRoute(root_1,"GET","api/suatb", "qldean/AdminTieubanController@suatb");
    setroute.pushRoute(root_1,"GET","api/xoatb", "qldean/AdminTieubanController@xoatb");

    setroute.pushRoute(root_1,"GET","api/danhsachGVphancongTB", "qldean/AdminTieubanController@danhsachGVphancongTB");
    setroute.pushRoute(root_1,"GET","api/checkaddGVintoTieuban", "qldean/AdminTieubanController@checkaddGVintoTieuban");
    setroute.pushRoute(root_1,"GET","api/addGVintoTieuban", "qldean/AdminTieubanController@addGVintoTieuban");

    setroute.pushRoute(root_1,"GET","api/themkhoasv", "qldean/AdminSinhvienController@themkhoasv");
    setroute.pushRoute(root_1,"GET","api/danhsachsinhvien", "qldean/AdminSinhvienController@danhsachsinhvien");
    setroute.pushRoute(root_1,"GET","api/dieukienthemsv", "qldean/AdminSinhvienController@dieukienthemsv");

    setroute.pushRoute(root_1,"GET","api/danhsach-theo-nghanh", "qldean/AdminSinhvienController@danhsach-theo-nghanh");
    setroute.pushRoute(root_1,"GET","api/danhsach-theo-nganhvakhoa", "qldean/AdminSinhvienController@danhsach-theo-nganhvakhoa");
    setroute.pushRoute(root_1,"GET","api/danhsach-theo-chuyennganhvakhoa", "qldean/AdminSinhvienController@danhsach-theo-chuyennganhvakhoa");
    setroute.pushRoute(root_1,"GET","api/taomoilop", "qldean/AdminSinhvienController@taomoilop");
    setroute.pushRoute(root_1,"GET","api/layniemkhoatheonam", "qldean/AdminSinhvienController@layniemkhoatheonam");
    

    setroute.pushRoute(root_1,"GET","api/themsv", "qldean/AdminSinhvienController@themsv");
    setroute.pushRoute(root_1,"GET","api/dieukiensuasv", "qldean/AdminSinhvienController@dieukiensuasv");
    setroute.pushRoute(root_1,"GET","api/suasv", "qldean/AdminSinhvienController@suasv");
    setroute.pushRoute(root_1,"GET","api/xoasv", "qldean/AdminSinhvienController@xoasv");

    setroute.pushRoute(root_1,"GET","api/danhsachgiangvien", "qldean/AdminGiangvienController@danhsachgiangvien");
    setroute.pushRoute(root_1,"GET","api/dieukienthemgv", "qldean/AdminGiangvienController@dieukienthemgv");
    setroute.pushRoute(root_1,"GET","api/themgv", "qldean/AdminGiangvienController@themgv");
    setroute.pushRoute(root_1,"GET","api/suagv", "qldean/AdminGiangvienController@suagv");
    setroute.pushRoute(root_1,"GET","api/xoagv", "qldean/AdminGiangvienController@xoagv");
    setroute.pushRoute(root_1,"GET","api/danhsachdulieugiangvien", "qldean/AdminGiangvienController@danhsachdulieugiangvien");
    // setroute.pushRoute(root_1,"GET","api/timmagv", "qldean/AdminGiangvienController@timmagv");

    setroute.pushRoute(root_1,"GET","api/danhsachphancongHD", "qldean/AdminPhancongHuongdanController@danhsachphancongHD");
    setroute.pushRoute(root_1,"GET","api/danhsachGVHDphancong", "qldean/AdminPhancongHuongdanController@danhsachGVHDphancong");
    setroute.pushRoute(root_1,"GET","api/addGVHDphancong", "qldean/AdminPhancongHuongdanController@addGVHDphancong");
    setroute.pushRoute(root_1,"GET","api/infoGVHD", "qldean/AdminPhancongHuongdanController@infoGVHD");

    setroute.pushRoute(root_1,"GET","api/danhsachphancongPB", "qldean/AdminPhancongPhanbienController@danhsachphancongPB");
    setroute.pushRoute(root_1,"GET","api/danhsachGVPBphancong", "qldean/AdminPhancongPhanbienController@danhsachGVPBphancong");
    setroute.pushRoute(root_1,"GET","api/addGVPBphancong", "qldean/AdminPhancongPhanbienController@addGVPBphancong");
    setroute.pushRoute(root_1,"GET","api/infoGVPB", "qldean/AdminPhancongPhanbienController@infoGVPB");
    
    setroute.pushRoute(root_1,"GET","api/danhsachphancongTB", "qldean/AdminPhancongTieubanController@danhsachphancongTB");
    setroute.pushRoute(root_1,"GET","api/danhsachTBphancong", "qldean/AdminPhancongTieubanController@danhsachTBphancong");
    setroute.pushRoute(root_1,"GET","api/addTBphancong", "qldean/AdminPhancongTieubanController@addTBphancong");
    setroute.pushRoute(root_1,"GET","api/infoTB", "qldean/AdminPhancongTieubanController@infoTB");

    setroute.pushRoute(root_1,"POST","api/upfile_doan", "qldean/TeacherController@upfiledoan");
    setroute.pushRoute(root_1,"GET","api/firstload-phancong-tailieu", "qldean/TeacherController@firstload-phancong-tailieu");
    setroute.pushRoute(root_1,"GET","api/infosv-phancong-tailieu", "qldean/TeacherController@infosv-phancong-tailieu");
    setroute.pushRoute(root_1,"GET","api/add-phancong-tailieu", "qldean/TeacherController@add-phancong-tailieu");
    setroute.pushRoute(root_1,"GET","api/check-phancong-tailieu", "qldean/TeacherController@check-phancong-tailieu");
    setroute.pushRoute(root_1,"GET","api/dieukiensuadoan", "qldean/TeacherController@dieukiensuadoan");
    setroute.pushRoute(root_1,"GET","api/suadoan", "qldean/TeacherController@suadoan");
    setroute.pushRoute(root_1,"GET","api/xoadoan", "qldean/TeacherController@xoadoan");
    setroute.pushRoute(root_1,"GET","api/danhsachtailieu", "qldean/TeacherController@danhsachtailieu");
    setroute.pushRoute(root_1,"GET","api/danhsachdoan-tatca", "qldean/TeacherController@danhsachdoan-tatca");
    setroute.pushRoute(root_1,"GET","api/danhsachdoan-canhan", "qldean/TeacherController@danhsachdoan-canhan");
    setroute.pushRoute(root_1,"GET","api/danhsachdoan-data", "qldean/TeacherController@danhsachdoan-data");
    setroute.pushRoute(root_1,"GET","api/dieukienthemdoan", "qldean/TeacherController@dieukienthemdoan");
    setroute.pushRoute(root_1,"GET","api/themdoan", "qldean/TeacherController@themdoan");
    setroute.pushRoute(root_1,"GET","api/danhsachtatcadoan", "qldean/TeacherController@danhsachtatcadoan");
    setroute.pushRoute(root_1,"GET","api/danhsachdoanhuongdan", "qldean/TeacherController@danhsachdoanhuongdan");
    setroute.pushRoute(root_1,"GET","api/IsExitFileHD", "qldean/TeacherController@IsExitFileHD");

    
    setroute.pushRoute(root_1,"GET","api/danhsach-chamdiem-huongdan", "qldean/TeacherController@danhsach-chamdiem-huongdan");
    setroute.pushRoute(root_1,"GET","api/loadChamdiemhuongdan", "qldean/TeacherController@loadChamdiemhuongdan");
    setroute.pushRoute(root_1,"GET","api/chamDiemHuongdan", "qldean/TeacherController@chamDiemHuongdan");

    setroute.pushRoute(root_1,"GET","api/danhsach-chamdiem-phanbien", "qldean/TeacherController@danhsach-chamdiem-phanbien");
    setroute.pushRoute(root_1,"GET","api/loadChamdiemphanbien", "qldean/TeacherController@loadChamdiemphanbien");
    setroute.pushRoute(root_1,"GET","api/chamDiemPhanbien", "qldean/TeacherController@chamDiemPhanbien");
    
    setroute.pushRoute(root_1,"GET","api/danhsachtieubanphancong", "qldean/TeacherController@danhsachtieubanphancong");
    setroute.pushRoute(root_1,"GET","api/danhsach-chamdiem-tieuban", "qldean/TeacherController@danhsach-chamdiem-tieuban");
    setroute.pushRoute(root_1,"GET","api/loadChamdiemtieuban", "qldean/TeacherController@loadChamdiemtieuban");
    setroute.pushRoute(root_1,"GET","api/chamDiemTieuban", "qldean/TeacherController@chamDiemTieuban");

    setroute.pushRoute(root_1,"GET","api/doan-sinhvien", "qldean/StudentController@doan-sinhvien");
    setroute.pushRoute(root_1,"GET","api/nopbaocao-sinhvien", "qldean/StudentController@nopbaocao-sinhvien");
    setroute.pushRoute(root_1,"GET","api/danhsach-tieuban-sinhvien", "qldean/StudentController@danhsach-tieuban-sinhvien");

    setroute.pushRoute(root_1,"GET","api/loadChartMot", "qldean/AdminThongkeController@loadChartMot");
    setroute.pushRoute(root_1,"GET","api/loadBieudoToankhoa", "qldean/AdminThongkeController@loadBieudoToankhoa");
    setroute.pushRoute(root_1,"GET","api/loadBieudoThongke5nam", "qldean/AdminThongkeController@loadBieudoThongke5nam");
    setroute.pushRoute(root_1,"GET","api/loadBieudoPhodiem", "qldean/AdminThongkeController@loadBieudoPhodiem");

    setroute.pushRoute(root_1,"GET","api/info_user", "qldean/TaikhoanController@info_user");
    setroute.pushRoute(root_1,"GET","api/sua_admin_teacher", "qldean/TaikhoanController@sua_admin_teacher");
    setroute.pushRoute(root_1,"GET","api/doi_matkhau", "qldean/TaikhoanController@doi_matkhau");
    setroute.pushRoute(root_1,"GET","api/sua_sv", "qldean/TaikhoanController@sua_sv");

    
    return setroute.getRoute();
}