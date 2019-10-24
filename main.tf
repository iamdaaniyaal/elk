provider "google" {
  credentials = "${file("${var.credentials}")}"
  project     = "${var.gcp_project}"
  region      = "${var.region}"
}


resource "google_compute_address" "elkip" {
  name   = "${var.elk_instance_ip_name}"
  region = "${var.elk_instance_ip_region}"
}

resource "google_compute_instance" "elk" {
  name         = "${var.elk_instance_name}"
  machine_type = "${var.elk_instance_machine_type}"
  zone         = "${var.elk_instance_zone}"

  tags = ["http-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20190816"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    # network = "default"
    network    = "${var.elk_instance_vpc_name}"
    subnetwork = "${var.elk_instance_subnet_name}"


    access_config {
      // Ephemeral IP
      
      nat_ip       = "${google_compute_address.elkip.address}"
      network_tier = "PREMIUM"
    }
  }

  #metadata = {
  # foo = "bar"
  #}

  metadata_startup_script = "sudo apt-get update; sudo apt-get install git -y; sudo echo 'export ip='$(hostname -i)'' >> ~/.profile; source ~/.profile; echo \"export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\" >>/etc/profile; echo \"export PATH=$PATH:$HOME/bin:$JAVA_HOME/bin\" >>/etc/profile; source /etc/profile; mkdir chandu; cd chandu; sudo apt-get install wget -y; git clone https://github.com/iamdaaniyaal/elk.git; cd elk; sudo chmod 777 elk.sh; sh elk.sh"



}
