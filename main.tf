module "vpc" {
    source = "./module"
    network_name = "testyubs"
    create_s3 = true
    names = ["hbscjhbsc-5651","tegstdgsd-55651"]

}

module "vpc2" {
    source = "./module"
    network_name = "testyubs2"
    create_s3 = false
    names = ["bxshjcbs-261"]

}