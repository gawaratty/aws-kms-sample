
require "aws-sdk-core"
require "./zipper.rb"
require "./cipher.rb"
require 'base64'
require "pp"

# キーID
kms_key_id = "alias/kms-sample"
# ZIP化＆暗号化対象のファイルが含まれるフォルダ
raw_folder = "./sample"

# ======================
# KMSで暗号キー（データキー）を生成
# ======================
kms = Aws::KMS::Client.new(
	ssl_verify_peer: false, 
	region: 'ap-northeast-1'
	)
resp = kms.generate_data_key(
  key_id: kms_key_id,
  number_of_bytes: 256
)
#生データキーを格納
data_key = resp['plaintext']
#暗号化済みデータキーを格納
encrypted_data_key = resp['ciphertext_blob']
#暗号化済みデータキーをbase64変換してファイル出力
base64_encrypted_data_key = Base64.encode64(encrypted_data_key)
File.open("./datakey.enc", "w") {|file| file.write base64_encrypted_data_key }
pp "DataKey(Base64Encoded): " + base64_encrypted_data_key

# ======================
# フォルダのZIP圧縮
# ======================
zf = ZipFileGenerator.new
# ZIPファイル名
zipped_file = "./sample.zip"
# ZIP化
zf.zip(raw_folder, zipped_file)

# ======================
# ZIPファイルのAES暗号化
# ======================
cipher1 = Cipher.new data_key
# 暗号化ファイルの出力パス指定
encrypted_file = "./sample.zip.enc"
# ZIPファイルをAES暗号化
iv = cipher1.encrypt(zipped_file, encrypted_file) # IVキーを戻す
# IVをファイルとして保存
File.open("./iv.dat", "w") {|file| file.write iv }
# ZIPファイルを削除
File.delete zipped_file









