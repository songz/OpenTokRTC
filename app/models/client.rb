class Client < ActiveRecord::Base
  attr_accessible :flag, :imgdata, :point, :room_id, :name
  belongs_to :room
  before_save :uploadImage

  def uploadImage
    img = MiniMagick::Image.read(Base64.decode64(self.imgdata))
    img.resize "100x100"
    img.format "png"

    filePath = "/clientImages/#{Time.now.to_f.to_s}.png"
    AWS::S3::S3Object.store( filePath, img.to_blob , S3Bucket, :access => :public_read )
    self.imgdata = S3URL+filePath
  end
end
