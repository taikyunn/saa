# ハンズオン10の環境を作成するためのコード
# こちらのアカウントにスイッチするとEC2インスタンスがt2.micro以外作成できないようになる
resource "aws_organizations_account" "account" {
  name  = "taichi_test_dev"
  email = "test123345678@example.com"
  tags = {
    Name = "taichi_test_dev"
  }
  parent_id = aws_organizations_organizational_unit.this.id
  role_name = "OrganizationAccountAccessRole"
}

resource "aws_organizations_organizational_unit" "this" {
  name = "taichi_test_ou"
  # 面倒なので一旦ハードコード
  parent_id = "r-qhv3"
  tags = {
    "Name" = "taichi_test_ou"
  }
}

resource "aws_organizations_policy" "this" {
  name = "ec2_for_dev"
  content = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = "DenyNonMicroInstanceType"
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringNotEquals"
      variable = "ec2:InstanceType"
      values   = ["t2.micro"]
    }
  }
}

resource "aws_organizations_policy_attachment" "unit" {
  policy_id = aws_organizations_policy.this.id
  target_id = aws_organizations_organizational_unit.this.id
}
