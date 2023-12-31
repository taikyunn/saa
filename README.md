## SAA学習用のリソースを作成したリポジトリ

## ハマったエラー集
https://dev.classmethod.jp/articles/delete-aws-account-with-terraform/
- 組織から離れる・削除するにはクレジットカードの情報を記入する必要がある

## default vpc
- ec2インスタンスの作成でvpc周りを何も設定しないと、default vpcが自動的に作成される
- またdefault vpcを誤って削除した場合も、後から作成することも可能
- https://dev.classmethod.jp/articles/create-new-default-vpc/

## 特定のmoduleのみdestroyする
```
terraform destroy -target=module.[モジュール名]
```
