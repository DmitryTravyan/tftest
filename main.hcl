terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

data "yandex_iam_service_account" "srv_account" {
    name = var.service_account
}

data "yandex_iam_policy" "srv_iam_policy" {
    binding {
        role = "editor"

        members = [
            "serviceAccount:${data.yandex_iam_service_account.srv_account.id}",
        ]
    }
}

resource "yandex_iam_service_account_iam_policy" "srv_account_policy" {
    service_account_id = data.yandex_iam_service_account.srv_account.id
    policy_data        = "${data.yandex_iam_policy.srv_iam_policy.policy_data}"
}

resource "yandex_vpc_network" "internal_lqvuc" {
    name = "internal_lqvuc"
    depends_on =  [yandex_iam_service_account_iam_policy.srv_account_policy, ]
}

resource "yandex_vpc_subnet" "internal_a_lqvuc" {
    name           = "internal_a_lqvuc"
    zone           = var.zone
    network_id     = yandex_vpc_network.internal_lqvuc.id
    v4_cidr_blocks = ["172.16.25.0/24"]

    depends_on =  [yandex_iam_service_account_iam_policy.srv_account_policy, ]
}

data "yandex_compute_image" "ubuntu_image" {
    family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance_group" "workers-1amosu" {
    name               = "workers-1amosu"
    service_account_id = data.yandex_iam_service_account.srv_account.id
    instance_template {
      platform_id = "standard-v2"
      resources {
        memory = 8
        cores  = 4
      }
      boot_disk {
        mode = "READ_WRITE"
        initialize_params {
          image_id = data.yandex_compute_image.ubuntu_image.id
          size     = 50
          type     = "network-ssd"
        }
      }
      network_interface {
        network_id = "${yandex_vpc_network.internal_lqvuc.id}"
        subnet_ids = ["${yandex_vpc_subnet.internal_a_lqvuc.id}"]
        nat        = true
      }
      metadata = { 
        ssh-keys = "ubuntu:${file("id_rsa.pub")}"
    }
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  allocation_policy {
    zones = [var.zone]
  }
  deploy_policy {
    max_unavailable = 1
    max_creating    = 3
    max_expansion   = 1
    max_deleting    = 3
  }
    depends_on =  [yandex_iam_service_account_iam_policy.srv_account_policy, ]
}

resource "yandex_compute_instance" "masterkgzdx" {
    name        = "masterkgzdx"
    zone        = var.zone
    hostname    = "masterkgzdx"
    platform_id = "standard-v2"
    service_account_id = data.yandex_iam_service_account.srv_account.id
    resources {
      memory = 4
      cores  = 2
    }
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu_image.id
            size     = 15
            type     = "network-ssd"
        }
    }
    network_interface {
        subnet_id = yandex_vpc_subnet.internal_a_lqvuc.id
        nat       = true
    }
    metadata = { 
        ssh-keys = "ubuntu:${file("id_rsa.pub")}"
    }
    depends_on =  [yandex_iam_service_account_iam_policy.srv_account_policy, ]
}
