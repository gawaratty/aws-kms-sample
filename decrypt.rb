
require "aws-sdk-core"
require "./zipper.rb"
require "./cipher.rb"
require 'base64'
require "pp"


# 暗号化済みファイルのパス
encrypted_file = "./sample.zip.enc"
# 復号化済みファイルのパス
decrypted_file = "./sample.zip.dec"
# 最終的にUnzip＆復号化されるファイルの出力先
unzip_destination_path = "./ext"

# 出力先のフォルダがある場合に、消しておく
FileUtils.rmdir unzip_destination_path


# ======================
# KMSから暗号キー（データキー）を取得
# ======================
# 暗号化済みデータキーをファイルから取得
base64_encrypted_data_key_file = "./datakey.enc"
File.open(base64_encrypted_data_key_file, "r") {|file| @base64_encrypted_data_key = file.read }
# 暗号化済みデータキーファイルを削除
File.delete base64_encrypted_data_key_file
# base64複合
encrypted_data_key = Base64.decode64(@base64_encrypted_data_key)
# KMSからデータキーを取得
kms = Aws::KMS::Client.new(
	ssl_verify_peer: false, 
	region: 'ap-northeast-1'
	)
resp = kms.decrypt(
	ciphertext_blob: encrypted_data_key
	)
# データキーを格納
data_key = resp['plaintext']

# ======================
# ZIPファイルのAES復号化
# ======================
# IVキーをファイルから取得
iv_file = "./iv.dat"
File.open(iv_file, "r") {|file| @iv = file.read }
# IVファイルを削除
File.delete iv_file
# 復号化インスタンスにデータキーとIVキーを渡す
cipher = Cipher.new data_key, @iv
# 復号化実行
cipher.decrypt(encrypted_file, decrypted_file)
# 暗号化済みファイルを削除
File.delete encrypted_file

# ======================
# ZIPの解凍
# ======================
zf = ZipFileGenerator.new
zf.unzip(decrypted_file, unzip_destination_path)
# 復号化済みファイルを削除
File.delete decrypted_file













