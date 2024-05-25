terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  credentials = "armageddon-sandbox-8221597e6835.json"
  project     = "armageddon-sandbox"
  region      = "us-east4"
}

resource "google_storage_bucket" "hangman_game" {
  name          = "hangman_game_keisha_lied"
  location      = "us-east4"
  force_destroy = true

  website {
    main_page_suffix = "hangman-keisha-lied.html"
  }
  uniform_bucket_level_access = false
}


# Setting the bucket ACL to public read
resource "google_storage_bucket_acl" "bucket_acl" {
  bucket         = google_storage_bucket.hangman_game.name
  predefined_acl = "publicRead"
}

# Uploading and setting public read access for HTML files
resource "google_storage_bucket_object" "upload_html" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = google_storage_bucket.hangman_game.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "text/html"
}

# Public ACL for each HTML file
resource "google_storage_object_acl" "html_acl" {
  for_each       = google_storage_bucket_object.upload_html
  bucket         = google_storage_bucket_object.upload_html[each.key].bucket
  object         = google_storage_bucket_object.upload_html[each.key].name
  predefined_acl = "publicRead"
}

# Output showing the Public Link
output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.hangman_game.name}/${google_storage_bucket.hangman_game.website[0].main_page_suffix}"
}
