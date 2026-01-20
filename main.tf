module "vpc" {
    source = "./module"
    network_name = "new-tesewd"
    create_s3 = true
    names = ["new-hbscjhbsc-545651"]

}

module "vpc2" {
    source = "./module"
    network_name = "new-testyubwes2"
    create_s3 = false
    names = ["new-bxshjcbs-278961"]

}