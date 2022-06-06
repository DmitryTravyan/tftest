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

data "yandex_iam_service" "srv_account" {
    name = var.service_account
}

//data "yandex_iam_policy" "srv_iam_policy" {
//    binding {
//        role = "editor"
//
//        members = [
//            "serviceAccount:${data.yandex_iam_service_account.srv_account.id}",
//        ]
//    }
//}
