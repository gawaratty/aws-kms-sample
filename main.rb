
require "aws-sdk-core"
require "./zipper.rb"
require "./cipher.rb"
require 'base64'
require "pp"


kms_key_id = "alias/kms-sample"
raw_folder = "./sample"
zipped_file = "./sample.zip"
encrypted_file = "./sample.zip.enc"
iv_file = "./iv.dat"
decrypted_file = "./sample.zip.dec"
final_folder = "./ext"

FileUtils.rmdir final_folder


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
data_key = resp['plaintext']
encrypted_data_key = resp['ciphertext_blob']
base64_encrypted_data_key = Base64.encode64(encrypted_data_key)
pp "DataKey(Base64Encoded): " + base64_encrypted_data_key

# ======================
# フォルダのZIP圧縮
# ======================
zf = ZipFileGenerator.new
zf.zip(raw_folder, zipped_file)

# ======================
# ZIPファイルのAES暗号化
# ======================
cipher1 = Cipher.new data_key
iv = cipher1.encrypt(zipped_file, encrypted_file)
File.delete zipped_file
# IVをファイルとして保存
File.open(iv_file, "w") do |file|
  file.write iv
end

# データキーを削除
data_key = ""

# ======================
# KMSから暗号キー（データキー）を取得
# ======================
encrypted_data_key = Base64.decode64(base64_encrypted_data_key)
resp = kms.decrypt(ciphertext_blob: encrypted_data_key)
data_key = resp['plaintext']

# ======================
# ZIPファイルのAES復号化
# ======================
# IVを読み込み
File.open(iv_file, "r") do |file|
  iv = file.read
end
File.delete iv_file
cipher2 = Cipher.new data_key, iv
cipher2.decrypt(encrypted_file, decrypted_file)
File.delete encrypted_file

# ======================
# ZIPの解凍
# ======================
zf = ZipFileGenerator.new
zf.unzip(decrypted_file, final_folder)
File.delete decrypted_file













