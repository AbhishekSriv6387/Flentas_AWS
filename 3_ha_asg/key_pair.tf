
# Key Pair for ASG Instances
resource "aws_key_pair" "asg" {
  key_name   = "${var.first_name_last_name}-asg-key"
  public_key = file("${path.module}/../1_vpc/id_rsa.pub")
}
